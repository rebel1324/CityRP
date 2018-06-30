AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Hobocan"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.donateAmount = 1000
--models/props/cs_assault/dollar

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Money")
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/MetalBucket02a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.health = 100

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0) then
			self.onbreak = true
			self:Remove()
		end
	end

	function ENT:Use(client)
		local owner = self:CPPIGetOwner()

		if (IsValid(owner)) then
			if (client == owner) then
				if (client.nextDonation and client.nextDonation > CurTime()) then return end

				local char = owner:getChar()

				if (char) then
					char:giveMoney(self:GetMoney())
					client:notifyLocalized("moneyTaken", nut.currency.get(self:GetMoney()))
					self:SetMoney(0)

					self:EmitSound("suitchargeok1.wav")

					client.nextDonation = CurTime() + 1
				end
			else
				if (client.nextDonation and client.nextDonation > CurTime()) then return end

				local char = client:getChar()

				if (char and char:hasMoney(self.donateAmount)) then
					client:notifyLocalized("donatedHobo", nut.currency.get(self.donateAmount))

					char:giveMoney(-self.donateAmount)
					self:SetMoney(self:GetMoney() + self.donateAmount)
					self:EmitSound("ambient/levels/labs/coinslot1.wav")

					client.nextDonation = CurTime() + .25
				end
			end
		end
	end

	function ENT:OnRemove()
	end

	function ENT:setHealth(amount)
		self.health = amount
	end
else
	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:Draw()
		if (!self.nextEmit or self.nextEmit < CurTime()) then
			local pos = self:GetPos()
			local new = nut.util.getMaterial("icon16/money.png")
			local smoke = WORLDEMITTER:Add( new, pos + self:GetUp()*6 + VectorRand()*8)
			smoke:SetVelocity(self:GetUp()*20)
			smoke:SetDieTime(math.Rand(.2,.4))
			smoke:SetStartAlpha(math.Rand(188,211))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(2)
			smoke:SetEndSize(2)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetGravity( Vector( 0, 0, -200 ) )
			smoke:SetAirResistance(500)

			self.nextEmit = CurTime() + .05
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:canSeeContent(client)
		if (self:CPPIGetOwner() == client) then
			return true
		end

		return false
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*16):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"hoboCanName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"hoboCanDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		if (self:canSeeContent(LocalPlayer())) then
			local money = self:GetMoney()

			nut.util.drawText(L("hoboCanOwner", nut.currency.get(money)), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end
