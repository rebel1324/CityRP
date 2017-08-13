local PLUGIN = PLUGIN
PLUGIN.name = "Perma Stash"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "You save your stuffs in the stash."
PLUGIN.stashData = PLUGIN.stashData or {}

nut.config.add("maxStash", 20, "Maximum storage of Permanant Stash.", nil, {
	data = {min = 1, max = 40},
	category = "stash"
})

local function savestash(char)
	local stash = char:getStash()

	nut.db.updateTable({
		_items = char:getStash()
	}, nil, "stash", "_charID = "..char:getID())
end

do
	if (SERVER) then
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

		function PLUGIN:OnLoadTables()
			if (nut.db.module) then
				nut.db.query(MYSQL_CREATE_TABLES)
			else
				nut.db.query(SQLITE_CREATE_TABLES)
			end
		end

		function PLUGIN:CharacterPreSave(char)
			savestash(char)
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
	end
end

local meta = nut.meta.character

function meta:getStash()
	return self:getVar("stash", {})
end

function meta:getStashCount()
	return table.Count(self:getStash())
end

function meta:getStashMax()
	return nut.config.get("maxStash", 10)
end

if (SERVER) then
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
	
	function meta:setStash(tbl)
		self:setVar("stash", tbl, nil, self:getPlayer())
		savestash(self)
	end

	function requestStash(client)
		local char = client:getChar()
		local stashItems = char:getStash()
		local queryTable = {}
		local nearStash = false

		-- Check if the client is near the stash.
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:GetClass() == "nut_stash") then
				nearStash = true
				break
			end
		end

		if (nearStash == false) then
			client:notify(L("stashFar", client))
			return
		end

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
				requestStash(client)
			end)

			return
		end
		-- Send stash menu to the client.
		netstream.Start(client, "stashMenu", stashItems)
	end

	netstream.Hook("stashIn", function(client, itemID)
		local char = client:getChar()
		local item = nut.item.instances[itemID]
		local nearStash = false

		-- Check if the client is near the stash.
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:GetClass() == "nut_stash") then
				nearStash = true
				break
			end
		end

		-- If client is far away from the stash, don't do any interaction.
		if (nearStash == false) then
			client:notify(L("stashFar", client))
			return
		end

		if (char:getStashMax() == char:getStashCount()) then
			client:notify(L("stashFull", client))
			return
		end

		-- If item information is valid.
		if (item) then
			local clientStash = char:getStash()

			-- If client is trying to put bag in the stash, reject the request.
			if (item.base == "base_bags" or clientStash[itemID] or item:getOwner() != client) then
				client:notify(L("stashError", client))
				return
			end

			-- Make an attempt to put item into the stash.
			if (item:transfer(nil, nil, nil, client, nil, true)) then
				clientStash[itemID] = true

				char:setStash(clientStash)
				netstream.Start(client, "stashIn")
			else
				client:notify(L("stashError", client))
			end
		end
	end)

	netstream.Hook("stashOut", function(client, itemID)
		local char = client:getChar()
		local item = nut.item.instances[itemID]
		local nearStash = false

		-- Check if the client is near the stash.
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:GetClass() == "nut_stash") then
				nearStash = true
				break
			end
		end

		-- If client is far away from the stash, don't do any interaction.
		if (nearStash == false) then
			client:notify(L("stashFar", client))
			return
		end

		-- If item information is valid.
		if (item) then
			local clientStash = char:getStash()

			-- If the activator does not owns the item, reject request.
			if (!clientStash[itemID]) then
				client:notify(L("stashError", client))
				return
			end

			-- Make an attempt to take item from the stash.
			if (item:transfer(char:getInv():getID(), nil, nil, client)) then
				clientStash[itemID] = nil

				char:setStash(clientStash)
				netstream.Start(client, "stashOut")
			else
				client:notify(L("stashError", client))
			end
		end
	end)
else
	-- I'm so fucking lazy
	-- Stash vgui needs more better sync.
	netstream.Hook("stashIn", function(id)
		if (nut.gui.stash and nut.gui.stash:IsVisible()) then
			nut.gui.stash:setStash()
			surface.PlaySound("items/ammocrate_open.wav")
		end
	end)

	netstream.Hook("stashOut", function(id)
		if (nut.gui.stash and nut.gui.stash:IsVisible()) then
			nut.gui.stash:setStash()
			surface.PlaySound("items/ammocrate_open.wav")
		end
	end)

	netstream.Hook("stashMenu", function(items)
		local stash = vgui.Create("nutStash")
		stash:setStash(items)
	end)
end