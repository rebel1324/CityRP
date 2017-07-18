ITEM.name = "Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/hat07.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(25.90327835083, 220.06370544434, 0),
	fov	= 3.3974515710477,
	pos	= Vector(137.89633178711, 114.16724395752, 86.119575500488)
}

ITEM.pacData = {
[1] = {
	["children"] = {
		[1] = {
			["children"] = {
			},
			["self"] = {                
				["Angles"] = Angle(-12.39999961853, 0, 0),
				["UniqueID"] = "HAT_02_PART",
				["Position"] = Vector(-4.0390000343323, 0, 2.0130000114441),
				["Size"] = 0.992,
				["Bone"] = "eyes",
				["Model"] = "models/modified/hat07.mdl",
				["ClassName"] = "model",
			},
		},
	},
	["self"] = {
		["EditorExpand"] = true,
		["UniqueID"] = "HAT_02_OUTFIT",
		["ClassName"] = "group",
	},
},

}