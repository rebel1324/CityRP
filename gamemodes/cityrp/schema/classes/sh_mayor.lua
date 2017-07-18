CLASS.name = "Mayor"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 300
CLASS.vote = true
CLASS.law = true
CLASS.weapons = {
	"nut_stunstick",
}
CLASS.business = {}
CLASS.limit = 1
CLASS.team = 1
CLASS.color = Color(150, 20, 20)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_MAYOR = CLASS.index