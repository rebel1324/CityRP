local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "How about getting new foods in NutScript?"

nut.craft = nut.craft or {}

nut.util.include("sh_ingredients.lua")
nut.util.include("sh_craftings.lua")
nut.util.include("cl_vgui.lua")

function nut.craft.canMake(client, id)
	local char = client:getChar()

	if (id) then
		if (char) then
			local char = client:getChar()
			local inventory = char:getInv()

			if (inventory) then
				local craftData = nut.craft.get(id)

				if (craftData) then
					local attributeRequirement = craftData.requiredAttribute

					if (attributeRequirement) then
						for id, req in pairs(attributeRequirement) do
							local at = char:getAttrib(id, 0)

							if (at < req) then
								return false, "lowAttribute"
							end
						end
					end

					local itemRequirement = craftData.requiredItem

					if (itemRequirement) then
						local pass = true
						for itemType, quantity in pairs(itemRequirement) do
							local currentItemQuantity = inventory:getItemCount(itemType)

							if (currentItemQuantity < quantity) then
								pass = false
								break
							end
						end

						if (pass == false) then
							return false, "reqItems"
						end
					end

					local bool, reason = hook.Run("CanPlayerCraftItem", client, craftData, id)

					if (bool == false) then
						return false, reason
					end

					return true
				else
					return false, "invalidCraft"
				end
			else
				return false, "noInv"
			end
		else
			return false, "noChar"
		end
	else
		return false, "invalidID"
	end

	return false, "unknown"
end

function nut.craft.make(client, id)
	local d = deferred.new()
	local affectedItems, reason = nut.craft.canMake(client, id)
	
	if (affectedItems == false) then
		return d:reject(reason)
	else
		local craftData = nut.craft.get(id)
		
		if (craftData) then
			local char = client:getChar()
			local inventory = char:getInv()

			if (inventory) then
				local remainingItems = table.Copy(craftData.requiredItem) -- now it's a counter.
				local items = inventory:getItems()
				
				local actions = {}
				
				for id, item in pairs(items) do
					local remainingItem = remainingItems[item.uniqueID]

					if (remainingItem) then
						local q = item:getQuantity()
						if (q <= remainingItem) then
							remainingItems[item.uniqueID] = remainingItems[item.uniqueID] - q
							actions[item] = -1
						else
							remainingItems[item.uniqueID] = 0
							actions[item] = q - remainingItem
						end
					end
				end

				local promises = {}
				for item, quantity in pairs(actions) do
					if (quantity <= 0) then
						table.insert(promises, item:remove())
					else
						table.insert(promises, function()
							local d = deferred.new()
								item:setQuantity(quantity)
							return d
						end)
					end
				end

				deferred.all(promises):next(function()
					local reqC = craftData.resultItem

					for itemClass, quantity in pairs(reqC) do
						if (quantity == true) then
							inventory:add(itemClass):next(function(craftedItem)
								d:resolve(craftedItem)
							end, function(err)
								d:reject(error)
							end) -- whole shits.
						else
							inventory:add(itemClass, quantity):next(function(craftedItem)
								d:resolve(craftedItem)
							end, function(err)
								d:reject(error)
							end)
						end
					end
				end, function(error)
					d:reject(error)
				end)
			end
		else
			return d:reject(reason)
		end
	end

	return d
end

if (SERVER) then
	netstream.Hook("nutCraftItem", function(client, id)
		nut.craft.make(client, id):next(function(item)
			if (IsValid(client) and IsValid(item)) then
				client:notifyLocalized("craftedItem", L(item:getName(), client))
				client:EmitSound("ui/good.wav")
			end
		end, function(error)
			client:notifyLocalized(error)
		end)
	end)
end