ITEM.name = "Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/sal/acc/fix/cheafhat.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(-0.053513813763857, 0.363893866539, 0),
	fov	= 3.8529947175734,
	pos	= Vector(-200, 0, 0)
}
ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["Skin"] = 1,
                    ["UniqueID"] = "CHIEF_PART",
                    ["Position"] = Vector(-3.8090000152588, 0, 4.7430000305176),
                    ["Size"] = 0.953,
                    ["Bone"] = "eyes",
                    ["Model"] = "models/sal/acc/fix/cheafhat.mdl",
                    ["ClassName"] = "model",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "CHIEF_OUTFIT",
            ["ClassName"] = "group",
        },
    },

}