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
	["gasmask"] = 1,
}
CLASS.limit = 8
CLASS.team = 1
CLASS.color = Color(25, 25, 170)
CLASS.model = {
	"models/taggart/police01/male_01.mdl",
	"models/taggart/police01/male_02.mdl",
	"models/taggart/police01/male_03.mdl",
	"models/taggart/police01/male_04.mdl",
	"models/taggart/police01/male_05.mdl",
	"models/taggart/police01/male_06.mdl",
	"models/taggart/police01/male_07.mdl",
	"models/taggart/police01/male_08.mdl",
	"models/taggart/police01/male_09.mdl"
}
CLASS.needKiosk = true

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

CLASS_POLICE = CLASS.index