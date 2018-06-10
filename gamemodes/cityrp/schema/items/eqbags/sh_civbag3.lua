ITEM.name = "Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/modified/backpack_3.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 3
ITEM.outfitCategory = "back"
ITEM.price = 60000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(715.57769775391, 603.86932373047, 470.69512939453),
	ang = Angle(23.887893676758, -139.78233337402, 0),
	entAng = Angle(0, -48.118144989014, 38.284679412842),
	fov = 1.4718538547905,
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
                    ["UniqueID"] = "CIVBAG3_MODEL",
                    ["Model"] = "models/rebel1324/b_gtabag3.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "CIVBAG3_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}