ITEM.name = "Mask"
ITEM.desc = "maskDesc"
ITEM.model = "models/modified/mask5.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(1.7422156333923, -178.87524414063, 0),
	fov	= 4.319620375411,
	pos	= Vector(199.80902099609, 3.9262549877167, 7.8055419921875)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["ClassName"] = "model",
				["Position"] = Vector(-3.4790000915527, 0, -2.0069999694824),
				["Size"] = 0.945,
				["Bone"] = "eyes",
				["Model"] = "models/modified/mask5.mdl",
				["UniqueID"] = "MASK_04_PART",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "MASK_04_OUTFIT",
		["ClassName"] = "group",
	},
},


}