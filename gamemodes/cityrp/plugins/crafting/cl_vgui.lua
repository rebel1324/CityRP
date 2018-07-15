local craftingWidth = ScrW()*.3
hook.Add("TooltipInitialize", "nutCraftingTooltip", function(self, panel)
	if (panel.craftingID) then
		self.markupObject = nut.markup.parse(self:GetText(), craftingWidth)
		self:SetText("")
		self:SetWide(math.max(craftingWidth, 200) + 15)
		self:SetHeight(self.markupObject:getHeight() + 20)
		self.isCraftingTooltip = true
	end
end)

hook.Add("TooltipPaint", "nutCraftingTooltip", function(self, w, h)
	if (self.isCraftingTooltip) then
		nut.util.drawBlur(self, 10)
		surface.SetDrawColor(55, 55, 55, 120)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(255, 255, 255, 120)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

		if (self.markupObject) then
			self.markupObject:draw(15, 10)
		end

		return true
	end
end)

hook.Add("TooltipLayout", "nutCraftingTooltip", function(self)
	if (self.isCraftingTooltip) then
		return true
	end
end)


local PANEL = {}

local margin = 4
function PANEL:Init()
	self:Dock(TOP)
	self:SetTall(margin*2 + 32)
	self.name = self:Add("DLabel")
	self.name:Dock(FILL)
	self.name:DockMargin(margin * 2, margin, margin * 2, margin)
	self.name:SetFont("nutMediumFont")

	self.craft = self:Add("DButton")
	self.craft:Dock(RIGHT)
	self.craft:DockMargin(margin * 2, margin, margin * 2, margin)
	self.craft:SetFont("nutSmallFont")
	self.craft:SetWide(80)
	self.craft:SetText(L"craft")
	self.craft:SetTextColor(color_white)
end

function PANEL:Paint()
end

local function fnt(s, font)
	return string.format("<font=%s>%s</font>", font, s)
end
function PANEL:setBlueprint(info)
	self.name:SetText(L(info.name))
	self.craftingID = info.id

	self.craft.DoClick = function()
		netstream.Start("nutCraftItem", self.craftingID)
	end

	local s = ""
	s = s .. fnt(L(info.name), "nutMediumFont") .. "\n"
	s = s .. fnt(L(info.desc), "nutSmallFont") .. "\n"

	local req = ""
	for class, quantity in pairs(info.requiredItem) do
		local itemTable = nut.item.list[class]

		if (itemTable) then
			req = req .. "\n" .. L(itemTable.name) .. " x" .. quantity
		end
	end
	s = s .. fnt(L("craftingReq", req), "nutSmallFont")

	local final = ""
	for class, quantity in pairs(info.resultItem) do
		local itemTable = nut.item.list[class]

		if (itemTable) then
			if (quantity == true) then
				final = final .. "\n" .. L(itemTable.name)
			else
				final = final .. "\n" .. L(itemTable.name) .. " x" .. quantity
			end

		end
	end
	s = s .. fnt(L("craftingFinal", final), "nutSmallFont") .. "\n"

	self:SetTooltip(s)
end
vgui.Register("nutCraftingRow", PANEL, "DPanel")

local PANEL = {}

function PANEL:Init()
    if (IsValid(nut.gui.crafting)) then
        nut.gui.crafting:Remove()
    end
    nut.gui.crafting = self

    self:SetSize(800, 600)
    self:Center()
    self:MakePopup()

    self.title = self:Add("DLabel")
    self.title:Dock(TOP)
	self.title:SetFont("nutBigFont")
	self.title:SetTall(26)
	self.title:DockMargin(2, 10, 2, 10)
	self.title:SetText(L"crafting")

	local cunt = self:Add("DPanel")
	cunt:Dock(FILL)

	self.category = cunt:Add("DScrollPanel")
	self.category:Dock(LEFT)
	self.category:SetWide(0 or math.min(200, self:GetWide() * .3))

    self.content = cunt:Add("DScrollPanel")
    self.content:Dock(FILL)
    
    for id, info in pairs(nut.craft.list) do
        local panel = self.content:Add("nutCraftingRow")
        panel:setBlueprint(info)   
    end
end
vgui.Register("nutCraftingMenu", PANEL, "DFrame")


