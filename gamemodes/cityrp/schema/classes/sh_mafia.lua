CLASS.name = "Mafia"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 180
CLASS.business = {
	["sh_b_acide"] = 1,
	
}
CLASS.weapons = {
	"nut_unarrest",
}
CLASS.limit = 6
CLASS.team = 3
CLASS.color = Color(75, 75, 75)
CLASS.model = {
		"models/fearless/mafia02.mdl",
		"models/fearless/mafia04.mdl",
		"models/fearless/mafia06.mdl",
		"models/fearless/mafia07.mdl",
		"models/fearless/mafia09.mdl"
}

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_MAFIA = CLASS.index