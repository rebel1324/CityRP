AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "printer_base"
ENT.PrintName = "printerNameTier4"
ENT.setting = {
	upgrade = {
		price = {
			power = {4000, 1},
			stability = {4000, 1},
			cooler = {4000, 1},
			speed = {4000, 1},
		},
		val = {
			power = {500, 1}, -- add, mul
			stability = {3, 2, 1, .5, .1, 0}, -- hey
			cooler = {10, 20, 30, 33, 36, 40}, -- cooler
			speed = (.1), -- upg
		},
		max = 5, -- Maximum Upgrade
	},
	spec = {
		price = 70000,
		maxHoldStacks = 15,
		time = 75,
		coolTime = 20,
		print = 2000,
		maxTemp = 120,
		printTemp = 5,
		enableCoolEfficieny = .15,
	}
}
ENT.ModelSkin = 3