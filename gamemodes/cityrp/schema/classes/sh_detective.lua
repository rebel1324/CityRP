CLASS.name = "Detective"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 160
CLASS.business = {
}
CLASS.weapons = {
}
CLASS.limit = 2

CLASS.business = {
}
CLASS.color = Color(150, 150, 150)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_DETECTIVE = CLASS.index