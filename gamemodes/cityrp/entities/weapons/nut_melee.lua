AddCSLuaFile()
-- stealing code 2017
DEFINE_BASECLASS( "weapon_base" )

if ( SERVER ) then

  SWEP.Weight         = 5
  SWEP.AutoSwitchTo   = false
  SWEP.AutoSwitchFrom = false
end



if ( CLIENT ) then
  SWEP.PrintName        = "Melee"
  SWEP.Slot             = 0
  SWEP.SlotPos          = 0
  SWEP.DrawAmmo         = false
  SWEP.DrawCrosshair    = true
  SWEP.ViewModelFOV     = 65
  SWEP.ViewModelFlip    = false
  SWEP.CSMuzzleFlashes  = true
  SWEP.UseHands         = true
  SWEP.ViewModelFlip    = false
 
end

SWEP.Category              = "CS:GO Knives"

SWEP.Spawnable             = false
SWEP.AdminSpawnable        = false

--SWEP.ViewModel           = "models/weapons/v_csgo_default.mdl"
--SWEP.WorldModel          = "models/weapons/W_csgo_default.mdl"

SWEP.DrawWeaponInfoBox     = false

SWEP.Weight                = 5
SWEP.AutoSwitchTo          = false
SWEP.AutoSwitchFrom        = false

SWEP.Primary.ClipSize		  = -1
SWEP.Primary.Damage			  = -1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "none"


SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage      = -1
SWEP.Secondary.Automatic   = true
SWEP.Secondary.Ammo        = "none"

function SWEP:SetupDataTables()
  self:NetworkVar( "Float", 1, "IdleTime" )
end

function SWEP:Initialize()
  self:SetHoldType(self.HoldType or "melee")
end

function SWEP:DrawWorldModel()
	self:DrawModel()
end

function SWEP:Deploy()
  self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
  self.Weapon:SetNextPrimaryFire( CurTime() + 1 )
  self.Weapon:SetNextSecondaryFire( CurTime() + 1 )
  return true
end

function SWEP:EntityFaceBack(ent)
  local angle = self.Owner:GetAngles().y -ent:GetAngles().y
  if angle < -180 then angle = 360 +angle end
  if angle <= 90 and angle >= -90 then return true end

  return false
end

function SWEP:SecondaryAttack()
	self.Owner:LagCompensation(true)
		local data = {}
			data.start = self.Owner:GetShootPos()
			data.endpos = data.start + self.Owner:GetAimVector()*72
			data.filter = self.Owner
			data.mins = Vector(-8, -8, -30)
			data.maxs = Vector(8, 8, 10)
		local trace = util.TraceHull(data)
		local entity = trace.Entity
	self.Owner:LagCompensation(false)

	local viewModel = self.Owner:GetViewModel()
	
	if (SERVER and IsValid(entity)) then
		local pushed

		if (entity:isDoor()) then
			if (hook.Run("PlayerCanKnock", self.Owner, entity) == false) then
				return
			end

			self.Owner:ViewPunch(Angle(-1.3, 1.8, 0))
			self.Owner:EmitSound("physics/plastic/plastic_box_impact_hard"..math.random(1, 4)..".wav")	
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			self:SetNextSecondaryFire(CurTime() + 0.4)
			self:SetNextPrimaryFire(CurTime() + 1)
		elseif (entity:IsPlayer()) then
			local direction = self.Owner:GetAimVector() * (300 + (self.Owner:getChar():getAttrib("str", 0) * 3))
			direction.z = 0

			entity:SetVelocity(direction)

			pushed = true
		else
			local physObj = entity:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:SetVelocity(self.Owner:GetAimVector() * 180)
			end

			pushed = true
		end

		if (pushed) then
			self:SetNextSecondaryFire(CurTime() + 1.5)
			self:SetNextPrimaryFire(CurTime() + 1.5)
			self.Owner:EmitSound("weapons/crossbow/hitbod"..math.random(1, 2)..".wav")

			local model = string.lower(self.Owner:GetModel())
			local owner = self.Owner

			if (nut.anim.getModelClass(model) == "metrocop") then
				self.Owner:forceSequence("pushplayer")
			end
		end
	end
end


function SWEP:DoPunchAnimation()
	local viewModel = self.Owner:GetViewModel()

	if (IsValid(viewModel)) then
		viewModel:SetPlaybackRate(1)
			viewModel:SetSequence( 0 )
		timer.Simple(0, function()
			viewModel:SetSequence( 1 )
		end)
	end
end

function SWEP:PrimaryAttack( Altfire )
	if (hook.Run("CanPlayerThrowPunch", self.Owner) == false) then
		return
	end
	

	local staminaUse = nut.config.get("punchStamina")

	if (staminaUse > 0) then
		local value = self.Owner:getLocalVar("stm", 0) - (self.Primary.Stamina or 17)

		if (value < 0) then
			return
		elseif (SERVER) then
			self.Owner:setLocalVar("stm", value)
		end
	end

	if (SERVER) then
		self.Owner:EmitSound("npc/vort/claw_swing"..math.random(1, 2)..".wav")
	end
	
	local damage = self.Primary.Damage
	local delay = self.Primary.Delay or 0.5
	local context = {delay = delay, damage = damage}
	local result = hook.Run("PlayerGetMeleeDelay", self.Owner, delay, context)

	if (result != nil) then
		delay = result
	else
		delay = context.delay
	end
			
	self:SetNextPrimaryFire(CurTime() + delay)
	self:DoPunchAnimation()

	self.Owner:SetAnimation(PLAYER_ATTACK1)

	timer.Simple(0.15, function()
		if (IsValid(self) and IsValid(self.Owner)) then
			self.Owner:ViewPunch(Angle(2, 5, 0.125))
			local result = hook.Run("PlayerGetMeleeDamage", self.Owner, damage, context)

			if (result != nil) then
				damage = result
			else
				damage = context.damage
			end

			self.Owner:LagCompensation(true)
				local data = {}
					data.start = self.Owner:GetShootPos()
					data.endpos = data.start + self.Owner:GetAimVector()*96
					data.filter = self.Owner
				local trace = util.TraceLine(data)

				if (SERVER and trace.Hit) then
					local entity = trace.Entity

					if (IsValid(entity)) then
						local damageInfo = DamageInfo()
							damageInfo:SetAttacker(self.Owner)
							damageInfo:SetInflictor(self)
							damageInfo:SetDamage(damage)
							damageInfo:SetDamageType(DMG_SLASH)
							damageInfo:SetDamagePosition(trace.HitPos)
							damageInfo:SetDamageForce(self.Owner:GetAimVector()*10000)
						entity:DispatchTraceAttack(damageInfo, data.start, data.endpos)

						self.Owner:EmitSound(Sound( "Canister.ImpactHard" ), 80)
					end
				end

				hook.Run("PlayerDoMelee", self.Owner, trace)
			self.Owner:LagCompensation(false)
		end
	end)
end

function SWEP:Reload()
end

function SWEP:Holster( wep )
  return true
end

function SWEP:OnRemove()
end

function SWEP:OwnerChanged()
end