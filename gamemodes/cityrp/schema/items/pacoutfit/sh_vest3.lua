ITEM.name = "Tactical Vest"
ITEM.desc = "tacVestDesc"
ITEM.model = "models/rebel1324/b_olive.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(19.873210906982, 130.2998046875, 0),
	fov	= 1.7950190917068,
	pos	= Vector(541.49884033203, -638.29797363281, 354.3369140625)
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
                    ["UniqueID"] = "SMALLVEST_MODEL",
                    ["Model"] = "models/rebel1324/b_olive.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "SMALLVEST_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}