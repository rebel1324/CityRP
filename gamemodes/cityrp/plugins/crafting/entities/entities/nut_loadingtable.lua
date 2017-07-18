AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Crafting Table"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript"
ENT.invType = "crafttable"
nut.item.registerInv(ENT.invType, 5, 4)

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/rebel1324/reload_table.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:setNetVar("active", false)
		self:SetUseType(SIMPLE_USE)
		self.loopsound = CreateSound(self, "plats/elevator_move_loop1.wav")
		self.receivers = {}
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		nut.item.newInv(0, self.invType, function(inventory)
			self:setInventory(inventory)
			inventory.noBags = true

			function inventory:onCanTransfer(client, oldX, oldY, x, y, newInvID)
				return hook.Run("StorageCanTransfer", inventory, client, oldX, oldY, x, y, newInvID)
			end
		end)
	end

	function ENT:activate(client)
		if (client:canCraft()) then
			local blueprint, weapon
			local blurprintNum, weaponNum = 0, 0
			local inv = self:getInv()
			local craftableItems = inv:getItems()

			for k, v in pairs(craftableItems) do
				if (v.isBlueprint) then
					blueprint = v
					blurprintNum = blurprintNum + 1
				end

				if (v.isWeapon) then
					weapon = v
					weaponNum = weaponNum + 1
				end
			end
			-- this part is for generic crafting
			if (blueprint) then
				if (blurprintNum == 1) then
					local itemsToRemove = {}
					for _, req in ipairs(blueprint.requirements) do
						local item = inv:getItemCount(req[1])
						
						if (item < req[2]) then
							client:notifyLocalized("craftMoreIngredients")
							return false
						else
							table.insert(itemsToRemove, {req[1], req[2]})
						end
					end

					for _, q in ipairs(itemsToRemove) do
						for i=1, q[2] do
							inv:hasItem(q[1]):remove()
						end
					end

					local notified = false
					for _, add in ipairs(blueprint.result) do
						for i=1, add[2] do
							local succ, res = client:getChar():getInv():add(add[1])

							if (!succ) then
								if (res == "noSpace") then
									if (notified) then
										client:notifyLocalized("craftNoSpace")

										notified = true
									end

									nut.item.spawn(add[1], self:GetPos() + self:GetUp() * 15)
								else
									client:notifyLocalized("illegalAccess")
								end
							end
						end
					end

					return true
				else
					if (blurprintNum > 1) then
						client:notifyLocalized("craftOnlyOneBluprint")
					end

					return false
				end
			elseif (weapon) then
				if (weaponNum == 1) then
					local attachments = weapon:getData("mod") or {}
					local weaponTable = weapons.GetStored(weapon.class)

					if (weaponTable) then
						local availableAttachments = {}
						local attachTable = {}
						local itemsToRemove = {}

						-- remove attachments
						for k, v in pairs(attachments) do
							inv:add(v)
						end

						-- attach attachments
						-- get available attachments
						for k, v in pairs(craftableItems) do
							if (v.isAttachment) then
								availableAttachments[v.uniqueID] = v
							end
						end
						-- set target attachments
						for atcat, data in ipairs(weaponTable.Attachments) do
							for k, name in pairs(data.atts) do
								local atItem = availableAttachments[name]

								if (atItem and !attachTable[atcat]) then
									attachTable[atcat] = name

									table.insert(itemsToRemove, atItem)
								end
							end
						end

						-- remove attached items.
						for k, v in pairs(itemsToRemove) do
							v:remove()
						end
						-- yeah .. attachSpecificAttachment(attachmentName)

						-- save attachment data on the item.
						if (table.Count(attachTable) <= 0) then
							attachTable = nil
						end

						weapon:setData("mod", attachTable)
					else
						client:notifyLocalized("invalid", "weapon information")
					end
				else
					if (weaponNum > 1) then
						client:notifyLocalized("craftOnlyOneWeapon")
					end
				end
			else
				client:notifyLocalized("nothingCraftable")
			end
		end
	end

	function ENT:setInventory(inventory)
		if (inventory) then
			self:setNetVar("id", inventory:getID())

			inventory.onAuthorizeTransfer = function(inventory, client, oldInventory, item)
				if (IsValid(client) and IsValid(self) and self.receivers[client]) then
					return true
				end
			end

			inventory.getReceiver = function(inventory)
				local receivers = {}

				for k, v in pairs(self.receivers) do
					if (IsValid(k)) then
						receivers[#receivers + 1] = k
					end
				end

				return #receivers > 0 and receivers or nil
			end
		end
	end
	
	function ENT:Use(activator)
		local inventory = self:getInv()

		if (inventory and (activator.nutNextOpen or 0) < CurTime()) then
			if (activator:getChar()) then
				activator:setAction("Opening...", 1, function()
					if (activator:GetPos():Distance(self:GetPos()) <= 100) then
						self.receivers[activator] = true
						activator.nutBagEntity = self
						
						inventory:sync(activator)
						netstream.Start(activator, "craftingTableOpen", self, inventory:getID())
					end
				end)
			end

			activator.nutNextOpen = CurTime() + 1.5
		end
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
		
		local index = self:getNetVar("id")

		if (!nut.shuttingDown and !self.nutIsSafe and index) then
			local item = nut.item.inventories[index]

			if (item) then
				nut.item.inventories[index] = nil

				nut.db.query("DELETE FROM nut_items WHERE _invID = "..index)
				nut.db.query("DELETE FROM nut_inventories WHERE _invID = "..index)

				hook.Run("StorageItemRemoved", self, item)
			end
		end
	end

	function ENT:getInv()
		return nut.item.inventories[self:getNetVar("id", 0)]
	end

	function ENT:Think()
		if (self:getNetVar("gone")) then
			return
		end
	end

	netstream.Hook("doCraft", function(client, entity, seconds)
		local distance = client:GetPos():Distance(entity:GetPos())
		
		if (entity:IsValid() and client:IsValid() and client:getChar() and
			distance < 128) then
			entity:activate(client)
		end
	end)
else
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*16):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"loadingTableName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"loadingTableDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end
