ITEM.name = "Old Military Bag"
ITEM.desc = "oldMilDesc"
ITEM.model = "models/rebel1324/b_gunjang.mdl"
ITEM.invWidth = 4
ITEM.invHeight = 3
ITEM.outfitCategory = "back"
ITEM.price = 80000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(731.87103271484, 617.03521728516, 470.85153198242),
	ang = Angle(23.345558166504, -139.83682250977, 0),
	entAng = Angle(0, -52.223865509033, 15.47972202301),
	fov = 1.378362920489,
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
                    ["UniqueID"] = "GUNJANG_MODEL",
                    ["Model"] = "models/rebel1324/b_gunjang.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "GUNJANG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}