ITEM.name = "Bag"
ITEM.desc = "A bag to hold items."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Storage"
ITEM.width = 1
ITEM.height = 1
ITEM.invWidth = 4
ITEM.invHeight = 2
ITEM.isBag = true
ITEM.outfitCategory = "bags"
ITEM.pacData = {}

function ITEM:getDesc()
	if (self.entity and IsValid(self.entity)) then
		return L("eqbagDescEntity", self.invWidth or 4, self.invHeight or 2)
	end

	return L("eqbagDesc", self.invWidth or 4, self.invHeight or 2)
end

ITEM.functions.View = {
	icon = "icon16/briefcase.png",
	onClick = function(item)
		local index = item:getData("id")

		if (index) then
			local panel = nut.gui["inv"..index]
			local parent = item.invID and nut.gui["inv"..item.invID] or nil
			local inventory = nut.item.inventories[index]
			
			if (IsValid(panel)) then
				panel:Remove()
			end

			if (inventory and inventory.slots) then
				panel = vgui.Create("nutInventory", parent)
				panel:setInventory(inventory)
				panel:ShowCloseButton(true)
				panel:SetTitle(item.name)

				nut.gui["inv"..index] = panel
			else
				ErrorNoHalt("[NutScript] Attempt to view an uninitialized inventory '"..index.."'\n")
			end
		end

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and item:getData("id") and item:getData("equip") == true
	end
}

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/cross.png",
	onRun = function(item)
		item:removePart(item.player)
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/tick.png",
	onRun = function(item)
		local char = item.player:getChar()
		local items = char:getInv():getItems()

		for k, v in pairs(items) do
			if (v.id != item.id) then
				local itemTable = nut.item.instances[v.id]

				if (itemTable.pacData and v.outfitCategory == item.outfitCategory and itemTable:getData("equip")) then
					item.player:notify("You're already equipping this kind of outfit")

					return false
				end
			end
		end

		item:setData("equip", true)
		item.player:addPart(item.uniqueID, item)

		if (item.attribBoosts) then
			for k, v in pairs(item.attribBoosts) do
				char:addBoost(item.uniqueID, k, v)
			end
		end
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}

-- Called when a new instance of this item has been made.
function ITEM:onInstanced(invID, x, y)
	local inventory = nut.item.inventories[invID]

	nut.item.newInv(inventory and inventory.owner or 0, self.uniqueID, function(inventory)
		inventory.vars.isBag = self.uniqueID
		self:setData("id", inventory:getID())
	end)
end

function ITEM:getInv()
	local index = self:getData("id")

	if (index) then
		return nut.item.inventories[index]
	end
end

-- Called when the item first appears for a client.
function ITEM:onSendData()
	local index = self:getData("id")

	if (index) then
		local inventory = nut.item.inventories[index]

		if (inventory) then
			inventory:sync(self.player)
		else
			local owner = self.player:getChar():getID()

			nut.item.restoreInv(self:getData("id"), self.invWidth, self.invHeight, function(inventory)
				inventory.vars.isBag = self.uniqueID
				inventory:setOwner(owner, true)
			end)
		end
	else
		local inventory = nut.item.inventories[self.invID]
		local client = self.player

		nut.item.newInv(self.player:getChar():getID(), self.uniqueID, function(inventory)
			inventory.vars.isBag = self.uniqueID
			self:setData("id", inventory:getID())
		end)
	end
end

-- Called before the item is permanently deleted.
function ITEM:onRemoved()
	local index = self:getData("id")

	if (index) then
		nut.db.query("DELETE FROM nut_items WHERE _invID = "..index)
		nut.db.query("DELETE FROM nut_inventories WHERE _invID = "..index)
	end
end

-- Called when the item should tell whether or not it can be transfered between inventories.
function ITEM:onCanBeTransfered(oldInventory, newInventory)
	if (newInventory and self:getData("equip")) then
		return false
	end

	local index = self:getData("id")

	if (newInventory) then
		if (newInventory.vars and newInventory.vars.isBag) then
			return false
		end

		local index2 = newInventory:getID()

		if (index == index2) then
			return false
		end

		for k, v in pairs(self:getInv():getItems()) do
			if (v:getData("id") == index2) then
				return false
			end
		end
	end
	
	return !newInventory or newInventory:getID() != oldInventory:getID() or newInventory.vars.isBag
end

-- Called after the item is registered into the item tables.
function ITEM:onRegistered()
	nut.item.registerInv(self.uniqueID, self.invWidth, self.invHeight, true)
end

-- Inventory drawing
if (CLIENT) then
	-- Draw camo if it is available.
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end
	end
end

function ITEM:removePart(client)
	local char = client:getChar()
	
	self:setData("equip", false)
	client:removePart(self.uniqueID)

	if (self.attribBoosts) then
		for k, _ in pairs(self.attribBoosts) do
			char:removeBoost(self.uniqueID, k)
		end
	end
end

ITEM:hook("drop", function(item)
	-- to be sure.
	if (SERVER) then
		if (item:getData("equip")) then
			item:removePart(item.player)
		end

		local index = item:getData("id")

		nut.db.query("UPDATE nut_inventories SET _charID = 0 WHERE _invID = "..index)
	end
end)
