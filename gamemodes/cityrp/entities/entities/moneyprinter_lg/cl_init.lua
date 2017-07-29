/*---------------------------------------------------------------------------
Tomas
---------------------------------------------------------------------------*/
include("shared.lua")

function ENT:Initialize()
	self.Money = 0
	self.rot = 0
	self.last = SysTime()
	self.Speed = 20
	self.Heat = 0
	self.PlusMoney = 0
	self.LvlExp = 100
	self.CurLaws = 0
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