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

SWEP.PrintName      = 'Pot'
SWEP.Category       = 'Nutscript'

SWEP.Spawnable      = true
SWEP.AdminSpawnable = true

SWEP.ViewModel      = 'models/weapons/hl2meleepack/v_pot.mdl'
SWEP.WorldModel     = 'models/weapons/hl2meleepack/w_pot.mdl'

SWEP.Primary.ClipSize		  = -1
SWEP.Primary.Damage			  = 7
SWEP.Primary.Delay			  = 0.5
SWEP.Primary.Stamina		= 11
SWEP.Primary.DefaultClip   = -1
SWEP.Primary.Automatic     = true
SWEP.Primary.Ammo          = "none"

SWEP.exRender = true
SWEP.iconCam = {
	pos = Vector(213.20068359375, 178.75917053223, 130.21290588379),
	ang = Angle(25, 220, 0),
	entAng = Angle(-92.277313232422, 105.5724105835, 54.191249847412),
	fov = 2.1308876581827,
}


util.PrecacheModel( SWEP.ViewModel )
util.PrecacheModel( SWEP.WorldModel )