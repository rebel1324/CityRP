AddCSLuaFile()

local TAZE_TIME = nut.config.get("tazeTime")

if (CLIENT) then
	SWEP.PrintName = "Taser"
	SWEP.Slot = 2
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Category = "Nutscript"
SWEP.Author = "AngryBaldMan"
SWEP.Instructions = ""
SWEP.Purpose = ""
SWEP.Drop = false

SWEP.ViewModelFlip = false
SWEP.Primary.ClipSize = 0
SWEP.Primary.Ammo = ""
SWEP.Secondary.ClipSize = 0
SWEP.Secondary.Ammo = ""

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = Model("models/weapons/c_pistol.mdl")
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.IconLetter = ""

SWEP.ViewModel = "models/weapons/c_pistol.mdl"
SWEP.UseHands = true

function SWEP:Initialize()
	self:SetHoldType("pistol")
end

function SWEP:PrimaryAttack()
	
	self.Owner:LagCompensation(true)
	local trace = self.Owner:GetEyeTrace()
	self.Owner:LagCompensation(false)

	if not IsValid(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 400) or (not trace.Entity:IsPlayer()) then
		self:SetNextPrimaryFire(CurTime() + 2)
		return
	end

	self.Weapon:EmitSound("Weapon_StunStick.Activate")
	self.BaseClass.ShootEffects(self)

	if SERVER then
		
		if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:getChar():getClass() == CLASS_POLICE then
			self.Owner:notify("You can't taze other cops!")
			return
		end
	
		self.Owner:notify("You have stunned someone!")
		trace.Entity:setAction("Unstunning", TAZE_TIME)
		
		self.Weapon:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")
		
		trace.Entity:Freeze(true)
		trace.Entity:setAction("Unstunning", TAZE_TIME)
		trace.Entity:notify("You have been stunned!")
		trace.Entity:Stun()
		timer.Simple(nut.config.get("tazeTime"), function() 
		trace.Entity:Freeze(false)
		trace.Entity:Unstun()
		end)
	end
	self:SetNextPrimaryFire(CurTime() + 5)
end

function SWEP:SecondaryAttack()

	self.Owner:LagCompensation(true)
	local trace = self.Owner:GetEyeTrace()
	self.Owner:LagCompensation(false)

	if not IsValid(trace.Entity) or (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 400) or (not trace.Entity:IsPlayer()) then
		self:SetNextPrimaryFire(CurTime() + 2)
		return
	end

	self.Weapon:EmitSound("Weapon_StunStick.Activate")
	self.BaseClass.ShootEffects(self)

	if SERVER then
		
		if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:getChar():getClass() == CLASS_POLICE then
			self.Owner:notify("You can't taze other cops!")
			return
		end

	
	self.Owner:notify("You have tased someone unconcious!")
	trace.Entity:ConCommand( "say /fallover " .. nut.config.get("tazeTime") )
	trace.Entity:notify("You have been tased unconcious!")
	end
end