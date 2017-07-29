-- The 'nice' name of the faction.
FACTION.name = "Citizen"
-- This faction is default by the server.
-- This faction does not requires a whitelist.
FACTION.isDefault = true
-- A description used in tooltips in various menus.
FACTION.desc = "The civilian faction of the city."
-- A color to distinguish factions from others, used for stuff such as
-- name color in OOC chat.
FACTION.color = Color(20, 150, 15)
-- The list of models of the citizens.
-- Only default citizen can wear Advanced Citizen Wears and new facemaps.
local CITIZEN_MODELS = {
	"models/btcitizen/female_01.mdl",
	"models/btcitizen/female_02.mdl",
	"models/btcitizen/female_03.mdl",
	"models/btcitizen/female_04.mdl",
	"models/btcitizen/female_06.mdl",
	"models/btcitizen/female_07.mdl",
	"models/btcitizen/female_08.mdl",
	"models/btcitizen/male_01.mdl",
	"models/btcitizen/male_02.mdl",
	"models/btcitizen/male_03.mdl",
	"models/btcitizen/male_04.mdl",
	"models/btcitizen/male_05.mdl",
	"models/btcitizen/male_06.mdl",
	"models/btcitizen/male_07.mdl",
	"models/btcitizen/male_08.mdl",
	"models/btcitizen/male_09.mdl",
	"models/btcitizen/male_10.mdl",
	"models/btcitizen/male_11.mdl",
	"models/btcitizen/male_12.mdl",
	"models/btcitizen/male_13.mdl",
	"models/btcitizen/male_14.mdl",
}
FACTION.models = CITIZEN_MODELS
-- The amount of money citizens get.
FACTION.salary = 150
-- FACTION.index is defined when the faction is registered and is just a numeric ID.
-- Here, we create a global variable for easier reference to the ID.
FACTION_CITIZEN = FACTION.index
