ITEM.name = "Large Bag"
ITEM.desc = "bagDesc"
ITEM.model = "models/rebel1324/b_hugebag.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 5
ITEM.outfitCategory = "back"
ITEM.price = 190000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(20.480054855347, 61.058376312256, 56.555320739746),
	ang = Angle(5.899998664856, -109.37295532227, 1.6088266372681),
	entAng = Angle(0, -21.135969161987, 20.621829986572),
	fov = 20.29129456246,
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
                    ["UniqueID"] = "HUGEBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_hugebag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "HUGEBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}