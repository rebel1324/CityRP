ITEM.name = "Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/hat06.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(25.661548614502, 220.09889221191, 0),
	fov	= 4.2042842381458,
	pos	= Vector(118.71318817139, 99.23030090332, 74.440040588379)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {                
				["UniqueID"] = "HAT_03_PART",
				["ClassName"] = "model",
				["Position"] = Vector(-3.819000005722, 0, 2.1730000972748),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/hat06.mdl",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "HAT_03_OUTFIT",
		["ClassName"] = "group",
	},
},

}