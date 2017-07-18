local PANEL = {}

function PANEL:Init()
	if (IsValid(nut.gui.stoveinv)) then
		nut.gui.stoveinv:Remove()
	end
	
	nut.gui.stoveinv = self

	self:SetSize(64, 64)
	self:setGridSize(nut.config.get("invW"), nut.config.get("invH"))

	self.panels = {}

	local created = {}

	if (LocalPlayer():getChar() and LocalPlayer():getChar():getInv().slots) then
		for x, items in pairs(LocalPlayer():getChar():getInv().slots) do
			for y, data in pairs(items) do
				if (!data.id) then continue end

				local item = nut.item.instances[data.id]

				if (item and !IsValid(self.panels[item.id])) then
					local icon = self:addIcon(item.model or "models/props_junk/popcan01a.mdl", x, y, item.width, item.height)

					if (IsValid(icon)) then
						icon:SetToolTip("Item #"..item.id.."\n"..L("itemInfo", item.name, (type(item.desc) == "function" and item.desc(item) or item.desc)))

						self.panels[item.id] = icon
					end
				end
			end
		end
	end
end
	
function PANEL:setGridSize(w, h)
	self.gridW = w
	self.gridH = h
	
	self:SetSize(w * 64 + 8, h * 64 + 8)
	self:buildSlots()
end

function PANEL:buildSlots()
	self.slots = self.slots or {}
	
	local function PaintSlot(slot, w, h)
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(1, 1, w - 2, h - 2)
		
		surface.SetDrawColor(0, 0, 0, 130)
		surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
	end
	
	for k, v in ipairs(self.slots) do
		for k2, v2 in ipairs(v) do
			v2:Remove()
		end
	end
	
	self.slots = {}
	
	for x = 1, self.gridW do
		self.slots[x] = {}
		
		for y = 1, self.gridH do
			local slot = self:Add("DPanel")
			slot.gridX = x
			slot.gridY = y
			slot:SetPos((x - 1) * 64 + 4, (y - 1) * 64 + 8)
			slot:SetSize(64, 64)
			slot.Paint = PaintSlot
			
			self.slots[x][y] = slot	
		end
	end
end

function PANEL:addIcon(model, x, y, w, h)
	w = w or 1
	h = h or 1
	if (self.slots[x] and self.slots[x][y]) then
		local panel = self:Add("nutItemIcon")
		panel:SetSize(w * 64, h * 64)
		panel:SetZPos(1)
		panel:InvalidateLayout(true)
		panel:SetModel(model)
		panel:SetPos(self.slots[x][y]:GetPos())
		panel.gridX = x
		panel.gridY = y
		panel.gridW = w
		panel.gridH = h
		panel.OnMousePressed = function(this, code)
			if (this.doRightClick) then
				this:doRightClick()
			end
		end
		panel.doRightClick = function(this)
			local itemTable = LocalPlayer():getChar():getInv():getItemAt(panel.gridX, panel.gridY)
			
			if (itemTable) then
				itemTable.client = LocalPlayer()
				local cooked = itemTable:getData("cooked", 0)

				if (itemTable.isFood != true or cooked != 0 or itemTable.cookable == false) then
					surface.PlaySound("buttons/button10.wav")
				else
					local menu = DermaMenu()

					menu:AddOption("Cook", function()
						netstream.Start("cookFood", itemTable:getID())
					end):SetImage(itemTable.icon or "icon16/brick.png")

					menu:Open()
				end
				itemTable.client = nil
			end
		end
		panel.PaintOver = function(this, w, h)
			local itemTable = LocalPlayer():getChar():getInv():getItemAt(this.gridX, this.gridY)
			local cooked = itemTable:getData("cooked", 0)

			if (itemTable.isFood != true or cooked != 0 or itemTable.cookable != true) then
				surface.SetDrawColor(255, 0, 0, 15)
				surface.DrawRect(2, 2, w - 4, h - 4)
			end

			if (itemTable and itemTable.paintOver) then
				itemTable.paintOver(this, itemTable, w, h)
			end
		end

		panel.slots = {}

		for i = 0, w - 1 do
			for i2 = 0, h - 1 do
				local slot = self.slots[x + i] and self.slots[x + i][y + i2]

				if (IsValid(slot)) then
					slot.item = panel
					panel.slots[#panel.slots + 1] = slot
				else
					for k, v in ipairs(panel.slots) do
						v.item = nil
					end

					panel:Remove()

					return
				end
			end
		end
		
		return panel
	end
end

vgui.Register("nutStoveInventory", PANEL, "EditablePanel")

PANEL = {}
function PANEL:Init()
	self:SetTitle("Cooking Menu")
	
	self.inv = self:Add("nutStoveInventory")
	local x, y = self.inv:GetSize()

	self.inv:SetPos(0, 20)
	self:SetSize(x, y + 24)
	self:Center()
	self:MakePopup()
end
vgui.Register("nutStoveFrame", PANEL, "DFrame")

netstream.Hook("nutStoveFrame", function()
	if (cookMenu and cookMenu:IsVisible()) then
		cookMenu:Close()
		cookMenu = nil
	end

	cookMenu = vgui.Create("nutStoveFrame")
end)