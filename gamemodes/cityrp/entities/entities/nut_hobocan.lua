AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Hobocan"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
--models/props/cs_assault/dollar

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_junk/MetalBucket01a.mdl")
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
			local smoke = WORLDEMITTER:Add( new, pos + self:GetUp()*6 + VectorRand()*4)
			smoke:SetVelocity(VectorRand() * math.random(30, 20) + self:GetUp()*100)
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

		-- 도둑을 위한 자리.
		if (false) then
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
			local money = 0

			nut.util.drawText(L("hoboCanOwner", nut.currency.get(money)), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end
