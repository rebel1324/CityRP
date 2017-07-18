AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Punchbag"
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
		self.health = 1800

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

			if (weapon and weapon:IsValid() and weapon:GetClass() == "nut_hands") then
				attacker:getChar():updateAttrib("str", 0.005)
			end
		end


		local effectdata = EffectData()
		effectdata:SetOrigin( self:LocalToWorld(self:OBBCenter()) + self:GetUp()*25 )
		effectdata:SetStart( Vector( 255, 255, 255 ) )
		util.Effect( "balloon_pop", effectdata )
	end

	function ENT:OnRemove()
	end

	function ENT:setHealth(amount)
		self.health = amount
	end
else
	function ENT:Draw()
		if (!self.hola or !self.hola:IsValid()) then
			self.hola = ClientsideModel("models/props_lab/huladoll.mdl", RENDERGROUP_BOTH)
		end

		self.hola:SetModelScale(10,0)
		self.hola:SetRenderOrigin(self:GetPos())
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

		nut.util.drawText(L"strBoosterName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"strBoosterDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end
