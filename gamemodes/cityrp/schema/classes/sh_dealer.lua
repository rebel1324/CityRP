CLASS.name = "Supply Dealer"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 210
CLASS.limit = 2
CLASS.color = Color(160, 100, 30)
CLASS.business = {
	-- Storages
	["bagsmall"] = 1,	

	-- Communication
	["radio"] = 1,	
	["pager"] = 1,	

	-- Misc
	["spraycan"] = 1,
	
	-- Outfit
	["endbook"] = 1,
	["gunskillbook"] = 1,
	["medicalbook"] = 1,
	["meleeskillbook"] = 1,
	["stmbook"] = 1,
	
	-- Weapons
	["nut_m_hook"] = 1,
	["nut_m_pickaxe"] = 1,
	["nut_m_shovel"] = 1,
	["nut_m_pot"] = 1,
	["nut_m_pipe"] = 1,
	["nut_m_pan"] = 1,

	-- Foods
	["cannedbean"] = 1,	
	["sodabottle"] = 1,	
	["sodacan"] = 1,	
}

--[[
	-- Ammo
	["ammo10x25"] = 1,
	["ammo12gauge"] = 1,
	["ammo23x75"] = 1,
	["ammo357sig"] = 1,
	["ammo380acp"] = 1,
	["ammo44mag"] = 1,
	["ammo45acp"] = 1,
	["ammo454casull"] = 1,
	["ammo50ae"] = 1,
	["ammo50bmg"] = 1,
	["ammo545x39"] = 1,
	["ammo556x45"] = 1,
	["ammo762x39"] = 1,
	["ammo762x51"] = 1,
	["ammo9x18"] = 1,
	["ammo9x19"] = 1,]]

function CLASS:OnSet(client)
end

CLASS_DEALER = CLASS.index