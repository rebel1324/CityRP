local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.stash)) then
			nut.gui.stash:Remove()
		end

		nut.gui.stash = self

		self:SetSize(ScrW() * 0.5, 680)
		self:MakePopup()
		self:Center()

		local noticeBar = self:Add("nutNoticeBar")
		noticeBar:Dock(TOP)
		noticeBar:setType(4)
		noticeBar:setText(L("stashTip"))
		noticeBar:DockMargin(3, 0, 3, 5)

		self.stash = self:Add("nutStashItemList")
		self.stash:Dock(LEFT)
		self.stash:SetWide(self:GetWide() * 0.5 - 7)
		self.stash:SetDrawBackground(true)
		self.stash:DockMargin(0, 0, 5, 0)
		self.stash.action:SetText(L"stashOut")

		self.inv = self:Add("nutStashItemList")
		self.inv:Dock(RIGHT)
		self.inv:SetWide(self:GetWide() * 0.5 - 7)
		self.inv:SetDrawBackground(true)
		self.inv.title:SetText(LocalPlayer():Name())
		self.inv.action:SetText(L"stashIn")

		self.stash.action.DoClick = function()
			local selectedItem = nut.gui.stash.activeItem

			if (IsValid(selectedItem)) then
				-- transfer items.
				netstream.Start("stashOut", selectedItem.indexID)
			end
		end

		self.inv.action.DoClick = function()
			local selectedItem = nut.gui.stash.activeItem

			if (IsValid(selectedItem)) then
				netstream.Start("stashIn", selectedItem.indexID, true)
			end
		end
	end

	function PANEL:setStash()
		local char = LocalPlayer():getChar()

		self.stash.title:SetText("Storage ("..char:getStashCount().."/"..char:getStashMax()..")")

		self.stash.items:Clear()
		self.inv.items:Clear()

		self:SetTitle(L("stashMenu"))

		for k, v in pairs(char:getInv():getItems()) do
			if (v.base == "base_bags") then
				continue
			end

			self.inv:addItem(v.uniqueID, v)
		end

		for k, _ in pairs(char:getStash()) do
			local item = nut.item.instances[k]
			if (item) then
				if (item.base == "base_bags") then
					continue
				end
				
				self.stash:addItem(item.uniqueID, item, true)
			end
		end
	end

	function PANEL:OnRemove()
		--netstream.Start("vendorExit")
	end
vgui.Register("nutStash", PANEL, "DFrame")

PANEL = {}
	function PANEL:Init()
		self.title = self:Add("DLabel")
		self.title:SetTextColor(color_white)
		self.title:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.title:Dock(TOP)
		self.title:SetFont("nutBigFont")
		self.title:SizeToContentsY()
		self.title:SetContentAlignment(7)
		self.title:SetTextInset(10, 5)
		self.title.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0, 150)
			surface.DrawRect(0, 0, w, h)
		end
		self.title:SetTall(self.title:GetTall() + 10)

		self.items = self:Add("DScrollPanel")
		self.items:Dock(FILL)
		self.items:SetDrawBackground(true)
		self.items:DockMargin(5, 5, 5, 5)

		self.action = self:Add("DButton")
		self.action:Dock(BOTTOM)
		self.action:SetTall(32)
		self.action:SetFont("nutMediumFont")
		self.action:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		self.itemPanels = {}
	end

	function PANEL:addItem(uniqueID, itemObject, stash)
		local itemTable = nut.item.list[uniqueID]

		if (!itemTable) then
			return
		end

		local oldPanel = self.itemPanels[uniqueID]

		local color_dark = Color(0, 0, 0, 80)

		local panel = self.items:Add("DPanel")
		panel:SetTall(36)
		panel:Dock(TOP)
		panel:DockMargin(5, 5, 5, 0)
		panel.Paint = function(this, w, h)
			surface.SetDrawColor(nut.gui.stash.activeItem == this and nut.config.get("color") or color_dark)
			surface.DrawRect(0, 0, w, h)
		end
		panel.indexID = itemObject:getID()
		panel.count = count

		panel.icon = panel:Add("SpawnIcon")
		panel.icon:SetPos(2, 2)
		panel.icon:SetSize(32, 32)
		panel.icon:SetModel(itemTable.model, itemTable.skin)

		panel.name = panel:Add("DLabel")
		panel.name:DockMargin(40, 2, 2, 2)
		panel.name:Dock(FILL)
		panel.name:SetFont("nutChatFont")
		panel.name:SetTextColor(color_white)
		panel.name:SetText(L(itemTable.name)..(count and " ("..count..")" or ""))
		panel.name:SetExpensiveShadow(1, Color(0, 0, 0, 150))

		panel.overlay = panel:Add("DButton")
		panel.overlay:SetPos(0, 0)
		panel.overlay:SetSize(ScrW() * 0.25, 36)
		panel.overlay:SetText("")
		panel.overlay.Paint = function() end
		panel.overlay.DoClick = function(this)
			nut.gui.stash.activeItem = panel

			if (input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) then
				if (stash) then
					netstream.Start("stashOut", panel.indexID)
				else
					netstream.Start("stashIn", panel.indexID, true)
				end
			end
		end

		//panel.overlay:SetToolTip(L("itemPriceInfo", nut.currency.get(price), nut.currency.get(price2)))
		self.itemPanels[uniqueID] = panel

		return panel
	end
vgui.Register("nutStashItemList", PANEL, "DPanel") 
