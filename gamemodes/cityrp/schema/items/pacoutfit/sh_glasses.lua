ITEM.name = "Glasses"
ITEM.desc = "glassesDesc"
ITEM.model = "models/modified/glasses01.mdl"
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
						["UniqueID"] = "GLASSAESA",
						["Position"] = Vector(-4.2550001144409, 0, -0.30899998545647),
						["Bone"] = "eyes",
						["Model"] = "models/modified/glasses01.mdl",
						["ClassName"] = "model",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "GLASSAESA2",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},

}