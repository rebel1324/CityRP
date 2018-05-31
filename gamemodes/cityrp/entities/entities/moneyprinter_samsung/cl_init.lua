--[[
Tomas
--]]
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

local upgradeOptions = {
	"printerUpgPower",
	"printerUpgStable",
	"printerUpgCooler",
	"printerUpgSpeed",
}

local upgradeIcons = {
	"", -- power
	"", -- stable
	"", -- cooler
	"", -- speed
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

surface.CreateFont("nutPrinterIcons", {
	font = "nsicons",
	size = 32,
	extended = true,
})
	
local function PRINTER_UPGRADE_RENDER(self, ent, w, h)
	local mx, my = self:mousePos()
	
	surface.SetDrawColor(0, 0, 0, 200)
	surface.DrawRect(0, 0, w, h)

	local ah = h*0.2
	local aw = w - 40 - 40
	self.currentButton = nil
	
	nut.util.drawText(L"upgradePrinter", 40, ah, color_white, 3, 3, "nutBigFont")

	ah = ah - 5
	for i = 1, 4 do
		local ba, bb = aw, ah
		local bc, bd = 55, 55

		local bool = self:cursorInBox(ba, bb, bc, bd)
		local text = upgradeOptions[i]

		if (bool) then
			surface.SetDrawColor(60, 70, 110)
			self.currentButton = i
		else
			surface.SetDrawColor(80, 89, 123)
		end

		surface.DrawRect(ba, bb, bc, bd)
		draw.DrawText( upgradeIcons[i], "nutPrinterIcons", ba + bc * .5, ah + 11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		aw = aw - 55 * 1.1
	end
	
	if (self.hasFocus) then
		surface.SetDrawColor(255, 255, 255)
		surface.DrawRect(mx, my, 5, 5)
	end
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

	self.upgrades = nut.screen.new(13.1, 15.5, 0.042)
	
	self.upgrades.noClipping = false
	self.upgrades.fadeAlpha = 1
	self.upgrades.idxAlpha = {}
	self.upgrades.dorp = 1
	self.upgrades.entity = self

	self.upgrades.w = 10.5
	self.upgrades.h = 1.5
	self.upgrades.scale = .02

	self.upgrades.renderCode = PRINTER_UPGRADE_RENDER
	self.upgrades.onMouseClick = function()
		local scr = self.upgrades
		netstream.Start("printerUpgrade", scr.currentButton, scr.entity) 
	end

	self.SpeedPrice = 200
	self.CoolerPrice = 100

	timer.Simple(0.1, function()
		self:SetSequence("print")
		self:SetPlaybackRate(0)
	end)
end


function ENT:Draw()
	self:DrawModel()
	
	if ( halo.RenderedEntity() == self ) then return end
	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 512 then return end

	local Pos, Ang, pWidth = self:GetPos(), self:GetAngles()

	Ang:RotateAroundAxis(Ang:Right(), 7)

	Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Up(), 0)
	Ang:RotateAroundAxis(Ang:Right(), 30)

	self.upgrades.pos = Pos + self:GetUp() * 3.3  + self:GetForward() * 15.8 + self:GetRight() * 5.2
	self.upgrades.ang = Ang
	self.upgrades.ent = self

	self.upgrades:think()
	self.upgrades:render()
	
	self:SetCycle(RealTime())
	
	self.upgrades.renderCode = PRINTER_UPGRADE_RENDER
	self.upgrades.onMouseClick = function()
		local scr = self.upgrades
		netstream.Start("printerUpgrade", scr.currentButton, scr.entity) 
	end
end

local gap = 25
hook.Add("HUDPaint", "moneyprinter", function()
	local client = LocalPlayer()
	local screen = CURRENT_SCREEN_MODULE

	if (screen) then
		local entity =  screen.entity

		if (IsValid(entity)) then
			local upgrade = screen.currentButton

			if (upgrade) then
				local x, y = ScrW()*.5, ScrH()*.55
				nut.util.drawText(upgradeOptions[upgrade], x, y, color_white, 1, 1, "nutMediumFont")
				y = y + gap
				nut.util.drawText(nut.currency.get(upgradeOptionsMoney[upgrade](entity)), x, y, color_white, 1, 1, "nutMediumFont")
				y = y + gap
				nut.util.drawText(upgradeOptionsDisplay[upgrade](entity), x, y, color_white, 1, 1, "nutMediumFont")
			end
		end
	end
end)

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
