ITEM.name = "Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/modified/backpack_3.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 3
ITEM.outfitCategory = "back"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(13.476480484009, 331.01541137695, 0),
	fov	= 1.2747311243008,
	pos	= Vector(-993.56823730469, 548.451171875, 271.07095336914)
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