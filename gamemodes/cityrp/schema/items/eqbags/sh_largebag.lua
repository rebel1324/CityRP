ITEM.name = "Medium Bag"
ITEM.desc = "bagDesc"
ITEM.model = "models/rebel1324/b_largebag.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 4
ITEM.outfitCategory = "back"
ITEM.price = 140000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(20.480054855347, 53.296756744385, 57.94811630249),
	ang = Angle(5.899998664856, -110.00015258789, -4.4567834265763e-05),
	entAng = Angle(0, -21.135969161987, 20.621829986572),
	fov = 20.084085527002,
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
                    ["UniqueID"] = "LARGEBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_largebag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "LARGEBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}