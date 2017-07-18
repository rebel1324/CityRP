ITEM.name = "Glasses"
ITEM.desc = "glassesDesc"
ITEM.model = "models/modified/glasses02.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "face"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(-0.053513813763857, 0.363893866539, 0),
	fov	= 3.8529947175734,
	pos	= Vector(-200, 0, 0)
}
ITEM.pacData = {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
					},
					["self"] = {
						["ClassName"] = "model",
						["Position"] = Vector(-3.7950000762939, 0.000579833984375, 0.0107421875),
						["Bone"] = "eyes",
						["Model"] = "models/modified/glasses02.mdl",
						["UniqueID"] = "GLASGJK",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "GLASGJK2",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
}