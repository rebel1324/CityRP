CLASS.name = "Police"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 250
CLASS.law = true
CLASS.weapons = {
	"cw_p99",
	"nut_stunstick",
	"nut_arrestbaton",
	"keypad_cracker",
	"nut_handcuffs",
}
CLASS.business = {
	["doorcharge"] = 1,
	["teargas_shipment"] = 1,	
	["polivest"] = 1,
}
CLASS.limit = 8
CLASS.team = 1
CLASS.color = Color(25, 25, 170)
CLASS.model = {
	"models/humans/nypd1940/male_01.mdl",
	"models/humans/nypd1940/male_02.mdl",
	"models/humans/nypd1940/male_03.mdl",
	"models/humans/nypd1940/male_04.mdl",
	"models/humans/nypd1940/male_05.mdl",
	"models/humans/nypd1940/male_06.mdl",
	"models/humans/nypd1940/male_09.mdl"
}

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_POLICE = CLASS.index