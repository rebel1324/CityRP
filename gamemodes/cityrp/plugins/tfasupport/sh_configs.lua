﻿-- ITEM INFORMATION
PLUGIN.muzDir = {
    [1] = function(a) return a:Right():Angle() end,
    [2] = function(a) return a:Up():Angle() end,
    [3] = function(a) return a:Forward():Angle() end
}

PLUGIN.changeAmmo = {}

PLUGIN.TFAInfo = {
    tfa_tfap_dp210 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1,
        muzDir = 3
    },
    tfa_tfap_dma11 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1,
        muzDir = 3
    },
    tfa_tfap_dmuzi = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1,
        muzDir = 3
    },
    tfa_csgo_scar20 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 2,
        muzDir = 3
    },
    tfa_csgo_xm1014 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_p2000 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_flash = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_sg556 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 2
    },
    tfa_csgo_revolver = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = 1.4,
        viewMuzzle = 3,
        muzDir = 3
    },
    tfa_csgo_famas = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_sawedoff = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1,
        shell = "CW_SHELL_SHOT"
    },
    tfa_csgo_frag = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_mp5 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1,
        muzDir = 3
    },
    tfa_csgo_galil = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_p250 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_deagle = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_molly = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_smoke = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_decoy = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_fiveseven = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_tec9 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = 1,
        viewMuzzle = .7
    },
    tfa_csgo_m249 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 2
    },
    tfa_csgo_m4a4 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_awp = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 2,
        viewMuzzle = 3
    },
    tfa_csgo_negev = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1.4,
        muzDir = 3
    },
    tfa_csgo_g3sg1 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1.4
    },
    tfa_csgo_mp9 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_elite = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_ump45 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_usp = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_ssg08 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_p90 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_incen = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_mac10 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = .7,
        viewMuzzle = .5
    },
    tfa_csgo_mp7 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_bizon = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_ak47 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1.6
    },
    tfa_csgo_nova = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 3,
        shell = "CW_SHELL_SHOT"
    },
    tfa_csgo_mag7 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_glock18 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_cz75 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 1,
        shell = "CW_SHELL_SMALL",
        worldMuzzle = .6,
        viewMuzzle = 1
    },
    tfa_csgo_m4a1 = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    },
    tfa_csgo_aug = {
        holster = {
            bone = "ValveBiped.Bip01_Spine2",
            ang = Angle(0, 0, 0),
            pos = Vector(0, 0, 0)
        },
        itemW = 4,
        itemH = 2,
        price = 8000,
        slot = 2,
        worldMuzzle = 1,
        viewMuzzle = 1
    }
}