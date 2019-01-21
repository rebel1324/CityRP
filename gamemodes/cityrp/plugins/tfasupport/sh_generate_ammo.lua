
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

hook.Add("OnGenerateTFAItems", "TFA_GenerateAmmo", function(self)
    for name, data in pairs(self.ammoInfo) do
        local uniqueID = "ammo_"..name:lower()
        local ammoInfo = data
    
        local ITEM = nut.item.register(uniqueID, "base_ammo", nil, nil, true)
        ITEM.name = ammoInfo.name
        ITEM.ammo = name
        ITEM.price = ammoInfo.price or 200
        ITEM.model = ammoInfo.model or AMMO_BOX
        ITEM.isStackable = true
        ITEM.maxQuantity = ammoInfo.maxQuantity
        ITEM.exRender = true
    
        function ITEM:getDesc()
            return L("ammoDesc", self.getQuantity and self:getQuantity() or "", L(self.ammo))
        end
    end
    
    print("[+] TFA Integration: Generated Ammo Types")
end)