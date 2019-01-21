
ENT.Base = "nut_microwave"
ENT.PrintName = "Stove"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript"
ENT.isCooker = true
ENT.cookerModel = "models/props_c17/furnitureStove001a.mdl"
ENT.StorageInfo = {
	name = "stove",
	desc = "stoveDesc",
	invType = "grid",
	invData = {
		w = 2,
		h = 2
	}
}

if (SERVER) then
	function ENT:canCookThis(item)
        if (item.requireStove) then
            return true
        end
        
		return false
	end
else
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	local COLOR_ACTIVE = Color(0, 255, 0)
	local COLOR_INACTIVE = Color(255, 0, 0)

	function ENT:Initialize()
		self.emitter = ParticleEmitter(self:GetPos())
		self.nextEmit = 0
	end

	function ENT:DrawTranslucent()
		if (self:getNetVar("gone")) then
			if (self.nextEmit < CurTime()) then
				local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:GetPos() + self:OBBCenter() + self:GetRight() * -13)
				smoke:SetVelocity(Vector( 0, 0, 120))
				smoke:SetDieTime(math.Rand(0.2,1.3))
				smoke:SetStartAlpha(math.Rand(150,200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(4,14))
				smoke:SetEndSize(math.random(40,60))
				smoke:SetRoll(math.Rand(180,480))
				smoke:SetRollDelta(math.Rand(-3,3))
				smoke:SetColor(50,50,50)
				smoke:SetGravity( Vector( 0, 0, 120 ) )
				smoke:SetAirResistance(200)

				self.nextEmit = CurTime() + .1
			end
		end

		local position = self:GetPos() + self:GetForward() * -12 + self:GetUp() * 13 + self:GetRight() * -11.5

		render.SetMaterial(GLOW_MATERIAL)
		render.DrawSprite(position, 14, 14, self:getNetVar("active", false) and COLOR_ACTIVE or COLOR_INACTIVE)
	end
end