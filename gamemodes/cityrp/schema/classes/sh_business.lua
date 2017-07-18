CLASS.name = "Businessman"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 160
CLASS.business = {
}
CLASS.weapons = {
}
CLASS.limit = 4

CLASS.business = {
	-- Foods
	--["aidkit"] = 1,	
}
CLASS.color = Color(170, 255, 240)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end


CLASS_BUSINESS = CLASS.index