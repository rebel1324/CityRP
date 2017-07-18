AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Popcorn Vendor"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.denySound = Sound("items/medshotno1.wav")
ENT.useSound = Sound("items/medshot4.wav")
ENT.chargeSound = "items/medcharge4.wav"
ENT.restoreRate = .1
ENT.restoreAmount = 1
ENT.restoreCost = .03
ENT.restoreCool = 5
ENT.carePrice = 100

function ENT:getUsed()
	return self:getNetVar("used", 0)
end

function ENT:isActive()
	return self:getNetVar("active", false)
end

if (SERVER) then
	function ENT:SpawnFunction(client, trace, className)
		if (!trace.Hit or trace.HitSky) then return end

		local pos = trace.HitPos + trace.HitNormal * -1

		local ent = ents.Create(className)
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/rebel1324/popgen2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:setNetVar("used", 0)
		self.rechargeTime = CurTime()
		self.usedCharge = 0
		local phys = self:GetPhysicsObject()

		if (IsValid(phys)) then
			phys:Wake()
			phys:EnableMotion()
		end

		timer.Simple(0, function()
			self.loopSound = CreateSound(self, self.chargeSound)
		end)
	end

	function ENT:OnRemove()
		self.loopSound:Stop()
	end

	local dist = 0

	function ENT:finishUse(noService)
		self:setNetVar("active", false)
		self.loopSound:Stop()
		self:EmitSound(self.denySound)
		self.user:SetHealth(self.user:GetMaxHealth())

		-- Make user pay tokens
		if (self.usedCharge > 0) then
			local chargeprice = math.Round(self.usedCharge * self.carePrice)

			self.user:notifyLocalized(Format("medicalCare", nut.currency.get(chargeprice)))
		end
		
		self.user.onCharge = nil
		self.user = nil
		self.usedCharge = 0
	end
	
	function ENT:Think()
		if (self:getNetVar("active") and self.user and IsValid(self.user)) then
			dist = self.user:GetPos():Distance(self:GetPos())

			local chargeprice = math.Round(self.usedCharge * self.carePrice)

			if (dist > 64*1.5 or self.user:Health() >= self.user:GetMaxHealth() and 
				self.user:getChar():hasMoney(chargeprice)) then
				self:finishUse(self:getUsed() >= 1 or self.user:Health() >= self.user:GetMaxHealth())
				return
			end

			self.rechargeTime = CurTime() + self.restoreCool
		else
			if (!self.rechargeTime or self.rechargeTime < CurTime()) then
				self:setNetVar("used", math.Clamp(self:getUsed() - self.restoreCost * .8, 0, 1))
			end
		end

		self:NextThink(CurTime() + self.restoreRate)
		return true
	end

	function ENT:Use(client)
		if (!client.onCharge and !self.user and !IsValid(self.user) and self:getUsed() == 0 and client:Health() < client:GetMaxHealth()) then
			client.onCharge = true
			self.user = client
			self.user:notifyLocalized(Format("medicalCareStart"))
			self:setNetVar("active", true)
			self.loopSound:Play()
			self.loopSound:ChangeVolume(1, 0)
			self:EmitSound(self.useSound)

			timer.Create("ass_"..self:EntIndex(), 5, 0, function()
				if (self:getNetVar("active") and self.user and IsValid(self.user)) then
					self:setNetVar("active", false)
					self:setNetVar("used", 0)
				end
			end)
		else
			self:EmitSound(self.denySound)
		end
	end
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*8):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"popcornVendorName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"popcornVendorDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end