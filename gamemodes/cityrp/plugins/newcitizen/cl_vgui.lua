if (SERVER) then return end


hook.Add("LoadFonts", "nutOutfitPororiFont", function(font, genericFont)
	surface.CreateFont("nutOutfitFont", {
		font = font,
		extended = true,
		size = ScreenScale(30),
		weight = 1000
	})
end)


local PANEL = {}
	function PANEL:setOutfit(data)
		self.outfit = data
	end

	function PANEL:setOutfitData(index, value)
		local data = self.outfit[index] -- part

		if (type(data.outfits) == "function") then
			data.outfits = data.outfits(self.Entity)
		end

		if (data and data.outfits) then
			local cnt = (table.Count(data.outfits))
			value = value % cnt
			value = (value == 0 and cnt or value)

			if (data.func) then
				data.func(self.Entity, data.outfits[value], data)
			end
		end

		self.stored = self.stored or {}
		self.stored[index] = value
	end

	local MODEL_ANGLE = Angle(0, 45, 0)
	local MODEL_VECTOR = Vector(0, 0, 4)
	function PANEL:LayoutEntity()
		local entity = self.Entity
		entity:SetAngles(MODEL_ANGLE)
		entity:SetPos(MODEL_VECTOR)
	end

	function PANEL:getOutfitData(index, value)
		return self.stored[index] or 0
	end

	function PANEL:getOutfits(index, value)
		return self.stored
	end
vgui.Register("nutOutfitModel", PANEL, "DModelPanel")

local PANEL = {}
	local gradient = nut.util.getMaterial("vgui/gradient-u")
	local gradient2 = nut.util.getMaterial("vgui/gradient-d")
	local alpha = 80

	function PANEL:Init()
		if (nut.gui.outfit) then
			nut.gui.outfit:Remove()
			nut.gui.outfit = nil
		end

		nut.gui.outfit = self

		self:SetSize(ScrW(), ScrH())
		self:SetAlpha(0)
		self:AlphaTo(255, 0.25, 0)
		self:SetPopupStayAtBack(true)

		self.title = self:Add("DPanel")
		self.title:Dock(TOP)
		self.title:SetHeight(self:GetSize()*.1)
		self:setupTitle(self.title, self:GetSize()*.1)

		self.bottom = self:Add("DPanel")
		self.bottom:Dock(BOTTOM)
		self.bottom:SetHeight(self:GetSize()*.05)
		self.bottom.Paint = function() end
		self:setupBottom(self.bottom, self:GetSize()*.05)

		self.contents = self:Add("DPanel")
		self.contents:Dock(FILL)
		self.contents.Paint = function() end
		self:setupContents(self.contents)

		self:MakePopup()
		self:setupData()
	end

	function PANEL:setupTitle(ab)
		function self.title:Paint(w, h)--(text, x, y, color, alignX, alignY, font, alpha)
			nut.util.drawText(L"outfit", w/2, h/2, color_white, 1, 1, "nutOutfitFont")
		end
	end

	function PANEL:setupBottom(ab, ac)
		self.close = ab:Add("DButton")
		self.close:SetText(L"cancel")
		self.close:SetFont("nutMediumFont")
		self.close:Dock(RIGHT)
		self.close:SetTextColor(color_white)
		self.close:SetWidth(self:GetWide()*.2)	 
		self.close:DockMargin(ac * .2, ac * .2, ac * .2, ac * .2)

		self.close.DoClick = function()
			surface.PlaySound("ui/deny.wav")
			self:remove()
		end

		self.apply = ab:Add("DButton")
		self.apply:SetText(L"apply")
		self.apply:SetFont("nutMediumFont")
		self.apply:Dock(RIGHT)
		self.apply:SetTextColor(color_white)
		self.apply:SetWidth(self:GetWide()*.2)	 
		self.apply:DockMargin(ac * .2, ac * .2, ac * .2, ac * .2)

		self.apply.DoClick = function()
			local outfits = self.model:getOutfits()
			surface.PlaySound("ui/boop.wav")

			netstream.Start("nutApplyOutfit", outfits)
		end
	end

	function PANEL:setupContents(ab)
		self.cost = ab:Add("DPanel")
		self.cost:Dock(BOTTOM)
		self.cost:SetHeight(50)

		self.left = ab:Add("DPanelList")
		self.left:Dock(LEFT)
		self.left:SetWidth(self:GetWide()*.2)
		self.left:DockMargin(10, 10, 10, 10)

		self.right = ab:Add("DPanelList")
		self.right:Dock(RIGHT)
		self.right:SetWidth(self:GetWide()*.2)
		self.right:DockMargin(10, 10, 10, 10)

		self.model = ab:Add("nutOutfitModel")
		self.model:SetFOV(80)
		self.model:Dock(FILL)
		self.model:DockMargin(10, 10, 10, 10)

		self.cost.price = 0

		function self.cost:Paint(w, h)--(text, x, y, color, alignX, alignY, font, alpha)
			nut.util.drawText(L("outfitCost", nut.currency.get(self.price)), w/2, h/2, color_white, 1, 1, "nutMediumFont")
		end
	end

	function PANEL:updateCost()
		local price = 0 

		local char = LocalPlayer():getChar()
		local outfitList = self.model.outfit
		local charOutfits = char:getData("outfits", {})

		for k, v in ipairs(outfitList) do
			local index = self.model:getOutfitData(k)
			local data = outfitList[k].outfits

			if (data) then
				local info = data[index]

				if (info) then
					if ((charOutfits[k] or 1) != index) then
						price = price + info.price or 0
					end
				end
			end
		end

		self.cost.price = price
	end

	function PANEL:setupData()
		local client = LocalPlayer()
		local char = client:getChar()

		if (char) then
			local mdl = char:getModel()
			self.model:SetModel(mdl)

			local outfitList = OUTFIT_REGISTERED[OUTFIT_DATA[mdl:lower()].uid]
			if (outfitList) then
				for i = 0, 1 do
					for k, v in ipairs(outfitList) do
						local t = (i == 0) and self.left or self.right

						local b = t:Add("DLabel")
						b:SetText(L(v.name))
						b:SetHeight(50)
						b:SetContentAlignment(5)
						b:SetFont("nutMediumFont")
						t:AddItem(b)

						local b = t:Add("DButton")
						b:SetText((i == 0) and "s" or "t") 
						b:SetFont("nutIconsMedium")
						b:SetTextColor(color_white)
						b:SetHeight(50)
						t:AddItem(b)

						b.DoClick = function()
							local left = (i == 0) and -1 or 1

							surface.PlaySound("ui/bip.wav")
							local wow = self.model:getOutfitData(k)
							self.model:setOutfitData(k, wow + left)
							self:updateCost()
						end
					end
				end

				self.model:setOutfit(outfitList)
				local charOutfits = char:getData("outfits", {})

				for k, v in ipairs(outfitList) do
					self.model:setOutfitData(k, charOutfits[k] or 1)
				end
			end
		end
	end

	function PANEL:OnKeyCodePressed(key)
		self.noAnchor = CurTime() + .5

		if (key == KEY_F1) then
			self:remove()
		end
	end

	local color_bright = Color(240, 240, 240, 180)

	function PANEL:Paint(w, h)
		nut.util.drawBlur(self, 12)

		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(gradient)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	function PANEL:OnRemove()
	
	end

	function PANEL:remove()
		CloseDermaMenus()
		
		if (!self.closing) then
			self:AlphaTo(0, 0.25, 0, function()
				self:Remove()
			end)
			self.closing = true
		end
	end
vgui.Register("nutOutfit", PANEL, "EditablePanel")