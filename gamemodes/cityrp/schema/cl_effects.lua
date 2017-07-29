
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
function EFFECT:Init( data ) 
	self:SetNoDraw(true)

	local pos = data:GetOrigin()
	local scale = data:GetScale() or 1
	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
	self.emitter = WORLDEMITTER

	local smoke = self.emitter:Add("decals/flesh/blood1", pos)
	smoke:SetVelocity(Vector())
	smoke:SetDieTime(math.Rand(.1,.2))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(22)
	smoke:SetStartSize(math.random(3,5)*scale)
	smoke:SetEndSize(math.random(11,12)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))

	local smoke = self.emitter:Add("decals/blood_gunshot_decal", pos + VectorRand()*1)
	smoke:SetVelocity(Vector())
	smoke:SetDieTime(math.Rand(.1,.2))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(22)
	smoke:SetStartSize(math.random(3,5)*scale)
	smoke:SetEndSize(math.random(11,22)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))

	local smoke = self.emitter:Add("decals/blood_gunshot_decal", pos + VectorRand()*1)
	smoke:SetVelocity(Vector())
	smoke:SetDieTime(math.Rand(.15,.3))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(22)
	smoke:SetStartSize(math.random(3,5)*scale)
	smoke:SetEndSize(math.random(33,55)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))

	local smoke = self.emitter:Add("particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*2)
	smoke:SetVelocity(Vector())
	smoke:SetDieTime(math.Rand(.2, .4))
	smoke:SetStartAlpha(math.Rand(188,211))
	smoke:SetEndAlpha(0)
	smoke:SetStartSize(math.random(11,12)*scale)
	smoke:SetEndSize(math.random(33,44)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetColor(80, 10, 10)

	for i = 1, math.random(5, 8) do
		local smoke = self.emitter:Add("decals/blood_gunshot_decal", pos + VectorRand()*3)
		smoke:SetVelocity(VectorRand()*150)
		smoke:SetDieTime(math.Rand(.4,.5))
		smoke:SetStartAlpha(math.Rand(188,211))
		smoke:SetEndAlpha(155)
		smoke:SetStartSize(math.random(3,4)*scale)
		smoke:SetEndSize(math.random(1,1)*scale)
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetStartLength(math.Rand(22,14)*scale)
		smoke:SetEndLength(math.Rand(1,2))
		smoke:SetGravity(Vector( 0, 0, -600))
		smoke:SetAirResistance(50)
	end
end

effects.Register( EFFECT, "btBlood" )


local EFFECT = {}
function EFFECT:Init( data ) 
	self:SetNoDraw(true)
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local scale = data:GetScale() or 1
	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
	self.emitter = WORLDEMITTER
	local scol = 55

	local dang = dir:Angle()
	local a1= dang:Forward()
	local smi = 3
	dang:RotateAroundAxis(a1, math.random(10, 40))

	for i = 0, smi do
		dang:RotateAroundAxis(a1, 360/smi)

		local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
		smoke:SetVelocity(dang:Right()*math.random(250, 290)*scale)
		smoke:SetDieTime(math.Rand(.2,.4))
		smoke:SetStartAlpha(math.Rand(188,211))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(0,5)*scale)
		smoke:SetEndSize(math.random(55,66)*scale)
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetColor(scol, scol, scol)
		smoke:SetGravity( Vector( 0, 0, 20 ) )
		smoke:SetAirResistance(450)
	end

	local spi = 5 * math.max(scale, .5)
	for i = 0, spi do
		local mid = (math.max(spi, spi/2)/spi)
		local dang = dir:Angle()
		local a1, a2, a3 = dang:Right(), dang:Up(), dang:Forward()
		dang:RotateAroundAxis(a1, math.random(-66, 66))
		dang:RotateAroundAxis(a2, math.random(-66, 66))

		local adf = dang:Forward()
		local dt = a3:Dot(adf)
		local smoke = self.emitter:Add( "effects/spark", pos + VectorRand()*1)
		smoke:SetVelocity(adf*math.random(333, 355)*scale*mid*dt)
		smoke:SetDieTime(math.Rand(.1,.2))
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(0)
		smoke:SetEndLength(math.random(15, 25)*mid*dt)
		smoke:SetStartLength(math.random(5, 7)*dt)
		smoke:SetStartSize(math.random(4,5)*scale)
		smoke:SetEndSize(0)
		smoke:SetGravity( Vector(0, 0, -600)*.5 )
	end

	for i = 0, 3 do
		local dang = dir:Angle()
		local a1, a2 = dang:Right(), dang:Up()
		dang:RotateAroundAxis(a1, math.random(-15, 15))
		dang:RotateAroundAxis(a2, math.random(-15, 15))

		local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
		smoke:SetVelocity(dang:Forward()*math.random(600, 1500)*((i + 3)/(5 + 3))*scale)
		smoke:SetDieTime(math.Rand(.3,.6))
		smoke:SetStartAlpha(math.Rand(188,211))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(2,5)*scale)
		smoke:SetEndSize(math.random(44,55)*scale)
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetColor(scol, scol, scol)
		smoke:SetGravity( Vector( 0, 0, 20 ) )
		smoke:SetAirResistance(450)
	end

	/*
	local smoke = self.emitter:Add( "particle/Particle_Glow_04_Additive", pos + dir * 2 * scale)
	smoke:SetDieTime(math.Rand(.05,.1))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(0)
	smoke:SetStartSize(math.random(11,12)*scale)
	smoke:SetEndSize(math.random(55,88)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	*/

	local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + dir * 5)
	smoke:SetVelocity(dir*350*scale)
	smoke:SetDieTime(math.Rand(.07,.12))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(0)
	smoke:SetStartSize(math.random(22,33)*scale)
	smoke:SetEndSize(math.random(66,77)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetColor(scol*1.5, scol*1.5, scol*1.5)
	smoke:SetGravity( Vector( 0, 0, 20 ) )
	smoke:SetAirResistance(250)

	local smoke = self.emitter:Add( "effects/muzzleflash" .. math.random(1, 4), pos + VectorRand()*1)
	smoke:SetVelocity(dir*300*scale)
	smoke:SetDieTime(math.Rand(.05,.1))
	smoke:SetStartAlpha(255)
	smoke:SetEndAlpha(155)
	smoke:SetStartSize(math.random(5,8)*scale)
	smoke:SetEndSize(math.random(8,14)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetGravity( Vector( 0, 0, 20 ) )
	smoke:SetAirResistance(250)

	/*
	local smoke = self.emitter:Add( "particle/Particle_Glow_04_Additive", pos + dir * 1)
	smoke:SetVelocity(dir*400*scale)
	smoke:SetDieTime(math.Rand(.05,.1))
	smoke:SetStartAlpha(44)
	smoke:SetEndAlpha(11)
	smoke:SetStartSize(math.random(5,8)*scale)
	smoke:SetEndSize(math.random(44,55)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetGravity(Vector(0, 0, 20))
	smoke:SetColor(255, 200, 50)
	smoke:SetAirResistance(250)
	*/
	local smoke = self.emitter:Add( "effects/muzzleflash" .. math.random(1, 4), pos + dir * 6)
	smoke:SetVelocity(dir*300*scale)
	smoke:SetDieTime(math.Rand(.05,.1))
	smoke:SetStartAlpha(100)
	smoke:SetEndAlpha(0)
	smoke:SetStartSize(math.random(6,11)*scale)
	smoke:SetEndSize(math.random(12,16)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetGravity( Vector( 0, 0, 20 ) )
	smoke:SetAirResistance(250)
end

effects.Register( EFFECT, "btImpact" )


local EFFECT = {}
function EFFECT:Init( data ) 
	self:SetNoDraw(true)
	local pos = data:GetOrigin()
	local dir = data:GetNormal()
	local scale = data:GetScale() or 1
	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
	self.emitter = WORLDEMITTER
	local scol = 55

	local dang = dir:Angle()
	local a1= dang:Forward()
	local smi = 2
	dang:RotateAroundAxis(a1, math.random(10, 40))

	for i = 0, smi do
		dang:RotateAroundAxis(a1, 360/smi)

		local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
		smoke:SetVelocity(dang:Right()*math.random(250, 290)*scale)
		smoke:SetDieTime(math.Rand(.2,.4))
		smoke:SetStartAlpha(math.Rand(188,211))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(0,5)*scale)
		smoke:SetEndSize(math.random(55,66)*scale)
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetColor(scol, scol, scol)
		smoke:SetGravity( Vector( 0, 0, 20 ) )
		smoke:SetAirResistance(450)
	end

	local spi = 8 * math.max(scale, .5) * math.Rand(.8, 1)
	for i = 0, spi do
		local mid = (math.max(spi, spi/2)/spi)
		local dang = dir:Angle()
		local a1, a2, a3 = dang:Right(), dang:Up(), dang:Forward()
		dang:RotateAroundAxis(a1, math.random(-66, 66))
		dang:RotateAroundAxis(a2, math.random(-66, 66))

		local adf = dang:Forward()
		local dt = a3:Dot(adf)
		local smoke = self.emitter:Add( "effects/yellowflare", pos + VectorRand()*1)
		smoke:SetVelocity(adf*math.random(444, 666)*scale*mid*dt)
		smoke:SetDieTime(math.Rand(.1,.3))
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(0)
		smoke:SetEndLength(math.random(1, 2)*mid*dt)
		smoke:SetStartLength(math.random(8, 16)*dt)
		smoke:SetStartSize(math.random(8,12)*scale)
		smoke:SetEndSize(0)
		smoke:SetGravity(Vector(0, 0, -600)*1)
	end

	spi = 2 * math.max(scale, .5) * math.Rand(.8, 1)
	for i = 0, spi do
		local mid = (math.max(spi, spi/2)/spi)
		local dang = dir:Angle()
		local a1, a2, a3 = dang:Right(), dang:Up(), dang:Forward()
		dang:RotateAroundAxis(a1, math.random(-66, 66))
		dang:RotateAroundAxis(a2, math.random(-66, 66))

		local adf = dang:Forward()
		local dt = a3:Dot(adf)
		local smoke = self.emitter:Add( "effects/yellowflare", pos + VectorRand()*1)
		smoke:SetVelocity(adf*math.random(222, 444)*scale*mid*dt)
		smoke:SetDieTime(math.Rand(.5,1))
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(0)
		smoke:SetCollide(true)
		smoke:SetEndLength(math.random(1, 2)*mid*dt)
		smoke:SetStartLength(math.random(8, 16)*dt)
		smoke:SetStartSize(math.random(5,11)*scale)
		smoke:SetEndSize(0)
		smoke:SetGravity(Vector(0, 0, -600)*1)
	end

	/*
	local smoke = self.emitter:Add( "particle/Particle_Glow_04_Additive", pos + dir * 1)
	smoke:SetVelocity(dir*400*scale)
	smoke:SetDieTime(math.Rand(.05,.1))
	smoke:SetStartAlpha(44)
	smoke:SetEndAlpha(11)
	smoke:SetStartSize(math.random(5,8)*scale)
	smoke:SetEndSize(math.random(44,55)*scale)
	smoke:SetRoll(math.Rand(180,480))
	smoke:SetRollDelta(math.Rand(-3,3))
	smoke:SetGravity(Vector(0, 0, 20))
	smoke:SetColor(255, 255, 211)
	smoke:SetAirResistance(250)
	*/

	sound.Play("weapons/fx/rics/ric" .. math.random(1, 4) .. ".wav", pos, 50, math.random(90, 110))
end

effects.Register( EFFECT, "btMetal" )

local function DoStunEffect(Type)
    local toggle = tobool(Type:ReadString())
    if toggle then
        hook.Add("RenderScreenspaceEffects", "StunScreen", function()
            DrawMotionBlur(0.1,1,0)
            local modify = {}
            modify["$pp_colour_addr"] = 0
            modify["$pp_colour_addg"] = 0
            modify["$pp_colour_addb"] = 0
            modify["$pp_colour_brightness"] = 0
            modify["$pp_colour_contrast"] = 1
            modify["$pp_colour_colour"] = 0.8
            modify["$pp_colour_mulr"] = 0
            modify["$pp_colour_mulg"] = 0
            modify["$pp_colour_mulb"] = 0
            DrawColorModify(modify)
        end)
    elseif toggle == false then
        hook.Remove("RenderScreenspaceEffects", "StunScreen")
    end
end
usermessage.Hook("StunEffect", DoStunEffect)