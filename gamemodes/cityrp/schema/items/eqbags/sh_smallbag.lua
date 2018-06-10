ITEM.name = "Bag"
ITEM.desc = "bagDesc"
ITEM.model = "models/rebel1324/b_usbag.mdl"
ITEM.invWidth = 3
ITEM.invHeight = 3
ITEM.outfitCategory = "back"
ITEM.price = 60000
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(-61.059139251709, 22.894073486328, 62.557632446289),
	ang = Angle(8.9666881561279, -20.000299453735, 0.73423635959625),
	entAng = Angle(7.9749183654785, -21.988801956177, 0),
	fov = 24.668837432147,
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
                    ["UniqueID"] = "USBAG_MODEL",
                    ["Model"] = "models/rebel1324/b_usbag.mdl",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "USBAG_PART",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}