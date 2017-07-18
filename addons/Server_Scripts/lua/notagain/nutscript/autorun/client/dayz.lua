local function initia()
if (engine.ActiveGamemode() != "dayz") then
	return
end

local hud = {}
local sscale = ScreenScale
local dbox = draw.RoundedBox
local rt = RealTime

function hud:createFonts()
    surface.CreateFont("nutDHUDNum", {
        font = "HalfLife2",
        extended = true, 
        size = sscale(10), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDNum2", {
        font = "HalfLife2",
        extended = true, 
        blursize = 4,
        scanlines = 2,
        size = sscale(10), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDIcon", {
        font = "HalfLife2",
        extended = true, 
        size = sscale(20), 
        weight = 1500, 
    })

    surface.CreateFont("nutDHUDIcon2", {
        font = "fontello",
        extended = true, 
        size = sscale(10), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDIcon3", {
        font = "fontello",
        extended = true, 
        size = sscale(6), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDFont", {
        font = "Malgun Gothic",
        extended = true, 
        size = sscale(8), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDFont2", {
        font = "Malgun Gothic",
        extended = true, 
        size = sscale(5), 
        weight = 400, 
    })

    surface.CreateFont("nutDHUDFont3", {
        font = "Malgun Gothic",
        extended = true, 
        size = sscale(11), 
        weight = 400, 
    })
end
hud:createFonts()

local percHistories = {}
function hud:percDisp(wok, title, percent, reverse)
    percHistories[title] = percHistories[title] or {}
    local meme = percHistories[title]
    meme.memes = meme.memes or percent
    meme.alpha = meme.alpha or 0

    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    y = y - sscale(2)
    nut.util.drawText(title, x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, 4, "nutDHUDFont")

    local colorFade = 100
    if (reverse == true) then
        if (percent >= 75) then
            colorFade = (RealTime() * 150) % 100
        end
    else
        if (percent < 25) then
            colorFade = (RealTime() * 150) % 100
        end
    end

    local colorWider = Color(255, 155 + colorFade, 155 + colorFade)

    if (meme.memes != percent) then
        meme.alpha = 255
    else
        if (meme.alpha > 0) then
            meme.alpha = math.max(meme.alpha - FrameTime() - 5, 0)
        end
    end
    
    local a, b = x + w/2, y + h/2
    nut.util.drawText(percent, a, b, colorWider, TEXT_ALIGN_CENTER, 5, "nutDHUDNum")
    nut.util.drawText(percent, a, b, ColorAlpha(colorWider, meme.alpha), TEXT_ALIGN_CENTER, 5, "nutDHUDNum2")
    meme.memes = percent
end

function hud:edgyBar(wok, color, text)
    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    local tx, ty = nut.util.drawText("+", x + sscale(4), y + h/2 - sscale(3.2), color_white, 3, TEXT_ALIGN_CENTER, "nutDHUDIcon")

    local totallen = w - tx - sscale(12)
    local hotdicks = sscale(40)
    local awto = (LocalPlayer():Health() / LocalPlayer():GetMaxHealth())

    local dw = totallen/(hotdicks+1)
    surface.SetDrawColor(192, 57, 43)
    surface.DrawRect(x + sscale(8) + tx, y + sscale(3), totallen * awto, h - sscale(6))
    nut.util.drawText(LocalPlayer():Health(), x + sscale(10) + tx, y + h/2 - sscale(0.5), color_white, 3, TEXT_ALIGN_CENTER, "nutDHUDNum")
end

function hud:drawText(wok, title, color)
    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    nut.util.drawText(title, x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "nutDHUDFont")
end

function hud:status(wok, text, icon)
    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    local tx, ty = nut.util.drawText(icon or "Z", x + sscale(4), y + h/2, color_white, 3, TEXT_ALIGN_CENTER, "nutDHUDIcon2")
    local next = w/2 + tx + sscale(2)
    local tx, ty = nut.util.drawText(text, next, y + h/2, color_white, 1, TEXT_ALIGN_CENTER, "nutDHUDFont")
end

local dirName = {
    [12] = "북",
    [0] = "동",
    [-12] = "남",
    [24] = "서",
    [-24] = "서",   
}

function hud:compass(wok)
    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))

    surface.SetDrawColor(color_white)
    local startX, endX = x + sscale(5), x + w - sscale(5)
    local displayW = (endX - startX)
    local angola = EyeAngles().y
    local dir = angola/7.5 -- 90 is north, -90 is south -180/180 is west 0 is east
    local macOpt = (displayW)/24
    local a, b = math.floor(dir-12), math.ceil(dir+12)

    a = (a + 24)%48 - 24
    b = (b + 24)%48 - 24

    for i = -24, 23 do
        -- POSITION DEPENDANCY

        if (a > b) then
            if (i > b and i < a) then
                continue
            end
        else
            if (i > b or i < a) then
                continue
            end
        end

        local pos
        if (a > b) then
            if (dir < 0) then -- 좌측
                if (i > 0) then
                    pos = endX - macOpt*(i - 36 - dir)
                else
                    pos = endX - macOpt*(i + 12 - dir)   
                end
            elseif (dir >= 0) then -- 우측 -- 마이너스가 오른쪽
                if (i < 0) then
                    pos = endX - macOpt*(i + 60 - dir)
                else
                    pos = endX - macOpt*(i + 12 - dir)   
                end
            end
        else
            pos = endX - macOpt*(i + 12 - dir)
        end

        pos = math.Clamp(pos, startX, endX)
        
        if (i%6 == 0) then
            if (dirName[i]) then
                local tx, ty = nut.util.drawText(dirName[i], pos, y + h - sscale(10), color_white, 1, TEXT_ALIGN_CENTER, "nutDHUDFont2")
            end
            surface.DrawLine(pos, y + h - sscale(2), pos, y + h - sscale(6.5) )
        else
            surface.DrawLine(pos, y + h - sscale(2), pos, y + h - sscale(5) )
        end
    end
    
    --SCHEMA.targets = {

    for k, v in ipairs(ents.FindByClass("nut_tempitem")) do
        local angola = math.NormalizeAngle((v:GetPos() - LocalPlayer():GetPos()):Angle().y)
        local target = angola/7.5
        local pos
        
        if (a > b) then
            if (dir < 0) then -- 좌측
                if (target > 0) then
                    pos = endX - macOpt*(target - 36 - dir)
                else
                    pos = endX - macOpt*(target + 12 - dir)   
                end
            elseif (dir >= 0) then -- 우측 -- 마이너스가 오른쪽
                if (target < 0) then
                    pos = endX - macOpt*(target + 60 - dir)
                else
                    pos = endX - macOpt*(target + 12 - dir)   
                end
            end
        else
            pos = endX - macOpt*(target + 12 - dir)
        end
        
        pos = math.Clamp(pos, startX, endX)
        local tx, ty = nut.util.drawText("c", pos, y + h - sscale(10), color_white, 1, TEXT_ALIGN_CENTER, "nutDHUDIcon3")
    end
end

hud.noti = {}

local increc = 0
local function addText(text, time)
    local wow = {str = 0, text = text, time = CurTime() + time, alpha = 0, aalpha = 155, gloss = false}

    increc = increc + 1
    hud.noti[0 + increc] =  wow
end

hook.Add("InitializedSchema", "dayzNotify", function()
    function nut.util.notifyShine(text, time)
        addText(text, time)
    end

    netstream.Hook("nutShineText", function(text, time, ...)
        nut.util.notifyShine(L(text, ...), time or 5)
    end)
end)

local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
function hud:drawNoti()
    local x, y = ScrW()/2, ScrH()/4*3

    local blyat = 0
    local cnt = 0
    for k, v in pairs(hud.noti) do
        cnt = cnt + 1

        v.y = v.y or y + blyat
        v.y = Lerp(FrameTime() * 10, v.y, y + blyat)

        if (cnt > 5) then
            v.time = CurTime() + 3
            continue
        end

        if (v.time < CurTime()) then
            if (v.alpha < 5) then
                hud.noti[k] = nil

                continue
            end

            v.alpha = Lerp(FrameTime()*3, v.alpha, 0)
        else
            v.alpha = Lerp(FrameTime()*3, v.alpha, 255)
        end

        if (v.gloss) then
            v.aalpha = Lerp(FrameTime()*5, v.aalpha, 0)
        else
            if (v.aalpha > 150) then
                v.gloss = true
            end

            v.aalpha = Lerp(FrameTime()*15, v.aalpha, 255)
        end
        
        v.str = Lerp(FrameTime()*4, v.str, 4)
        local tx, ty = nut.util.drawText(v.text, x, v.y, ColorAlpha(color_white, v.alpha), 1, TEXT_ALIGN_CENTER, "nutDHUDFont3")
        surface.SetMaterial(GLOW_MATERIAL)
        surface.SetDrawColor(ColorAlpha(color_white, v.aalpha))
        blyat = blyat + ty*1.1

        tx, ty = tx*(2 + v.str*0.8), ty*(v.str*1.3)
        
        surface.DrawTexturedRect(x - tx/2, v.y - ty/2, tx, ty)
    end
end

netstream.Hook("nutSafeZone", function(bool)
    if (bool) then
        surface.PlaySound("safezone_enter.mp3")        
		displayDayz(L"safeEnter")
    else
        surface.PlaySound("safezone_exit.mp3")        
		displayDayz(L"safeExit")
    end
end)

netstream.Hook("nutNeatSounds", function(bool)
    addText(L(bool and "lostRep" or "gainRep"), 4)

    if (bool) then
        surface.PlaySound("stat_bad.mp3")   
    else
        surface.PlaySound("stat_good.mp3")   
    end
end)

-- draw matrix string.
-- slow as fuck I guess?
local function drawMatrixString(str, font, x, y, scale, angle, color)
	surface.SetFont(font)
	local tx, ty = surface.GetTextSize(str)

	local matrix = Matrix()
	matrix:Translate(Vector(x, y, 1))
	matrix:Rotate(angle or Angle(0, 0, 0))
	matrix:Scale(scale)

	cam.PushModelMatrix(matrix)
		surface.SetTextPos(2, 2)
		surface.SetTextColor(color or color_white)
		surface.DrawText(str)
	cam.PopModelMatrix()
end

-- configureable values.
local speed = 0
local targetScale = 0
local dispString = ""
local tickSound = "UI/buttonrollover.wav"
local dieTime = 5

-- non configureable values.
-- local scale = 0
local scale = 0
local flipTable = {}
local powTime = RealTime()*speed
local curChar = 0
local mathsin = math.sin
local mathcos = math.cos
local dieTrigger = false
local dieTimer = RealTime()
local dieAlpha = 0
local ft, w, h, dsx, dsy

function displayDayz(str, time)
	speed = 10
	targetScale = 1
	dispString = str
	dieTime = time or 2

	scale = targetScale * .1
	flipTable = {}
	powTime = RealTime()*speed
	curChar = 0
	dieTrigger = false
	dieTimer = RealTime()
	dieAlpha = 255
end

function hud:safe()
	-- values
	if ((hook.Run("CanDisplaySafeZone") == false) or (dieTrigger and dieTimer < RealTime() and dieAlpha <= 1)) then
		return	 
	end
	
     
	ft = FrameTime()
	w, h = ScrW(), ScrH()
	dsx, dsy = 0
	local strEnd = string.utf8len(dispString)
	local rTime = RealTime()

	surface.SetFont("nutAreaDisplay")
	local sx, sy = surface.GetTextSize(dispString)	

	-- Number of characters to display.
	local maxDisplay = math.Round(rTime*speed - powTime)

	-- resize if it's too big.
	while (sx and sx*targetScale > w*.8) do
		targetScale = targetScale * .9
	end

	-- scale lerp
	scale = Lerp(ft*5, scale, targetScale)
	--scale = targetScale

	-- change event
	if (maxDisplay != curChar and curChar < strEnd) then
		curChar = maxDisplay
		if (string.utf8sub(dispString, curChar, curChar) != " ") then
			--LocalPlayer():EmitSound(tickSound, 100, math.random(190, 200))
		end
	end

	-- draw recursive
	for i = 1, math.min(maxDisplay, strEnd) do
		-- character scale/color lerp
		flipTable[i] = flipTable[i] or {}
		flipTable[i][1] = flipTable[i][1] or .2
		--flipTable[i][1] = flipTable[i][1] or targetScale*3
		flipTable[i][2] = flipTable[i][2] or 0
		flipTable[i][1] = Lerp(ft*6, flipTable[i][1], scale)
		flipTable[i][2] = Lerp(ft*6, flipTable[i][2], 255)

		-- draw character.
		local char = string.utf8sub(dispString, i, i)
		local tx, ty = surface.GetTextSize(char)
		drawMatrixString(char,
			"nutAreaDisplay",
			math.Round(w/2 + dsx - (sx or 0)*scale/2),
			math.Round(h/3*1 - (sy or 0)*scale/2),
			Vector(Format("%.2f", flipTable[i][1]), Format("%.2f", scale), 1),
			nil,
			Color(255, 255, 255,
			(dieTrigger and dieTimer < RealTime()) and dieAlpha or flipTable[i][2])
		)

		-- next 
		dsx = dsx + tx*scale
	end

	if (maxDisplay >= strEnd) then
		if (dieTrigger != true) then
			dieTrigger = true
			dieTimer = RealTime() + 2
		else
			if (dieTimer < RealTime()) then
				dieAlpha = Lerp(ft*4, dieAlpha, 0)
			end
		end
	end
end

hud.notilist = hud.notilist or {}
TYPE_TIMER = 1
TYPE_OBJECTIVE = 2

netstream.Hook("nutAddTimer", function(uniqueID, text, time)
    local data = {
        text = L(text or "error"),
        time = CurTime() + time,
        type = TYPE_TIMER,
        w = 0,
        h = 15,
    }

    hud.notilist[uniqueID] = data
end)

netstream.Hook("nutAddObjective", function(uniqueID, title, desc)
    if (title and desc) then
        local data = {
            title = title,
            desc = desc,
            type = TYPE_OBJECTIVE,
            w = 0,
            h = 30,
        }

        hud.notilist[uniqueID] = data
    else
        hud.notilist[uniqueID] = nil
    end
end)

function hud:leftTimer(wok, text, time)
    -- dynamic size adjust
    local x, y, w, h = wok.x, wok.y, 0, wok.h

    -- add time icon
    surface.SetFont("nutDHUDFont")
    local tx, ty = surface.GetTextSize(text)
    w = w + tx + sscale(10)
    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    nut.util.drawText(Format(text, time - CurTime()), x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "nutDHUDFont")

    return w, h
end

function hud:leftObj(wok, title, desc)
    local x, y, w, h = wok.x, wok.y, wok.w, wok.h

    dbox(wok.rnd or 8, x, y, w, h, ColorAlpha(color_black, 200))
    nut.util.drawText(title, x + w/2, y + h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "nutDHUDFont")
end


function hud:draw()
    local client = LocalPlayer()
    local char = client:getChar()

    if (!char or !client:Alive()) then return end

    hud:drawNoti()
    hud:safe()

    local margin = sscale(5)
    local w, h = ScrW(), ScrH()

    local perc = {}
    perc.w = sscale(150)
    perc.h = sscale(15)
    perc.x = w/2 - perc.w/2
    perc.y = h - perc.h - sscale(5)
    hud:compass(perc)

    local perc = {}
    perc.w = sscale(100)
    perc.h = sscale(15)
    perc.x = sscale(5)
    perc.y = h - perc.h - sscale(5)
    hud:edgyBar(perc)
    
    local oldX = perc.x
    perc.h = sscale(15)
    perc.x = perc.x + perc.w + sscale(5)
    perc.w = sscale(50)
    perc.y = perc.y
    
	local rep, repDiv = char:getRep(), nut.config.get("maxRep", 1500)/SCHEMA.rankLevels
    hud:drawText(perc, SCHEMA.ranks[math.floor(char:getRep()/repDiv)])

    perc.w = sscale(30)
    perc.h = sscale(25)
    perc.x = oldX
    perc.y = perc.y - perc.h - margin
    hud:percDisp(perc, "방사능", 0, true)
    perc.x = perc.x + perc.w + margin
    hud:percDisp(perc, "허기", math.Round((1 - client:getHungerPercent())*100))
    perc.x = perc.x + perc.w + margin
    hud:percDisp(perc, "행동력", math.Round(client:getLocalVar("stm", 0)))
    
    perc.w = sscale(50)
    perc.h = sscale(15)
    perc.x = sscale(5)

    if (client:getHungerPercent() >= 1) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "굶주림")
    end
    if (char:getData("b_bld")) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "출혈")
    end
    if (char:getData("b_leg")) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "골절")
    end
    if (char:getData("b_inf")) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "감염")
    end
    if (false) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "노출됨", "R")
    end
    if (client:getNetVar("brth")) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "지침", "k")
    end
    if (false) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "전파방해", "y")
    end
    if (!client:canEnterSafe()) then
        perc.y = perc.y - perc.h - margin
        hud:status(perc, "수배중", "R")
    end  

    if (table.Count(hud.notilist) > 0) then
        local perc = {}
        perc.x = sscale(10)
        perc.y = sscale(10)
        local margin = sscale(5)
        for k, v in pairs(hud.notilist or {}) do
            if (v.time < CurTime()) then
                hud.notilist[k] = nil
                continue
            end

            perc.w = sscale(v.w)
            perc.h = sscale(v.h)

            if (TYPE_TIMER) then
                perc.w = hud:leftTimer(perc, v.text, v.time)
            elseif (TYPE_OBJECTIVE) then
                
            end

            perc.y = perc.y + perc.h + margin 
        end
    end
end
hook.Add("HUDPaint", "hud.draw", hud.draw)
end
timer.Simple(1, initia)