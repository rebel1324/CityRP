﻿DEFINE_BASECLASS('nut_melee')

if (SERVER) then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
end

if (CLIENT) then
    SWEP.Slot = 0
    SWEP.SlotPos = 0
end

SWEP.PrintName = 'Pot'
SWEP.Category = 'Nutscript'
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = 'models/weapons/hl2meleepack/v_pot.mdl'
SWEP.WorldModel = 'models/weapons/hl2meleepack/w_pot.mdl'
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = 7
SWEP.Primary.Delay = 0.5
SWEP.Primary.Stamina = 11
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)