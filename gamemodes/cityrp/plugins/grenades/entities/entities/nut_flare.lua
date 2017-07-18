ENT.Type = "anim"
ENT.PrintName = "Flare"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript Throwable"
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.configLifetime = 150
ENT.configColor = Color( 255, 50, 50 )

if (SERVER) then
	function ENT:SpawnFunction(client, trace, className)
		if (!trace.Hit or trace.HitSky) then return end

		local spawnPosition = trace.HitPos + trace.HitNormal * 16

		local ent = ents.Create(className)
		ent:SetPos(spawnPosition)
		ent:Spawn()
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/Items/grenadeAmmo.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self.lifetime = CurTime() + self.configLifetime
		self:SetUseType(SIMPLE_USE)
		self.loopsound = CreateSound( self, "weapons/flaregun/burn.wav" )
		self.loopsound:Play()
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end
	function ENT:OnRemove()
		self.loopsound:Stop()
	end
	function ENT:Think()
		if self.lifetime < CurTime() then
			self:Remove()
		end
		if self:WaterLevel() > 0 then
			self:Remove()
		end
		return CurTime()
	end
	function ENT:Use(activator)
	end
else
	function ENT:Initialize()
		self.lifetime = CurTime() + self.configLifetime
		self.emitter = ParticleEmitter( self:GetPos() )
		self.emittime = CurTime()
	end
	function ENT:Think()
		local firepos = self:GetPos() + ( self:GetUp() * 5 )
		local dlight = DynamicLight(self:EntIndex())
		local perc = ( ( self.lifetime - CurTime() )/self.configLifetime )
		dlight.Pos = firepos
		dlight.r = self.configColor.r
		dlight.g = self.configColor.g
		dlight.b = self.configColor.b
		dlight.Brightness = 7
		dlight.Size = 512 * perc + math.sin( CurTime()*FrameTime()/2 )*10
		dlight.Decay = 1024
		dlight.DieTime = CurTime() + 0.1
	end
	
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		self:DrawModel()
	end
	function ENT:DrawTranslucent()
		local firepos = self:GetPos() + ( self:GetUp() * 5 )
		local perc = ( ( self.lifetime - CurTime() )/self.configLifetime )

		local size = 70 + math.sin( CurTime()*FrameTime()*5 ) * 50
		render.SetMaterial(GLOW_MATERIAL)
		render.DrawSprite(firepos, size * perc, size * perc, self.configColor )
			
		if self.emittime < CurTime() then
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos	)
			smoke:SetVelocity( self:GetUp()*400*math.Rand( .5, 1 )*perc )
			smoke:SetDieTime(math.Rand(1.3,3.3)*perc)
			smoke:SetStartAlpha(math.Rand(75,150))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(66,220)*perc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(50,50,50)
			smoke:SetGravity( Vector( 0, 0, 50 ) )
			smoke:SetAirResistance(150)

			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), firepos	)
			smoke:SetVelocity( self:GetUp()*250*math.Rand( .5, 1 )*perc )
			smoke:SetDieTime(math.Rand(0.6,2.3)*perc)
			smoke:SetStartAlpha(math.Rand(150,200))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5))
			smoke:SetEndSize(math.random(22,88)*perc)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(self.configColor.r,self.configColor.g,self.configColor.b)
			smoke:SetGravity( Vector( 0, 0, 50 ) )
			smoke:SetAirResistance(150)

			for i = 1, math.random( 1, 10 ) do
				local smoke = self.emitter:Add( "particle/rebel1324/sparks/spark", firepos )
				smoke:SetVelocity( ( self:GetUp()*math.Rand(.5,1) + self:GetForward()*math.Rand(-.2,.2)  + self:GetRight()*math.Rand(-.2,.2) ) * 10 * perc)
				smoke:SetDieTime(math.Rand(0.05,0.01))
				smoke:SetStartAlpha(math.Rand(150,200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(3,2))
				smoke:SetEndSize(math.random(4,3))
				smoke:SetStartLength(math.random(1,1))
				smoke:SetEndLength(math.random(5,22))
				smoke:SetColor(255,186,50)
				smoke:SetAirResistance(300)
			end

			self.emittime = CurTime() + .05
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
