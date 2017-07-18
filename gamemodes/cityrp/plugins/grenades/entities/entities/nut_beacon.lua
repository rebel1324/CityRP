ENT.Type = "anim"
ENT.PrintName = "Beacon"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript Throwable"
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.configLifetime = 30
ENT.configPayload = .7
ENT.configTable = 
{
	[1] = { Color( 255, 255, 50 ), "common/warning.wav" },
	[2] = { Color( 255, 50, 50 ), "HL1/fvox/beep.wav" },
	[3] = { Color( 50, 255, 50 ), "HL1/fvox/bell.wav" },
	[4] = { Color( 50, 50, 255 ), "HL1/fvox/blip.wav" },
}

function ENT:SpawnFunction(client, trace, className)
	if (!trace.Hit or trace.HitSky) then return end

	local spawnPosition = trace.HitPos + trace.HitNormal * 16

	local ent = ents.Create(className)
	ent:SetPos(spawnPosition)
	ent:Spawn()
	ent:Activate()

	return ent
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/Items/grenadeAmmo.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.lifetime = CurTime() + self.configLifetime
		self.payload = CurTime() + self.configLifetime * self.configPayload
		self:SetDTInt(0,math.random(1,4))
		self:SetDTBool(0,true)
		self:SetUseType(SIMPLE_USE)
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:OnRemove()
	end

	function ENT:Payload()
	end

	function ENT:Think()
		if self.payload < CurTime() then
			if self:GetDTBool(0) then
				self:SetDTBool(0,false)
				self:Payload()
			end
		end
		if self.lifetime < CurTime() then
			self:Remove()
		end
		return CurTime()
	end
	function ENT:Use(activator)
	end
else
	GLOBAL_BEACONS = GLOBAL_BEACONS or {}

	function ENT:Initialize()
		self.schema = self:GetDTInt(0)
		self.lifetime = CurTime() + self.configLifetime
		self.beep = 255

		GLOBAL_BEACONS[self:EntIndex()] = self
	end

	function ENT:OnRemove()
		GLOBAL_BEACONS[self:EntIndex()] = nil
	end
	
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:BeepLight()
		local firepos = self:GetPos() + ( self:GetUp() * 5 )
		local col = self.configTable[self.schema][1]
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = firepos
		dlight.r = col.r
		dlight.g = col.g
		dlight.b = col.b
		dlight.Brightness = 5
		dlight.Size = 128 
		dlight.Decay = 256
		dlight.DieTime = CurTime() + 0.5
	end

	function ENT:Think()
		if self:GetDTBool(0) then
			self.beep = self.beep - FrameTime()*500
			if self.beep <= 0 then
				self.beep = 255
				local snd = self.configTable[self.schema][2]
				local rnd = self.configTable[self.schema][3] or { 150, 150 }
				self:EmitSound( snd, 70, math.random(rnd[1], rnd[2]) )
				self:BeepLight()
			end
		else
			self.beep = 0
		end
	end

	function ENT:DrawTranslucent()
		if self:GetDTBool(0) then
			local firepos = self:GetPos() + ( self:GetUp() * 5 )
			local size = self.beep/5
			local col = self.configTable[self.schema][1]
			render.SetMaterial(GLOW_MATERIAL)
			render.DrawSprite(firepos, size, size, col )
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	if data.Speed > 50 then
		self.Entity:EmitSound( Format( "physics/metal/metal_grenade_impact_hard%s.wav", math.random( 1, 3 ) ) ) 
	end
	
	local impulse = -data.Speed * data.HitNormal * 0.1 + (data.OurOldVelocity * -0.6)
	phys:ApplyForceCenter(impulse)
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
