ITEM.name = "Ear Protection Headphone"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/headphones.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(5.6117305755615, 218.84663391113, 0),
	fov	= 3.7505062559934,
	pos	= Vector(132.0482635498, 106.58437347412, 18.17067527771)
}
ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["ClassName"] = "model",
				["Position"] = Vector(-3.4790000915527, 0, -0.89700001478195),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/headphones.mdl",
				["UniqueID"] = "HEADSET_PART",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "HEADSET_OUTFIT",
		["ClassName"] = "group",
	},
},

}