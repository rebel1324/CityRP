/*---------------------------------------------------------------------------
Tomas
---------------------------------------------------------------------------*/
include("shared.lua")

surface.CreateFont( "SmallInfoFont", {
	font = "Arial",
		extended = true,
	size = 12,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "InfoFont", {
	font = "Arial",
		extended = true,
	size = 17,
	weight = 800,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BigInfoFont", {
	font = "Arial",
		extended = true,
	size = 32,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "BiggestInfoFont", {
	font = "Arial",
		extended = true,
	size = 30,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

local pHeight = 290
local pWidth = 279
local function drawCircl( x, y, radius, seg, ang )
	local cir = {}
	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, (ang/5) do
		local a = math.rad( ( i / (ang/5) ) * -ang +180)
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end
	surface.DrawPoly( cir )
end

CURRENT_LAW_COUNT = 0
timer.Create("memedPolices", 1, 0, function()
	local neat = 0
	for k, v in ipairs(player.GetAll()) do
		local char = v:getChar()

		if (char) then
			local class = char:getClass()
			local classData = nut.class.list[class]

		if (classData and classData.law) then
			neat = neat + 1
			end
		end
	end
	CURRENT_LAW_COUNT = neat
end)


function surface.DrawPercRect(x, y, w, h, perc, sten)
        local d
        local rx, ry
        local px, py

        if (sten) then
            w, h = w*2, h*2
            d = w/2
        else
            d = math.sqrt(w^2 + h^2)/2
        end

        px, py = math.sin(perc*math.pi*2), -math.cos(perc*math.pi*2)
        rx, ry = math.Clamp(x + px*d, x - w/2, x + w/2), math.Clamp(y + py*d, y - h/2, y + h/2)
    
        if (perc < .25) then
            triangle = {
                { x = rx , y = ry },
                { x = x + w/2, y = y - h/2 },
                { x = x + w/2, y = y + 0 },
                { x = x , y = y + 0 },
            }
            surface.DrawPoly( triangle )
        end
        
        if (perc < .5) then
            triangle = {
                { x = x , y = y - 0 },
                { x = x + w/2, y = y - 0 },
                { x = x + w/2, y = y + h/2 },
                { x = x , y = y + h/2 },
            }
            if (perc > .25) then
                triangle[2] = { x = rx , y = ry }
                if (perc > (.25 + .25/2)) then
                    triangle[3] = { x = rx , y = ry }
                end
            end
            surface.DrawPoly( triangle)
        end

        if (perc < .75) then
            triangle = {
                { x = x - w/2, y = y - 0 },
                { x = x + 0, y = y - 0 },
                { x = x + 0, y = y + h/2 },
                { x = x - w/2, y = y + h/2 },
            }
            if (perc > .5) then
                triangle[3] = { x = rx , y = ry }
            end
            surface.DrawPoly( triangle )
        end

        triangle = {
            { x = x - w/2, y = y - h/2 },
            { x = x + 0, y = y - h/2 },
            { x = x + 0, y = y + 0 },
            { x = x - w/2, y = y + 0 },
        }
        if (perc > .75) then
            triangle[4] = { x = rx , y = ry }
            if (perc > (.75 + .25/2)) then
                triangle[1] = { x = rx , y = ry }
            end
        end
        surface.DrawPoly( triangle )
end

local mat = Material("ring_thicc.png")
local function drawRingCunt(x, y, w, h, perc, color, cirMat)
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
        
        -- why
        surface.SetDrawColor( 0, 0, 0, 1 )
        draw.NoTexture()
        surface.DrawPercRect(x, y, w, h, perc, true)

		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	
    surface.SetDrawColor(color.r, color.g, color.b)
    cirMat = cirMat or mat
    surface.SetMaterial(cirMat)
    surface.DrawTexturedRect(x - w/2, y - h/2, w, h)
	render.SetStencilEnable(false)
end

function PRINTER_INFORMATION_RENDER(self, ent, w, h)
	if (self.ent:getNetVar("locked")) then
			surface.SetDrawColor(200, 55, 22, 250)
			surface.DrawRect(0, 0, w, h-10)	
		
			local tx, ty = draw.SimpleText("P", "nutIconsBig", w/2, (h-10)/2, color_white, 1, 4)
			tx, ty = draw.SimpleText(L"printerLocked", "nutBigFont", w/2, (h-10)/2, color_white, 1, 5)
		return
	end

	surface.SetDrawColor(57, 66, 100)
	surface.DrawRect(0, 0, pWidth, 290)

	surface.SetDrawColor(80, 89, 123)
	surface.DrawRect(0, 0, pWidth, 50)

	surface.SetDrawColor(17, 168, 171)
	surface.DrawRect(0, 50, pWidth, 3)
	for i = 0, 3 do
		surface.SetDrawColor(80, 89, 123)
		surface.DrawRect(i*70, pHeight, 69, 65)
	end

	surface.SetDrawColor(230, 76, 101)
	surface.DrawRect(0, pHeight, 69, 3)

	surface.SetDrawColor(17, 168, 171)
	surface.DrawRect(70, pHeight, 69, 3)

	surface.SetDrawColor(252, 177, 80)
	surface.DrawRect(140, pHeight, 69, 3)

	surface.SetDrawColor(79, 196, 246)
	surface.DrawRect(210, pHeight, 69, 3)
	
	local Owner = self.ent:Getowning_ent()
	
	if IsValid(Owner) and Owner:Nick() then 
		Owner = Owner:Nick()
	else 
		Owner = "Unknown" 
	end

	local magnumDong = L("printerOwner", Owner, L(self.ent.CrclCfg.Name))
	surface.SetFont("BigInfoFont")
	local tx, ty = surface.GetTextSize(magnumDong)

	if (tx > pWidth) then
		draw.DrawText(magnumDong, "BigInfoFont", (pWidth+tx) - (pWidth+tx*1.1)*(RealTime()*0.3%1), 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT )
	else
		draw.DrawText(magnumDong, "BigInfoFont", pWidth/2, 10, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	end

	draw.DrawText(L"printerFinal", "InfoFont", 34, pHeight * 1.04, Color( 131, 140, 171, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText("$"..
	self.ent:CalcMoney()
	, "BiggestInfoFont", 34, pHeight * 1.09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )

	draw.DrawText(L"printerMul", "InfoFont", 104, pHeight * 1.04, Color( 131, 140, 171, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText("x"..string.format("%.2f", math.Clamp(0.5, CURRENT_LAW_COUNT/3, 2)), "BiggestInfoFont", 104, pHeight * 1.09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
	
	draw.DrawText(L"printerSpeed", "InfoFont", 174, pHeight * 1.04, Color( 131, 140, 171, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText(self.ent:GetDTInt(4).."%", "BiggestInfoFont", 174, pHeight * 1.09, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )

	draw.DrawText(L"printerLevel", "InfoFont", 244, pHeight * 1.04, Color( 131, 140, 171, 255 ), TEXT_ALIGN_CENTER )

	draw.DrawText( math.floor(self.ent:GetDTFloat(1)/100), "BiggestInfoFont", 245, pHeight * 1.09, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

	draw.DrawText(L"printerDone", "BiggestInfoFont", pWidth/2, pHeight*0.49, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	draw.DrawText( "$"..self.ent:GetMoney(), "BigInfoFont", pWidth/2, pHeight*0.58, Color( 144, 153, 183, 255 ), TEXT_ALIGN_CENTER )

	surface.SetMaterial(Material("ring.png"))
	surface.SetDrawColor(79, 196, 246)
	local r = 150*.94
	surface.DrawTexturedRect(pWidth/2 - r/2, pHeight*0.59 - r/2, r, r)
	 r = 150
	drawRingCunt(pWidth/2, pHeight*0.59, r, r, 1-(self.ent:GetNextPrint()-CurTime())/self.ent:GetPrintRate(), Color(230, 76, 101))

	if (true) then return end
	do
		local a, b, ra, rb = .5, 0, 0, .5
		local cir = {
			{ x = pWidth/2, y = y, u = a, v = a},
			{ x = pWidth/2, y = y - r, u = b, v = a},
			{ x = pWidth/2 + r, y = y - r, u = b, v = b},
			{ x = pWidth/2 + r, y = y, u = a, v = b},
		}
		surface.DrawPoly( cir )

		local a, b = 0, .5
		local cir = {
			{ x = pWidth/2, y = y + r, u = a, v = b},
			{ x = pWidth/2, y = y, u = b, v = b},
			{ x = pWidth/2 + r, y = y, u = b, v = a},
			{ x = pWidth/2 + r, y = y + r, u = a, v = a},
		}
		surface.DrawPoly( cir )

		local a, b = 0, .5
		local cir = {
			{ x = pWidth/2 - r, y = y + r, u = a, v = a},
			{ x = pWidth/2 - r, y = y, u = b, v = a},
			{ x = pWidth/2, y = y, u = b, v = b},
			{ x = pWidth/2, y = y + r, u = a, v = b},
		}
		surface.DrawPoly( cir )

		local a, b = .5, 0
		local cir = {
			{ x = pWidth/2 - r, y = y, u = a, v = b},
			{ x = pWidth/2 - r, y = y - r, u = b, v = b},
			{ x = pWidth/2, y = y - r, u = b, v = a},
			{ x = pWidth/2, y = y, u = a, v = a},
		}
		surface.DrawPoly( cir )
	end
end

local upgradeOptions = {
	"printerUpgPower",
	"printerUpgStable",
	"printerUpgCooler",
	"printerUpgSpeed",
}
local upgradeOptionsMoney = {
	function(ent) return math.Round((ent:GetDTInt(2)+1) * ent.CrclCfg.PowerUpgradePrice) end,
	function(ent) return math.Round((ent:GetDTInt(3)+1) * ent.CrclCfg.StabilityUpgradePrice) end,
	function(ent) return math.Round(ent.CrclCfg.CoolingUpgradePrice) end,
	function(ent) return math.Round(ent.CrclCfg.SpeedUpgradePrice * ent:GetDTInt(4)/2) end,
}

local upgradeOptionsDisplay = {
	function(ent) return L"level" .. " " .. ent:GetDTInt(2) end,
	function(ent) return L"level" .. " " .. ent:GetDTInt(3) end,
	function(ent) return ent:GetDTBool(0) and L"installed" or L"notInstalled" end,
	function(ent) return ent:GetDTInt(4) .. "%" end,
}

function PRINTER_UPGRADE_RENDER(self, ent, w, h)
	if (self.ent:getNetVar("locked")) then
			surface.SetDrawColor(200, 55, 22, 250)
			surface.DrawRect(0, 0, w, h-10)	
		
			local tx, ty = draw.SimpleText("P", "nutIconsBig", w/2, (h-10)/2, color_white, 1, 4)
			tx, ty = draw.SimpleText(L"printerLocked", "nutBigFont", w/2, (h-10)/2, color_white, 1, 5)
		return
	end

	local mx, my = self:mousePos()
	
	surface.SetDrawColor(57, 66, 100)
	surface.DrawRect(0, 0, w, h)

	draw.DrawText(L"printerUpgMenu", "BigInfoFont", w/2, 20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
	
	local ah = h/4*0.9
	self.currentButton = nil

	for i = 1, 4 do
		local ba, bb = w*0.1, ah
		local bc, bd = w*0.8, 40

		local bool = self:cursorInBox(ba, bb, bc, bd)
		local text = upgradeOptions[i]

		if (bool) then
			self.currentButton = i
			surface.SetDrawColor(60, 70, 110)
			text = L(upgradeOptions[i]) .. " - " .. nut.currency.get(upgradeOptionsMoney[i](self.ent))
		else
			surface.SetDrawColor(80, 89, 123)
			text = L(upgradeOptions[i]) .. " - " .. upgradeOptionsDisplay[i](self.ent)
		end

		surface.DrawRect(ba, bb, bc, bd)
		draw.DrawText( text, "BigInfoFont", w/2, ah + 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		ah = ah + 40 * 1.3
	end
	
	if (self.hasFocus) then
		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(mx, my, 5, 5)
	end
end

function PRINTER_UPGRADE_CLICK(self)
	netstream.Start("printerUpgrade", self.currentButton, self.ent) 
end

function ENT:Initialize()
	self.Money = 0
	self.rot = 0
	self.last = SysTime()
	self.Speed = 20
	self.Heat = 0
	self.PlusMoney = 0
	self.LvlExp = 100
	self.CurLawsMoney = 0

	self.screen = nut.screen.new(11.7, 15.5, 0.042)
	
	self.screen.noClipping = false
	self.screen.fadeAlpha = 1
	self.screen.idxAlpha = {}
	self.screen.dorp = 1
	self.screen.entity = self

	self.screen.renderCode = PRINTER_INFORMATION_RENDER

	self.upgrades = nut.screen.new(13.1, 15.5, 0.042)
	
	self.upgrades.noClipping = false
	self.upgrades.fadeAlpha = 1
	self.upgrades.idxAlpha = {}
	self.upgrades.dorp = 1
	self.upgrades.entity = self

	self.upgrades.renderCode = PRINTER_UPGRADE_RENDER
	self.upgrades.onMouseClick = PRINTER_UPGRADE_CLICK
	self.SpeedPrice = 200
	self.CoolerPrice = 100
end


function ENT:Draw()
	self:DrawModel()
	
	if ( halo.RenderedEntity() == self ) then return end
	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 512 then return end

	local Pos, Ang, pWidth = self:GetPos(), self:GetAngles()

	Ang:RotateAroundAxis(Ang:Right(), 7)

	self.screen.pos = Pos + Ang:Up() * 3.8 + Ang:Forward() * 14.6 + Ang:Right() * -26.0
	self.screen.ang = Ang
	self.screen.ent = self

	self.screen.renderCode = PRINTER_INFORMATION_RENDER
	self.screen:render()
	
	Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Up(), 90)

	self.upgrades.pos = Pos + Ang:Up() * 2.5  + Ang:Forward() * 38 + Ang:Right() * -4.5
	self.upgrades.ang = Ang
	self.upgrades.ent = self

	self.upgrades.w = 16
	self.upgrades.h = 12.5

	self.upgrades.renderCode = PRINTER_UPGRADE_RENDER
	self.upgrades.onMouseClick = PRINTER_UPGRADE_CLICK
	self.upgrades:think()
	self.upgrades:render()
end


local EFFECT = {}
function EFFECT:Init( data ) 
	self:SetNoDraw(true)

	local pos = data:GetOrigin()
	local scale = data:GetScale() or 1
	local fucker = data:GetNormal() or 1
	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
	self.emitter = WORLDEMITTER

	for i = 1, math.random(15, 28) do
		timer.Simple(math.Rand(0, .5), function()
			if (WORLDEMITTER) then
				local smoke = WORLDEMITTER:Add(nut.util.getMaterial("effects/money.png"), pos + VectorRand()*3 + fucker:Angle():Right() * math.Rand(-10, 10))
				smoke:SetVelocity((fucker:Angle() + Angle(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1))*40):Forward()*150)
				smoke:SetDieTime(math.Rand(.4,.5))
				smoke:SetStartAlpha(math.Rand(188,211))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(3,4)*scale)
				smoke:SetEndSize(math.random(2,3)*scale)
				smoke:SetRoll(math.Rand(180,480))
				smoke:SetRollDelta(math.Rand(-3,3))
				smoke:SetGravity(Vector( 0, 0, -222))
				smoke:SetAirResistance(50)
			end
		end)
	end
end

effects.Register( EFFECT, "btMoneySplat" )
