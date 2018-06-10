ITEM.name = "Waist Bag"
ITEM.desc = "waistBagDesc"
ITEM.model = "models/rebel1324/b_buttbag.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 2
ITEM.outfitCategory = "butt"
ITEM.price = 40000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(500, 419.87237548828, 346.1178894043),
	ang = Angle(25, 220, 0),
	entAng = Angle(0, -48.649551391602, 17.080837249756),
	fov = 1.5407081047111,
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
                    ["UniqueID"] = "BUTTBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_buttbag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "BUTTBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}