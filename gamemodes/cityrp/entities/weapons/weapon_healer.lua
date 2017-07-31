AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Healer";
	SWEP.Slot = 0;
	SWEP.SlotPos = 0;
	SWEP.CLMode = 0
end

SWEP.HoldType = "fists"

SWEP.Category = "Co-op"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_medkit.mdl"
SWEP.WorldModel = "models/weapons/w_medkit.mdl"

SWEP.ViewModelFOV	= 55
SWEP.Primary.Delay			= 1
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
 
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

SWEP.idlePosition, SWEP.idleAngle = Vector(-3.2, -2, -4), Angle(0, 0, 14)
SWEP.healPosition, SWEP.healAngle = Vector(0, 0, 0), Angle(0, 0, 0)

SWEP.denySound = Sound("items/medshotno1.wav")
SWEP.useSound = Sound("items/medshot4.wav")
SWEP.chargeSound = "items/medcharge4.wav"

SWEP.maxHeal = 100
function SWEP:SetupDataTables()
	self:NetworkVar("Int", 0, "Heal")
end

function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
	self.loopsound = CreateSound(self, self.chargeSound)

	if (CLIENT) then
		self.curPos, self.curAng = self.idlePosition, self.idleAngle
		self.percLerp = 0
	end

	timer.Create( "medkit_regen" .. self:EntIndex(), 1, 0, function()
		local client = self.Owner

		if (client and client:IsValid() and !client:KeyDown(IN_ATTACK)) then
			if (self:GetHeal() != self.maxHeal) then
				self:SetHeal(math.min(self:GetHeal() + 4, self.maxHeal))
			end
		end
	end )
end

function SWEP:Holster()
	self.loopsound:Stop()

	return true
end

function SWEP:OnRemove()
	timer.Stop( "medkit_regen" .. self:EntIndex() )
	self.loopsound:Stop()
end

function SWEP:Think()
	local bool = self.Owner:KeyDown(IN_ATTACK)

	if (bool) then

	end
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
end

function SWEP:PrimaryAttack()
end

function SWEP:Heal(target)
	local heal = self:GetHeal()
	local client = self.Owner

	if (heal > 0) then		
		local health = target:Health()
		local max = target:GetMaxHealth()
		if (health < max) then
			if (CLIENT) then
				if (!self.loopsound:IsPlaying()) then
					self:EmitSound(self.useSound)
				end
				self.loopsound:Play()
			end

			target:SetHealth(math.min(health + 1, max))
			self:SetHeal(math.max(heal - 1, 0))

			self:SetNextPrimaryFire(CurTime() + 0.1)
		else
			self:SetNextPrimaryFire(CurTime() + 0.9)

			if (CLIENT) then
				self.loopsound:Stop()
				self:EmitSound(self.denySound)
			end
		end
	else
		self:SetNextPrimaryFire(CurTime() + 0.9)

		if (CLIENT) then
			self.loopsound:Stop()
			self:EmitSound(self.denySound)
		end
	end
end

function SWEP:Think()
	local client = self.Owner
	local trace = client:GetEyeTrace()
	local entity = trace.Entity
	local dist = trace.HitPos:Distance(client:GetPos())

	self.target = (entity:IsValid() and entity:IsPlayer()) and entity or client

	if (client:KeyDown(IN_ATTACK) and self:GetNextPrimaryFire() < CurTime()) then
		if (!entity:IsValid()) then
			self:Heal(client)
		end

		if (dist < 80 and entity:IsValid() and entity:IsPlayer()) then
			self:Heal(entity)
		end
	end

	if (!client:KeyDown(IN_ATTACK)) then
		if (CLIENT) then
			if (self.loopsound:IsPlaying()) then
				self:EmitSound(self.denySound)
			end

			self.loopsound:Stop()
		end
	end
end

	
local reg = debug.getregistry()
local right = reg.Angle.Right
local up = reg.Angle.Up
local forward = reg.Angle.Forward
local rAngle = reg.Angle.RotateAroundAxis
local ea, ft
function SWEP:GetViewModelPosition(pos, ang)
	ea = EyeAngles()
	ft = FrameTime()

	self.curPos = LerpVector(ft*4, self.curPos, self.idlePosition)
	self.curAng = LerpAngle(ft*4, self.curAng, self.idleAngle)

	rAngle(ang, right(ang), self.curAng.x)
	rAngle(ang, up(ang), self.curAng.y)
	rAngle(ang, forward(ang), self.curAng.z)

	pos = pos + self.curPos.x * right(ang)
	pos = pos + self.curPos.y * forward(ang)
	pos = pos + self.curPos.z * up(ang)

	return pos, ang
end

if (CLIENT) then
	surface.CreateFont("MedFont", {
		font = "Arial",
		extended = true,
		size = 60,
		weight = 800,
		shadow = true,
	})

	surface.CreateFont("MedSubFont", {
		font = "Arial",
		extended = true,
		size = 22,
		weight = 500,
		shadow = true,
	})

	local gap = 4
	local perc = 0
	SWEP.dispPos, SWEP.dispAng = Vector(-6.5, -5, 0), Angle(0, 0, 0)
	local ft
	function SWEP:ViewModelDrawn(vm)
		ft = FrameTime()
		local pos, ang = vm:GetBonePosition(39)

		rAngle(ang, right(ang), self.dispAng.x)
		rAngle(ang, up(ang), self.dispAng.y)
		rAngle(ang, forward(ang), self.dispAng.z)

		pos = pos + self.dispPos.x * right(ang)
		pos = pos + self.dispPos.y * forward(ang)
		pos = pos + self.dispPos.z * up(ang)

		if (self.target and self.target:IsValid()) then
			cam.Start3D2D(pos, ang, .02)
				draw.SimpleText("MEDKIT", "MedFont", 0, -16, Color(255, 255, 255, alpha), 3, 4)
				draw.SimpleText("Target: " .. (self.target and self.target:Name()) or "", "MedSubFont", 2, -1, Color(255, 255, 255, alpha), 3, 4)

				local bw, bh = 410, 20
				local bx, by = 0, 0
				self.percLerp = Lerp(ft*5, self.percLerp, self:GetHeal() / self.maxHeal)
				local perc = self.percLerp

				surface.SetDrawColor(255, 255, 255, 15)
				surface.DrawRect(bx, by, bw, bh)
				surface.DrawOutlinedRect(bx, by, bw, bh)

				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(bx + gap, by + gap, (bw - gap*2)*perc, bh - gap*2)
			cam.End3D2D()
		end
	end
end
function SWEP:SecondaryAttack()
end
