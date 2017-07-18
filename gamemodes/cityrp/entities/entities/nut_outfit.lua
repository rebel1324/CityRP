AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Outfitter"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Server"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_wasteland/controlroom_storagecloset001b.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.health = 100

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:OnRemove()
	end

	local fuckoff = CurTime()
	function ENT:Use(client)
		if (fuckoff and fuckoff > CurTime()) then return end
		fuckoff = CurTime() + 1
		netstream.Start(client, "nutOutfitShow")
	end
else
	netstream.Hook("nutOutfitShow", function()
		vgui.Create("nutOutfit")
	end)

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")

	function ENT:Draw()

		if (!self.nextEmit or self.nextEmit < CurTime()) then
			local pos = self:GetPos()
			local new = GLOW_MATERIAL
			for i = 1, 2 do
				local vc1, vc2 = self:GetRenderBounds()
				local randPos = Vector(math.random(vc1.x, vc2.x), math.random(vc1.y, vc2.y), math.random(vc1.z, vc2.z))
				local smoke = WORLDEMITTER:Add( new, pos + randPos)
				smoke:SetVelocity(randPos * math.random(2, 4))
				smoke:SetDieTime(math.Rand(.2,.4))
				smoke:SetStartAlpha(math.Rand(188,211))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(2)
				smoke:SetEndSize(2)
				smoke:SetRoll(math.Rand(180,480))
				smoke:SetRollDelta(math.Rand(-3,3))
				smoke:SetGravity( Vector( 0, 0, -200 ) )
				smoke:SetAirResistance(500)
			end
			self.nextEmit = CurTime() + .05
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*16):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"outfitterName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"outfitterDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)

	end
end