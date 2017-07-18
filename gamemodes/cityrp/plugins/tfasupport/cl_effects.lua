
	-- EFFECT MODIFICATION
	timer.Simple(1, function()
		local META = FindMetaTable("CLuaEmitter")
		if not META then return end
		function META:DrawAt(pos, ang, fov)
			local pos, ang = WorldToLocal(EyePos(), EyeAngles(), pos, ang)
			
			cam.Start3D(pos, ang, fov)
				self:Draw()
			cam.End3D()
		end

		WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

		local EFFECT = {}

		local muzzleMaterials = {}
		for i = 1, 8 do
			muzzleMaterials[i] = Material("effects/fas_muzzle" .. i .. ".png", "SpriteCard")
			muzzleMaterials[i]:SetInt("$additive", 1)
			muzzleMaterials[i]:SetInt("$translucent", 1)
			muzzleMaterials[i]:SetInt("$vertexcolor", 1)
			muzzleMaterials[i]:SetInt("$vertexalpha", 1)
		end


		function EFFECT:FixedParticle()
			local function maxLife(min, max)
				return math.Rand(math.min(min, self.lifeTime), math.min(max or self.lifeTime, self.lifeTime)) * 1
			end	

			local p = self.emitter:Add("particle/smokesprites_000"..math.random(4,9), Vector(3, 0, 0))
			p:SetVelocity(222*Vector(1, 0, 0)*self.scale)
			p:SetDieTime(maxLife(.1, .2))
			p:SetStartAlpha(math.Rand(22,44))
			p:SetEndAlpha(0)
			p:SetStartSize(math.random(5,11)*self.scale)
			p:SetEndSize(math.random(33,55)*self.scale)
			p:SetRoll(math.Rand(180,480))
			p:SetRollDelta(math.Rand(-3,3))
			p:SetColor(150,150,150)
			p:SetGravity( Vector( 0, 0, 100 )*math.Rand( .2, 1 ) )
			
			local p = self.emitter:Add(muzzleMaterials[math.random(1, 4)], Vector(-5, 0, 0))
			p:SetVelocity(math.Rand(60, 80)*Vector(1, 0, 0)*(self.scale))
			p:SetDieTime(maxLife(.06, .02))
			p:SetStartAlpha(155)
			p:SetEndAlpha(0)
			if (self.ent.Owner == LocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer()) then
				p:SetStartSize(math.random(12,13)*self.scale)
				p:SetEndSize(math.random(33,55)*self.scale)
				p:SetStartLength(44*math.Rand(.9, 1.1)*self.scale)
				p:SetEndLength(99*math.Rand(.9, 1.1)*self.scale)
			else
				p:SetStartSize(math.random(11,22)*self.scale)
				p:SetEndSize(math.random(44,33)*self.scale)
				p:SetStartLength(44*math.Rand(.9, 1.1)*self.scale)
				p:SetEndLength(66*math.Rand(.9, 1.1)*self.scale)
			end
			p:SetRoll(math.Rand(180,480))
			p:SetColor(255,255,222 )
			p:SetRollDelta(math.Rand(-3,3))
			
			local p = self.emitter:Add(muzzleMaterials[math.random(1, 8)], Vector(3, 0, 0))
			p:SetVelocity(math.Rand(333, 444)*Vector(1, 0, 0)*(self.scale*2))
			p:SetDieTime(maxLife(.06, .02))
			p:SetStartAlpha(155)
			p:SetEndAlpha(0)
			p:SetStartSize(math.random(44,33)*self.scale/2)
			p:SetEndSize(math.random(11,22)*self.scale/2)
			p:SetRoll(math.Rand(180,480))
			p:SetColor(255,255,222 )
			p:SetRollDelta(math.Rand(-3,3))
		
			local p = self.emitter:Add("particle/Particle_Glow_04_Additive", Vector(3, 0, 0))
			p:SetVelocity(888*Vector(1, 0, 0)*self.scale)
			p:SetDieTime(maxLife(.02, .05))
			p:SetStartAlpha(math.Rand(61,99))
			p:SetEndAlpha(0)
			p:SetStartSize(math.random(22,33)*self.scale)
			p:SetEndSize(math.random(33,22)*self.scale)
			p:SetRoll(math.Rand(180,480))
			p:SetRollDelta(math.Rand(-3,3))
			p:SetColor(245,155,100 )
			p:SetGravity( Vector( 0, 0, 100 )*math.Rand( .2, 1 ) )

			self.daz = {}
			for i = 1, math.random( 1, 2 ) do
				local smoke = self.emitter:Add( "effects/yellowflare", Vector(3, 0, 0))
				self.daz[i] = smoke
				
				smoke:SetVelocity(1*Vector(math.Rand(0, 5), math.Rand(-25, 25), math.Rand(-25, 25))*self.scale)
				smoke:SetDieTime(math.Rand(0.05,0.1))
				smoke:SetStartAlpha(math.Rand(22,133))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(1)
				smoke:SetEndSize(2)
				smoke:SetStartLength(math.random(0,1))
				smoke:SetEndLength(math.random(2,8))
				smoke:SetColor(255,255,220)
				smoke:SetGravity( Vector( 0, 0, -50 ) )
				smoke:SetAirResistance(300)
			end
		end
		
		function EFFECT:FreeParticle(at)
			local dir = self.dir
			
			local p = WORLDEMITTER:Add("particle/smokesprites_000"..math.random(4,9), self.origin + self.dir * 10)
			p:SetVelocity(133*dir*self.scale)
			p:SetDieTime(math.Rand(.1, .2))
			p:SetStartAlpha(math.Rand(11,99))
			p:SetEndAlpha(0)
			p:SetStartSize(math.random(14,15)*self.scale)
			p:SetEndSize(math.random(33,24)*self.scale)
			p:SetRoll(math.Rand(180,480))
			p:SetRollDelta(math.Rand(-3,3))
			p:SetColor(150,150,150)
			p:SetAirResistance(100)
			p:SetGravity( Vector( 0, 0, 22 )*math.Rand( .2, 1 ) )
			
			local snum = 3
			for i = 1, snum do
				local p = WORLDEMITTER:Add("particle/smokesprites_000"..math.random(4,9), self.origin + self.dir*snum)
				p:SetVelocity(333*dir*self.scale)
				p:SetDieTime(math.min(math.Rand(.1, .04) * (snum - i), 1))
				p:SetStartAlpha(math.Rand(22,76))
				p:SetEndAlpha(0)
				p:SetStartSize(math.random(4,7)*self.scale)
				p:SetEndSize(math.random(11,2)*self.scale)
				p:SetRoll(math.Rand(180,480))
				p:SetRollDelta(math.Rand(-1,1))
				p:SetColor(150,150,150)
				p:SetAirResistance(550)
				p:SetGravity( Vector( 0, 0, 100 )*math.Rand( .2, 1 ) )
			end
			
		end

		WEAPONEMITTER = ParticleEmitter(Vector(0, 0, 0))
		function EFFECT:Init(data)
			self.ent = data:GetEntity()
			self.scale = math.Rand(.35, 1.3)
			self.origin = data:GetOrigin()
			self.dir = data:GetNormal()
			self.muzPattern = data:GetMagnitude() or 0
			self.lifeTime = .2
			if (self.ent.Akimbo) then
				self.att = 2 - (game.SinglePlayer() and self.ent:GetNW2Int("AnimCycle",1) or self.ent.AnimCycle)
			else
				self.att = data:GetAttachment()
			end
			
			self.origin = self:GetTracerShootPos(self.origin, self.ent, self.att)
			self.decayTime = CurTime() + 1
			
			if (self.ent.Owner == LocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer()) then
				self.scale = self.scale * math.Rand(.5, 1) * (self.ent.viewScale or 1)
				self.ent = LocalPlayer():GetViewModel()
			else
				self.scale = self.scale * (self.ent.worldScale or 1)
			end

			self.emitter = self.ent.emitter

			WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
			self.freeEmitter = WORLDEMITTER

			self:FreeParticle()
			self:FixedParticle()
		end		

		function EFFECT:Render()
		end

		function EFFECT:Think()
			if (self.decayTime < CurTime()) then
				return false
			end

		
			for _, p in ipairs(self.daz) do
				p:SetVelocity(55*Vector(math.Rand(3, 10), math.Rand(-5, 5), math.Rand(-5, 5))*self.scale)
			end

			return true
		end
		
		effects.Register(EFFECT, "tfa_muzzleflash_generic")
		effects.Register(EFFECT, "tfa_muzzleflash_rifle")
		effects.Register(EFFECT, "tfa_muzzleflash_rifle_p")
		effects.Register(EFFECT, "tfa_muzzleflash_shotgun")
		effects.Register(EFFECT, "tfa_muzzleflash_pistol")
		effects.Register(EFFECT, "tfa_muzzleflash_smg")
		effects.Register(EFFECT, "tfa_muzzleflash_sniper")
		effects.Register(EFFECT, "tfa_muzzleflash_revolver")


		local angleVel = Vector(0, 0, 0)
		local shellMins, shellMaxs = Vector(-0.5, -0.15, -0.5), Vector(0.5, 0.15, 0.5)

		local shellSounds = {
			["CW_SHELL_MAIN"] =  {"player/pl_shell1.wav", "player/pl_shell2.wav", "player/pl_shell3.wav"},
			["CW_SHELL_SMALL"] =  {"player/pl_shell1.wav", "player/pl_shell2.wav", "player/pl_shell3.wav"},
			["CW_SHELL_SHOT"] = {"weapons/fx/tink/shotgun_shell1.wav", "weapons/fx/tink/shotgun_shell2.wav", "weapons/fx/tink/shotgun_shell3.wav"},
		}
		local shellModel = {
			["CW_SHELL_MAIN"] = "models/weapons/rifleshell.mdl",
			["CW_SHELL_SMALL"] =  "models/weapons/shell.mdl",
			["CW_SHELL_SHOT"] = "models/weapons/Shotgun_shell.mdl",
		}

		local EFFECT = {}
			local bvec = Vector(0, 0, 0)
			local uAng = Angle(90, 0, 0)

			function EFFECT:Init(data)
				self.Position = bvec
				self.WeaponEnt = data:GetEntity()
				if not IsValid(self.WeaponEnt) then return end
				self.WeaponEntOG = self.WeaponEnt
				self.Attachment = data:GetAttachment()
				self.Dir = data:GetNormal()
				local owent = self.WeaponEnt.Owner or self.WeaponEnt:GetOwner()

				if not IsValid(owent) then
					owent = self.WeaponEnt:GetParent()
				end

				if IsValid(owent) and owent:IsPlayer() then
					if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
						self.WeaponEnt = owent:GetActiveWeapon()
						if not IsValid(self.WeaponEnt) then return end
					else
						self.WeaponEnt = owent:GetViewModel()
						local theirweapon = owent:GetActiveWeapon()

						if IsValid(theirweapon) and theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped then
							self.Flipped = true
						end

						if not IsValid(self.WeaponEnt) then return end
					end
				end

				if IsValid(self.WeaponEntOG) and self.WeaponEntOG.ShellAttachment then
					self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.ShellAttachment)

					if not self.Attachment or self.Attachment <= 0 then
						self.Attachment = 2
					end

					if self.WeaponEntOG.Akimbo then
						self.Attachment = 4 - ( game.SinglePlayer() and self.WeaponEntOG:GetNW2Int("AnimCycle",1) or self.WeaponEntOG.AnimCycle )
					end

					if self.WeaponEntOG.ShellAttachmentRaw then
						self.Attachment = self.WeaponEntOG.ShellAttachmentRaw
					end
				end

				local angpos = self.WeaponEnt:GetAttachment(self.Attachment)

				if not angpos or not angpos.Pos then
					angpos = {
						Pos = bvec,
						Ang = uAng
					}
				end

				if self.Flipped then
					local tmpang = (self.Dir or angpos.Ang:Forward()):Angle()
					local localang = self.WeaponEnt:WorldToLocalAngles(tmpang)
					localang.y = localang.y + 180
					localang = self.WeaponEnt:LocalToWorldAngles(localang)
					--localang:RotateAroundAxis(localang:Up(),180)
					--tmpang:RotateAroundAxis(tmpang:Up(),180)
					self.Dir = localang:Forward()
				end

				-- Keep the start and end Pos - we're going to interpolate between them
				self.Pos = self:GetTracerShootPos(angpos.Pos, self.WeaponEnt, self.Attachment)
				self.Norm =  angpos.Ang:Forward()
				
				self.Magnitude = data:GetMagnitude()
				self.Scale = data:GetScale()

				velocity = self.Norm or Vector(0, 0, 1)
				velocity.x = velocity.x + math.Rand(-.3, .3)
				velocity.y = velocity.y + math.Rand(-.3, .3)
				velocity.z = velocity.z + math.Rand(-.3, .3)
				velocity = velocity * math.random(170,150) 

				time = time or 0.5
				removetime = removetime or 5
				
				local t = self.WeaponEntOG.shell or "CW_SHELL_MAIN" -- default to the 'mainshell' shell type if there is none defined

				local ent = ClientsideModel(shellModel[t], RENDERGROUP_BOTH) 
				ent:SetPos(self.Pos)
				ent:PhysicsInitBox(shellMins, shellMaxs)
				ent:SetAngles(ang + AngleRand())
				ent:SetModelScale((self.Scale*.9 or .7), 0)
				ent:SetMoveType(MOVETYPE_VPHYSICS) 
				ent:SetSolid(SOLID_VPHYSICS) 
				ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				
				local phys = ent:GetPhysicsObject()
				phys:SetMaterial("gmod_silent")
				phys:SetMass(10)
				phys:SetVelocity(velocity)
				
				angleVel.x = math.random(-500, 500)
				angleVel.y = math.random(-500, 500)
				angleVel.z = math.random(-500, 500)
				
				phys:AddAngleVelocity(ang:Right() * 100 + angleVel + VectorRand()*50000)

				timer.Simple(time, function()
					if table.Random(shellSounds[t]) and IsValid(ent) then
						sound.Play(table.Random(shellSounds[t]), ent:GetPos())
					end
				end)
				
				SafeRemoveEntityDelayed(ent, removetime)
			end

			function EFFECT:Think()
				return false
			end

			function EFFECT:Render()
			end
		effects.Register(EFFECT, "tfa_shell")

		local EFFECT = {}
		function EFFECT:Init()
		end
		function EFFECT:Render()
		end
		effects.Register(EFFECT, "tfa_muzzlesmoke")
		effects.Register(EFFECT, "tfa_shelleject_smoke")
	end)