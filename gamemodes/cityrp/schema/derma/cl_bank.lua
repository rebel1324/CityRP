local PANEL = {}
	function PANEL:Init()
		self:SetSize(350, 162)
		self:SetTitle(L"bankMenu")
		self:Center()
		self:MakePopup()
		nut.gui.bank = self
	end
vgui.Register("nutTransfer", PANEL, "DFrame")

/*
netstream.Hook("nutBank", function()
	if (nut.gui.bank and nut.gui.bank:IsVisible()) then
		nut.gui.bank:Close()
		nut.gui.bank = nil
	end

	vgui.Create("nutTransfer")
end)
*/