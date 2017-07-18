ITEM.name = "Biker Helmet"
ITEM.desc = "bikerHelmetDesc"
ITEM.model = "models/dean/gtaiv/helmet.mdl"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 150
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["ClassName"] = "model",
					["Position"] = Vector(-3.21435546875, 0.0006103515625, -0.017578125),
					["Bone"] = "eyes",
					["Model"] = "models/dean/gtaiv/helmet.mdl",
					["UniqueID"] = "BIKER_PART",
				},
			},
		},
		["self"] = {
			["UniqueID"] = "BIKER_OUTFIT",
			["ClassName"] = "group",
		},
	},
}