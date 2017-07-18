ITEM.name = "Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/hat01_fix.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(26.745073318481, 220.00262451172, 0),
	fov	= 0.72931081416563,
	pos	= Vector(729.23101806641, 611.23022460938, 479.73980712891)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {                
				["UniqueID"] = "HAT_05_PART",
                
				["Skin"] = 1,
				["Position"] = Vector(-3.819000005722, 0, 2.1730000972748),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/hat01_fix.mdl",
				["ClassName"] = "model",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "HAT_05_OUTFIT",
		["ClassName"] = "group",
	},
},

}