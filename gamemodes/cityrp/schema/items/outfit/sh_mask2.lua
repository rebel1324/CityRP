ITEM.name = "Mask"
ITEM.desc = "maskDesc"
ITEM.model = "models/sal/acc/fix/mask_2.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(-3.3892376422882, -540.45831298828, 0),
	fov	= 4.0670499796608,
	pos	= Vector(199.71739196777, -1.3346152305603, -10.534560203552)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["ClassName"] = "model",
				["Position"] = Vector(-3.93310546875, 0.0029296875, -2.2197265625),
				["Size"] = 0.953,
				["Bone"] = "eyes",
				["Model"] = "models/sal/acc/fix/mask_2.mdl",
				["UniqueID"] = "MASK_02_PART",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "MASK_02_OUTFIT",
		["ClassName"] = "group",
	},
},


}