ITEM.name = "Life Vest"
ITEM.desc = "lvestDesc"
ITEM.model = "models/rebel1324/b_lifevest.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(5.6796727180481, 58.452518463135, 0),
	fov	= 1.5291959440523,
	pos	= Vector(-616.39172363281, -1002.9677124023, 169.84010314941)
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
                    ["UniqueID"] = "LIFEVEST_MODEL",
                    ["Model"] = "models/rebel1324/b_lifevest.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "LIFEVEST_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}