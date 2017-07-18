ITEM.name = "Bandana"
ITEM.desc = "bandanaDesc"
ITEM.model = "models/modified/bandana.mdl"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "lower"
ITEM.price = 150
ITEM.iconCam = {
	ang	= Angle(5.9440808296204, 204.58561706543, 0),
	fov	= 0.6743679817525,
	pos	= Vector(906.84088134766, 414.51400756836, 103.0235824585)
}
ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {
				["Skin"] = 1,
				["UniqueID"] = "BANDA_PART",
				["Position"] = Vector(-3.818359375, 0, -3.7734375),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/bandana.mdl",
				["ClassName"] = "model",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "BANDA_OUTFIT",
		["ClassName"] = "group",
	},
},


}