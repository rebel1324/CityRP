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
			local inv = char:getInv()

			if (inv) then
				local craftData = nut.craft.get(id)

				if (craftData) then
					local reqA = craftData.requiredAttribute

					if (reqA) then
						for id, req in pairs(reqA) do
							local at = char:getAttrib(id, 0)

							if (at < req) then
								return false, "lowAttribute"
							end
						end
					end

					local reqB = craftData.requiredItem
					local items2remove = {}

					if (reqB) then
						local itemList = inv:getItemsByClass()
						
						for class, requirements in pairs(reqB) do
							local reqLeft = requirements
							local items = itemList[class]
							
							if (items) then
								for _, itemObject in pairs(items) do
									local itemQuantity = itemObject:getQuantity()

									if (reqLeft < 0) then
										break
									end

									if ((reqLeft - itemQuantity) < 0) then
										table.insert(items2remove, {
											item = itemObject,
											remove = false,
											quantity = reqLeft
										})

										reqLeft = 0
										break
									else
										reqLeft = reqLeft - itemQuantity

										table.insert(items2remove, {
											item = itemObject,
											remove = true,
										})
									end
								end
							end
							
							if (reqLeft > 0) then
								return false, "lowitems"
							end
						end
					end

					local bool, reason = hook.Run("CanPlayerCraftItem", client, craftData, id)

					if (bool == false) then
						return false, reason
					end

					return items2remove
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
	local affectedItems, error = nut.craft.canMake(client, id)
	
	if (not affectedItems) then
		return bool, error
	else
		local char = client:getChar()
		local inv = char:getInv()
		local craftData = nut.craft.get(id)

		for _, itemData in pairs(affectedItems) do
			if (itemData.remove) then
				itemData.item:remove()
			else
				if (itemData.quantity) then
					itemData.item:setQuantity(itemData.item:getQuantity() - itemData.quantity)
				end
			end
		end

		local reqC = craftData.resultItem

		for itemClass, quantity in pairs(reqC) do
			inv:add(itemClass, quantity)
		end
	
		return true
	end
end