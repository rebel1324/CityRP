/*---------------------------------------------------------------------------
Tomas
---------------------------------------------------------------------------*/
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetUseType(SIMPLE_USE)
	self:SetModel("models/custom/rprinter.mdl")
	
	self.ModelColor = Color(255, 255, 255, 255)

	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetColor(self.ModelColor)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	phys:Wake()
	self.Working = true

	self.MaxMoney = 1500
	self.PrintRate = 77
	self.PlusSpeed = 20
	self.SpeedPrice = 200
	self.CoolerPrice = 100

	self.Money = 0 -- Startup things
	self.Speed = 20
	self.Heat = 0
	self.CurLaws = 0
	self.CurLawsMoney = 0
	self.Cooler = false

	self.LvlExp = 100

	self.PowerConsume = 0
	self.Stability = 0

	self:SetDTBool(0, self.Cooler)
	self:SetDTFloat(1, self.LvlExp)
	self:SetDTInt(2, self.PowerConsume)
	self:SetDTInt(3, self.Stability)
	self:SetDTInt(4, self.PlusSpeed)
	self:SetDTInt(5, self.Speed)
	
	self:SetPrintRate(self.PrintRate)
	timer.Simple(1, function() 
		if IsValid(self) then 
			self.NextPrint = CurTime() + self.PrintRate
			self:SetNextPrint(self.NextPrint)
		end 
	end)
	timer.Simple(self.PrintRate, function() if IsValid(self) then self:Work() end end)

	//This is how much power this bitminer uses. This is used to determin if the generator can power it or not.
	self.powerUsage = 1

	//This is the entity that we are "plugged" into. Will be nil if not pluged into any
	self.connectedEntity = nil

	self.socket = {
		position = Vector(-3.49,2.7,18),
		angle = Angle(0,0,0),
		pluggedInEntity = nil
	}
end

function ENT:AddMoney( amnt )
	self:SetDTFloat(2, self:GetMoney() + math.min(amnt, self.MaxMoney))
end

function ENT:Destruct(dmg)
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	
	local client = self:Getowning_ent()
	client:notifyLocalized("printerGone")

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
	if not IsValid(self:Getowning_ent()) then
		self:Destruct()
		self:Remove()
	end

	if self.Working then return end
	local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(1)
    effectdata:SetScale(1)
    effectdata:SetRadius(2)
    util.Effect("Sparks", effectdata)
end

function ENT:HeatControll()
	if IsValid(self) then
		if self.Cooler then
			if self.Heat < 90 and self.Speed > 40 then
				self.Heat = self.Heat + 10
			else
				if self.Heat > 0 then
					self.Heat = self.Heat - 10
				end
			end
		else
			if self.Speed > 50 then
				self.Heat = self.Heat + 10
			else
				if self.Heat <= 50 then
					self.Heat = self.Heat + 10
				else
					self.Heat = self.Heat - 10
				end
			end
		end
		if self.Heat >= 100 then
			self:Destruct()
			self:Remove()
		end
	end
end

function ENT:BreakControll()
	if math.random(1, self.CrclCfg.FireUpChance) == 3 then
		self.Working = false

		local client = self:Getowning_ent()
		client:notifyLocalized("printerBork")
	end
end


function ENT:Work()
	if IsValid(self) then
		if self.Working then

			self:AddMoney(self:CalcMoney())

			self.NextPrint = CurTime() + self.PrintRate
			self:SetNextPrint(self.NextPrint)
			self:HeatControll()
			if self.CrclCfg.OnPrintFunc and IsValid(self:Getowning_ent()) then
				self.CrclCfg.OnPrintFunc(self:Getowning_ent())
			end
			self:BreakControll()
			self.LvlExp = math.min(self.LvlExp + 15, 500)
			self:SetDTFloat(1, self.LvlExp)
		end

		timer.Simple(self.PrintRate, function() if IsValid(self) then self:Work() end end)
	end
end

function ENT:Use(ply)
	if (self:getNetVar("locked")) then return end
	if(ply:IsPlayer())then
		self.Working = true
		local char = ply:getChar()

		if (!char) then return end

		if self:GetMoney() > 0 then
			char:giveMoney(math.Round(self:GetMoney()))

			ply:notifyLocalized("moneyTaken", nut.currency.get(self:GetMoney()))
			self:SetDTFloat(2, 0)
			timer.Simple(0.1, function()
				local vPoint = self:GetBonePosition(1) + self:GetForward() * 15
				local effectdata = EffectData()
				effectdata:SetStart(vPoint)
				effectdata:SetOrigin(vPoint)
				effectdata:SetNormal(self:GetForward())
				effectdata:SetScale(1)
				util.Effect("btMoneySplat", effectdata)
				self:ResetSequence("withdraw")
			end)
		end
    end
end