 -- This hook returns whether player can use bank or not.
function SCHEMA:CanUseBank(client, atmEntity)
	return true
end

-- This hook returns whether character is recognised or not.
function SCHEMA:IsCharRecognised(char, id)
	local character = nut.char.loaded[id]
	local client = character:getPlayer()
	
	if (client and character) then
		local faction = nut.faction.indices[client:Team()]

		if (faction and faction.isPublic) then
			return true
		end
	end
end

-- Restrict Business.
function SCHEMA:CanPlayerUseBusiness(client, id)
	local item = nut.item.list[id]
	local char = client:getChar()

	if (char) then
		local class = nut.class.list[char:getClass()]

		if (class and class.business and class.business[id]) then
			return true
		end
	end

	return (false)
end

function SCHEMA:CanDrive()
	return false
end

function SCHEMA:PlayerSpawnProp(client)
	return (!self.serious)
end

function SCHEMA:ShouldWeaponBeRaised()
	return self.serious
end

-- lol test
function SCHEMA:GetSchemaCWDamage(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 0.5
	return 0.4 + math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWReloadSpeed(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1
	return 1 + math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWRecoil(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 2 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWHipSpread(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 2 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWAimSpread(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = 1.5
	return 2 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:GetSchemaCWFirerate(weapon, client)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("gunskill", 0)
	end

	local maximum = .6
	return 1.3 - math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerGetMeleeDamage(client, damage)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("meleeskill", 0)
	end

	local maximum = 1.5
	return damage + damage * math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerGetMeleeDelay(client, delay)
	local attrib = 0

	if (client and client:IsValid() and client:getChar()) then
		attrib = client:getChar():getAttrib("meleeskill", 0)
	end

	local maximum = 0.8
	return delay * 1.5 - delay * math.Clamp(attrib / nut.config.get("maxAttribs", 30) * maximum, 0, maximum)
end

function SCHEMA:PlayerDoMelee(client, hit)
	if (CLIENT) then return end
	
	if (client:getChar()) then
		client:getChar():updateAttrib("str", 0.002)
		client:getChar():updateAttrib("meleeskill", 0.002)
	end
end

function SCHEMA:InitializedSchema()
	-- Initialize Salary Timer.
	if (SERVER) then
		timer.Create("nutSalary", nut.config.get("wageInterval", 180), 0, SCHEMA.SalaryPayload)
		timer.Create("nutGrabage", nut.config.get("garbageInterval", 20), 0, SCHEMA.CrapPayload)
		timer.Create("nutBankIncome", nut.config.get("incomeInterval", 180), 0, SCHEMA.BankIncomePayload)
		timer.Create("nutDoorTax", nut.config.get("doorTaxInterval", 180), 0, SCHEMA.BuildingTaxPayload)
	else
		-- 커맨드 번역
	end

	for class, data in ipairs(nut.class.list) do
		if (data.business) then
			data.business = table.Merge(data.business, DEFAULT_PURCHASE)
		end
	end
	
	-- lol i'm so lazy
	-- 미안 내가 너무 게을러서..
	for k, v in ipairs(weapons.GetList()) do
		local class = v.ClassName

		if (class:find("nut_m") and !class:find("base")) then
			local uniqueID = class:lower()
			local dat = {}

			local ITEM = nut.item.register(class:lower(), "base_weapons", nil, nil, true)
			ITEM.name = uniqueID
			ITEM.desc = "사람을 효과적으로 때릴수 있는 무기"
			ITEM.model = v.WorldModel
			ITEM.price = dat.price or 1000
			ITEM.width = dat.width or 1
			ITEM.height = dat.height or 2
			ITEM.class = class
			ITEM.weaponCategory = "melee"

			if (CLIENT) then
				if (nut.lang.stored["english"] and nut.lang.stored["korean"]) then
					ITEM.name = v.PrintName 

					nut.lang.stored["english"]["cw_" .. uniqueID] = v.PrintName 
					nut.lang.stored["korean"]["cw_" .. uniqueID] = v.PrintName 
				end
			end
			ITEM = nil
		end
	end
end

function SCHEMA:PhysgunPickup(client, entity)
	if (ALLOWED_ENTS[entity:GetClass()]) then
		if (entity:CPPIGetOwner() == client) then
			return true
		end
	end
end

function SCHEMA:PhysgunFreeze(weapon, phys, entity, client)
	if (ALLOWED_ENTS[entity:GetClass()]) then
		if (entity:CPPIGetOwner() == client) then
			return true
		end
	end
end

function SCHEMA:CanTool(client, trace, tool, ENT)
	local entity = trace.Entity
	
	if (IsValid(entity)) then
		if (ALLOWED_ENTS[entity:GetClass()]) then
			if (entity:CPPIGetOwner() == client) then
				return true
			end
		end
	end
end

function SCHEMA:CanItemBeTransfered(itemObject, curInv, inventory)
	if (!itemObject) then
		if (SERVER) then
			for k, v in ipairs(player.GetAll()) do
				curInv:sync(v, true)
				inventory:sync(v, true)
			end
		end

		if (CLIENT) then
			nut.gui.inv1:Remove()
		end
	end

    if (inventory and curInv) then
		local a = curInv.owner
		local b = inventory.owner

		local owner, newowner

		for k, v in ipairs(player.GetAll()) do
			local char = v:getChar()

			if (char) then
				if (char:getID() == a) then
					owner = v
				elseif (char:getID() == b) then
					newowner = v
				end
			end
		end 
		
		if (IsValid(owner)) then
			if (IsValid(owner:getNetVar("searcher"))) then
				return false
			end
		end

		if (IsValid(newowner)) then
			if (IsValid(newowner:getNetVar("searcher"))) then
				return false
			end
		end
        if (inventory.vars) then
			if (itemObject and itemObject.isBag) then
				local bag = inventory.vars.isBag

				if (bag) then
					if (SERVER) then
						if (IsValid(owner) and curInv and curInv:getID() != 0) then
							curInv:sync(owner, true)
						end

						if (IsValid(newowner) and inventory and inventory:getID() != 0) then
							inventory:sync(newowner, true)
						end
					end

					return false
				end
			end

            local isWeedag = (inventory.vars.isBag == "weedag")

            if (isWeedag and itemObject and itemObject.uniqueID != "raweed") then
				if (SERVER) then
					if (curInv and curInv:getID() != 0) then
						if (IsValid(owner)) then
							curInv:sync(owner, true)
						end
					end

					if (inventory and inventory:getID() != 0) then
						if (IsValid(newowner)) then
							inventory:sync(newowner, true)
						end
					end

					if (itemObject.player) then
						itemObject.player:notifyLocalized("onlyWeed")
					end
				end
			
                return false
            end
        end
    end
end

function SCHEMA:Move(client, movedata)
	if client:GetMoveType() != MOVETYPE_WALK then return end
    local char = client:getChar()

    if (char) then
        if (client:isLegBroken()) then
            local speed = movedata:GetMaxSpeed() * .4
            movedata:SetMaxSpeed( speed )
            movedata:SetMaxClientSpeed( speed )
        end
    end
end