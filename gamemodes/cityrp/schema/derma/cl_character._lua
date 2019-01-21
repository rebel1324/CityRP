-- back from the scrapped project bitch

local function inQuad(t, b, c, d)
	t = t / d
	return c * math.pow(t, 2) + b
end

local function outQuad(t, b, c, d)
	t = t / d
	return -c * t * (t - 2) + b
end

local function inOutQuad(t, b, c, d)
	t = t / d * 2
	if t < 1 then
		return c / 2 * math.pow(t, 2) + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

local moveType = {
	["in"] = inQuad,
	["out"] = outQuad,
	["inout"] = inOutQuad
}

local function MoveToCustomAnimSetup(pnl, type)
	pnl.OldThink = pnl.Think

	local toFunc = moveType[type]

	pnl.CustomAnim = Derma_Anim("MoveTo", pnl, function(this, anim, delta, data)
		if anim.Started then
			data.startX = this.x
			data.startY = this.y
			data.endX = data.x
			data.endY = data.y
		end

		local endDelta = toFunc(delta, 0, 1, 1)
		local toX, toY = Lerp(endDelta, data.startX, data.endX), Lerp(endDelta, data.startY, data.endY)

		this:SetPos(toX, toY)

		if anim.Finished then
			this:SetPos(data.endX, data.endY)
		end
	end)

	pnl.Think = function(this)
		if this.OldThink then
			this:OldThink()
		end

		if this.CustomAnim:Active() then
			this.CustomAnim:Run()
		end

		if this.CustomAnimCallback then
			this.CustomAnimCallback()
		end

		if this.DelayedAnims and not this.CustomAnim:Active() then
			for k, v in pairs(this.DelayedAnims) do
				if v[3] <= RealTime() then
					this.CustomAnim:Start(v[1], v[2])
					this.DelayedAnims[k] = nil
				end
			end
		end
	end

	pnl.MoveTo = function(this, x, y, time, delay, _, callback)
		this.CustomAnimCallback = callback

		local data = {x = x, y = y}

		if delay and delay > 0 then
			if !this.DelayedAnims then
				this.DelayedAnims = {}
			end

			table.insert(this.DelayedAnims, {time, data, RealTime() + delay})
		else
			this.CustomAnim:Start(time, data)
		end
	end
end


local PANEL = {}
	local gradient = surface.GetTextureID("vgui/gradient-u")
	local gradient2 = surface.GetTextureID("vgui/gradient-d")
	local testt = surface.GetTextureID("vgui/gradient-down")
	local W, H = ScrW(), ScrH()

	function PANEL:Init()
		local fadeSpeed = 1

		if (IsValid(nut.gui.loading)) then
			nut.gui.loading:Remove()
		end

		if (!nut.localData.intro) then
			if (!nut.gui.charLoaded) then
				timer.Simple(0.1, function()
					vgui.Create("nutIntro", self)
				end)
				nut.gui.charLoaded = true
			else
				self:playMusic()
			end
		else
			self:playMusic()
		end

		if (IsValid(nut.gui.char) or (LocalPlayer().getChar and LocalPlayer():getChar())) then
			nut.gui.char:Remove()
			fadeSpeed = 0
		end

		nut.gui.char = self

		self:Dock(FILL)
		self:MakePopup()
		self:Center()
		self:ParentToHUD()

		self.darkness = self:Add("DPanel")
		self.darkness:Dock(FILL)
		self.darkness.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(0, 0, w, h)
		end
		self.darkness:SetZPos(99)

		self.background = self:Add("DPanel")
		self.background:Dock(FILL)
		self.background.Paint = function(this, w, h)
			nut.util.drawBlur(this, 4, 2)
		end
		self.background:SetAlpha(0)
		self.background:AlphaTo(255, fadeSpeed)


		self.title = self:Add("DImage")
		local TitleMatW, TitleMatH = 1024, 256
		self.title:SetMaterial("titlemaniac.png")
		self.title:SetSize(math.min(TitleMatW, W * 0.65), math.min(TitleMatH, ((W * 0.65) / TitleMatW) * TitleMatH))
		-- self.title:SetSize(TitleMatW, TitleMatH)
		self.title:SetAlpha(0)
		self.title:SetPos((W - self.title:GetWide()) / 2, H * 0.15)
		self.title:AlphaTo(255, fadeSpeed, 3 * fadeSpeed, function()
			self.darkness:AlphaTo(0, 2 * fadeSpeed, 0, function()
				self.darkness:SetZPos(-99)
			end)
		end)
		MoveToCustomAnimSetup(self.title, "inout")
		self.title.MoveUp = function(this)
			this:MoveTo((W - this:GetWide()) / 2, H * 0.01, 1, 0, 1.5)
		end
		self.title.ResetPos = function(this)
			this:MoveTo((W - this:GetWide()) / 2, H * 0.15, 1, 0, 1.5)
		end

		local x, y = W * 0.1, H * 0.4
		local i = 1

		self.buttons = {}
		surface.SetFont("nutMenuButtonFont")

		local function AddMenuLabel(text, callback, isLast, noTranslation, parent, noCenter)
			parent = parent or self

			local newText = noTranslation and text or L(text)
			local tempString = ""
			for i = 1, newText:utf8len() do
				tempString = tempString .. newText:utf8sub(i, i) .. " "
			end

			local label = parent:Add("nutMenuButton")
			label:setText(tempString, true)
			local menuX = noCenter and x or (W - label:GetWide()) / 2
			label:SetPos(menuX, y)
			label:SetAlpha(0)
			label:AlphaTo(255, 0.3, (fadeSpeed * 6) + 0.15 * i, function()
				if (isLast) then
					fadeSpeed = 0
				end
			end)

			if (callback) then
				label.DoClick = function(this)
					if (this:GetAlpha() == 255 and callback) then
						callback(this)
					end
				end
			end

			i = i + 0.33
			y = y + label:GetTall() + 19

			self.buttons[#self.buttons + 1] = label
			return label
		end

		local function ClearAllButtons(callback)
			x, y = W * 0.1, H * 0.4

			local i = 0
			local max = table.Count(self.buttons)

			for k, v in pairs(self.buttons) do
				local reachedMax = i == (max - 1)

				v:AlphaTo(0, 0.3, 0.15 * i, function()
					if (reachedMax and callback) then
						callback()
					end

					v.noClick = true
					v:Remove()
				end)

				i = i + 1
			end

			self.buttons = {}
		end

		self.fadePanels = {}

		local function MoveTitles(up)
			if (up) then
				self.title:MoveUp()
			else
				self.title:ResetPos()
			end
		end

		local CreateMainButtons

		local function CreateReturnButton(shouldCenter)
			self.returnLabel = AddMenuLabel("return", function()
				if (IsValid(self.creation) and self.creation.creating) then
					return
				end

				self.setupCharList = nil

				for k, v in pairs(self.fadePanels) do
					if (IsValid(v)) then
						v:AlphaTo(0, 0.25, 0, function()
							v:Remove()
						end)
					end
				end

				MoveTitles(false)

				self.fadePanels = {}
				ClearAllButtons(CreateMainButtons)
			end, nil, nil, nil, shouldCenter != true)
			MoveToCustomAnimSetup(self.returnLabel, "out")
		end

		function CreateMainButtons()
			local count = 0

			for k, v in pairs(nut.faction.teams) do
				if (nut.faction.hasWhitelist(v.index)) then
					count = count + 1
				end
			end

			y = ScrH() * 0.60

			local maxChars = hook.Run("GetMaxPlayerCharacter", LocalPlayer()) or nut.config.get("maxChars", 5)

			if (#nut.characters > 0 and hook.Run("ShouldMenuButtonShow", "load") != false) then
				AddMenuLabel("load", function()
					MoveTitles(true)
					ClearAllButtons(function()
						i = 0
						CreateReturnButton()

						local lastButton
						local id
						local width = 128

						local function SetupCharacter(character)
							if (id != character:getID()) then
								self.model:SetModel(character:getModel())
								self.model.teamColor = team.GetColor(character:getFaction())

								if (IsValid(self.model.Entity)) then
									self.model.Entity:SetSkin(character:getData("skin", 0))

									local groups = character:getData("groups", {})

									for k, v in pairs(groups) do
										self.model.Entity:SetBodygroup(k, v)
									end
								end

								id = character:getID()
							end
						end

						local function LerpColor(tr, tg, tb, from, to)
							tg = tg or tr
							tb = tb or tr
							return Color(Lerp(tr, from.r, to.r),Lerp(tg, from.g, to.g),Lerp(tb, from.b, to.b))
						end

						self.charList = self:Add("DScrollPanel")
						self.charList:SetPos(x, y)
						self.charList:SetTall(H * 0.4)
						self.charList:SetAlpha(0)

						self.fadePanels[#self.fadePanels + 1] = self.charList

						self.model = self:Add("nutModelPanel")
						self.model:SetPos(W * 0.35, H * 0.2 + 16)
						self.model:SetSize(W * 0.3, H * 0.7)
						self.model:SetModel("models/error.mdl")
						self.model:SetFOV(49)
						self.model:SetAlpha(0)
						self.model:AlphaTo(255, 0.5, 0)
						self.model.PaintModel = self.model.Paint
						self.model.Paint = function(this, w, h)
							local color = self.model.teamColor or color_black

							surface.SetDrawColor(color.r, color.g, color.b, 125)
							surface.SetTexture(gradient2)
							surface.DrawTexturedRect(0, 0, w, h)

							this:PaintModel(w, h)
						end
						self.model.OldThink = self.model.Think
						self.model.Think = function(this)
							if (this.anim) then
								if (this.anim:Active()) then
									this.anim:Run()
								end
							end
						end
						self.model.anim = Derma_Anim("Transition", self.model, function(this, anim, delta, data)
							local clr = nut.config.get("color")
							if (anim.Started) then
								data.AlphaFrom = this:GetAlpha() or 255
								data.ColorFrom = data.buttonFrom.color or clr
							end

							local deltaTrans = delta * 2
							local after = deltaTrans > 1
							if (after) then
								deltaTrans = 2 - deltaTrans
							end
							deltaTrans = 1 - deltaTrans

							if (after and !data.after) then
								data.after = true

								SetupCharacter(data.charTo)
							end

							this:SetAlpha((after and 255 or data.AlphaFrom) * deltaTrans)

							data.buttonFrom.color = LerpColor(delta, nil, nil, data.ColorFrom, color_white)
							data.buttonFrom:SetTextColor(data.buttonFrom.color)
							data.buttonTo.color = LerpColor(delta, nil, nil, color_white, clr)
							data.buttonTo:SetTextColor(data.buttonTo.color)

							if (anim.Finished) then
								data.buttonFrom.color = nil
								data.buttonTo.color = clr
								this:SetAlpha(255)
							end
						end)
						self.fadePanels[#self.fadePanels + 1] = self.model

						self.choose = self.model:Add("nutMenuButton")
						self.choose:SetWide(self.model:GetWide() * 0.45)
						self.choose:setText("choose")
						self.choose:Dock(LEFT)
						self.choose.DoClick = function()
							if ((self.nextUse or 0) < CurTime()) then
								self.nextUse = CurTime() + 1
							else
								return
							end

							local status, result = hook.Run("CanPlayerUseChar", client, nut.char.loaded[id])

							if (status == false) then
								if (result:sub(1, 1) == "@") then
									nut.util.notifyLocalized(result:sub(2))
								else
									nut.util.notify(result)
								end

								return
							end

							if (LocalPlayer().getChar and LocalPlayer():getChar() == nut.char.loaded[id]) then
								nut.util.notifyLocalized("usingChar")

								return
							end

							if (!self.choosing and id) then
								self.choosing = true
								self.darkness:SetZPos(999)
								self.darkness:AlphaTo(255, 1, 0, function()
									self:Remove()

									local darkness = vgui.Create("DPanel")
									darkness:SetZPos(999)
									darkness:SetSize(W, H)
									darkness.Paint = function(this, w, h)
										surface.SetDrawColor(0, 0, 0)
										surface.DrawRect(0, 0, w, h)
									end

									local curChar = LocalPlayer():getChar() and LocalPlayer():getChar():getID()

									netstream.Hook("charLoaded", function()
										if (IsValid(darkness)) then
											darkness:AlphaTo(0, 5, 0.5, function()
												darkness:Remove()
											end)
										end

										if (curChar != id) then
											hook.Run("CharacterLoaded", nut.char.loaded[id])
										end
									end)

									netstream.Start("charChoose", id)
								end)
							end
						end

						self.delete = self.model:Add("nutMenuButton")
						self.delete:SetWide(self.model:GetWide() * 0.45)
						self.delete:setText("delete")
						self.delete:Dock(RIGHT)
						self.delete.DoClick = function()
							local menu = DermaMenu()
								local confirm = menu:AddSubMenu(L("delConfirm", nut.char.loaded[id]:getName()))
								confirm:AddOption(L"no"):SetImage("icon16/cross.png")
								confirm:AddOption(L"yes", function()
									netstream.Start("charDel", id)
								end):SetImage("icon16/tick.png")
							menu:Open()
						end

						self.characters = {}

						local function TransitionToCharacter(character, newButton, oldButton)
							if (newButton == oldButton) then
								return false
							end
							if (self.model.anim:Active() and not self.model.anim.Data.after) then
								return false
							end

							self.model.anim:Start(1, {charTo = character, buttonTo = newButton, buttonFrom = oldButton})
						end

						local function SetupCharList()
							local first = true
							local charToBeLoaded

							if (LocalPlayer().getChar and LocalPlayer():getChar()) then
								local activeChar = LocalPlayer():getChar()
								-- SetupCharacter(activeChar)
								charToBeLoaded = activeChar
								first = nil
							end

							self.charList:Clear()
							self.charList:AlphaTo(255, 0.5, 0)

							for k, v in ipairs(nut.characters) do
								local character = nut.char.loaded[v]

								if (character) then
									local label = self.charList:Add("nutMenuButton")
									label:setText(character:getName(), true)
									label:Dock(TOP)
									label:DockMargin(0, 0, 0, 4)
									label.DoClick = function(this)
										if TransitionToCharacter(character, this, lastButton) == false then return end

										if (IsValid(lastButton)) then
											lastButton.color = nil
											lastButton:SetTextColor(color_white)
										end

										lastButton = this
										this.color = nut.config.get("color")
										-- SetupCharacter(character)
									end

									if (first or (charToBeLoaded and charToBeLoaded == character)) then
										SetupCharacter(character)
										label.color = nut.config.get("color")
										label:SetTextColor(label.color)
										lastButton = label
										first = nil
									end

									if (label:GetWide() > width) then
										width = label:GetWide() + 8
										self.charList:SetWide(width)
									end

									self.characters[#self.characters + 1] = {label = label, id = character:getID()}
								end
							end
						end

						SetupCharList()

						function self:setupCharList()
							if (#nut.characters == 0) then
								if (IsValid(self.creation) and self.creation.creating) then
									return
								end

								self.setupCharList = nil

								for k, v in pairs(self.fadePanels) do
									if (IsValid(v)) then
										v:AlphaTo(0, 0.25, 0, function()
											v:Remove()
										end)
									end
								end

								self.fadePanels = {}
								ClearAllButtons(CreateMainButtons)

								return
							end

							SetupCharList()
						end
					end)
				end)
			end

			local function MoveLabelsLeft(labels)
				local offset = 0

				self.returnLabel:MoveTo(x, self.returnLabel.y, 0.7, offset, 0.5)
				offset = offset + 0.1

				for k, v in pairs(labels) do
					v:MoveTo(x, v.y, 0.7, offset, 0.5)
					offset = offset + 0.1
				end
			end

			if (count > 0 and #nut.characters < maxChars and hook.Run("ShouldMenuButtonShow", "create") != false) then
				AddMenuLabel("create", function()
					ClearAllButtons(function()
						i = 0
						CreateReturnButton(true)

						local fadedIn = false

						local factionLabels = {}

						for k, v in SortedPairs(nut.faction.teams) do
							if (nut.faction.hasWhitelist(v.index)) then
								local factionLabel = AddMenuLabel(L(v.name), function()
									if (!self.creation or self.creation.faction != v.index) then
										MoveTitles(true) -- Move titles up
										MoveLabelsLeft(factionLabels)

										self.creation = self:Add("nutCharCreate")
										self.creation:SetAlpha(fadedIn and 255 or 0)
										self.creation:setUp(v.index)
										self.creation:AlphaTo(255, 0.5, 0)
										self.creation:SetPos(ScrW() * 0.42, self.creation.y)
										self.fadePanels[#self.fadePanels + 1] = self.creation

										self.finish = self:Add("nutMenuButton")
										self.finish:SetPos(ScrW() * 0.42 - 32, ScrH() * 0.3 + 16)
										self.finish:setText("finish")
										self.finish:MoveBelow(self.creation, 4)
										self.finish.DoClick = function(this)
											if (!self.creation.creating) then
												local payload = {}

												for k, v in SortedPairsByMemberValue(nut.char.vars, "index") do
													local value = self.creation.payload[k]

													if (!v.noDisplay or v.onValidate) then
														if (v.onValidate) then
															local result = {v.onValidate(value, self.creation.payload, LocalPlayer())}

															if (result[1] == false) then
																self.creation.notice:setType(1)
																self.creation.notice:setText(L(unpack(result, 2)).."!")

																return
															end
														end

														payload[k] = value
													end
												end

												self.creation.notice:setType(6)
												self.creation.notice:setText(L"creating")
												self.creation.creating = true
												self.finish:AlphaTo(0, 0.5, 0)

												netstream.Hook("charAuthed", function(fault, ...)
													timer.Remove("nutCharTimeout")

													if (type(fault) == "string") then
														self.creation.notice:setType(1)
														self.creation.notice:setText(L(fault, ...))
														self.creation.creating = nil
														self.finish:AlphaTo(255, 0.5, 0)

														return
													end

													if (type(fault) == "table") then
														nut.characters = fault
													end

													for k, v in pairs(self.fadePanels) do
														if (IsValid(v)) then
															v:AlphaTo(0, 0.25, 0, function()
																v:Remove()
															end)
														end
													end

													self.fadePanels = {}
													ClearAllButtons(CreateMainButtons)
												end)

												timer.Create("nutCharTimeout", 20, 1, function()
													if (IsValid(self.creation) and self.creation.creating) then
														self.creation.notice:setType(1)
														self.creation.notice:setText(L"unknownError")
														self.creation.creating = nil
														self.finish:AlphaTo(255, 0.5, 0)
													end
												end)

												netstream.Start("charCreate", payload)
											end
										end

										self.fadePanels[#self.fadePanels + 1] = self.finish

										fadedIn = true
									end
								end)

								MoveToCustomAnimSetup(factionLabel, "out")
								table.insert(factionLabels, factionLabel)
							end
						end
					end)
				end)
			end

			if (nut.config.get("forumShow")) then
				AddMenuLabel(L"forum", function()
					gui.OpenURL(nut.config.get("forumURL"))
				end)
			end

			local hasCharacter = LocalPlayer().getChar and LocalPlayer():getChar()

			if (hook.Run("ShouldMenuButtonShow", "leave") != false) then
				AddMenuLabel(hasCharacter and "return" or "leave", function()
					if (!hasCharacter) then
						if (self.darkness:GetAlpha() == 0) then
							self.title:SetZPos(-99)
							self.darkness:SetZPos(99)
							self.darkness:AlphaTo(255, 1.25, 0, function()
								timer.Simple(0.5, function()
									RunConsoleCommand("disconnect")
								end)
							end)
						end
					else
						self:AlphaTo(0, 0.5, 0, function()
							self:Remove()
							if (OPENNEXT) then
								vgui.Create("nutCharMenu")
							end
						end)
					end
				end, true)
			end
		end

		CreateMainButtons()
	end

	function PANEL:Think()
		if (input.IsKeyDown(KEY_F1) and LocalPlayer():getChar() and !self.choosing) then
			self:Remove()
		end
	end

	function PANEL:playMusic()
		if (nut.menuMusic) then
			nut.menuMusic:Stop()
			nut.menuMusic = nil
		end

		timer.Remove("nutMusicFader")

		local source = nut.config.get("hl2music", ""):lower()

		if (source:find("%S")) then
			local function callback(music, errorID, fault)
				if (music) then
					music:SetVolume(0.5)

					nut.menuMusic = music
					nut.menuMusic:Play()
				else
					MsgC(Color(255, 50, 50), errorID.." ")
					MsgC(color_white, fault.."\n")
				end
			end

			if (source:find("http")) then
				sound.PlayURL(source, "noplay", callback)
			else
				sound.PlayFile("sound/"..source, "noplay", callback)
			end
		end

		for k, v in ipairs(engine.GetAddons()) do
			if (v.wsid == "1355625344" and v.mounted) then
				return
			end
		end

		Derma_Query(L"contentWarning", L"contentTitle", L"yes", function()
			gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=1355625344")
		end, L"no")
	end

	function PANEL:OnRemove()
		if (nut.menuMusic) then
			local fraction = 1
			local start, finish = RealTime(), RealTime() + 10

			timer.Create("nutMusicFader", 0.1, 0, function()
				if (nut.menuMusic) then
					fraction = 1 - math.TimeFraction(start, finish, RealTime())
					nut.menuMusic:SetVolume(fraction * 0.5)

					if (fraction <= 0) then
						nut.menuMusic:Stop()
						nut.menuMusic = nil

						timer.Remove("nutMusicFader")
					end
				else
					timer.Remove("nutMusicFader")
				end
			end)
		end
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0, 235)
		surface.SetTexture(gradient)
		surface.DrawTexturedRect(0, 0, w, h)
	end
vgui.Register("nutCharMenu", PANEL, "EditablePanel")

hook.Add("CreateMenuButtons", "nutCharButton", function(tabs)
	tabs["Characters"] = function(panel)
		nut.gui.menu:Remove()
		vgui.Create("nutCharMenu")
	end
end)
