ATTACHMENT_SIGHT = 1
ATTACHMENT_BARREL = 2
ATTACHMENT_LASER = 3
ATTACHMENT_MAGAZINE = 4
ATTACHMENT_GRIP = 5
ATTACHMENT_MOD = 6

ATTACHMENT_SKIN = 99

local attItems = {}
attItems.att_rdot = {
    name = "Red Dot Sight",
    desc = "attRDotDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_aimpoint",
        "cw2_md_microt1",
        "cw2_md_rmr",
    },
    icon = Material("atts/microt1"),
}

attItems.att_holo = {
    name = "Holographic Sight",
    desc = "attHoloDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_kobra",
        "cw2_md_microt1",
        "cw2_md_eotech",
    },
    icon = Material("atts/eotech553"),
}

attItems.att_scope4 = {
    name = "4x Scope",
    desc = "attScope4Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_acog",
        --"cw2_md_schmidt_shortdot",
    },
    icon = Material("atts/acog"),
}

attItems.att_scope8 = {
    name = "8x Scope",
    desc = "attScope8Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "cw2_md_pso1",
        "cw2_g3_scope",
    },
    icon = Material("atts/sg1scope"),
}

attItems.att_muzsup = {
    name = "Suppressor",
    desc = "attSupDesc",
    slot = ATTACHMENT_BARREL,
    attSearch = {
        "cw2_silencer",
    },
    icon = Material("atts/suppressor"),
}

attItems.att_exmag = {
    name = "Extended Mag",
    desc = "attEMagDesc",
    slot = ATTACHMENT_MAGAZINE,
    attSearch = {
        "cw2_ar15_60rndmag",
        "cw2_ak74_mag_rpk",
        "cw2_makarov_extmag",
        "cw2_mp5_30rndmag",
        "cw2_vss_20rnd",
    },
    icon = Material("atts/ar1560rndmag"),
}

attItems.att_foregrip = {
    name = "Foregrip",
    desc = "attForeDesc",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "cw2_foregrip",
    },
    icon = Material("atts/foregrip"),
}

attItems.att_laser = {
    name = "Laser Sight",
    desc = "attLaserDesc",
    slot = ATTACHMENT_LASER,
    attSearch = {
        "cw2_md_anpeq15",
    },
    icon = Material("atts/anpeq15"),
}

attItems.att_longbarrel = {
    name = "Long Barrel",
    desc = "attLongBarrel",
    slot = ATTACHMENT_MOD,
    attSearch = {
        "cw2_mr96_long",
    },
    icon = Material("atts/longbarrel_revolver"),
}


hook.Add("OnGenerateTFAItems", "TFA_GenerateAttachments", function(self)
    for className, v in pairs(attItems) do
        local ITEM = nut.item.register(className, "base_attachment", nil, nil, true)
        ITEM.name = className
        ITEM.desc = v.desc
        ITEM.price = 2000
        ITEM.attSearch = v.attSearch
        ITEM.slot = v.slot
        ITEM.icon = v.icon
    end

    print("[+] TFA Integration: Generated Attachments")
end)