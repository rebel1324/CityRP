PLUGIN.name = "Door Bust Charges"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "A Charge that can blow up the door."

if (CLIENT) then

	local muzzleMaterials = {}
	for i = 1, 8 do
		muzzleMaterials[i] = Material("effects/fas_muzzle" .. i .. ".png", "SpriteCard")
		muzzleMaterials[i]:SetInt("$additive", 1)
		muzzleMaterials[i]:SetInt("$translucent", 1)
		muzzleMaterials[i]:SetInt("$vertexcolor", 1)
		muzzleMaterials[i]:SetInt("$vertexalpha", 1)
	end

	local EFFECT = {}
	function EFFECT:Init( data ) 
		self:SetNoDraw(true)
		local pos = data:GetStart()	
		local scale = 3
		self.emitter = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

		for i = 0, 1 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
			smoke:SetVelocity(VectorRand()*20*scale)
			smoke:SetDieTime(math.Rand(.5,.3))
			smoke:SetStartAlpha(math.Rand(244,144))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5)*scale)
			smoke:SetEndSize(math.random(55,44)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(33, 33, 33)
			smoke:SetGravity( Vector( 0, 0, 20 ) )
			smoke:SetAirResistance(250)
		end

		for i = 0, 4 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
			smoke:SetVelocity(VectorRand()*150*scale)
			smoke:SetDieTime(math.Rand(.5,1))
			smoke:SetStartAlpha(math.Rand(222,122))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(11,22)*scale)
			smoke:SetEndSize(math.random(55,77)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(33, 33, 33)
			smoke:SetGravity( Vector( 0, 0, 20 ) )
			smoke:SetAirResistance(500)
		end

            local smoke = self.emitter:Add(nut.util.getMaterial("particle/Particle_Glow_04_Additive"), pos + VectorRand()*10)
            smoke:SetVelocity(VectorRand()*20*scale)
            smoke:SetDieTime(math.Rand(.1,.1))
            smoke:SetStartAlpha(math.Rand(33,66))
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(math.random(33,25)*scale)
            smoke:SetEndSize(math.random(100,88)*scale)
            smoke:SetRoll(math.Rand(180,480))
            smoke:SetRollDelta(math.Rand(-3,3))
            smoke:SetColor(255, 66, 111)
            smoke:SetGravity( Vector( 0, 0, 20 ) )
            smoke:SetAirResistance(250)
            
		for i = 0, 1 do
            local smoke = self.emitter:Add( muzzleMaterials[math.random(1, 8)], pos + VectorRand()*10)
            smoke:SetVelocity(VectorRand()*20*scale)
            smoke:SetDieTime(math.Rand(.1,.1))
            smoke:SetStartAlpha(math.Rand(255,200))
            smoke:SetEndAlpha(0)
            smoke:SetStartSize(math.random(33,25)*scale)
            smoke:SetEndSize(math.random(44,66)*scale)
            smoke:SetRoll(math.Rand(180,480))
            smoke:SetRollDelta(math.Rand(-3,3))
            smoke:SetColor(255, 200, 200)
            smoke:SetGravity( Vector( 0, 0, 20 ) )
            smoke:SetAirResistance(250)
        end

        self.nig = {}
		for i = 0, 15 do
			local smoke = self.emitter:Add(nut.util.getMaterial("effects/yellowflare"), pos + VectorRand()*20)
			smoke:SetVelocity(VectorRand()*100*scale)
			smoke:SetDieTime(math.Rand(.05,.09))
			smoke:SetStartAlpha(math.Rand(111,155))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(1,3)*scale)
			smoke:SetEndSize(0)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
		    smoke:SetColor(255, 200, 200)
			smoke:SetAirResistance(250)
            table.insert(self.nig, smoke)
		end
	end

    function EFFECT:Think()
        for k, v in ipairs(self.nig) do
            v:SetVelocity(VectorRand()*1900)
        end
    end

	effects.Register( EFFECT, "doorCharge" )
end