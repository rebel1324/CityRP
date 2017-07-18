CLASS.name = "Pianist"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 190
CLASS.business = {
}
CLASS.weapons = {
}
CLASS.limit = 1

CLASS.business = {
}
CLASS.color = Color(200, 180, 0)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_PIANIST = CLASS.index