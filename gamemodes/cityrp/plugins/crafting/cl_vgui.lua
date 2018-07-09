local PANEL = {}

function PANEL:Init()
    self:Dock(TOP)
end

function PANEL:setBlueprint()

end

vgui.Register("nutCraftingRow", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
    if (IsValid(nut.gui.crafting)) then
        nut.gui.crafting:Remove()
    end
    nut.gui.crafting = self

    self:SetSize(800, 600)
    self:Center()
    self:MakePopup()

    for id, info in pairs(nut.craft.list) do
        
    end
end

vgui.Register("nutCraftingMenu", PANEL, "DFrame")