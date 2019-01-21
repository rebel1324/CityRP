SIGNAL_DEATH = 1
SIGNAL_CHAR = 2
SIGNAL_JOB = 3
SIGNAL_INITLOAD = 4

function SCHEMA:RegisterPreparedStatements()
	MsgC(Color(0, 255, 0), "[Nutscript] ADDED CITYRP PREPARED STATEMENTS\n")
	nut.db.prepare("reserveChange", "UPDATE nut_reserve SET _reserve = ? WHERE _charID = ?", {_reserve = MYSQLOO_INTEGER, _charID = MYSQLOO_INTEGER})
end

local function savereserve(char)
	if (MYSQLOO_PREPARED) then
		nut.db.preparedCall("reserveChange", nil, char:getReserve(), char:getID())
	else
		nut.db.updateTable({
			_reserve = char:getReserve()
		}, nil, "reserve", "_charID = "..char:getID())
	end
end

function SCHEMA:OnReserveChanged(char)
	savereserve(char)
end

do
		local MYSQL_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_reserve` (
	`_charID` int(11) NOT NULL,
	`_reserve` int(11) unsigned DEFAULT NULL,
	PRIMARY KEY (`_charID`)
);
CREATE TABLE IF NOT EXISTS `nut_guestboard` (
	`_postID` int(11) NOT NULL AUTO_INCREMENT,
	`_steamID` bigint(20) NOT NULL,
	`_steamName` varchar(32) NOT NULL,
	`_text` text NOT NULL,
	PRIMARY KEY (`_postID`)
);
		]]
		local SQLITE_CREATE_TABLES = [[
CREATE TABLE IF NOT EXISTS `nut_reserve` (
	`_charID` INTEGER PRIMARY KEY,
	`_reserve` INTEGER
);
CREATE TABLE IF NOT EXISTS `nut_guestboard` (
	`_postID` INTEGER PRIMARY KEY,
	`_steamID` INTEGER,
	`_steamName` TEXT,
	`_text` TEXT
);
		]]

		function SCHEMA:OnLoadTables()
			if (nut.db.object) then
				-- This is needed to perform multiple queries since the string is only 1 big query.
				local queries = string.Explode(";", MYSQL_CREATE_TABLES)

				nut.db.query(queries[1])
				nut.db.query(queries[2])
			else
				nut.db.query(SQLITE_CREATE_TABLES)
			end
		end

		function SCHEMA:CharacterPreSave(char)
			savereserve(char)
		end

		function SCHEMA:CharacterLoaded(id)
			-- legacy support
			-- for modernRP users
			local char = nut.char.loaded[id]

			nut.db.query("SELECT _reserve FROM nut_reserve WHERE _charID = "..id, function(data)
				if (data and #data > 0) then
					for k, v in ipairs(data) do
						local money = tonumber(v._reserve)

						char:setReserve(money)
					end
				else
					nut.db.insertTable({
						_reserve = 0,
						_charID = id,
					}, function(data)
						char:setReserve(0)
					end, "reserve")
				end
			end)
		end

	    function SCHEMA:PreCharDelete(client, char)
	    	nut.db.query("DELETE FROM nut_reserve WHERE _charID = "..char:getID())
	    end

end

-- Building Payload
function SCHEMA:BuildingTaxPayload()
	for k, v in ipairs(player.GetAll()) do
		if (v.properties) then
			local doors = table.Count(v.properties)

			if (doors > 0) then
				local tax = doors * nut.config.get("doorTax")

				local char = v:getChar()
				if (char) then
					local apsu = char:hasMoney(tax)

					if (!apsu) then
						for entity, _ in pairs(v.properties) do
							entity:removeDoorAccessData()
						end
						v.properties = {}

						v:notifyLocalized("doorCharged")
					else
						char:takeMoney(tax)
						v:notifyLocalized("doorTax", nut.currency.get(tax))
					end
				end
			end
		end
	end
end

-- Salary Timer Payload
function SCHEMA:SalaryPayload()
	for k, v in ipairs(player.GetAll()) do
		local char = v:getChar()

		-- If faction has default salary, give them the salary.
		if (char) then
			local class = char:getClass()
			local classInfo = nut.class.list[class]

			if (classInfo) then
				local amount = classInfo.salary or 1

				if (hook.Run("CanPlayerReceiveSalary", v) == false) then
					return false
				end

				char.player:notify(L("reserveSalary", v, nut.currency.get(amount)))

				char:addReserve(amount)
			end
		end
	end
end

-- Bank Interest Timer Payload
function SCHEMA:BankIncomePayload()
	local timerIndex = 0

	for k, client in ipairs(player.GetAll()) do
		if (client.IsAFK and client:IsAFK()) then
			continue
		end
		
		local char = client:getChar()

		-- If faction has default salary, give them the salary.
		if (char) then
			local charFaction = char:getFaction()
			local faction = nut.faction.indices[charFaction]

			if (faction.salary) then
				-- because i'm fucking lazy lmaoo
				timer.Simple(timerIndex * .1, function()
					if (IsValid(client)) then
						if (hook.Run("CanPlayerGetBankIncome", client) == false) then
							return false
						end
	
						local profit = math.Round(char:getReserve() * (math.abs(nut.config.get("incomeRate", 1) / 100)))
						profit = math.min(profit, 80000)
	
						client:notify(L("reserveIncome", client, nut.currency.get(profit)))
						char:addReserve(profit)
					end
				end)

				timerIndex = timerIndex + 1
			end
		end
	end
end

function SCHEMA:CrapPayload()
	-- removing whiles to not crash the server.
end

-- This hook restricts oneself from using a weapon that configured by the sh_config.lua file.
function SCHEMA:CanPlayerInteractItem(client, action, item)
	if (IsValid(client:getNetVar("searcher"))) then
		return false
	end

	local char = client:getChar()

	if (IsValid(client.nutRagdoll)) then return false end

	if (client:isArrested()) then return false end

	if (action == "drop" or action == "take") then
		return
	end

	local itemTable
	if (type(item) == "Entity") then
		if (IsValid(item)) then
			itemTable = nut.item.instances[item.nutItemID]
		end
	else
		itemTable = nut.item.instances[item]
	end

	if (itemTable and itemTable.team) then
		if (action == "use" or action == "Equip") then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (!table.HasValue(itemTable.team, classData.team)) then
				client:notifyLocalized("notRightClass")
				return false
			end
		end
	end

	if (itemTable and itemTable.isWeapon) then
		local reqattribs = WEAPON_REQSKILLS[itemTable.uniqueID]
		
		if (reqattribs) then
			for k, v in pairs(reqattribs) do
				local attrib = char:getAttrib(k, 0)
				if (attrib < v) then
					client:notify(L("requireAttrib", client, L(nut.attribs.list[k].name, client), attrib, v))

					return false
				end
			end
		end
	end
end

-- This hook returns whether player can receive the salary or not.
function SCHEMA:CanPlayerReceiveSalary(client)
	if (true) then
		return false
	end

	local char = client:getChar()

	if (!char.player:Alive()) then
		return false, char.player:notify(L("salaryRejected", client))	
	end
end

-- This hook notices you the death penalty that you've got by the server.
function SCHEMA:PlayerSpawn(client)
	local char = client:getChar()

	if (char) then
		if (client.deadChar and client.deadChar == char:getID() and char.lostMoney and char.lostMoney > 10) then
			client:notify(L("hospitalPrice", client, nut.currency.get(char.lostMoney)))
		end
			
		client.deadChar = nil
	end
end

function SCHEMA:PlayerLoadedChar(client, netChar, prevChar)
	nut.map.sync(client)
	
	if (prevChar) then
		hook.Run("PlayerHitCharacterDodge", client, netChar, prevChar)
		hook.Run("ResetVariables", client, SIGNAL_CHAR)

		-- TODO: reduce iteration count
		for k, v in ipairs(ents.GetAll()) do
			if (v:GetPersistent()) then continue end
			if (v:GetNWBool("fuckoff")) then continue end

			if (v:CPPIGetOwner() == client) then
				v:Remove()
			end
		end

		client:notifyLocalized("cleanupChar")
	else
		local char = client:getChar()
		client:arrest(false)
	end
	// TODO: Add fucking jail-bail re-jailer
end

function SCHEMA:OnPlayerDropWeapon(client, item, entity)
	local physObject = entity:GetPhysicsObject()
	
	if (physObject) then
		physObject:EnableMotion()
	end

	timer.Simple(30, function()
		if (entity and entity:IsValid()) then
			entity:Remove()
		end
	end)
end

local function item2world(inv, item, pos)
	item.invID = 0

	inv:remove(item.id, false, true)
	
	nut.db.query("UPDATE nut_items SET _invID = 0 WHERE _itemID = "..item.id)

	local ent = item:spawn(pos)	
	
	if (IsValid(ent)) then
		timer.Simple(0, function()
			local phys = ent:GetPhysicsObject()
			
			if (IsValid(phys)) then
				phys:EnableMotion(true)
				phys:Wake()
			end
		end)
	end

	return ent
end

function SCHEMA:PlayerDeath(client, inflicter, attacker)
	local char = client:getChar()
	
	if (char) then
		if (IsValid(attacker) and attacker:IsPlayer() and client != attacker) then
			client:ChatPrint(L("killedBy", client, attacker:Name()))
		end

		local class = char:getClass()
		local classData = nut.class.list[class] or nut.class.list[1]
		local job = classData.name
		local law = classData.law
		
		hook.Run("ResetVariables", client, SIGNAL_DEATH)

		-- money penalty
		if (nut.config.get("deathMoney", true) and !law ) then
			client.deadChar = char:getID()
			char.lostMoney = math.Round(char:getMoney() * (nut.config.get("dpBank", 10) / 100))
			if ( char.lostMoney > 10 ) then
				char:giveMoney(-char.lostMoney)
				else
			end
		end

		hook.Run("PlayerHitDeath", client, inflicter, attacker)

		-- weapon penalty
		local inv = char:getInv()
		local items = inv:getItems()

		for _, itemObject in pairs(items) do
			inv = nut.item.inventories[itemObject.invID]

			if (itemObject.removeOnDeath) then
				itemObject:remove()
				continue
			end

			if (itemObject.dropOnDeath) then
				local ent = item2world(inv, itemObject, client:GetPos() + Vector(0, 0, 10))

				hook.Run("OnPlayerDropItem", client, itemObject, ent)
			end

			if (itemObject.isWeapon) then
				if (itemObject:getData("equip")) then
					itemObject:remove()
				end
			end
		end
	end
end

-- Don't let them spray thier fucking spray without spraycan
function SCHEMA:PlayerSpray(client)
	return true
	--return (client:getChar():getInv():hasItem("spraycan")) or false
end

-- On character is created, Give him some money and items. 
function SCHEMA:OnCharCreated(client, char)
	if (char) then
		local inv = char:getInv()

		if (inv) then
			local stItems = self.startItems or {}
			for _, item in ipairs(stItems) do
				if (item[1] and item[2]) then
					inv:add(item[1], item[2], item[3])
				end
			end
		end

		char:setMoney(50000)

		local charCount = table.Count(client.nutCharList)

		if (charCount > 1) then
			char:setMoney(0)
			client:notifyLocalized("noExploitPlease")
		end
	end
end

function SCHEMA:KeyPress(client, key)
	if (key == IN_RELOAD and nut.config.get("isSerious", false)) then
		timer.Create("nutToggleRaise"..client:SteamID(), 1, 1, function()
			if (IsValid(client)) then
				client:toggleWepRaised()
			end
		end)
	elseif (key == IN_USE) then
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local entity = util.TraceLine(data).Entity

		
		if (IsValid(entity) and entity:isDoor() or entity:IsPlayer()) then
			hook.Run("PlayerUse", client, entity)
		end
	end
end

function SCHEMA:PlayerUse(client)
	if (client:isArrested()) then return end
end

function SCHEMA:PlayerInitialSpawn(client)
	netstream.Start(client, "nutLawSync", SCHEMA.laws)
end

-- Give Class Loadout.
function SCHEMA:PostPlayerLoadout(client, reload)
	client:AllowFlashlight(true)
	
	local char = client:getChar()

	if (!nut.config.get("isSerious", false)) then
		client:Give("weapon_physgun")
		client:Give("gmod_tool")
		client:Give("gmod_camera")
	end

	if (char) then
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData) then
			if (classData.law) then
				client:GiveAmmo(150, "pistol")
				client:GiveAmmo(120, "ar2")
			end

			local model = table.Random(classData.model or {})

			if (model) then
				client:SetModel(model)
			end
		end
	end

	if (client:isArrested()) then
		if (self.prisonPositions and #self.prisonPositions > 0) then
			client:SetPos(table.Random(self.prisonPositions))
		end
	end
end

function SCHEMA:EntityPurchased(client, char, entity, entTable)
	entity:CPPISetOwner(client)

	if (entTable.onSpawn) then
		entTable.onSpawn(entity, client, char, entTable)
	end
	
	nut.log.add(client, "entity", entity:GetClass())
end

function SCHEMA:OnNoteSpawned(entity, item)
	local client = item.player

	entity:CPPISetOwner(client)
end

netstream.Hook("carLightToggle", function(client)
	local vehicle = client:GetVehicle()

	if (vehicle and IsValid(vehicle)) then
		if (vehicle:getNetVar("policeCar")) then
			local light = vehicle:getNetVar("lightOn", false)
			
			vehicle:setNetVar("lightOn", !light)
			vehicle:EmitSound("buttons/lightswitch2.wav")
		end
	end
end)

function SCHEMA:CanBuyEntity(client, char, classname, entTable)
	if (char) then
		if (client:isArrested()) then
			client:notifyLocalized("arrested")
			return false
		end

		local max 
		if (classname == "nut_d_pot") then
			local laws = 0 
			for k, v in ipairs(player.GetAll()) do
				local char = v:getChar()
				if (char) then
					local class = char:getClass()
					local classData = nut.class.list[class]

					if (classData and classData.law) then
						laws = laws + 1
					end
				end
			end

			max = math.min(laws * nut.config.get("potPerLaw", 5), entTable.max)
		end

		local cnt = 0 
		local printers = {}
		-- TODO: reduce iteration count
		for k, v in ipairs(ents.GetAll()) do
			if (v:CPPIGetOwner() == client) then
				if (entTable.class == v:GetClass()) then
					cnt = cnt + 1
				end
				if (v:GetClass():find("printer_")) then
					table.insert(printers, v)
				end
			end
		end

		if (cnt >= (max or entTable.max)) then
			if (max) then
				client:notifyLocalized("maxReachedLaw", max)
			else
				client:notifyLocalized("maxReached")
			end

			return false
		end
		
		if (classname:find("printer_") and table.Count(printers) >= 3) then
			client:notifyLocalized("maxReached")
			return false
		end
	end
end

function SCHEMA:PlayerConnect(name)
	for k, v in ipairs(player.GetAll()) do
		v:ChatPrint(L("playerJoinedServer", v, name))
	end
end

function SCHEMA:PlayerDisconnected(client)
	hook.Run("PlayerCountChanged")

	if (IsValid(client.nutRagdoll)) then
		client.nutRagdoll:Remove()
	end

	-- TODO: reduce iteration count
	for k, v in ipairs(ents.GetAll()) do
		if (v:GetPersistent()) then continue end
		if (v:GetNWBool("fuckoff")) then continue end
		
		if (v:CPPIGetOwner() == client) then
			v:Remove()
		end
	end

	hook.Run("PlayerHitDisconnect", client)
end

function SCHEMA:OnPlayerRequestedHit(client, target, hitman, message)		
	nut.log.add(client, "hit", target, hitman, message)
end

function SCHEMA:OnPlayerArrested(arrester, arrested, isArrest)
	if (isArrest) then
		if (IsValid(arrested) and IsValid(arrester)) then
			for k, v in ipairs(player.GetAll()) do
				v:ChatPrint(arrested:Name() .. "님이 " .. arrester:Name() .. "님에게 체포되었습니다.")
			end

			nut.log.add(arrester, "arrest", arrested)
		end

		if (IsValid(arrested)) then
			local char = arrested:getChar()
			local inv = char:getInv():getItems()

			if (arrested:isWanted()) then
				char:setData("wanted", false, nil, player.GetAll())
			end
			
			for _, itemObject in pairs(inv) do
				print(itemObject.name)
				if (itemObject.isWeapon) then
					itemObject:remove()
				else
					if (itemObject:getData("equip")) then
						itemObject:setData("equip", nil)
					end
				end
			end

			if (self.prisonPositions and #self.prisonPositions > 0) then
				arrested:SetPos(table.Random(self.prisonPositions))
			end

			arrested:setAction("감옥 타이머", nut.config.get("jailTime"))
			arrested:StripWeapons()
			
			local jailTimer = arrested:UniqueID() .. "_jailTimer"
			timer.Create(jailTimer, nut.config.get("jailTime"), 1, function()
				if (IsValid(arrested) and arrested:isArrested()) then
					arrested:Spawn()
					arrested:notify("감옥에서 석방되었습니다.")
					arrested:arrest(false)
				end
			end)
			
			hook.Run("PlayerHitArrested", arrester, arrested, isArrest)
		end
	else
		if (IsValid(arrester)) then
			nut.log.add(arrester, "unarrest")
		end

		if (IsValid(arrested)) then
			nut.log.add(arrested, "unarrested")

			local jailTimer = arrested:UniqueID() .. "_jailTimer"
			timer.Remove(jailTimer)
		end

		if (IsValid(arrester) and IsValid(arrested)) then
			local pos = arrested:GetPos()

			arrested:Spawn()
			arrested:SetPos(pos)
		else
			arrested:Spawn()
		end
	end
end

function SCHEMA:CanBeArrested(client)
	if (client:isArrested()) then
		return false
	end

	return true
end

function SCHEMA:CanPlayerJoinClass(client, class, classData)
	if (client:isArrested()) then
		return false, "arrested"
	end
	
	if (client.bannedClasses and client.bannedClasses[class]) then
		return false, "banned"
	end
end

function SCHEMA:OnPlayerJoinClass(client, class, oldclass, silent)
	local info = nut.class.list[tonumber(class)]
	local infoa = nut.class.list[tonumber(oldclass)]
	nut.log.add(client, "job", info, infoa)
	
	client.nextBe = CurTime() + NUT_JOB_DELAY

	if (!silent) then
		for k, v in ipairs(player.GetAll()) do
			if (v != client) then
				v:notifyLocalized("changedClass", client:Name(), L(info.name, client))
			end
		end
	end

	-- TODO: reduce iteration count
	for k, v in ipairs(ents.GetAll()) do
		local entClass = v:GetClass()
		local bent = nut.bent.list[entClass]

		if (bent) then
			if (!bent.condition(client)) then
				if (v:CPPIGetOwner() == client) then
					v:Remove() --!!!
				end 
			end
		end
		
		if (entClass == "nut_lawboard") then
			if (v:CPPIGetOwner() == client) then
				v:Remove() --!!!
			end 
		end
	end

	if (infoa) then
		local weapons = infoa.weapons

		if (weapons) then
			for k, v in ipairs(weapons) do
				if (client:HasWeapon(v)) then
					client:StripWeapon(v)
				end
			end
		end
	end

	local char = client:getChar()

	if (info.model) then
		local inv = char:getInv():getItems()

		for k, v in pairs(inv) do
			if (v.isCloth and v:getData("equip")) then
				v:setData("equip", nil)
			end
		end

		client:SetModel(table.Random(info.model))
		client:SetSubMaterial()
	else
		client:SetModel(char:getModel())
	end

	hook.Run("ResetVariables", client, SIGNAL_JOB)
end

function SCHEMA:OnPlayerWanted(bool, wanted, reason, who, silence)
	if (silence) then return end
	
	if (bool) then
		nut.log.add(wanted, "wanted", who, reason)
	else
		--nut.log.add(who, "unwanted")
	end
	
	netstream.Start(player.GetAll(), "nutWantedText", bool, who, wanted, reason)
end

function SCHEMA:saveJail()
	nut.data.set("jailpos", self.prisonPositions)
end

function SCHEMA:loadJail()
	self.prisonPositions = nut.data.get("jailpos")
end

function SCHEMA:saveGarbage()
	nut.data.set("crap", self.crapPositions)
end

function SCHEMA:loadGarbage()
	self.crapPositions = nut.data.get("crap")
end

-- Save Data.
local saveEnts = {
	["frame_billboard"] = true,
	["nut_atm"] = true,
	["nut_outfit"] = true,
	["nut_m_recycler"] = true,
	["nut_fedboard"] = true,
	["nut_roll"] = true,
	["nut_helloboard"] = true,
	["nut_rotlight"] = true,
	["nut_checker"] = true,
	["nut_rock_model_01"] = true,
	["nut_rock_model_02"] = true,
	["nut_rock_model_03"] = true,
	["ssm_base_new"] = true,
	["sent_locker"] = true,
}
function SCHEMA:SaveData()
	self:saveJail()
	self:saveGarbage()

	local savedEntities = {}

	for k, v in ipairs(ents.GetAll()) do
		local class = v:GetClass():lower()

		if (class == "frame_billboard") then
			table.insert(savedEntities, {
				class = class, 
				pos = v:GetPos(),
				ang = v:GetAngles(),
				url = v:GetURL(),
			})
			
			continue
		end

		if (class:find("bingle") and v:GetNWBool("fuckoff")) then
			table.insert(savedEntities, {
				class = class, 
				pos = v:GetPos(),
				ang = v:GetAngles(),
				text = v:GetText(),
				font = v:GetFont(),
				type = v:GetType(),
				fontsize = v:GetFontSize(),
				outsize = v:GetOutSize(),
				animspeed = v:GetAnimSpeed(),
				neon = v:GetNeon(),
				colback = v:GetColorBack(),
				coltext = v:GetColorText(),
				colout = v:GetColorOut(),
			})
			
			continue
		end
			
		if (saveEnts[class]) then
			table.insert(savedEntities, {
				class = class, 
				pos = v:GetPos(),
				ang = v:GetAngles(),
			})
		end
	end

	-- Save Map Entities
	self:setData(savedEntities)

	-- Save schema variables.
	--self:setData(schemaData, true, true)
end

-- Load Data.
function SCHEMA:LoadData()
	self:loadJail()
	self:loadGarbage()
	-- Load Map Entities
	local savedEntities = self:getData() or {}
	
	for k, v in ipairs(savedEntities) do
		local ent = ents.Create(v.class)
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if (IsValid(phys)) then
			phys:Wake()
			phys:EnableMotion()
		end

		if (v.class == "frame_billboard") then
			ent:SetURL(v.url)
		end

		if (ent.isNotiboard) then
			ent:SetText(v.text)
			ent:SetFont(v.font)
			ent:SetType(v.type)
			ent:SetFontSize(v.fontsize)
			ent:SetOutSize(v.outsize)
			ent:SetAnimSpeed(v.animspeed)
			ent:SetNeon(v.neon)
			ent:SetColorBack(v.colback)
			ent:SetColorText(v.coltext)
			ent:SetColorOut(v.colout)
			ent:SetNWBool("fuckoff", true)
		end
	end

	-- Load Schema Variables.
	-- self:loadData(true, true)
end

function SCHEMA:CalculateGarbage(client, n)
	return math.ceil(n*0.8)
end


function SCHEMA:CanHitRequested(client)
	if (!client:Alive()) then
		return false
	end

	return true
end

function SCHEMA:CanHitRequest(client)
	if (!client:Alive()) then
		return false
	end

	return true
end

function SCHEMA:OnRequestHit(client, target, request, reason)
	netstream.Start(player.GetAll(), "nutHitText", request, target, reason)
end

function SCHEMA:OnHitSuccess(hitman, client)
	nut.log.add(hitman, "hitA")
	nut.log.add(client, "hitC")
	
	hitman:setNetVar("onHit", nil)
	client:setNetVar("hitman", nil)

	hitman:notifyLocalized("hitSuccess")

	local cost = nut.config.get("hitCost", 250)
	local char = hitman:getChar()

	char:addReserve(cost)
	hitman:notifyLocalized("hitReward", nut.currency.get(cost))
end

function SCHEMA:OnHitFailed(hitman, client, disconnect)
	if (hitman == client) then
		local target = hitman:getNetVar("onHit")

		hitman:setNetVar("onHit", nil)
		if (target and target:IsValid()) then
			target:setNetVar("hitman", nil)
		end
	else
		hitman:setNetVar("onHit", nil)
		client:setNetVar("hitman", nil)
	end

	hitman:notifyLocalized("hitFailed")
	nut.log.add(hitman, "hitB")
end

function SCHEMA:PlayerHitArrested(arrester, arrested, isArrest)
	local char = arrested:getChar()
	local class = char:getClass()

	if (class and class == CLASS_HITMAN) then
		if (arrested:getNetVar("onHit")) then
			hook.Run("OnHitFailed", arrested, arrested)
		end
	end
end

function SCHEMA:PlayerHitCharacterDodge(client, netChar, prevChar)
	local char = client:getChar()

	if (char) then
		local hitman = client:getNetVar("hitman")

		if (hitman and hitman:IsValid()) then
			client:setNetVar("hitman", nil)

			hook.Run("OnHitFailed", hitman, client, true)
		end
	end
end

function SCHEMA:PlayerHitDisconnect(client)
	local char = client:getChar()

	if (char) then
		local hitman = client:getNetVar("hitman")

		if (hitman and hitman:IsValid()) then
			client:setNetVar("hitman", nil)

			hook.Run("OnHitFailed", hitman, client, true)
		end
	end
end

function SCHEMA:PlayerHitDeath(client, inflicter, attacker)
	local char = client:getChar()

	if (char) then
		local hitman = client:getNetVar("hitman")

		if (hitman and hitman:IsValid()) then
			if (attacker != hitman) then 
				hook.Run("OnHitFailed", hitman, client)

			else
				hook.Run("OnHitSuccess", hitman, client)
			end
		else
			client:setNetVar("hitman", nil)
		end

		local class = char:getClass()

		if (class and class == CLASS_HITMAN) then
			if (client:getNetVar("onHit")) then
				hook.Run("OnHitFailed", client, client)
			end
		end
	end
end

function SCHEMA:PlayerStaminaLost(client)
	local char = client:getChar()
	char:updateAttrib("end", 0.008)
	char:updateAttrib("stm", 0.004)
end

function SCHEMA:OnMoneyPrinterDestroyed(printer, owner, attacker)
	if (attacker and attacker:IsValid()) then
		local char = attacker:getChar()

		if (char) then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (classData and classData.law) then
				local reward = printer.SeizeReward or 100

				attacker:notifyLocalized("printerSeized", reward)
				char:giveMoney(reward)
			end
		end
	end
end

function SCHEMA:PostLoadData()
	self:UpdateVendors()
end

function SCHEMA:OnPlayerStunstickEntity(client, entity, weapon)
	local class = entity:GetClass()
	local reutrnValue = ILLEGAL_ENTITY[class]

	if (reutrnValue) then
		local char = client:getChar()

		if (char) then
			local info = nut.bent.list[class]

			if (info) then
				local reward = math.Round(info.price * reutrnValue)

				char:giveMoney(reward)
				client:notifyLocalized("reutrnReward", nut.currency.get(reward))
				nut.log.add(client, "stunstick", entity:GetClass())
				entity:Remove()
			end
		end
	end
end

NUT_ITEM_REMOVE_INTERVAL = 300
function SCHEMA:OnItemSpawned(entity)
	timer.Simple(NUT_ITEM_REMOVE_INTERVAL, function()
		if (IsValid(entity)) then
			if (entity:getNetVar("sellPrice", 0) <= 0) then
				entity:Remove()
			end
		end
	end)
end

function SCHEMA:CanPlayerAccessDoor(client, door, access)
	local owner = door:getNetVar("owner")
	
	if (IsValid(owner)) then
		local char = owner:getChar()
		if (!char) then return false end

		local class = char:getClass()
		if (!class) then return false end

		local classData = nut.class.list[class]
		local charClass = client:getChar():getClass()
		local classData2 = nut.class.list[charClass]

		if (classData and classData2) then
			if (classData.team) then
				if (classData.team != classData2.team) then
					return false
				end
			else
				if (charClass != class) then
					return false
				end
			end

			return true
		end
	end
end

function SCHEMA:OnPlayerDemoted(client, targetClass, targetClassData)
	nut.log.add(client, "demote", targetClassData)
	
	if (targetClassData.law) then
		local classes = nut.class.list

		for k, v in ipairs(classes) do
			client.bannedClasses = client.bannedClasses or {}
			client.bannedClasses[k] = CurTime() + 500
		end
	else
		local classes = nut.class.list
		client.bannedClasses = client.bannedClasses or {}
		client.bannedClasses[targetClass] = CurTime() + 500
	end
end

function SCHEMA:CanPlayerModifyConfig(client)
	if (client:IsSuperAdmin()) then
		return true
	end

	return false
end

function SCHEMA:OnPlayerItemBreak(client, item)
	client:notifyLocalized("itemBroke")
end

function SCHEMA:searchPlayer(client, target)
	if (IsValid(target:getNetVar("searcher")) or IsValid(client.nutSearchTarget)) then
		return false
	end

	if (!target:getChar() or !target:getChar():getInv()) then
		return false
	end

	local inventory = target:getChar():getInv()

	-- Permit the player to move items from their inventory to the target's inventory.
	inventory.oldOnAuthorizeTransfer = inventory.onAuthorizeTransfer
	inventory.onAuthorizeTransfer = function(inventory, client2, oldInventory, item)
		if (IsValid(client2) and client2 == client) then
			return true
		end

		return false
	end
	inventory:sync(client)
	inventory.oldGetReceiver = inventory.getReceiver
	inventory.getReceiver = function(inventory)
		return {client, target}
	end
	inventory.onCheckAccess = function(inventory, client2)
		if (client2 == client) then
			return true
		end
	end

	-- Permit the player to move items from the target's inventory back into their inventory.
	local inventory2 = client:getChar():getInv()
	inventory2.oldOnAuthorizeTransfer = inventory2.onAuthorizeTransfer
	inventory2.onAuthorizeTransfer = function(inventory3, client2, oldInventory, item)
		if (oldInventory == inventory) then
			return true
		end

		return inventory2.oldOnAuthorizeTransfer(inventory3, client2, oldInventory, item)
	end

	-- Show the inventory menu to the searcher.
	netstream.Start(client, "searchPly", target, target:getChar():getInv():getID())

	client.nutSearchTarget = target
	target:setNetVar("searcher", client)

	return true
end

netstream.Hook("searchExit", function(client)
	local target = client.nutSearchTarget

	if (IsValid(target) and target:getNetVar("searcher") == client) then
		local inventory = target:getChar():getInv()
		inventory.onAuthorizeTransfer = inventory.oldOnAuthorizeTransfer
		inventory.oldOnAuthorizeTransfer = nil
		inventory.getReceiver = inventory.oldGetReceiver
		inventory.oldGetReceiver = nil
		inventory.onCheckAccess = nil
			
		local inventory2 = client:getChar():getInv()
		inventory2.onAuthorizeTransfer = inventory2.oldOnAuthorizeTransfer
		inventory2.oldOnAuthorizeTransfer = nil

		target:setNetVar("searcher", nil)
		client.nutSearchTarget = nil
	end
end)

function SCHEMA:OnPlayerSearch(client, target)
	if (IsValid(target) and target:IsPlayer()) then				
		if (target:getChar()) then
			client.searching = true
			client:EmitSound("npc/combine_soldier/gear"..math.random(3, 4)..".wav", 100, 70)

			client:setAction("@searching", 5)
			client:doStaredAction(target, function()
				local dist = client:GetPos():Distance(target:GetPos())

				if (dist < 128) then
					SCHEMA:searchPlayer(client, target)
				else
					client:notifyLocalized("tooFar")
				end

				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 5, function()
				client:setAction()
				target:setAction()

				client.searching = false
			end)

			target:setAction("@searched", 5)
		end
	else
		client:notifyLocalized("notValid")
	end
end

function SCHEMA:CanPlayerRefundEntity(client, entity)
	if (IsValid(entity)) then
		if (entity:GetClass() == "nut_shootbag") then
			if (entity.health < 2000) then
				return false, "usedBag"
			end
		end

		if (entity:GetClass() == "nut_punchbag") then
			if (entity.health < 1000) then
				return false, "usedBag"
			end
		end
	end
end

function SCHEMA:OnPlayerRefundEntity(client, entity)
	local class = entity:GetClass()
	local reutrnValue = nut.config.get("entityRefund", 0.5)
	local char = client:getChar()

	if (char) then
		local info = nut.bent.list[class]

		if (info and entity:CPPIGetOwner() == client) then
			local reward = math.Round(info.price * reutrnValue)

			char:giveMoney(reward)
			client:notifyLocalized("refundEntity", nut.currency.get(reward))
			nut.log.add(client, "refund", entity:GetClass())
			entity:Remove()
		end
	end
end

function SCHEMA:OnLockdown(client, bool)
	netstream.Start(player.GetAll(), "nutLockdown", bool)

	nut.log.add(client, "lockdown", bool or false)
end

function SCHEMA:OnPlayerLicensed(client, target, bool)
	local hasLicense = target:getNetVar("license", false)

	if (bool) then
		if (hasLicense) then
			client:notifyLocalized("hasLicense")
		else
			target:setNetVar("license", true)
			client:notifyLocalized("gaveLicense")
		end
	else
		if (hasLicense) then
			target:setNetVar("license", false)
			client:notifyLocalized("revokeLicense")
		else
			client:notifyLocalized("hasLicenseRevoked")
		end
	end
end

function SCHEMA:OnPlayerAFKLong(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData and !classData.isDefault) then
			char:kickClass()
		end

		if (client.properties) then
			for entity, bool in pairs(client.properties) do
				entity:removeDoorAccessData()
			end
		end

		for k, v in ipairs(player.GetAll()) do
			v:notifyLocalized("afkDemote", char:getName())
		end
	end
end

function SCHEMA:OnPlayerPurchaseDoor(client, entity, purchase, childFunc)
	client.properties = client.properties or {}

	client.properties[entity] = purchase and true or nil

	childFunc(nil, entity, function(child)
		client.properties[child] = purchase and true or nil
	end)
end 

function SCHEMA:OnCharDisconnect(client, char)
	if (char) then
		local inv = char:getInv()

		if (inv) then
			for _, itemObject in pairs(inv:getItems()) do
				if (itemObject.team) then
					itemObject:setData("equip", false)
				end
			end
		end
	end
end

function SCHEMA:ResetVariables(client, signal)
	local char = client:getChar()

	-- on player changed the character/dead
	if (signal != SIGNAL_JOB) then
		-- Reset Collected Garbages
		client:setNetVar("garbage", 0)

		-- Reset Wanted Status
		char:setData("wanted", false, nil, player.GetAll())

		-- Reset Search Warrant Status
		client:setNetVar("searchWarrant", false)
		timer.Remove(client:getChar():getID() .. "_chewAss")
		
		-- Heal broken legs. (it's abusive shit, I know.)
        client:healLegs()

		-- Remove all temporal boosts.
        client:resetAllAttribBoosts()
	end

	-- When player changed the job or changed the character.
	if (signal == SIGNAL_JOB or signal == SIGNAL_CHAR) then
		client:setNetVar("license", false)
	end

	if (signal == SIGNAL_JOB) then
		local inv = char:getInv()

		if (inv) then
			for _, itemObject in pairs(inv:getItems()) do
				if (itemObject.team) then
					itemObject:setData("equip", nil)
					client:removePart(itemObject.uniqueID)
				end
			end
		end
	end

	if (signal == SIGNAL_CHAR) then
		-- remove all properties when the player changed the character.
		if (client.properties) then
			for entity, bool in pairs(client.properties) do
				entity:removeDoorAccessData()
			end
		end

		client.properties = {}
	end
end

function SCHEMA:CanPlayerRoll(client)
	local char = client:getChar()
	local class = char:getClass()

	return (class == CLASS_THIEF)
end

function SCHEMA:CanPlayerUseTie(client)
	if (IsValid(client)) then
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]
		
		if (!classData.law) then
			client:notifyLocalized("notLaw")
			
			return false
		end
	end
end

function SCHEMA:OnPlayerHeal(item, client, target, amount, seconds)
	-- Increasing client's medical skill when they actually healed someone with the item.
	do 
		local char = client:getChar()

		if (char) then
			local curAttrib = char:getAttrib("medical") or 0

			if (curAttrib > 10) then return end

			char:updateAttrib("medical", 0.025)
		end
	end

	-- heal all weird shits on the character's body.
	do
		if (IsValid(target)) then
			target:setNetVar("legBroken", nil)
		end
		target:healLegs()
	end
end

-- i don't like it
function SCHEMA:CanSaveStorage()
	return false
end

-- get your memes away from me cunt
function SCHEMA:CanPlayerSpawnStorage()
	return false
end

-- remove all items
function SCHEMA:ShutDown()
	-- save DB space, mate.
	for k, v in ipairs(ents.FindByClass("nut_item")) do
		v:Remove()
	end
end

function SCHEMA:PlayerAuthed()
	hook.Run("PlayerCountChanged")
end

function GM:ScalePlayerDamage(client, hitGroup, dmgInfo)
	dmgInfo:ScaleDamage(1)
end

function SCHEMA:CanHungerTick(client)
	if (client:isArrested()) then
		return false
	end

	if (IsPurge) then
		return false
	end
end

function GM:PlayerSpawnVehicle(client, model, name, data)
	if (client:IsSuperAdmin()) then return true end
end
