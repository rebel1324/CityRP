PLUGIN.gunData = {}
PLUGIN.modelCam = {}

PLUGIN.slotCategory = {
	[1] = "secondary",
	[2] = "primary",
	[3] = "primary",
	[4] = "primary",
}

-- I don't want to make them to buy 50 different kind of ammo
PLUGIN.changeAmmo = {
	["7.92x33mm Kurz"] = "ar2",
	["300 AAC Blackout"] = "ar2",
	["5.7x28mm"] = "ar2",
	["7.62x25mm Tokarev"] = "smg1",
	[".50 BMG"] = "ar2",
	["5.56x45mm"] = "ar2",
	["7.62x51mm"] = "ar2",
	["7.62x31mm"] = "ar2",
	["Frag Grenades"] = "grenade",
	["Flash Grenades"] = "grenade",
	["Smoke Grenades"] = "grenade",
	["9x17MM"] = "pistol",
	["9x19MM"] = "pistol",
	["9x19mm"] = "pistol",
	[".45 ACP"] = "pistol",
	["9x18MM"] = "pistol",
	["9x39MM"] = "pistol",
	[".40 S&W"] = "pistol",
	[".44 Magnum"] = "357",
	[".50 AE"] = "357",
	["5.45x39MM"] = "ar2",
	["5.56x45MM"] = "ar2",
	["5.7x28MM"] = "ar2",
	["7.62x51MM"] = "ar2",
	["7.62x54mmR"] = "ar2",
	["12 Gauge"] = "buckshot",
	[".338 Lapua"] = "sniperround",
}

local AMMO_BOX = "models/Items/BoxSRounds.mdl"
local AMMO_CASE = "models/Items/357ammo.mdl"
local AMMO_FLARE = "models/rebel1324/sniperrounds.mdl"
local AMMO_BIGBOX = "models/Items/BoxMRounds.mdl"
local AMMO_BUCKSHOT = "models/Items/BoxBuckshot.mdl"
local AMMO_GREN = "models/Items/AR2_Grenade.mdl"

PLUGIN.ammoInfo = {}
PLUGIN.ammoInfo["pistol"] = {
	name = "Pistol Ammo",
	amount = 30,
	price = 200,
	model = AMMO_CASE,
	maxQuantity = 45,
}
PLUGIN.ammoInfo["357"] = {
	name = "Magnum Ammo",
	amount = 10,
	price = 350,
	model = AMMO_CASE,
	maxQuantity = 12,
}
PLUGIN.ammoInfo["smg1"] = {
	name = "Sub Machine Gun Ammo",
	amount = 30,
	price = 400,
	model = AMMO_BOX,
	maxQuantity = 120,
}
PLUGIN.ammoInfo["ar2"] = {
	name = "Rifle Ammo",
	amount = 30,
	price = 400,
	model = AMMO_BIGBOX,
	maxQuantity = 120,
}
PLUGIN.ammoInfo["buckshot"] = {
	name = "Shotgun Shells",
	amount = 10,
	price = 300,
	model = AMMO_BUCKSHOT,
	maxQuantity = 20,
}
PLUGIN.ammoInfo["sniperround"] = {
	name = "Sniper Rounds",
	amount = 10,
	price = 500,
	model = AMMO_FLARE,
	iconCam = {
		ang	= Angle(8.4998140335083, 170.05499267578, 0),
		fov	= 2.1218640972135,
		pos	= Vector(281.19021606445, -49.330429077148, 45.772754669189)
	},
	maxQuantity = 10,
}

nut.util.include("presets/sh_defcw.lua")
nut.util.include("presets/sh_customweapons.lua")

