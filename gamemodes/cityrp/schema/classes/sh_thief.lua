CLASS.name = "Thief"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 160
CLASS.business = {
}
CLASS.weapons = {
	"keypad_cracker",
}
CLASS.limit = 4

CLASS.business = {
	["lockpick"] = 1,	
}
CLASS.color = Color(200, 180, 0)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_THIEF = CLASS.index