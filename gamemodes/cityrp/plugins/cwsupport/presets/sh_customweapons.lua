
-- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
if (true) then return end -- IF YOU KNOW WHAT YOU'RE DOING, REMOVE THIS LINE BEFORE DO TEST!!!!!!!!!!!!!!!! PLEASE!
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


PLUGIN.gunData["<WEAPON CLASSNAME>"] = {
    -- Gun holster information
    holster = {
		bone = "ValveBiped.Bip01_R_Thigh",
		ang = Angle(-0, -0,90),
		pos = Vector(-6, 8, -4),
    },

    -- Where you can select the weapon
    -- 1 means you can select the weapon with the numeric key '2'
    slot = 1,

    -- The price of the weapon.
    price = 1000,

    -- The size of the weapon.
    width = 2,
    height = 1,

    -- Use IKON Rendering Library?
    exRender = true,
}

PLUGIN.modelCam["<WORLD MODEL PATH OF THE WEAPON>"] = {
	pos = Vector(-0.73431813716888, 186.86952209473, 3.543244600296),
	ang = Angle(0, 270, 0),
	fov = 13.190396880435
}

/*
    Rifile Holster Position Template.
    holster = {
		bone = "ValveBiped.Bip01_Spine2",
		ang = Angle(180, 0,20),
		pos = Vector(4, 10, -2),
    },
*/