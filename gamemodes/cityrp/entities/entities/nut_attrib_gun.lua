AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Shooting Target"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/canister_propane01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.health = 2000

		local size = 8
		self:PhysicsInitBox( Vector( -size, -size, -0 ), Vector( size, size, 64 ) )
		self:SetCollisionBounds( Vector( -size, -size, -0 ), Vector( size, size, 64 ) )

		self:PhysWake()
	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0) then
			self.onbreak = true
			self:Remove()
		end

		local attacker = dmginfo:GetAttacker()

		if (attacker and attacker:IsValid() and attacker:IsPlayer()) then
			local weapon = attacker:GetActiveWeapon()

			if (weapon and weapon:IsValid() and weapon.recalculateStats) then
				if (attacker:getChar():getAttrib("gunskill") < 15) then
					attacker:getChar():updateAttrib("gunskill", 0.001)
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
	function ENT:Draw()
		if (!self.hola or !self.hola:IsValid()) then
			self.hola = ClientsideModel("models/props_c17/doll01.mdl", RENDERGROUP_BOTH)
			self.hola:SetColor(Color(255, 0, 0))
		end

		self.hola:SetModelScale(4,0)
		self.hola:SetRenderOrigin(self:GetPos() + self:GetUp()*30)
		self.hola:SetRenderAngles(self:GetAngles())
		self.hola:DrawModel()
	end

	function ENT:OnRemove()
		if (self.hola) then
			self.hola:Remove()
		end
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*25):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"gunBoosterName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"gunBoosterDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end
