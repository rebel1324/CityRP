ITEM.name = "Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/hat06.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(26.737665176392, 220.0230255127, 0),
	fov	= 0.65340483432591,
	pos	= Vector(732.26898193359, 613.19561767578, 481.03002929688)
}
ITEM.pacData = {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
					},
					["self"] = {
						["ClassName"] = "model",
						["Position"] = Vector(-3.8550000190735, 0, 2.2909998893738),
						["Bone"] = "eyes",
						["Model"] = "models/modified/hat06.mdl",
						["UniqueID"] = "FRMNSHNC",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "FRMNSHNC2",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},

}