ITEM.name = "Mask"
ITEM.desc = "maskDesc"
ITEM.model = "models/modified/mask6.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(-0.27674955129623, -181.17459106445, 0),
	fov	= 4.319620375411,
	pos	= Vector(199.95974731445, -3.8557584285736, 1.0912104845047)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["ClassName"] = "model",
				["Position"] = Vector(-3.4790000915527, 0, -2.7969999313354),
				["Size"] = 0.87,
				["Bone"] = "eyes",
				["Model"] = "models/modified/mask6.mdl",
				["UniqueID"] = "MASK_03_PART",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "MASK_03_OUTFIT",
		["ClassName"] = "group",
	},
},


}