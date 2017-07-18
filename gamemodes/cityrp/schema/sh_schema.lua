SCHEMA.name = "Doshi" -- Change this name if you're going to create new schema.
SCHEMA.author = "Black Tea / RealKallos"
SCHEMA.desc = "새로운 세계에 오신것을 환영합니다."

-- Schema Help Menu. You can add more stuffs in cl_hooks.lua.
SCHEMA.helps = {
	["Alpha"] = 
	[[yay]],
}

SCHEMA.prisonPositions = SCHEMA.prisonPositions or {}
SCHEMA.crapPositions = SCHEMA.crapPositions or {}
SCHEMA.laws = {
	"Murder is illegal.",
	"Sharing is caring",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
}

nut.vote = nut.vote or {}
nut.vote.list = nut.vote.list or {}

nut.bent = nut.bent or {}
nut.bent.list = {}

nut.util.include("sv_database.lua")
nut.util.include("sh_configs.lua")
nut.util.include("cl_effects.lua")
nut.util.include("sv_hooks.lua")
nut.util.include("cl_hooks.lua")
nut.util.include("sh_hooks.lua")
nut.util.include("sh_commands.lua")
nut.util.include("meta/sh_player.lua")
nut.util.include("meta/sh_entity.lua")
nut.util.include("meta/sh_character.lua")
nut.util.include("sh_dev.lua") -- Developer Functions
nut.util.include("sh_character.lua")
nut.util.include("sv_schema.lua")

nut.anim.setModelClass("models/fearless/mafia02.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia04.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia06.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia07.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia09.mdl", "player")

nut.anim.setModelClass("models/humans/nypd1940/male_01.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_02.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_03.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_04.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_05.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_06.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_07.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_09.mdl", "player")

nut.anim.setModelClass("models/btcitizen/male_01.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_02.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_03.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_04.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_05.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_06.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_07.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_08.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_09.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_10.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_11.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_12.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_13.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_14.mdl", "player")

nut.anim.setModelClass("models/btcitizen/female_01.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_02.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_03.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_04.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_05.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_06.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_07.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_08.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_09.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_10.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_11.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_12.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_13.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_14.mdl", "player")

local fuckoff = {
	chatbox  = false,
	wepselect = false,
	thirdperson = false,
	spawnsaver = false,
	saveitems = false,
	recognition = false,
}
function SCHEMA:PluginShouldLoad(uniqueID)
	return fuckoff[uniqueID]
end