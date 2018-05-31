PLUGIN.name = "CityRP HUD"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds good HUD."

if (SERVER) then return end

NUT_CVAR_HUDTYPE = CreateClientConVar("nut_hudtype", 1, true)
TYPE_LEGACY_LACRP = 0
TYPE_LATEST_CITYRP = 1

function PLUGIN:ShouldHideBars()
	return true
end

function PLUGIN:LoadFonts(font, genericFont)
	surface.CreateFont("nutNumeric", {
		font = "HalfLife2",
		size = ScreenScale(15),
		weight = 1000,
		extended = true,	
	})
	surface.CreateFont("nutNumericName", {
		font = font,
		size = ScreenScale(10),
		weight = 1000,
		extended = true,	
	})
	surface.CreateFont("nutHUDNumeric", {
		font = "Century Gothic",
		size = ScreenScale(10),
		weight = 500,
		extended = true,	
		shadow = true,
	})
	surface.CreateFont("nutHUDNumericName", {
		font = font,
		size = ScreenScale(7),
		weight = 500,
		extended = true,	
		shadow = true,
	})
	surface.CreateFont("s_aadablur", {
		font = "fontello",
		size 		= ScreenScale(10),
		blursize = 2,
		scanlines = 1,
		antialias = true
	})
	surface.CreateFont("s_aada", {
		font = "fontello",
		size 		= ScreenScale(10),
		blursize = 0,
		scanlines = 1,
		antialias = true
	})
	surface.CreateFont("nutSmallFont2", {
		font = "Malgun Gothic",
		size = math.max(ScreenScale(6), 17),
		weight = 500,
		extended = true,	
	})
	surface.CreateFont(
		"s_weaponiconsselected", 
		{
			font 		= "HalfLife2",
			size 		= ScreenScale(20),
			blursize = 5,
			scanlines = 2,
			--additive 	= true,  --true
			antialias = true
		} 
	)
	surface.CreateFont(
		"s_weaponicons", 
		{
			font 		= "HalfLife2",
			size 		= ScreenScale(20),
			blursize = 0.5,
			scanlines = 1,
			--additive 	= true,  --true
			antialias = true
		} 
	)
end
	

local math=math
local surface=surface
local delayedHP = 0
local bubbleMaterial = Material("particle/warp1_warp","alphatest")
local curBubbles = {}


local aspect = {
	"health",
	"stamina",
	"hunger",
}
local aspect2 = {
	function(client) return math.max(0, client:Health()) end,
	function(client) return math.Round(client:getLocalVar("stm", 0)) end,
	function(client) return math.Round((1 - client:getHungerPercent())*100) end,
}
local status = {
	hasLicense = function(client, char) return client:getNetVar("license") end,
	arrested = function(client, char) return client:isArrested() end,
	onHit = function(client, char) return false end,
	onWanted = function(client, char) return client:isWanted() end,
	onWarrant = function(client, char) return client:getNetVar("searchWarrant") end,
	bleeding = function(client, char) return false end,
	legbroken = function(client, char) return client:isLegBroken() end,
	protected = function(client, char) local p = client:isProtected() return (p > 0), p*100 end,
}

function PLUGIN:CanDrawAmmoHUD()
	if (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LEGACY_LACRP) then

	elseif (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LATEST_CITYRP) then
		return false
	end
end

local reservebubble
local function addBubble()
	if #curBubbles > 15 then return end
	if reservebubble then
		reservebubble.x = math.random(-10,70)
		reservebubble.y = -2
		reservebubble.size = math.random(4,12)
		reservebubble.speed = math.random(20,40)
		reservebubble.alpha = 0
		reservebubble.timer = 0
		table.insert(curBubbles,reservebubble)
		reservebubble= nil
		return
	end
	table.insert(curBubbles,{
		x = math.random(-10,70),
		y = -2,
		size = math.random(4,12),
		speed = math.random(20,40),
		alpha = 0,
		timer = 0
	})
end

function PLUGIN:Think()
	if (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LEGACY_LACRP) then

	elseif (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LATEST_CITYRP) then
		addBubble()
		
		for i,v in pairs(curBubbles) do
			local y = v.y

			if y > delayedHP - 30 then
			reservebubble = table.remove(curBubbles,i)
		
			continue
			else
				v.y = v.y + FrameTime()*v.speed
				v.timer = v.timer + FrameTime()*v.speed/30
				if v.alpha < 60 then
					v.alpha = v.alpha + FrameTime()*70
				end
			end
		end
	end
end

local function drawCircle( x, y, radius )
	surface.SetMaterial(Material("hud_circle.png"))
	surface.DrawTexturedRect(x - radius, y - radius, radius * 2, radius * 2)
end

local function drawPercCircle( x, y, radius, frac, col )
	render.ClearStencil()
	render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(1)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetBlend(0) --don't visually draw, just stencil
		
		surface.SetDrawColor( 0, 0, 0, 1 )
		local r = radius * 2
		surface.DrawRect(x - radius, y + radius - r*frac, r,r*frac)

		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
		surface.SetDrawColor(col)
		drawCircle(x,y, radius)
	render.SetStencilEnable(false)
end

local gap = 3
local function drawBar(x, y, w, h, col, text, value)
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(x, y, w, h)	
	
	surface.SetDrawColor(col.r, col.g, col.b, 255)
	surface.DrawRect(x + gap, y + gap, w - gap*2, h - gap*2)	

	local tx, ty = draw.SimpleText(value, "nutNumeric", x + w*.03 + 2, y + h/2 - 1, color_black, 3, 1)
	tx, ty = draw.SimpleText(value, "nutNumeric", x + w*.03, y + h/2 - 4, color_white, 3, 1)

	local ax, ay = draw.SimpleText(L(text), "nutNumericName", x + w*.03 + 2 + tx * 1.1, y + h/2 + 2, color_black, 3, 1)
	ax, ay = draw.SimpleText(L(text), "nutNumericName", x + w*.03 + tx * 1.1, y + h/2, color_white, 3, 1)
end

local txtcol = Color(200,200,200,220)
local tc = TEXT_ALIGN_CENTER
local bg1 = Color(20,20,20,200)
local bg2 = Color(255,255,255,6)
function PLUGIN:HUDPaint()
	if (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LEGACY_LACRP) then
		local ply = LocalPlayer()
		if not ply:IsValid() then return end
		local char = ply:getChar()
		if (!char) then return end

		local DelayHP = delayedHP
		if DelayHP == nil then
			DelayHP = LocalPlayer():Health()
			delayedHP = DelayHP
		end
		
		local maxHealth = 100
		local maxHealthColor = 120
		local ypos = 120
		local DelayHPC=math.Clamp(DelayHP, 0, maxHealth)
		local HPColor = ColorAlpha(HSVToColor( (DelayHPC * maxHealth ) / maxHealthColor, 1, 0.8 ), 55)
		local HPColor2 = HSVToColor( (DelayHPC * maxHealth ) / maxHealthColor, 1, 1 )
		local HPBgColor = ColorAlpha(HSVToColor( (DelayHPC * maxHealth ) / maxHealthColor, 1, 0.4 ), 155)
		local ExtraSize = 2

		local SW = ScrW()
		local SH = ScrH()
		local Size = SH/15
		local ft =FrameTime()
		
		local hp = ply:Health()
		delayedHP = Lerp(FrameTime() * 3, delayedHP, hp)
	
		local cx,cy = Size*0.5 + Size, SH - Size*0.5 - Size
		do
			if (LocalPlayer():isProtected() > 0) then
				surface.SetDrawColor(Color(255, 255, 255, 155))
				drawCircle( cx,cy, Size + ExtraSize*3)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				drawCircle( cx,cy, Size )
			end

			surface.SetDrawColor(bg1)
			drawCircle( cx,cy, Size + ExtraSize)
				
			local hp = math.ceil(DelayHP)
			surface.SetDrawColor(bg2)
			drawCircle( cx,cy, Size)
						
			drawPercCircle(cx, cy, Size, hp/100, HPBgColor)
							
			-- BUBBLES
			surface.SetMaterial(bubbleMaterial)
			for _,v in pairs(curBubbles) do
				
				local x = v.x
				local y = v.y
				local size = v.size
				local timer = v.timer
				
				surface.SetDrawColor(10,10,10,v.alpha)
				surface.DrawTexturedRect(Size + x + math.cos(timer)*2 ,SH - 50 - y,size,size)
			end
			
			HPColor.a=255
			nut.util.drawText(hp, cx, cy, HPColor2, 1, 1, "s_weaponiconsselected")
			nut.util.drawText(hp, cx, cy, txtcol, 1, 1, "s_weaponicons")
		end

		local energyMax = 100
		local staminaMax = 100
		local colorMax = 200
		local energy = (1 - LocalPlayer():getHungerPercent())*100
		local stamina = LocalPlayer():getLocalVar("stm", 0)
		energy = math.Round(energy, 0, energyMax)
		stamina = math.Round(stamina, 0, staminaMax)

		local energyColor = ColorAlpha(HSVToColor( (energy * energyMax ) / colorMax, 1, 0.8 ), 55)
		local energyBgColor = ColorAlpha(HSVToColor( (energy * energyMax ) / colorMax, 1, 0.4 ), 55)
		local energy2Color = HSVToColor( (energy * energyMax ) / colorMax, 1, 1 )
		local staminaColor = ColorAlpha(HSVToColor( 0.8, 1, (stamina * staminaMax ) / colorMax ), 55)
		local staminaBgColor = ColorAlpha(HSVToColor( 0.4, 1, (stamina * staminaMax ) / colorMax ), 55)
		local stamina2Color = HSVToColor( 1, 1, (stamina * staminaMax ) / colorMax )
		
		cx = cx + Size*1.6
		cy = cy + Size*0.5
		local engSize = Size * 0.5

		do
			surface.SetDrawColor(bg1)
			drawCircle( cx,cy, engSize + ExtraSize)
			surface.SetDrawColor(bg2)
			drawCircle( cx,cy, engSize)

			local col = energyColor
			if (energy <= 20) then	
				col = ((RealTime()*3)%2 < 1) and Color(255, 55, 55, 155) or energyColor
			end
			surface.SetDrawColor(energyColor)
			drawPercCircle(cx, cy, engSize, energy / energyMax, col)

			local text = "j"
			local tx,ty = cx, cy 
			nut.util.drawText(text, tx, ty, energy2Color, 1, 1, "s_aadablur")
			nut.util.drawText(text, tx, ty, txtcol, 1, 1, "s_aada")
		end
		
		cx = cx + Size*1.1
		do
			surface.SetDrawColor(bg1)
			drawCircle( cx,cy, engSize + ExtraSize)
			surface.SetDrawColor(bg2)
			drawCircle( cx,cy, engSize)
			drawPercCircle(cx, cy, engSize, stamina / staminaMax, staminaBgColor)
			
			local text = "@"
			local tx,ty = cx +1, cy+1
			nut.util.drawText(text, tx, ty, stamina2Color, 1, 1, "s_aadablur")
			nut.util.drawText(text, tx, ty, txtcol, 1, 1, "s_aada")
		end

		local class = char:getClass()
		local classData = nut.class.list[class]

		local tx, ty = nut.util.drawText("현금: " .. nut.currency.get(char:getMoney()), cx + engSize + engSize*.3, cy + engSize, color_white, 3, 4, "nutSmallFont2")
		local tx, ty = nut.util.drawText("통장: " .. nut.currency.get(char:getReserve()), cx + engSize + engSize*.3, cy + engSize - ty*1.1, color_white, 3, 4, "nutSmallFont2")
		if (classData) then
			nut.util.drawText("월급: " .. nut.currency.get(classData.salary), cx + engSize + engSize*.3, cy + engSize - ty*2.2, color_white, 3, 4, "nutSmallFont2")
		end

		local text = ""

		if (LocalPlayer():isArrested()) then
			text = text .. "% "
		end

		if (LocalPlayer():isWanted()) then
			text = text .. "R "
		end

		if (LocalPlayer():getNetVar("searchWarrant")) then
			text = text .. "0 "
		end

		if (LocalPlayer():getNetVar("license") ) then
			text = text .. "e "
		end

		local tx, ty = nut.util.drawText(text, SW/2, SH - 50, color_white, 1, 1, "nutIconsBig")
	elseif (NUT_CVAR_HUDTYPE:GetInt() == TYPE_LATEST_CITYRP) then
		local localPlayer = LocalPlayer()
		local client = localPlayer
		local char = client:getChar()

		if (!char) then return end

		local w, h = ScrW(), ScrH()
		local margin, height, width  = 30, h*.02, w*.11
		local bx, by = margin, h - margin - height
		drawBar(bx, by, width, height, Color(231, 76, 60), aspect[1], aspect2[1](client))

		bx = bx + width*1.1
		drawBar(bx, by, width, height, Color(241, 196, 15), aspect[2], aspect2[2](client))

		bx = bx + width*1.1
		drawBar(bx, by, width, height, Color(26, 188, 156), aspect[3], aspect2[3](client))

		local class = char:getClass()
		local classData = nut.class.list[class]

		bx, by = margin, h - margin + height*-0.1
		local tx, ty = draw.SimpleText(L(classData.name), "nutHUDNumericName", bx + width*.03, by - height*2, color_white, 3, 4)
		draw.SimpleText("+" ..nut.currency.get(classData.salary), "nutHUDNumeric", bx + width*.03 + tx + 5, by - height*2, color_white, 3, 4)

		by = by - height*1.5
		local tx, ty = draw.SimpleText(L"cash", "nutHUDNumericName", bx + width*.03, by - height*2, color_white, 3, 4)
		draw.SimpleText(nut.currency.get(char:getMoney()), "nutHUDNumeric", bx + width*.03 + tx + 5, by - height*2, color_white, 3, 4)
		
		by = by - height*1.5
		local tx, ty = draw.SimpleText(L"reserve", "nutHUDNumericName", bx + width*.03, by - height*2, color_white, 3, 4)
		draw.SimpleText(nut.currency.get(char:getReserve()), "nutHUDNumeric", bx + width*.03 + tx + 5, by - height*2, color_white, 3, 4)

		bx, by = w - margin - width, h - margin - height
		local weapon = client:GetActiveWeapon()
		if (IsValid(weapon)) then
			local ta, tb = weapon.Clip1(weapon), localPlayer.GetAmmoCount(localPlayer, weapon.GetPrimaryAmmoType(weapon))
				
			if (weapon.GetClass(weapon) != "weapon_slam" and ta > 0 or tb > 0) then

				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(bx, by, width, height)	
				surface.SetDrawColor(52, 73, 94, 255)
				surface.DrawRect(bx + gap, by + gap, width - gap*2, height - gap*2)	

				local tx, ty = draw.SimpleText(ta, "nutNumeric", bx + width*.05 + 2, by + height/2 - 1, color_black, 3, 1)
				tx, ty = draw.SimpleText(ta, "nutNumeric", bx + width*.05, by + height/2 - 4, color_white, 3, 1)

				local ax, ay = draw.SimpleText(tb, "nutNumericName", bx + width*.05 + 2 + tx * 1.1, by + height/2 + 2, color_black, 3, 1)
				ax, ay = draw.SimpleText(tb, "nutNumericName", bx + width*.05 + tx * 1.1, by + height/2, color_white, 3, 1)
				by = by - height * 1.5
			end
		end

		bx = bx + width * 0.95
		for k, v in pairs(status) do
			local bool, val = v(client, char)
			if (bool) then
				local ax, ay = draw.SimpleText(L(k, val), "nutHUDNumericName", bx, by, color_white, 2, 1)
				by = by - ay - 5
			end
		end
	end
end