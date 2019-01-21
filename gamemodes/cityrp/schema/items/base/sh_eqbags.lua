local INVENTORY_TYPE_ID = "grid"

ITEM.name = "Bag"
ITEM.desc = "A bag to hold more items."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Storage"
ITEM.isBag = true

ITEM.outfitCategory = "bags"
ITEM.pacData = {}
ITEM.width = 1
ITEM.height = 1

-- The size of the inventory held by this item.
ITEM.invWidth = 2
ITEM.invHeight = 2

ITEM.functions.View = {
	icon = "icon16/briefcase.png",
	onClick = function(item)
		local inventory = item:getInv()
		if (not inventory) then return false end

		local panel = nut.gui["inv"..inventory:getID()]
		local parent = item.invID and nut.gui["inv"..item.invID] or nil

		if (IsValid(panel)) then
			panel:Remove()
		end

		if (inventory) then
			local panel = nut.inventory.show(inventory, parent)
			if (IsValid(panel)) then
				panel:ShowCloseButton(true)
				panel:SetTitle(item:getName())
			end
		else
			local itemID = item:getID()
			local index = item:getData("id", "nil")
			ErrorNoHalt(
				"Invalid inventory "..index.." for bag item "..itemID.."\n"
			)
		end
		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity) and item:getInv() and item:getData("equip") == true
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

function ITEM:onInstanced()
	local data = {
		item = self:getID(),
		w = self.invWidth,
		h = self.invHeight
	}
	nut.inventory.instance(INVENTORY_TYPE_ID, data)
		:next(function(inventory)
			self:setData("id", inventory:getID())
			hook.Run("SetupBagInventoryAccessRules", inventory)
			inventory:sync()
			self:resolveInvAwaiters(inventory)
		end)
end

function ITEM:onRestored()
	local invID = self:getData("id")
	if (invID) then
		nut.inventory.loadByID(invID)
			:next(function(inventory)
				hook.Run("SetupBagInventoryAccessRules", inventory)
				self:resolveInvAwaiters(inventory)
			end)
	end
end

function ITEM:onRemoved()
	local invID = self:getData("id")
	if (invID) then
		nut.inventory.deleteByID(invID)
	end
end

function ITEM:getInv()
	return nut.inventory.instances[self:getData("id")]
end

function ITEM:onSync(recipient)
	local inventory = self:getInv()
	if (inventory) then
		inventory:sync(recipient)
	end
end

function ITEM.postHooks:drop()
	local invID = self:getData("id")
	if (invID) then
		net.Start("nutInventoryDelete")
			net.WriteType(invID)
		net.Send(self.player)
	end
end

function ITEM:onCombine(other)
	local client = self.player
	local invID = self:getInv() and self:getInv():getID() or nil
	if (not invID) then return end

	-- If other item was combined onto this item, put it in the bag.
	local res = hook.Run(
		"HandleItemTransferRequest",
		client,
		other:getID(),
		nil,
		nil,
		invID
	)
	if (not res) then return end

	-- If an attempt was made, either report the error or make a
	-- "success" sound.
	res:next(function(res)
		if (not IsValid(client)) then return end
		if (istable(res) and type(res.error) == "string") then
			return client:notifyLocalized(res.error)
		end
		client:EmitSound(
			"physics/cardboard/cardboard_box_impact_soft2.wav",
			50
		)
	end)
end

if (SERVER) then
	function ITEM:onDisposed()
		local inventory = self:getInv()
		if (inventory) then
			inventory:destroy()
		end
	end

	function ITEM:resolveInvAwaiters(inventory)
		if (self.awaitingInv) then
			for _, d in ipairs(self.awaitingInv) do
				d:resolve(inventory)
			end
			self.awaitingInv = nil
		end
	end

	function ITEM:awaitInv()
		local d = deferred.new()
		local inventory = self:getInv()

		if (inventory) then
			d:resolve(inventory)
		else
			self.awaitingInv = self.awaitingInv or {}
			self.awaitingInv[#self.awaitingInv + 1] = d
		end

		return d
	end
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

ITEM.postHooks.drop = function(item, result)
	-- to be sure.
	if (SERVER) then
		if (item:getData("equip")) then
			item:removePart(item.player)
		end
	end
end
