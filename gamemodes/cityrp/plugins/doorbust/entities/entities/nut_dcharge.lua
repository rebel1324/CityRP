AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Doorbust Charge"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript - Weapons"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.radius = 32
ENT.burstTime = 5
ENT.doorRestore = 300

function ENT:SpawnFunction(client, trace, className)
	if (!trace.Hit or trace.HitSky) then return end

	local spawnPosition = trace.HitPos + trace.HitNormal * 16

	local ent = ents.Create(className)
	local target = trace.Entity

	if (target and IsValid(target)) then
		local angles = trace.HitNormal:Angle()
		local axis = Angle(angles[1], angles[2], angles[3])
		angles:RotateAroundAxis(axis:Right(), 90)
		ent:SetParent(target)
		ent:SetPos(spawnPosition - trace.HitNormal*13)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:ManipulateBoneScale(0, Vector(1, 1, 1)*.5)
	end
	
	return ent
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_c17/consolebox05a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetDTBool(0,true)
		self:SetUseType(SIMPLE_USE)
		self.lifetime = CurTime() + self.burstTime
		self:EmitSound("buttons/button5.wav")

		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:Explode()
		self:EmitSound("ambient/explosions/explode_1.wav", 120, 200)

		local doors = ents.FindInSphere(self:GetPos(), self.radius)
		for k, v in ipairs(doors) do
			if (v:isDoor()) then
				local dir = v:GetPos() - self:GetPos()
				dir:Normalize()
				v:blastDoor(dir * 300, 20, true)
			end

			if (v.fadeActivate) then -- isFadingdoor
		        v:fadeActivate()
		        timer.Simple(5, function() if IsValid(v) and v.fadeActive then v:fadeDeactivate() end end)
		    end
		end

		local e = EffectData()
		e:SetStart(self:GetPos() + self:OBBCenter())
		util.Effect( "doorCharge", e )
	end

	function ENT:OnRemove()
	end

	function ENT:Think()
		if self.lifetime < CurTime() then
			self:Explode()
			self:Remove()
		end

		return CurTime()
	end
	function ENT:Use(activator)
	end
else
	function ENT:Initialize()
		self.schema = self:GetDTInt(0)
		self.lifetime = CurTime() + self.burstTime
		self.beep = 255
	end
	
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:BeepLight()
		local firepos = self:GetPos() + ( self:GetUp() * 5 )
		local col = Color(255, 0, 0)
		local dlight = DynamicLight(self:EntIndex())
		dlight.Pos = firepos
		dlight.r = col.r
		dlight.g = col.g
		dlight.b = col.b
		dlight.Brightness = 2
		dlight.Size = 64 
		dlight.Decay = 512
		dlight.DieTime = CurTime() + 0.5
	end

	function ENT:Think()
		if self:GetDTBool(0) then
			local burst = self.burstTime + (CurTime() - self.lifetime)
			self.beep = self.beep - FrameTime()*450*burst

			if self.beep <= 0 then
				self.beep = 255
				local snd = "common/warning.wav"
				local rnd = { 150, 150 }
				self:EmitSound( snd, 70, math.random(rnd[1], rnd[2]) )
				self:BeepLight()
			end
		else
			self.beep = 0
		end
	end

	function ENT:DrawTranslucent()
		if self:GetDTBool(0) then
			local firepos = self:GetPos() - ( self:GetUp() * 2 )
			local size = math.Clamp(self.beep/10, 0, 40)
			local col = Color(255, 0, 0)

			render.SetMaterial(GLOW_MATERIAL)
			render.DrawSprite(firepos, size, size, col )
		end
	end
end