local gradient = nut.util.getMaterial("vgui/gradient-r.vtf")
local glow = surface.GetTextureID("particle/Particle_Glow_04_Additive")

    local kunt = "Malgun Gothic"
	surface.CreateFont("nutIntroNSFont", {
		font = kunt,
		size = ScreenScale(50),
		extended = true,
        shadow = true,
		weight = 1000
	})

	surface.CreateFont("nutIntroHeaderFont", {
		font = kunt,
		size = ScreenScale(17),
		extended = true,
        shadow = true,
		weight = 1000
	})

	surface.CreateFont("nutIntroConFont", {
		font = kunt,
		size = ScreenScale(13),
		extended = true,
        shadow = true,
		weight = 1000
	})


local function drawMatrixString(str, font, x, y, scale, color)
	local matrix = Matrix()
	matrix:Translate(Vector(x, y, 0))
	matrix:Scale(scale)

	cam.PushModelMatrix(matrix)
		surface.SetFont(font)
		surface.SetTextPos(2, 2)
		surface.SetTextColor(color)
		surface.DrawText(str)
	cam.PopModelMatrix()
end

local PANEL = {}
function PANEL:Init()
	self:SetTextColor(Color(0, 0, 0, 0))
    self.disp = 0
    self.alpha = 0
    self.cache = {}
end

function PANEL:FadeIn(delay, offset, callback)
    if (!offset) then
        self.active = true
		self.started = RealTime()
		print("Started: " .. self.started)
    end

    self.fadeInInfo = {callback, delay}
    if (offset) then
        self.fadeInInfo[3] = RealTime() + offset
    end
end

function PANEL:FadeOut(delay, offset, callback)
    if (!offset) then
        self.dying = true
    end

    self.fadeOutInfo = {callback, delay}
    if (offset) then
        self.fadeOutInfo[3] = RealTime() + offset
    end
end

function PANEL:Think()
    if (self.fadeInInfo and self.fadeInInfo[3] and !self.active) then
        if (self.fadeInInfo[3] <= RealTime()) then
            self.active = true
        end
    end
    if (self.fadeOutInfo and self.fadeOutInfo[3] and !self.dying) then
        if (self.fadeOutInfo[3] <= RealTime()) then
            self.dying = true
        end
    end

    if (self.finishedIntro and self.fadeInInfo and self.fadeInInfo[1]) then
        self.fadeInData = self.fadeInData or {}
        if (!self.fadeInData[1]) then
            if (self.fadeInInfo[2]) then
                if (self.fadeInData[2]) then
					if (self.fadeInData[2] <= RealTime()) then
						self.fadeInData[1] = true
						self.fadeInInfo[1](self)
					end
                else
                    self.fadeInData[2] = RealTime() + self.fadeInInfo[2]
                end
            else
                self.fadeInData[1] = true
                self.fadeInInfo[1](self)
            end
        end
    end
    if (self.finishedOutro and self.fadeOutInfo and self.fadeOutInfo[1]) then
        self.fadeOutData = self.fadeOutData or {}
        if (!self.fadeOutData[1]) then
            if (self.fadeOutInfo[2]) then
                if (self.fadeOutData[2]) then
					if (self.fadeOutData[2] <= RealTime()) then
						self.fadeOutData[1] = true
						self.fadeOutInfo[1](self)
						self:Remove()
					end
                else
                    self.fadeOutData[2] = RealTime() + self.fadeOutInfo[2]
                end
            else
                self.fadeOutData[1] = true
                self.fadeOutInfo[1](self)
				self:Remove()
            end
        end
    end
end

function PANEL:Paint(w, h)
    if (!self.active) then return end

    local dispString = self:GetText()
    local font = self:GetFont()
	local strEnd = string.utf8len(dispString)
    self.disp = self.disp + FrameTime()*15

    if (self.dying) then
        if (self.alpha == 0) then
            self.finishedOutro = true

            return
        end

        self.alpha = math.max(0, self.alpha - FrameTime() * 1000)
    else
        self.alpha = math.max(0, self.alpha + FrameTime() * 150)
    end

    local x, y = 0, 0
	for i = 1, math.min(self.disp, strEnd) do
		surface.SetFont(font)
		local hey = string.utf8sub(dispString, i, i)
		local sx, sy = surface.GetTextSize(hey)	

        self.cache[i] = self.cache[i] or {
            a = 0, b = 1, -- scale
            c = 0, d = 0, -- pos
        }
        local c = self.cache[i]
        
        c.a = Lerp(FrameTime()*5, c.a, 1)

        local px, py = self:GetPos()

        drawMatrixString(
            hey,
            self:GetFont(),
            x + (px + sy/4)*(1-c.a),
            y,
            Vector(c.a, c.b, 1),
            ColorAlpha(color_white, self.alpha)
        )
        
        x = x + sx*1

        if (i >= strEnd) then
            self.finishedIntro = true
        end
    end
end
vgui.Register("nutIntroText", PANEL, "DLabel")

local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.intro)) then
			nut.gui.intro:Remove()
		end

		nut.gui.intro = self

		self:SetSize(ScrW(), ScrH())
		self:SetZPos(9999)

		timer.Simple(0.1, function()
			if (!IsValid(self)) then
				return
			end

			self.sound = CreateSound(LocalPlayer(), "music/hl1_song20.mp3")
			self.sound:Play()
			self.sound:ChangePitch(80, 0)
		end)
		
		local expire = 7
		local leftMargin = ScrW()*0.03
		local gh = ScrH()*.75

		self.intro1_1 = vgui.Create("nutIntroText", self)
		self.intro1_1:SetText("POWERED BY")
		self.intro1_1:SetFont("nutIntroHeaderFont")
		self.intro1_1:SizeToContents()
		self.intro1_1:SetPos(leftMargin, gh)

		self.intro1_2 = vgui.Create("nutIntroText", self)
		self.intro1_2:SetText("NUTSCRIPT 1.1")
		self.intro1_2:SetFont("nutIntroNSFont")
		self.intro1_2:SizeToContents()
		self.intro1_2:SetPos(leftMargin, gh + self.intro1_1:GetTall()*1.1)

		local heightCalc = 0
		local gh = ScrH()*.77

		self.intro2_1 = vgui.Create("nutIntroText", self)
		self.intro2_1:SetText("프레임워크 제작자")
		self.intro2_1:SetFont("nutIntroHeaderFont")
		self.intro2_1:SizeToContents()
		self.intro2_1:SetPos(leftMargin, gh)
		heightCalc = heightCalc + self.intro2_1:GetTall()*1.1

		self.intro2_2 = vgui.Create("nutIntroText", self)
		self.intro2_2:SetText("Black Tea za rebel1324")
		self.intro2_2:SetFont("nutIntroConFont")
		self.intro2_2:SizeToContents()
		self.intro2_2:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc +  self.intro2_2:GetTall()*1.1

		self.intro2_3 = vgui.Create("nutIntroText", self)
		self.intro2_3:SetText("Chessnut")
		self.intro2_3:SetFont("nutIntroConFont")
		self.intro2_3:SizeToContents()
		self.intro2_3:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc +  self.intro2_3:GetTall()*1.1


		gh = ScrH()*.69
		heightCalc = 0
		self.intro3_1 = vgui.Create("nutIntroText", self)
		self.intro3_1:SetText("게임모드 개발자")
		self.intro3_1:SetFont("nutIntroHeaderFont")
		self.intro3_1:SizeToContents()
		self.intro3_1:SetPos(leftMargin, gh)
		heightCalc = heightCalc + self.intro3_1:GetTall()*1.1

		self.intro3_2 = vgui.Create("nutIntroText", self)
		self.intro3_2:SetText("Black Tea za rebel1324")
		self.intro3_2:SetFont("nutIntroConFont", self)
		self.intro3_2:SizeToContents()
		self.intro3_2:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc + self.intro3_2:GetTall()*1.1

		self.intro3_3 = vgui.Create("nutIntroText", self)
		self.intro3_3:SetText("Chessnut")
		self.intro3_3:SetFont("nutIntroConFont", self)
		self.intro3_3:SizeToContents()
		self.intro3_3:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc + self.intro3_3:GetTall()*1.1

		self.intro3_4 = vgui.Create("nutIntroText", self)
		self.intro3_4:SetText("Omar")
		self.intro3_4:SetFont("nutIntroConFont")
		self.intro3_4:SizeToContents()
		self.intro3_4:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc + self.intro3_4:GetTall()*1.1


		self.intro3_5 = vgui.Create("nutIntroText", self)
		self.intro3_5:SetText("Teflon")
		self.intro3_5:SetFont("nutIntroConFont")
		self.intro3_5:SizeToContents()
		self.intro3_5:SetPos(leftMargin, gh + heightCalc)
		heightCalc = heightCalc + self.intro3_5:GetTall()*1.1

		self.schemalogo = self:Add("DImage")
		self.schemalogo:SetMaterial("titlemaniac2.png")
		local originalSizeX, originalSizeY = 1024, 256
		self.schemalogo:SetSize(ScrW() * 0.7, ((ScrW() * 0.7) / originalSizeX) * originalSizeY)
		self.schemalogo:Center()
		self.schemalogo:SetExpensiveShadow(2, color_black)

		self.cover = self.schemalogo:Add("DPanel")
		self.cover:SetSize(ScrW(), self.schemalogo:GetTall())
		self.cover.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.SetMaterial(gradient)
			surface.DrawTexturedRect(0, 0, 100, h)

			surface.DrawRect(100, 0, ScrW(), h)
		end
		self.cover:SetPos(-100, 0)

		self.intro1_1:FadeIn()
		self.intro1_2:FadeIn(3, .5, function()
			self.intro1_1:FadeOut()
			self.intro1_2:FadeOut(3, nil, function()
				self.intro2_1:FadeIn()
				self.intro2_2:FadeIn(nil, 0.8)
				self.intro2_3:FadeIn(4, 1.6, function()
					self.intro2_1:FadeOut()
					self.intro2_2:FadeOut()
					self.intro2_3:FadeOut(2, nil, function()
						self.intro3_1:FadeIn()
						self.intro3_2:FadeIn(nil, 0.8)
						self.intro3_3:FadeIn(nil, 1.6)
						self.intro3_4:FadeIn(nil, 2.4)
						self.intro3_5:FadeIn(5, 3.2, function()
							self.intro3_1:FadeOut()
							self.intro3_2:FadeOut()
							self.intro3_3:FadeOut()
							self.intro3_4:FadeOut()
							self.intro3_5:FadeOut(1, nil, function()
								self.LogoTransition = true
								self.cover:MoveTo(self.schemalogo:GetWide(), 0, 3.5, 1, nil, function()
									self.glow = true
									self.delta = 0
								end)
							end)
						end)
					end)
				end)
			end)
		end)
		

		timer.Simple(5, function()
			if (!IsValid(self)) then return end
			if (IsValid(self)) then
				self:addContinue()
			end
		end)

		-- timer.Simple(expire*3.05, function()
		-- 	if (!IsValid(self)) then return end
		-- 	self.LogoTransition = true
		-- 	self.cover:MoveTo(self.schemalogo:GetWide(), 0, 3.5, 1, nil, function()
		-- 		self.glow = true
		-- 		self.delta = 0
		-- 	end)
		-- end)
	end

	function PANEL:addContinue()
		self.info = self:Add("DLabel")
		self.info:Dock(BOTTOM)
		self.info:SetTall(36)
		self.info:DockMargin(0, 0, 0, 32)
		self.info:SetText("Press Space to continue...")
		self.info:SetFont("nutIntroSmallFont")
		self.info:SetContentAlignment(2)
		self.info:SetAlpha(0)
		self.info:AlphaTo(255, 1, 0, function()
			self.info.Paint = function(this)
				this:SetAlpha(math.abs(math.cos(RealTime() * 0.8) * 255))
			end
		end)
		self.info:SetExpensiveShadow(1, color_black)
	end

	function PANEL:Think()
		if (IsValid(self.info) and input.IsKeyDown(KEY_SPACE) and !self.closing) then
			self.closing = true
			if (!self.LogoTransition) then
				self.schemalogo:SetAlpha(0)
				self.cover:SetAlpha(0)
			end
			self:AlphaTo(0, 2.5, 0, function()
				self:Remove()
			end)
		end
	end

	function PANEL:OnRemove()
		if (self.sound) then
			self.sound:Stop()
			self.sound = nil

			if (IsValid(nut.gui.char)) then
				nut.gui.char:playMusic()
			end
		end
	end

	function PANEL:Paint(w, h)
		surface.SetDrawColor(0, 0, 0)
		surface.DrawRect(0, 0, w, h)

		if (self.glow) then
			self.delta = math.Approach(self.delta, 100, FrameTime() * 10)

			local x, y = ScrW()*0.5 - 700, ScrH()*0.5 - 340

			surface.SetDrawColor(self.delta, self.delta, self.delta, self.delta + math.sin(RealTime() * 0.7)*10)
			surface.SetTexture(glow)
			surface.DrawTexturedRect(x, y, 1400, 680)
		end
	end
vgui.Register("nutIntro", PANEL, "EditablePanel")