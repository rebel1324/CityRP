PLUGIN.name = "Doorbust"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gun Jesus have arrived."

nutDoorBust = nutDoorBust or {
	IsValid = function() return true end
}

if (CLIENT) then
	local oneEmitter
	netstream.Hook("nutDoorbustEffect", function(knobPos, dir, isDestroy)
		isDestroy = (isDestroy == 1)
		local pos = knobPos
		local scale = 2
		
		oneEmitter = ParticleEmitter(Vector(0, 0, 0))
		

		sound.Play(string.format("physics/metal/metal_solid_impact_bullet%s.wav", math.random(1, 4)), pos, 99, math.random(90, 110))
		sound.Play(string.format("physics/metal/metal_solid_impact_bullet%s.wav", math.random(1, 4)), pos, 99, math.random(90, 110))
		if (isDestroy) then
			sound.Play(string.format("weapons/fx/rics/ric%s.wav", math.random(1, 4)), pos, 99, math.random(90, 50))
		end

		local smoke
		smoke = oneEmitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + dir*10 + VectorRand()*2)
		smoke:SetVelocity(dir*22*scale)
		smoke:SetDieTime(math.Rand(.2,.1))
		smoke:SetStartAlpha(math.Rand(222,255))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(5,10)*scale)
		smoke:SetEndSize(math.random(10,15)*scale*(isDestroy and 2 or 1))
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetColor(88, 88, 88)
		smoke:SetGravity( Vector( 0, 0, 10 ) )
		smoke:SetAirResistance(11)

		local flare
		flare = oneEmitter:Add( "effects/yellowflare", pos + dir*7)
		flare:SetDieTime(math.Rand(.05,.1))
		flare:SetStartAlpha(math.Rand(222,155))
		flare:SetEndAlpha(0)
		flare:SetStartSize(0)
		flare:SetEndSize(math.random(10,15)*scale*(isDestroy and 2 or 1))
		flare:SetRoll(math.Rand(180,480))
		flare:SetRollDelta(math.Rand(-3,3))
		flare:SetColor(255,186,50)

		for i = 1, isDestroy and 5 or 3 do
			local spark
			spark = oneEmitter:Add("particle/rebel1324/sparks/spark2", pos)
			spark:SetVelocity(dir*1*scale + VectorRand() * (isDestroy and 5 or 2) * scale)
			spark:SetDieTime(math.Rand(0.01,.1))
			spark:SetStartAlpha(math.Rand(150,200))
			spark:SetEndAlpha(0)
			spark:SetStartSize(math.random(35,22))
			spark:SetEndSize(0)
			spark:SetStartLength(math.random(1,1))
			spark:SetEndLength(math.random(55,12))
			spark:SetColor(255,186,50)
			spark:SetAirResistance(0)
		end

		for i = 1, isDestroy and 20 or 5 do
			local spark
			spark = oneEmitter:Add("effects/spark", pos)
			spark:SetVelocity(dir*44*scale + VectorRand() * (isDestroy and 88 or 33) * scale)
			spark:SetDieTime(math.Rand(0.2, .5))
			spark:SetStartAlpha(math.Rand(150,200))
			spark:SetEndAlpha(0)
			spark:SetStartSize(math.random(3,2))
			spark:SetEndSize(math.random(4,3))
			spark:SetStartLength(math.random(5,11))
			spark:SetEndLength(0)
			spark:SetColor(255,186,50)
			spark:SetGravity(Vector(0, 0, -600))
			spark:SetAirResistance(0)
		end

		oneEmitter:Finish()
	end)
end

-- Door Helath
nutDoorBust.doorHealth = 512

-- Distance of where player can bust the door.
nutDoorBust.bustDistance = 128

function nutDoorBust:Damage(entity, damage)
	if (entity:isDoor()) then
		local mdl = entity:GetModel()

		if (mdl) then
			local inflictor = damage:GetInflictor()
			
			if (IsValid(inflictor)) then
				local dmgPos = damage:GetDamagePosition()
				local center = entity:GetPos()
				local inflictorPos = inflictor.GetShootPos and inflictor:GetShootPos() or inflictor:GetPos()
				local sourceDist = dmgPos:Distance(inflictorPos)

				if (sourceDist < self.bustDistance) then
					local bonePos = entity:GetBonePosition(1)
					local knobPos = bonePos or center + entity:GetRight() * -42 + entity:GetUp() * -5
					
					if (knobPos) then
						local dist = knobPos:Distance(dmgPos)

						if (dist < 8) then
							local curDamage = damage:GetDamage()
							curDamage = hook.Run("GetDoorDamage", entity, damage, curDamage) or curDamage

							local wep = inflictor:GetActiveWeapon()
							if (curDamage < 15 and !(IsValid(wep) and wep.ShotgunReload)) then return end

							entity.doorHealth = entity.doorHealth or nutDoorBust.doorHealth
							if (entity.blasted) then
								entity.doorHealth = nutDoorBust.doorHealth
								entity.blasted = false
							end

							entity.doorHealth = entity.doorHealth - curDamage
							local isDestroy = (entity.doorHealth < 0)
							local dir = inflictorPos - dmgPos
							dir:Normalize()

							if (isDestroy) then
								entity.blasted = true
								entity:blastDoor(dir * -30, 20, true)
			
								if (entity.fadeActivate) then -- isFadingdoor
									entity:fadeActivate()
									timer.Simple(5, function() if IsValid(entity) and entity.fadeActive then entity:fadeDeactivate() end end)
								end
							end

							-- This is to prevent shotgun effect spam. 
							-- You don't want to get like 12 different effects
							-- in very short amount of time ;)
							timer.Create("_H_I_D_E_Y_O_U_R_K_I_D_", 0, 1, function()
								netstream.Start(bonePos, "nutDoorbustEffect", knobPos, dir, isDestroy and 1 or 0)
							end)
						end
					end
				end
			end
		end
	end
end

hook.Add("EntityTakeDamage", nutDoorBust, nutDoorBust.Damage)