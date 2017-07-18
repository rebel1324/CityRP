timer.Simple(1, function()
    local lang = nut.lang.stored.korean

    local newLang = {
        ["Red Dot Sight"] = "레드 닷 조준기",
        att_rdot = "레드 닷 조준기",
        attRDotDesc = "조준을 도와주는 레드닷 조준기.",
        ["Holographic Sight"] = "홀로그래픽 조준기",
        att_holo = "홀로그래픽 조준기",
        attHoloDesc = "조준을 도와주는 홀로그래픽 조준기",
        ["4x Scope"] = "4배율 조준경",
        att_scope4 = "4배율 조준경",
        attScope4Desc = "멀리 있는 목표를 조준할 수 있게 해주는 4배율 조준경",
        ["8x Scope"] = "8배율 조준경",
        att_scope8 = "8배율 조준경",
        attScope8Desc = "멀리 있는 목표를 조준할 수 있게 해주는 8배율 조준경",
        ["Suppressor"] = "소음기",
        att_muzsup = "소음기",
        attSupDesc = "총기 소음을 줄여주는 소음기",
        ["Extended Mag"] = "확장 탄알집",
        att_exmag = "확장 탄알집",
        attEMagDesc = "총기의 탄약 장전양을 늘려주는 확장 탄알집",
        ["Foregrip"] = "수직 손잡이",
        att_foregrip = "수직 손잡이",
        attForeDesc = "더 안정적이게 조준을 도와주는 수직 손잡이",
        ["Laser Sight"] = "레이저 조준기",
        att_laser = "레이저 조준기",
        attLaserDesc = "조준하는 곳을 가리켜주는 레이저 조준기",
        ["Bipod"] = "양각대",
        att_bipod = "양각대",
        attBipodDesc = "사격시 반동을 줄여주는 양각대",
        Attach = "부품 장착",
        Detach = "부품 떼기",
        primary = "주무기",
        secondary = "보조무기",
    }


    table.Merge(lang, newLang)
    local lang = nut.lang.stored.english

    local newLang = {
        att_rdot = "Red Dot Sight",
        attRDotDesc = "A Small Sight that displays red dot in the center",
        att_holo = "Holographic Sight",
        attHoloDesc = "A Small sight that displays aim-assisting image in the center",
        att_scope4 = "4x Scope",
        attScope4Desc = "A Scope that allows you to aim at mid-long distance targets",
        att_scope8 = "8x Scope",
        attScope8Desc = "A Scope that allows you to aim at long distance targets",
        att_muzsup = "Suppressor",
        attSupDesc = "A Suppressor that reduces the sound from the gun",
        att_exmag = "Extended Mag",
        attEMagDesc = "A Magazine that has more rounds capacity",
        att_foregrip = "Foregrip",
        attForeDesc = "A Grip that makes you to aim hip-fire more accurate.",
        att_laser = "Laser Sight",
        attLaserDesc = "A Laser that displays where you're aiming at",
        att_bipod = "Bipod",
        attBipodDesc = "A Bipod that assists your aim.",
        primary = "Primary Weapon",
        secondary = "Secondary Weapon",
    }

    table.Merge(lang, newLang)
end)