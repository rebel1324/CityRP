CLASS.name = "Doctor"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 230
CLASS.business = {
}
CLASS.weapons = {
	"weapon_healer",
}
CLASS.limit = 3

CLASS.business = {
	-- Foods
	["aidkit"] = 1,	
	["healthkit"] = 1,	
	["healvial"] = 1,	
}
CLASS.color = Color(47, 79, 79)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end


CLASS_DOCTOR = CLASS.index