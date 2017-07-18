ITEM.name = "Hipster Hat"
ITEM.desc = "hatDesc"
ITEM.model = "models/modified/hat03.mdl"
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
						["Angles"] = Angle(-8.6999998092651, 0, 0),
						["UniqueID"] = "HIASSGDPee2",
						["Position"] = Vector(-3.8550000190735, 0, 1.6909999847412),
						["Bone"] = "eyes",
						["Model"] = "models/modified/hat03.mdl",
						["ClassName"] = "model",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "HIASSGDPee",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
}