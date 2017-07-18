ITEM.name = "Large Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/modified/backpack_2.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 4
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(12.172930717468, 319.24600219727, 0),
	fov	= 1.6931144824502,
	pos	= Vector(-977.61212158203, 834.09033203125, 269.92984008789)
}
ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["BoneMerge"] = true,
                    ["ClassName"] = "model",
                    ["UniqueID"] = "CIVBAG2_MODEL",
                    ["Model"] = "models/rebel1324/b_gtabag2.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "CIVBAG2_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}