AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Mining Rock"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_canal/rock_riverbed01a.mdl"

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end

	do
	REWARDWEIGHT = {
		mineral_rock = 80,
		mineral_copper = 45,
		mineral_iron = 30,
		mineral_silver = 10,
		mineral_gold = 5,
		mineral_platinum = 1,
		mineral_diamond = .03,
    }

    local sum = 0
		for k, v in pairs(REWARDWEIGHT) do
			sum = sum + v
		end

		for k, v in pairs(REWARDWEIGHT) do
			REWARDWEIGHT[k] = v/sum
		end

		local first = 0
		REWARDRANGE = {}
		for k, v in pairs(REWARDWEIGHT) do
			REWARDRANGE[k] = {}
			REWARDRANGE[k].a = first
			REWARDRANGE[k].b = first + v

			first = first + v
		end

	--[[
		if (SERVER) then
			local aaoa = {}
			local tries = 10000
			
			for i = 1, tries do
				local lmao = getChance()
				if (lmao) then
					aaoa[lmao] = aaoa[lmao] or 0
					aaoa[lmao] = aaoa[lmao] + 1
				end
			end
		end
	]]
	end


	local function getChance()
		local random = math.Rand(0, 1)
			
		for k, v in pairs(REWARDRANGE) do
			if (v.a < random and v.b >= random) then
				return k
			end
		end
	end

	function ENT:OnTakeDamage(damageinfo)
		local weapon = damageinfo:GetInflictor()
		local client = damageinfo:GetAttacker()
		if (IsValid(client) and client:IsPlayer()) then
			local char = client:getChar()

			if (char) then
				local class = char:getClass()

				if (class) then
					if (class != CLASS_MINER) then
						return
					end
				end
			end


			if (IsValid(weapon)) then
				local class = weapon:GetClass()

				if (class:find("pickaxe")) then
					client.hit = client.hit or 0
					client.hit = client.hit + 1

					if (client.hit >= 2) then
						local itemClass = getChance()
						local char = client:getChar()

						if (char) then
							local inv = char:getInv()

							if (inv) then
								local char = client:getChar()
								local inventory = char:getInv()
								
								inventory:add(itemClass, 1):next(function(item)
									client:notifyLocalized("minedSomething", itemClass)
								end, function(error)
									client:notifyLocalized(error)
								end)
							end
						end

						client.hit = 0
					end
				end
			end
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end