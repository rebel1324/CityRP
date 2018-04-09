﻿CLASS.name = "Defensive Armed Force"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 220
CLASS.law = true
CLASS.weapons = {"cw_m1911", "cw_mp5", "nut_stunstick", "nut_arrestbaton", "weapon_riotshield", "keypad_cracker"}

CLASS.business = {
    ["doorcharge"] = 1,
    ["teargas"] = 1,
    ["tie"] = 1,
    ["ammo_ar2"] = 1
}

--	["bg_wf_p226_silencer"] = 1,
--	["bg_wf_p226_rds"] = 1,
CLASS.limit = 3
CLASS.team = 1
CLASS.color = Color(11, 11, 190)
CLASS.model = {"models/humans/nypd1940/male_01.mdl", "models/humans/nypd1940/male_02.mdl", "models/humans/nypd1940/male_03.mdl", "models/humans/nypd1940/male_04.mdl", "models/humans/nypd1940/male_05.mdl", "models/humans/nypd1940/male_06.mdl", "models/humans/nypd1940/male_09.mdl"}

function CLASS:onSet(client)
    for k, v in ipairs(self.weapons) do
        client:Give(v)
    end
end

function CLASS:onCanBe(client)
    local char = client:getChar()

    return (char and char:getClass() == CLASS_POLICE)
end

CLASS_POLICESHIELD = CLASS.index