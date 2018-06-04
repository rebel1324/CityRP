AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Weapon Checker"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 0)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/heracles421/metal_detector/metal_detector_small.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		self.trigger = ents.Create("nut_checker_trigger")
		self.trigger:SetTrigger(true)
		self.trigger:SetParent(self)
		self.trigger:Spawn()
		self.trigger:SetPos(self:GetPos() + self:GetUp()*40)
		self.trigger:SetAngles(self:GetAngles())

		timer.Simple(0, function()
			self.loopSound = CreateSound(self, "ambient/alarms/alarm1.wav")
		end)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end

	function ENT:OnRemove()
		self.loopSound:Stop()
		self.trigger:Remove()
	end

	function ENT:Popup(ent, sus)
		self:SetDTBool(0, true)
		self.loopSound:Play()

		timer.Create("chke"..self:EntIndex(), 5, 1, function()
			if (IsValid(self)) then
				self:SetDTBool(0, false)
				self.loopSound:Stop()
			end
		end)
	end
else
	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/props_c17/light_decklight01_off.mdl"
	MODEL.angle = Angle(0, 0, -90)
	MODEL.position = Vector(0, -24, 77)
	MODEL.scale = Vector(1, 1, 1)*.4
	ENT.modelData["light1"] = MODEL
	local MODEL = {}
	MODEL.model = "models/props_c17/light_decklight01_off.mdl"
	MODEL.angle = Angle(0, 0, 90)
	MODEL.position = Vector(0, 24, 77)
	MODEL.scale = Vector(1, 1, 1)*.4
	ENT.modelData["light2"] = MODEL

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:Initialize()
		self.models = {}
		
		for k, v in pairs(self.modelData) do
			self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
			self.models[k]:SetColor( v.color or color_white )
			self.models[k]:SetNoDraw(true)

			if (v.material) then
				self.models[k]:SetMaterial( v.material )
			end
		end
	end

	function ENT:OnRemove()
		for k, v in pairs(self.models) do
			if (v and v:IsValid()) then
				v:Remove()
			end
		end
	end

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		for uid, dat in pairs(self.modelData) do
			local drawEntity = self.models[uid]

			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = self:GetPos(), self:GetAngles()
				local ang2 = ang

				pos = pos + self:GetForward() * dat.position[1]
				pos = pos + self:GetRight() * dat.position[2]
				pos = pos + self:GetUp() * dat.position[3]

				ang:RotateAroundAxis(self:GetForward(), dat.angle[1])
				ang:RotateAroundAxis(self:GetRight(), dat.angle[2])
				ang:RotateAroundAxis(self:GetUp(), dat.angle[3])

				if (dat.scale) then
					local matrix = Matrix()
					matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
					drawEntity:EnableMatrix("RenderMultiply", matrix)
				end

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )
				drawEntity:DrawModel()

				local size = self:GetDTBool(0, false) and math.abs(math.sin(RealTime()*10)) * 32 or 32
				local color = self:GetDTBool(0, false) and Color( 255, 44, 44, 255 ) or Color( 44, 255, 44, 255 )
				pos = pos + ang:Forward() * 8
				pos = pos + ang:Right() * 0
				pos = pos + ang:Up() * 0

				render.SetMaterial(GLOW_MATERIAL)
				render.DrawSprite(pos, size, size, color)
			end
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
	end
end