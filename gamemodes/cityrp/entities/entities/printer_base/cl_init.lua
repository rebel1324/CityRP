--[[
Tomas
--]]
include("shared.lua")

local upgradeOptions = {
	power = "printerUpgPower", -- Power upgrade (upg amount)
	stability = "printerUpgStable", -- Stability (abs explod rate)
	cooler = "printerUpgCooler", -- Cooling efficiency
	speed = "printerUpgSpeed", -- Speed
}

local upgradeIcons = {
	power = "", -- power
	stability = "", -- stable
	cooler = "", -- cooler
	speed = "", -- speed
}

surface.CreateFont("nutPrinterIcons", {
	font = "nsicons",
	size = 60,
	extended = true,
})
	
local rectSize = 80
local function PRINTER_UPGRADE_RENDER(self, ent, w, h)
	local mx, my = self:mousePos()

	if (self.entity:getNetVar("locked")) then
		surface.SetDrawColor(200, 20, 20, 200)
		surface.DrawRect(0, 0, w, h)
		nut.util.drawText(L"locked", w/2, h/2, color_white, 1, 1, "nutATMTitleFont")
	else
		if (!self.hasFocus) then
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)
			nut.util.drawText(L"upgradePrinterTouch", w/2, h/2, color_white, 1, 1, "nutATMTitleFont")
		else
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, w, h)

			local ah = h*0.2
			local aw = w - rectSize * 1.4
			self.currentButton = nil
			
			nut.util.drawText(L"upgradePrinter", 40, ah, color_white, 3, 3, "nutATMTitleFont")

			ah = ah - 5
			
			local entity = self.entity
			for upgrade, _ in pairs(entity.printerUpgrades) do
				local ba, bb = aw, ah
				local bc, bd = rectSize, rectSize

				local bool = self:cursorInBox(ba, bb, bc, bd)

				if (bool) then
					surface.SetDrawColor(60, 70, 110)
					self.currentButton = upgrade
				else
					surface.SetDrawColor(80, 89, 123)
				end

				surface.DrawRect(ba, bb, bc, bd)
				draw.DrawText( upgradeIcons[upgrade], "nutPrinterIcons", ba + bc * .5, ah + 11, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
				aw = aw - rectSize * 1.1
			end
			
			if (self.hasFocus) then
				surface.SetDrawColor(255, 255, 255)
				surface.DrawRect(mx, my, 5, 5)
			end
		end
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


local offMat = Material("rebel1324/printers/error")
function ENT:Draw()
	if (self:GetEnabled()) then
		self:DrawModel()
	else
		render.MaterialOverrideByIndex(2, offMat)
		self:DrawModel()
		render.MaterialOverrideByIndex()
	end
	
	if ( halo.RenderedEntity() == self ) then return end
	if self:GetPos():Distance( LocalPlayer():GetPos() ) > 512 then return end

	local Pos, Ang, pWidth = self:GetPos(), self:GetAngles()

	Ang:RotateAroundAxis(Ang:Right(), 7)

	Ang = self:GetAngles()
	Ang:RotateAroundAxis(Ang:Up(), 0)
	Ang:RotateAroundAxis(Ang:Right(), 29)

	self.upgrades.pos = Pos + self:GetUp() * 3.7  + self:GetForward() * 25.4 + self:GetRight() * 9.7
	self.upgrades.ang = Ang
	self.upgrades.ent = self

	self.upgrades.w = 18
	self.upgrades.h = 2.5

	self.upgrades:think()
	self.upgrades:render()
	
	self:SetCycle(RealTime())
	
	self.upgrades.renderCode = PRINTER_UPGRADE_RENDER
	self.upgrades.onMouseClick = function()
		local scr = self.upgrades
		
		if (scr) then
			netstream.Start("printerUpgrade", scr.currentButton, scr.entity) 
		end
	end
end

local gap = 25
hook.Add("HUDPaint", "moneyprinter", function()
	local client = LocalPlayer()
	local screen = CURRENT_SCREEN_MODULE

	if (screen) then
		local entity = screen.entity

		if (IsValid(entity)) then
			local upgrade = screen.currentButton

			local keys = entity.printerUpgrades
			if (keys and keys[upgrade]) then
				local getFunc = entity[("Get" .. keys[upgrade])]

				local x, y = ScrW()*.5, ScrH()*.55
				nut.util.drawText(upgradeOptions[upgrade], x, y, color_white, 1, 1, "nutMediumFont")

				local money = entity:GetUpgradeMoney(upgrade)
				if (money >= 0) then
					y = y + gap
					nut.util.drawText(nut.currency.get(entity:GetUpgradeMoney(upgrade)), x, y, color_white, 1, 1, "nutMediumFont")
				end

				if (getFunc) then
					if (entity.upgradeText) then
						y = y + gap
						nut.util.drawText(L"level" .. " " .. getFunc(entity) .. " (" .. entity.upgradeText[upgrade](entity) .. ")", x, y, color_white, 1, 1, "nutMediumFont")
					end
				end
			end
		end
	end
end)

function ENT:onShouldDrawEntityInfo()
	return true
end

function ENT:onDrawEntityInfo(alpha)
	local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*0):ToScreen()
	local x, y = position.x, position.y
	local heat = (math.Round(self:GetTemperature() / self.setting.spec.maxTemp * 100) .. "%")

	nut.util.drawText(L(self.PrintName), x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
	nut.util.drawText(L("moneyPrinterInfo", nut.currency.get(self:GetMoney()), heat), x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	nut.util.drawText(L("moneyPrinterHelp"), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	nut.util.drawText(L("moneyPrinterHelp2"), x, y + 48, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
end