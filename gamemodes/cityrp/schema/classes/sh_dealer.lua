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
	
	-- Bags
	["civbag"] = 1,
	["civbag2"] = 1,
	["civbag3"] = 1,
	["buttbag"] = 1,
	["gunjang"] = 1,
	["hugebag"] = 1,
	["smallbag"] = 1,
	["largebag"] = 1,

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

function CLASS:OnSet(client)
end

CLASS_DEALER = CLASS.index