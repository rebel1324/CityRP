ITEM.name = "Medium Bag"
ITEM.desc = "civBagDesc"
ITEM.model = "models/rebel1324/b_gtabag1.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 4
ITEM.outfitCategory = "back"
ITEM.price = 70000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(715.57751464844, 602.69744873047, 499.56411743164),
	ang = Angle(25.32452583313, -139.89186096191, 0),
	entAng = Angle(0, -48.649551391602, 17.080837249756),
	fov = 1.4519209818837,
}

ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["BoneMerge"] = true,
                    ["ClassName"] = "model",
                    ["UniqueID"] = "CIVBAG1_MODEL",
                    ["Model"] = "models/rebel1324/b_gtabag1.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "CIVBAG1_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}