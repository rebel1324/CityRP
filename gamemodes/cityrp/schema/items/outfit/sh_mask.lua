ITEM.name = "Mask"
ITEM.desc = "maskDesc"
ITEM.model = "models/sal/acc/fix/mask_4.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(8.4955530166626, 179.23202514648, 0),
	fov	= 0.77865774177467,
	pos	= Vector(1082.013671875, -14.348900794983, 162.9444732666)
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
				["Model"] = "models/sal/acc/fix/mask_4.mdl",
				["UniqueID"] = "MASK_01_PART",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "MASK_01_OUTFIT",
		["ClassName"] = "group",
	},
},

}