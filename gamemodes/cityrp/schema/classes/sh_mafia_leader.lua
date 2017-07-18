CLASS.name = "Mafia Godfather"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 200
CLASS.business = {
	["sh_b_acide"] = 1,
	
}
CLASS.weapons = {
	"nut_unarrest",
}
CLASS.limit = 1
CLASS.team = 3
CLASS.color = Color(50, 50, 40)
CLASS.model = {
		"models/fearless/don1.mdl",
}

function CLASS:onCanBe(client)
	local char = client:getChar()

	return (char and char:getClass() == CLASS_MAFIA)
end

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_MAFIALEADER = CLASS.index