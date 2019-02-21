CLASS.name = "Police Chief"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 230
CLASS.law = true
CLASS.vote = true
CLASS.weapons = {
	"tfa_bt_glock",
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
	"models/player/police_agent/commissaire_01.mdl",
	"models/player/police_agent/commissaire_02.mdl",
	"models/player/police_agent/commissaire_03.mdl",
	"models/player/police_agent/commissaire_04.mdl",
	"models/player/police_agent/commissaire_05.mdl",
	"models/player/police_agent/commissaire_06.mdl",
	"models/player/police_agent/commissaire_07.mdl",
	"models/player/police_agent/commissaire_08.mdl",
	"models/player/police_agent/commissaire_09.mdl"
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