DEFINE_BASECLASS( 'nut_melee' )

if ( SERVER ) then
  SWEP.Weight         = 5
  SWEP.AutoSwitchTo   = false
  SWEP.AutoSwitchFrom = false
end

if ( CLIENT ) then
  SWEP.Slot         = 0
  SWEP.SlotPos      = 0
end

SWEP.PrintName      = 'Shovel'
SWEP.Category       = 'Nutscript'

SWEP.Spawnable      = true
SWEP.AdminSpawnable = true

SWEP.ViewModel      = 'models/weapons/hl2meleepack/v_shovel.mdl'
SWEP.WorldModel     = 'models/weapons/hl2meleepack/w_shovel.mdl'

SWEP.Primary.ClipSize		  = -1
SWEP.Primary.Damage			  = 15
SWEP.Primary.Delay			  = 1
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "none"
SWEP.HoldType = "melee2"

util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )