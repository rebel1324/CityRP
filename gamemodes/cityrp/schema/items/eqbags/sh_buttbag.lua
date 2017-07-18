ITEM.name = "Waist Bag"
ITEM.desc = "waistBagDesc"
ITEM.model = "models/rebel1324/b_buttbag.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 2
ITEM.outfitCategory = "butt"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(23.65446472168, 219.75495910645, 0),
	fov	= 1.2298666747857,
	pos	= Vector(550.05511474609, 467.93591308594, 353.10968017578)
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