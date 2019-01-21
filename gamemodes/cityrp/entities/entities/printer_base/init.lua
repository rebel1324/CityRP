--[[
Tomas
--]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self:SetModel("models/rebel1324/mprint.mdl")

	self.ModelSkin = self.ModelSkin or 0

	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetSkin(self.ModelSkin)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()

	self:SetEnabled(true)

	self:UpdateCoolerTimer()
	self:UpdatePrintTimer()
end

function ENT:UpdateCoolerTimer()
	local timerName = self:EntIndex() .. "_cool"
	timer.Create(timerName, self.setting.spec.coolTime * 1, 0, function()
		if (!IsValid(self) or self:GetNoDraw(true)) then
			timer.Destroy(timerName)
			return
		end

		if (!self:GetEnabled()) then
			local temp = self:GetTemperature()
			self:SetTemperature(math.max(0, temp - self:CalcCooling()))
		end
	end)
end

function ENT:UpdatePrintTimer(destroy)
	local timerName = self:EntIndex() .. "_print"

	if (destroy) then
		timer.Destroy(timerName)
		return
	end
	
	timer.Create(timerName, self:CalcSpeed() * 1, 0, function()
		if (!IsValid(self) or self:GetNoDraw(true)) then
			timer.Destroy(timerName)
			return
		end

		self:Work()
	end)
end

function ENT:AddMoney(amount )
	local maxAmount = self.setting.spec.maxHoldStacks * self:CalcMoney()

	self:SetMoney(math.min(self:GetMoney() + self:CalcMoney(), maxAmount))
end

function ENT:Destruct(dmg)
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)

	local client = self:Getowning_ent()
    if IsValid(client) then
        client:notifyLocalized("printerGone")
    end

	hook.Run("OnMoneyPrinterDestroyed", self, client, (dmg and dmg:GetAttacker()))
end

function ENT:OnTakeDamage(dmg)
	if (!dmg) then return end
	if self:IsOnFire() then return end

	self.damage = (self.damage or 100) - dmg:GetDamage()
	if self.damage <= 0 then
		self:Destruct()
		self:Remove()
	end
end

function ENT:Think()
	local phys = self:GetPhysicsObject()
	if (IsValid(phys)) then
		phys:EnableMotion(true)
	end

 	if not IsValid(self:Getowning_ent()) or self:WaterLevel() > 0 then
		self:Destruct()
		self:Remove()
	end
end

function ENT:HeatControl()
	if (IsValid(self)) then
		local temp = self:GetTemperature()
		local printHeat = self.setting.spec.printTemp
		local maxHeat = self.setting.spec.maxTemp

		self:SetTemperature(self:GetTemperature() + printHeat)

		if (self:GetTemperature() >= maxHeat) then
			self:Destruct()
			self:Remove()
		end
	end
end

function ENT:BreakControl()
	local chance = self:CalcStability()

	if (math.Rand(1, 100) < chance) then
		self:SetEnabled(false)

		local client = self:Getowning_ent()
		client:notifyLocalized("printerBork")
	end
end


function ENT:Work()
	if (self:GetEnabled()) then
		self:AddMoney(self:CalcMoney())

		self:HeatControl()
		self:BreakControl()

		local client = self:Getowning_ent()
		hook.Run("OnMoneyPrinterPrinted", self, client)
	end
end

function ENT:Use(client)
	if (client:IsPlayer()) then
		if (self:GetMoney() <= 0) then
			self:SetEnabled(!self:GetEnabled())
			client:notifyLocalized("printerToggled", (self:GetEnabled() == true) and L("on", client) or L("off", client))
		end

		local char = client:getChar()

		if (!char) then return end

		if self:GetMoney() > 0 then
			char:giveMoney(math.Round(self:GetMoney()))

			client:notifyLocalized("moneyTaken", nut.currency.get(self:GetMoney()))
			self:SetMoney(0)
		end
    end
end

netstream.Hook("printerUpgrade", function(client, upgKey, entity)
	if (IsValid(entity) and IsValid(client)) then
		local dist = entity:GetPos():Distance(client:GetPos())
		if (dist > 256) then return end

		local char = client:getChar()

		if (char) then
			--char:giveMoney(-money)

			local keys = entity.printerUpgrades
			if (keys[upgKey]) then
				local info = entity.setting.upgrade.price[upgKey]
				local getFunc = entity[("Get" .. keys[upgKey])]
				local setFunc = entity[("Set" .. keys[upgKey])]
				
				if (info and getFunc and setFunc) then
					local level = getFunc(entity)
					local money = info[1] * info[2] * (level + 1)
					local maxLevel = entity.setting.upgrade.max

					if (char:hasMoney(money)) then
						if (maxLevel <= level) then
							sound.Play( "buttons/button18.wav", entity:GetPos(), 100, 100, 1 )
							return
						end

						setFunc(entity, level + 1)
						char:takeMoney(money)
						sound.Play( "buttons/button15.wav", entity:GetPos(), 100, 100, 1 )
					else
						sound.Play( "buttons/button18.wav", entity:GetPos(), 100, 100, 1 )
					end
				end
			end
		end
	end
end)


