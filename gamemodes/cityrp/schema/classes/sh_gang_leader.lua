CLASS.name = "Gangster King"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 200
CLASS.business = {
	["sh_b_acide"] = 1,
	
}
CLASS.weapons = {
	"nut_unarrest",
}
CLASS.limit = 1
CLASS.team = 2
CLASS.color = Color(60, 82, 50)
CLASS.model = {
		"models/sd/players/[dbs_brawler_2]-head_brawler_dbs.mdl",
		"models/sd/players/[dbs_grappler_2].mdl",
		"models/sd/players/[dbs_quick]-head_quick_dbs.mdl",
		"models/sd/players/[dbs_quick]-head_quick_dbs_2.mdl",
		"models/sd/players/[dbs_quick]-head_striker_dbs.mdl"
}


function CLASS:onCanBe(client)
	local char = client:getChar()

	return (char and char:getClass() == CLASS_GANG)
end

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_GANGLEADER = CLASS.index