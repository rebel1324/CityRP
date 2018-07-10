CLASS.name = "Police Chief"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 230
CLASS.law = true
CLASS.vote = true
CLASS.weapons = {
	"cw_p99",
	"cw_mp5",
	"nut_stunstick",
	"nut_arrestbaton",
	"nut_handcuffs",
	"keypad_cracker",
}
CLASS.business = {
	["doorcharge"] = 1,
	["teargas_shipment"] = .9,	
	["polivest"] = 1,
	["gasmask"] = 1,
}
CLASS.limit = 1
CLASS.team = 1
CLASS.color = Color(20, 20, 255)
CLASS.model = {
	"models/humans/nypd1940/male_01.mdl",
	"models/humans/nypd1940/male_02.mdl",
	"models/humans/nypd1940/male_03.mdl",
	"models/humans/nypd1940/male_04.mdl",
	"models/humans/nypd1940/male_05.mdl",
	"models/humans/nypd1940/male_06.mdl",
	"models/humans/nypd1940/male_07.mdl",
	"models/humans/nypd1940/male_09.mdl"
}

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

function CLASS:onCanBe(client)
	local char = client:getChar()

	return (char and char:getClass() == CLASS_POLICE)
end

CLASS_POLICELEADER = CLASS.index