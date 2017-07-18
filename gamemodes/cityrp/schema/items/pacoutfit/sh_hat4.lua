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
						["Angles"] = Angle(-8.6999998092651, 0, 0.10000000149012),
						["UniqueID"] = "HWEASDFG",
						["Position"] = Vector(-3.6549999713898, 0, 1.7910000085831),
						["Size"] = 1.025,
						["Bone"] = "eyes",
						["Model"] = "models/modified/hat07.mdl",
						["ClassName"] = "model",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "HWEASDFG2",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
}