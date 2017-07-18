ITEM.name = "!!memes"
ITEM.desc = "meme"
ITEM.model = "models/props_lab/keypad.mdl"
ITEM.price = 500

-- This will change a player's skin after changing the model. Keep in mind it starts at 0.
ITEM.newSkin = 1
/*
-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}
*/
-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"
/*
-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}
*/
-- This will apply body groups.
ITEM.bodyGroups = {
	["blade"] = 1,
	["bladeblur"] = 1
}
