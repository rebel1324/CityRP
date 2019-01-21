ITEM.name = "Large Bag Tier 3"
ITEM.desc = "bagDesc"
ITEM.model = "models/rebel1324/b_hugebag.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 5
ITEM.width = 2
ITEM.height = 3
ITEM.outfitCategory = "back"
ITEM.price = 100000000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(0.14335063099861, 196.48181152344, 49.661422729492),
	ang = Angle(0, 270, 0),
	entAng = Angle(0, 0, 0),
	fov = 6.4263869138511,
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