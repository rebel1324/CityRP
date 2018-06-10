ITEM.name = "Large Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/modified/backpack_2.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 4
ITEM.outfitCategory = "back"
ITEM.price = 90000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(715.57751464844, 604.79113769531, 470.69500732422),
	ang = Angle(24.117046356201, -139.79110717773, 0),
	entAng = Angle(0, -48.649551391602, 17.080837249756),
	fov = 2.1228075255791,
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