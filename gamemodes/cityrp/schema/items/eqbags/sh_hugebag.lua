ITEM.name = "Large Bag"
ITEM.desc = "bagDesc"
ITEM.model = "models/rebel1324/b_hugebag.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 5
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(21.697832107544, -109.91729736328, -4.4567834265763e-005),
	fov	= 27.848277201777,
	pos	= Vector(20.480054855347, 61.058376312256, 71.960678100586)
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