AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName = "Unarrest Baton"
	SWEP.Slot = 1
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Category = "Nutscript"
SWEP.Author = "Black Tea"
SWEP.Instructions = ""
SWEP.Purpose = ""
SWEP.Drop = false

SWEP.HoldType = "melee"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModelFOV = 47
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "melee"

SWEP.ViewTranslation = 4

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 7.5
SWEP.Primary.Delay = 0.7

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = Model("models/weapons/c_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.UseHands = true
SWEP.LowerAngles = Angle(15, -10, -20)

SWEP.FireWhenLowered = true

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Activated")
end

function SWEP:Precache()
	util.PrecacheSound("weapons/stunstick/stunstick_swing1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_swing2.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact1.wav")	
	util.PrecacheSound("weapons/stunstick/stunstick_impact2.wav")
	util.PrecacheSound("weapons/stunstick/spark1.wav")
	util.PrecacheSound("weapons/stunstick/spark2.wav")
	util.PrecacheSound("weapons/stunstick/spark3.wav")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	self:SetActivated(true)
end

function SWEP:PrimaryAttack()	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if (!self.Owner:isWepRaised()) then
		return
	end

	self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1, 2)..".wav", 70)
	self:SendWeaponAnim(ACT_VM_HITCENTER)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(1, 0, 0.125))

	self.Owner:LagCompensation(true)
		local data = {}
			data.start = self.Owner:GetShootPos()
			data.endpos = data.start + self.Owner:GetAimVector()*72
			data.filter = self.Owner
		local trace = util.TraceLine(data)
	self.Owner:LagCompensation(false)

	if (SERVER and trace.Hit) then
		self.Owner:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")

		local entity = trace.Entity

		if (IsValid(entity) and entity:IsPlayer()) then
			entity:arrest(false, self.Owner)
		end
	end
end

function SWEP:OnLowered()
	self:SetActivated(false)
end

function SWEP:Holster(nextWep)
	self:OnLowered()

	return true
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)

	if (!self.Owner:isWepRaised()) then
		return
	end

	self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1, 2)..".wav", 70)
	self:SendWeaponAnim(ACT_VM_HITCENTER)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(1, 0, 0.125))

	self.Owner:LagCompensation(true)
		local data = {}
			data.start = self.Owner:GetShootPos()
			data.endpos = data.start + self.Owner:GetAimVector()*72
			data.filter = self.Owner
		local trace = util.TraceLine(data)
	self.Owner:LagCompensation(false)

	if (SERVER and trace.Hit) then
		self.Owner:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")

		local entity = trace.Entity

		if (IsValid(entity) and entity:IsPlayer()) then
			entity:arrest(false, self.Owner)
		end
	end
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end