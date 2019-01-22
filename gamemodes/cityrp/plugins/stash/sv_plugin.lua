local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_stash` (
	`_charID` int(11) NOT NULL,
	`_items` text NOT NULL,
	PRIMARY KEY (`_charID`)
);

]]
local SQLITE_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_stash` (
	`_charID` INTEGER PRIMARY KEY,
	`_items` TEXT
);
]]

local function saveStash(char)
	local stash = char:getStash()

	nut.db.updateTable({
		_items = char:getStash()
	}, nil, "stash", "_charID = "..char:getID())
end

function PLUGIN:OnLoadTables()
	if (nut.db.module) then
		nut.db.query(MYSQL_CREATE_TABLES)
	else
		nut.db.query(SQLITE_CREATE_TABLES)
	end
end

function PLUGIN:CharacterPreSave(char)
	saveStash(char)
end
 
function PLUGIN:CharacterLoaded(id)
	-- legacy support
	local char = nut.char.loaded[id]

	nut.db.query("SELECT _items FROM nut_stash WHERE _charID = "..id, function(data)
		if (data and #data > 0) then
			for k, v in ipairs(data) do
				local data = util.JSONToTable(v._items or "[]")

				char:setStash(data)
			end
		else
			nut.db.insertTable({
				_items = {},
				_charID = id,
			}, function(data)
				char:setStash({})
			end, "stash")
		end
	end)
end

function PLUGIN:PreCharDelete(client, char)
	-- get character stash items and eradicate item data from the DATABASE.
	if (char) then
		local stashItems = char:getStash()
		local queryTable = {}
		for k, v in pairs(stashItems) do
			table.insert(queryTable, k)
		end
		
		if (table.Count(queryTable) > 0) then
			-- Check all stash items of the character.
			nut.item.loadItemByID(queryTable, 0, nil)
			for k, v in pairs(stashItems) do
				local item = nut.item.instances[k]

				-- Remove all items in stash.
				if (item) then
					item:remove()
				end
			end
		end
	end
end

function PLUGIN:LoadData()
	local savedTable = self:getData() or {}

	for k, v in ipairs(savedTable) do
		local stash = ents.Create("nut_stash")
		stash:SetPos(v.pos)
		stash:SetAngles(v.ang)
		stash:Spawn()
		stash:Activate()

		local physicsObject = stash:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:EnableMotion()
		end
	end
end
	
function PLUGIN:SaveData()
	local savedTable = {}

	for k, v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "nut_stash") then
			table.insert(savedTable, {pos = v:GetPos(), ang = v:GetAngles()})
		end
	end

	self:setData(savedTable)
end
	
local meta = nut.meta.character
function meta:setStash(tbl)
	self:setVar("stash", tbl, nil, self:getPlayer())
	saveStash(self)
end

local function findStash(client)
	local d = deferred.new()

	for _, entity in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
		if (entity:GetClass() == "nut_stash") then
			return d:resolve(entity)
		end
	end
	
	return d:reject()
end

function PLUGIN:DoStashRequest(client)
	local char = client:getChar()
	local stashItems = char:getStash()
	local queryTable = {}

	findStash(client):next(function()
		-- Insert items to load.
		for k, v in pairs(stashItems) do
			table.insert(queryTable, k)
		end
			
		-- Load item informations.
		if (#queryTable != 0) then
			nut.item.loadItemByID(queryTable, 0, nil)
		end

		-- Check if item's information is loaded, if does not, do not load the item.
		for k, v in pairs(stashItems) do
			local item = nut.item.instances[k]

			if (item) then
				netstream.Start(client, "item", item.uniqueID, k, item.data or {}, 0)
			end
		end

		if (!char.firstInit) then
			char.firstInit = true
			-- why?
			timer.Simple(0.1, function()
				hook.Run("DoStashRequest", client)
			end)

			return
		end
		-- Send stash menu to the client.
		netstream.Start(client, "stashMenu", stashItems)
	end, function(error)
		client:notifyLocalized("stashFar")
	end)
end

if (not STASH_INVENTORY_MEASURE) then
	STASH_INVENTORY_MEASURE = nut.inventory.types["grid"]:new()
	STASH_INVENTORY_MEASURE.data = {w = 8, h = 8}
	STASH_INVENTORY_MEASURE.virtual = true
	STASH_INVENTORY_MEASURE:onInstanced()
end

netstream.Hook("stashIn", function(client, itemID)
	if (IsValid(client)) then
		local char = client:getChar()
		local item = nut.item.instances[itemID]
		local inventory = nut.item.inventories[item.invID]

		if (item and inventory) then
			findStash(client):next(function(stashEntity)
				if (IsValid(stashEntity)) then
					if (char:getStashMax() == char:getStashCount()) then
						client:notifyLocalized("stashFull")
						return
					end

					local clientStash = char:getStash()

					local context = {
						client = client,
						item = item,
						from = inventory,
						to = STASH_INVENTORY_MEASURE
					}
					local canTransfer, reason = STASH_INVENTORY_MEASURE:canAccess("transfer", context)
					if (not canTransfer) then
						client:notifyLocalized(reason or "stashError")

						return
					end

					local canTransferItem, reason = hook.Run("CanItemBeTransfered", item, inventory, STASH_INVENTORY_MEASURE)
					if (canTransferItem == false) then
						client:notifyLocalized(reason or "stashError")
					
						return
					end
					
					-- If client is trying to put bag in the stash, reject the request.
					if (item.isBag) then
						client:notifyLocalized("stashBag")
						return
					end
					if (clientStash[itemID]) then
						client:notifyLocalized("stashError")
						return
					end

					item:removeFromInventory(true):next(function()
						clientStash[itemID] = true

						char:setStash(clientStash)
						netstream.Start(client, "stashIn")
					end, function(error)
						client:notifyLocalized("stashError")
					end)
				end
			end, function(error)
				client:notifyLocalized("stashFar")
			end)
		end
	end
end)

netstream.Hook("stashOut", function(client, itemID)
	if (IsValid(client)) then
		local char = client:getChar()
		local item = nut.item.instances[itemID]
		local inventory = char:getInv()

		if (item and inventory) then
			findStash(client):next(function(stashEntity)
				if (IsValid(stashEntity)) then
					if (char:getStashMax() == char:getStashCount()) then
						client:notifyLocalized("stashFull")
						return
					end

					local clientStash = char:getStash()

					-- If client is trying to put bag in the stash, reject the request.
					if (item.isBag) then
						client:notifyLocalized("stashBag")
						return
					elseif (not clientStash[itemID]) then
						client:notifyLocalized("stashError")
						return
					end
						
					inventory:add(item):next(function()
						clientStash[itemID] = nil

						char:setStash(clientStash)
						netstream.Start(client, "stashOut")
					end, function(error)
						client:notifyLocalized("stashError")
					end)
				end
			end, function(error)
				client:notifyLocalized("stashFar")
			end)
		end
	end
end)