PLUGIN.name = "CityRP HUD"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds good HUD."

if (SERVER) then return end

function SCHEMA:LoadFonts(font, genericFont)
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

function SCHEMA:CanDrawAmmoHUD()
	return false
end

function SCHEMA:HUDPaint()
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