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

function PANEL:setBlueprint(info)
	self.name:SetText(L(info.name))
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

	local cunt = self:Add("DPanel")
	cunt:Dock(FILL)

	self.category = cunt:Add("DScrollPanel")
	self.category:Dock(LEFT)
	self.category:SetWide(math.min(200, self:GetWide() * .3))

    self.content = cunt:Add("DScrollPanel")
    self.content:Dock(FILL)
    
    for id, info in pairs(nut.craft.list) do
        local panel = self.content:Add("nutCraftingRow")
        panel:setBlueprint(info)   
    end
end
vgui.Register("nutCraftingMenu", PANEL, "DFrame")
