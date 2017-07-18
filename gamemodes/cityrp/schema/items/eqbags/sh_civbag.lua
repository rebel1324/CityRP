ITEM.name = "Medium Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/modified/backpack_1.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 4
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(9.6204557418823, 333.65219116211, 0),
	fov	= 1.2651762196055,
	pos	= Vector(-1014.6419067383, 499.74407958984, 192.10636901855)
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
                    ["UniqueID"] = "CIVBAG1_MODEL",
                    ["Model"] = "models/rebel1324/b_gtabag1.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "CIVBAG1_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}