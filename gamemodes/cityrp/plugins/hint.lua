PLUGIN.name = "Noob Hinter"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds good HUD."

if (SERVER) then return end

local function languageDeclare()
	local langkey = "english"
	do
		local langTable = {
            helpFist1 = "Attack with Fists",
            helpFist2 = "Knock",
            helpFist3 = "Pick up Object",
            helpKey1 = "Unlock Door",
            helpKey2 = "Lock Door",
            helpKey3 = "Unlock Vehicle",
            helpKey4 = "Lock Vehicle",
            helpKey5 = "Get close to the door or vehicle",
            helpStun1 = "Stun Target",
            helpStun2 = "Push Target",
            helpArr1 = "Arrest Target",
            helpArr2 = "Unarrest Target",
			helpTaz1 = "Stun Target In Place",
			helpTaz2 = "Stun Target Unconcious",
            helpCure = "Heal Target",
            helpHack = "Hack Keypad",
            helpShield = "The shield only blocks 'bullets'.",
            helpDetect = "This Weapon detects Illegal Entities",
            toggleHelper = "Enable Helper HUD",

            tipAtm = "Withdraw/Deposit your Bank Account in here!",
            tipBankReserve = "You can steal goverment's money from this",
            tipCheckout = "You can sell your item more conviently with this",
            tipCovfefe = "You can purchase small boost gain from this",
            tipGoaway = "You can turn off this message in Right-Top of 'C' menu",
            tipOutfitter = "You can change your look in here",
            tipCrafting = "You can craft stuffs with blueprint in here",
            tipCooker = "You can cook your foods with this",
            tipStash = "You can store your items in here",
            tipCardealer = "You can purchase vehicles from this NPC",
            tipPunchBag = "You can grind your Strength Attribute with punching this with fists",
            tipGunBag = "You can grind your Gun Skills Attribute with shooting this with guns",

		}

		table.Merge(nut.lang.stored[langkey], langTable)
	end

	langkey = "korean"
	do
		local langTable = {
            helpFist1 = "주먹으로 공격",
            helpFist2 = "노크",
            helpFist3 = "물건 줍기",
            helpKey1 = "문 열기",
            helpKey2 = "문 잠금",
            helpKey3 = "차량 열기",
            helpKey4 = "차량 잠금",
            helpKey5 = "차량이나 문에 가까이 가세요",
            helpStun1 = "사람 때려 기절시키기",
            helpStun2 = "사람 밀치기",
            helpArr1 = "대상 체포",
            helpArr2 = "대상 체포 해제",
            helpCure = "대상 치료",
            helpHack = "키패드 해킹",
            helpShield = "이 방패는 총알만 막습니다",
            helpDetect = "이 무기로 불법 물품을 감지합니다",
            toggleHelper = "초보 도우미 사용",

            tipAtm = "은행 계좌를 쓸 수 있는 ATM",
            tipBankReserve = "정부 자금이 보관된 돈 보관함",
            tipCheckout = "더 편리하게 판매를 도와주는 계산대",
            tipCovfefe = "능력치를 잠시 올려주는 커피 판매기",
            tipGoaway = "'C'의 오른쪽 위 메뉴에서 메세지를 끌 수 있습니다.",
            tipOutfitter = "현재 옷을 바꿀수 있는 옷장",
            tipCrafting = "청사진을 이용해 물건을 조합할수 있는 조합대",
            tipCooker = "음식을 조리할 수 있는 물건",
            tipStash = "물건을 안전하게 보관할 수 있는 보관함",
            tipCardealer = "차량을 판매하는 NPC",
		}

		table.Merge(nut.lang.stored[langkey], langTable)
	end
end
function PLUGIN:InitializedPlugins()
	languageDeclare()
end

local iconMat = {
    Material("hud/iconsheet1.png"),
    Material("hud/iconsheet2.png"),
    Material("hud/iconsheet3.png"),
}

function PLUGIN:LoadFonts(font, genericFont)
    surface.CreateFont( "nutHelperFont", {
        font = font,
        extended = true,
        size = 34,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = false,
        outline = false,
    } )
end
    
local matSize = 256
local iconSize = 60
local iconSizeSect = 64
local txtMiddle = 18
local sw, sh = ScrW(), ScrH()

local function drawIconText(_icoX, _icoY, _x, _y, _t, _icoTex, _alpha)
    _alpha = _alpha or 255
    surface.SetFont("nutHelperFont")
    local tw, th = surface.GetTextSize(_t)
    local icoSect = (iconSize + 10)
    
    surface.SetMaterial(iconMat[_icoTex or 2])
    surface.SetDrawColor(255, 255, 255, _alpha)
    surface.DrawTexturedRectUV(_x - icoSect/2 - tw/2, _y - iconSize/2, iconSize, iconSize, iconSizeSect/matSize*_icoX, iconSizeSect/matSize*_icoY, iconSizeSect/matSize*(_icoX+1), iconSizeSect/matSize*(_icoY+1))
    surface.SetTextColor(255, 255, 255, _alpha)
    surface.SetTextPos(_x - tw/2 + icoSect/2, _y - txtMiddle)
    surface.DrawText(_t)
end

local function drawIcon(_icoX, _icoY, _x, _y, _icoTex, _alpha) 
    _alpha = _alpha or 255
    surface.SetMaterial(iconMat[_icoTex or 2])
    surface.SetDrawColor(255, 255, 255, _alpha)
    surface.DrawTexturedRectUV(_x - iconSize/2, _y - iconSize/2, iconSize, iconSize, iconSizeSect/matSize*_icoX, iconSizeSect/matSize*_icoY, iconSizeSect/matSize*(_icoX+1), iconSizeSect/matSize*(_icoY+1))
end

local function getEntity()
    local client = LocalPlayer()
    local char = client:getChar()

    if (client and char) then
        local trace = client:GetEyeTraceNoCursor()

        if (IsValid(trace.Entity)) then
            return trace.Entity
        end
    end

    return
end

local informationDraw = {
    nut_hands = function()
                    local client = LocalPlayer()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpFist1")

                    local ent = getEntity()

                    if (ent) then
                        local dist = ent:GetPos():Distance(client:GetPos())
                        if (dist > 128) then return end

                        if (ent:isDoor()) then
                            drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpFist2")
                        else
                            drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpFist3")
                        end
                    end
                end,
    nut_keys = function()
                    local client = LocalPlayer()
                    local ent = getEntity()

                    if (ent) then
                        local dist = ent:GetPos():Distance(client:GetPos())
                        if (dist <= 128) then
                            if (ent:isDoor()) then
                                drawIconText(1, 0, sw/2, sh/3*2, L"helpKey2")
                                drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpKey1")


                                return
                            elseif (ent:IsVehicle()) then
                                drawIconText(1, 0, sw/2, sh/3*2, L"helpKey3")
                                drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpKey4")

                                return
                            end
                        end
                    end

                    drawIconText(0, 0, sw/2, sh/3*2, L"helpKey5", 1)
                end,
    weapon_physgun = function()
                end,
    nut_stunstick = function()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpStun1")
                    drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpStun2")
                end,
    nut_arrestbaton = function()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpArr1")
                    drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpArr2")
                end,
    nut_unarrest = function()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpArr2")
                    drawIconText(0, 0, sw/2, sh/3*2+iconSize, L"helpArr2")
                end,
	nut_taser = function()
                    drawIconText(1, 0, sw/2, sh/3*2, "Stun Target In Place")
                    drawIconText(0, 0, sw/2, sh/3*2+iconSize, "Stun Target Unconcious")
                end,
    weapon_healer = function()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpCure")
                end,
    keypad_cracker = function()
                    drawIconText(1, 0, sw/2, sh/3*2, L"helpHack")
                end,
    weapon_riotshield = function()
                    drawIconText(0, 0, sw/2, sh/3*2, L"helpShield", 1)
                end,
    weapon_detector = function()
                    drawIconText(0, 0, sw/2, sh/3*2, L"helpDetect", 1)
                end,
}

local entDraw = {
    nut_bankreserve = function()
                            drawIconText(0, 1, sw/2, sh/3*2, "돈을 집을시 바로 현상수배가 됩니다", 1)
                            drawIconText(0, 2, sw/2, sh/3*2+iconSize, "은행 돈 훔치기", 1)
                        end,
    nut_bankreserve = function()
                            drawIconText(0, 1, sw/2, sh/3*2, "가방에서 가격을 설정후 팔게 해줍니다", 1)
                            drawIconText(1, 2, sw/2, sh/3*2+iconSize, "떨어진 아이템 가격 관리", 1)
                        end,
}

local helperTrackingEnts = {}

local function addTrackEntity(icoX, icoY, text, lifeTime, target)
    surface.PlaySound("nui/beepclear.wav")

    local kek = {
        pos = Vector(sw/2, sh/2),
        ico = {icoX, icoY},
        text = text,
        alpha = 0,
        lifetime = CurTime() + lifeTime,
        target = target
    }
    table.insert(helperTrackingEnts, kek)
end

local annoyingEnts = {}
local displayInfo = {
    nut_bankreserve = {"tipBankReserve", 0, 2},
    nut_seller = {"tipCheckout", 1, 2},
    nut_atm = {"tipAtm", 1, 2},
    nut_vnd_covfefe = {"tipCovfefe", 1, 2},
    nut_vnd_medical = {"tipMedven", 1, 2},
    nut_attrib_gun = {"tipGunBag", 0, 0},
    nut_attrib_punch = {"tipPunchBag", 0, 0},
    nut_helloboard = {"tipGoaway", 0, 0},
    nut_outfit = {"tipOutfitter", 0, 0},
    nut_craftingtable = {"tipCrafting", 0, 0},
    nut_loadingtable = {"tipCrafting", 0, 0},
    nut_microwave = {"tipCooker", 0, 0},
    nut_stove = {"tipCooker", 0, 0},
    nut_stash = {"tipStash", 0, 0},
    freshcardealer = {"tipCardealer", 0, 0},
}

local nextUpdate = 0
local lastTrace = {}
local lastEntity
local mathApproach = math.Approach
local surface = surface
local hookRun = hook.Run
local toScreen = FindMetaTable("Vector").ToScreen

function PLUGIN:HUDPaintBackground()
    local realTime = RealTime()
    local localPlayer = LocalPlayer()

	if (localPlayer.getChar(localPlayer) and nextUpdate < realTime) then
		nextUpdate = realTime + 0.8

		lastTrace.start = localPlayer.GetShootPos(localPlayer)
		lastTrace.endpos = lastTrace.start + localPlayer.GetAimVector(localPlayer)*512
		lastTrace.filter = localPlayer		
		lastTrace.mins = Vector( -3, -3, -3 )
		lastTrace.maxs = Vector( 3, 3, 3 )

		lastEntity = util.TraceHull(lastTrace).Entity
	end

    if (IsValid(lastEntity)) then
        local class = lastEntity:GetClass()
        if (displayInfo[class]) then
            if (annoyingEnts[class] and annoyingEnts[class] < CurTime()) then
                annoyingEnts[class] = nil
            end

            if (class and !annoyingEnts[class]) then
                addTrackEntity(displayInfo[class][2], displayInfo[class][3], L(displayInfo[class][1]), 5, lastEntity)
                annoyingEnts[class] = CurTime() + 300
            end
        end
    end
end

function PLUGIN:HUDPaint()
    if (NUT_CVAR_HELPERS:GetBool()) then

        local client = LocalPlayer()
        local char = client:getChar()
        if (!signal.open and client and char) then        
            local wep = client:GetActiveWeapon()
            
            if (IsValid(wep)) then
                if (informationDraw[wep:GetClass()]) then
                    informationDraw[wep:GetClass()]()
                end
            end
        end
    end

    local lerpFT = RealFrameTime() * 7

    for k, v in pairs(helperTrackingEnts) do
        if (!IsValid(v.target)) then
            helperTrackingEnts[k] = nil
            return
        end

        local pos = isentity(v.target) and (v.target:GetPos() + v.target:OBBCenter()) or v.target 
        
        if (v.lifetime and v.lifetime < CurTime()) then
            if (v.alpha) then
                v.alpha = Lerp(lerpFT, v.alpha, 0)
            end

            if (v.alpha and v.alpha < 1) then
                helperTrackingEnts[k] = nil
                return
            end
        else
            if (v.alpha) then
                v.alpha = Lerp(lerpFT, v.alpha, 255)
            end
        end

        v.pos = v.pos or Vector()
        local nw, nh = sh*.1, sh*.1
        local t = pos:ToScreen()

        if (t.x >= nw and t.x <= (sw-nw) and
            t.y >= nh and t.y <= (sh-nh)) then
            v.pos = Lerp(lerpFT, v.pos, Vector(t.x, t.y, 0))
            drawIconText(v.ico[1], v.ico[2], v.pos.x, v.pos.y, v.text, 1, v.alpha)
        else
            t.x = math.Clamp(t.x, nw*.9, sw - nw*.9)
            t.y = math.Clamp(t.y, nh*.9, sh - nh*.9)
            v.pos = Lerp(lerpFT, v.pos, Vector(t.x, t.y, 0))
            drawIcon(v.ico[1], v.ico[2], v.pos.x, v.pos.y, 1, v.alpha)
        end 
    end
end

NUT_CVAR_HELPERS = CreateClientConVar("nut_helpers", 1, true, true)
function PLUGIN:SetupQuickMenu(menu)
	 local button = menu:addCheck(L"toggleHelper", function(panel, state)
	 	if (state) then
	 		RunConsoleCommand("nut_helpers", "1")
	 	else
	 		RunConsoleCommand("nut_helpers", "0")
	 	end
	 end, NUT_CVAR_HELPERS:GetBool())

	 menu:addSpacer()
end