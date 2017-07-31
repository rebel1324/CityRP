AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "ATM"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/rebel1324/machine_atm.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end

		if (IS_INTERNATIONAL) then
			self:SetSkin(1)
		end
	end
else
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local gradient2 = nut.util.getMaterial("vgui/gradient-u")

	STATUS_DEPOSIT = 1
	STATUS_WITHDRAW = 2
	STATUS_INFO = 3
	STATUS_STANBY = 0


	surface.CreateFont("nutNATMFont", {
		font = "Arial",
		extended = true,
		size = 40,
		weight = 1000
	})

	surface.CreateFont("nutSubNATMFont", {
		font = "Arial",
		extended = true,
		size = 24,
		weight = 500
	})

	surface.CreateFont("nutKeypadFont", {
		font = "Trebuchet MS",
		extended = true,
		size = 25,
		weight = 500
	})

	local text = {
		"deposit", "withdraw", "info"
	}
	local text2 = {
		"reset", "allmoney"
	}

	local function renderCode(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			local mx, my = self:mousePos()
			local scale = 1 / self.scale
			local bx, by, color	

			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(0, 0, w, h)	

				surface.SetMaterial(gradient)
				surface.SetDrawColor(255, 255, 255, 30)
				surface.DrawTexturedRect(0, 0, w, h)

				self.selection = nil
				if (self.status == STATUS_STANBY) then
					draw.SimpleText(L"atmWelcome", "nutSubNATMFont", w/2, scale*1.5, color_white, 1, 5)

					for i = 1, 3 do
						local sp, sp2 = 12 * scale, 3 * scale
						local bp, bp2 = w/2 - sp/2, scale * 4.2 + (i-1) * sp2*1.3

						local bool = self:cursorInBox(bp, bp2, sp, sp2)

						if (bool) then
							self.selection = i
						end

						surface.SetDrawColor(46, 204, 113)
						surface.DrawRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(0, 0, 0, 155)
						surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
						surface.DrawTexturedRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(39, 174, 113)
						surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

						draw.SimpleText(L(text[i]), "nutSubNATMFont", bp + sp/2, bp2 + sp2/2 - 2, color_white, 1, 1)
					end
					self.decimalText = ""
				elseif (self.status == STATUS_DEPOSIT or self.status == STATUS_WITHDRAW) then
					draw.SimpleText(
						L(self.status == STATUS_DEPOSIT and "myMoney" or "bankMoney")
					, "nutSubNATMFont", scale*1.5, scale, color_white, 3, 5)

					local b1, b2 = w*0.9, scale*2
					local p1, p2 = w/2, scale*4
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							self.status == STATUS_DEPOSIT and char:getMoney() or char:getReserve()
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L(self.status == STATUS_DEPOSIT and "depositAmount" or "withdrawAmount")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)

					p1, p2 = w/2, scale*8.3
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)

					draw.SimpleText(
					nut.currency.get((self.decimalText == "" and 0 or self.decimalText)) .. (RealTime()%2 >= 1 and "_" or ""), "nutSubNATMFont"
					, p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)
					
					p1, p2 = scale*2.2, scale*11
					local kx, ky = 0, 0
					local kw, kh = scale*2, scale*2

					for i = 1, 2 do
						local sp, sp2 = 9 * scale, 2.2 * scale
						local bp, bp2 = w - sp - scale*1.3, scale * 10.2 + (i-1) * sp2*1.2

						local bool = self:cursorInBox(bp, bp2, sp, sp2)

						if (bool) then
							self.selection = "b" .. i
						end

						surface.SetDrawColor(46, 204, 113)
						surface.DrawRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(0, 0, 0, 155)
						surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
						surface.DrawTexturedRect(bp, bp2, sp, sp2)
						surface.SetDrawColor(39, 174, 113)
						surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

						draw.SimpleText(L(text2[i]), "nutSubNATMFont", bp + sp/2, bp2 + sp2/2 - 2, color_white, 1, 1)
					end
				elseif (self.status == STATUS_INFO) then
					draw.SimpleText(
						L("bankMoney")
					, "nutSubNATMFont", scale*1.5, scale, color_white, 3, 5)
					local b1, b2 = w*0.9, scale*2
					local p1, p2 = w/2, scale*4
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							char:getReserve()
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L("profitRate")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)
					p1, p2 = w/2, scale*8.3
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						(nut.config.get("incomeRate") / 100) .. "%"
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)

					draw.SimpleText(
						L("profitAmount")
					, "nutSubNATMFont", scale*1.5, p2 + scale*1.2, color_white, 3, 5)
					p1, p2 = w/2, scale*12.7
					surface.SetDrawColor(0, 0, 0, 100)
					surface.DrawRect(p1 - b1/2, p2 - b2/2, b1, b2)
					draw.SimpleText(
						nut.currency.get(
							math.Round(char:getReserve() * (nut.config.get("incomeRate") / 100))
						)
					, "nutSubNATMFont", p1 - b1/2 + scale * 0.5, p2-2, color_white, 3, 1)
				end
		end
	end


	local keypad = {	
		"1", "2", "3",
		"4", "5", "6",
		"7", "8", "9",
		"0", "00", "s",
	}
	local btnCalls = {
		"apply",
		"cancel",
	}
	local function renderCode2(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			self.selection = nil

			local mx, my = self:mousePos()
			local scale = 1 / self.scale
			local bx, by, color	

			surface.SetDrawColor(0, 0, 0, 100)
			surface.DrawRect(0, 0, w, h)	

			local b1, b2 = 0, 0
			local p1, p2 = scale, scale

			local kw, kh = scale*2, scale*1.5
			for k, v in ipairs(keypad) do
				local col = math.ceil(k/3)
				local row = (k%3) 
				
				kx, ky = p1 - kw/2 + (row == 0 and 2 or row - 1) * kw * 1.2, p2 - kh/2 + (col-1) * kh * 1.2
				local bool = self:cursorInBox(kx, ky, kw, kh)

				if (bool) then
					self.selection = "k" .. k
				end

				surface.SetDrawColor(46, 204, 113)
				surface.DrawRect(kx, ky, kw, kh)
				surface.SetDrawColor(0, 0, 0, 155)
				surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
				surface.DrawTexturedRect(kx, ky, kw, kh)
				surface.SetDrawColor(39, 174, 113)
				surface.DrawOutlinedRect(kx+1, ky+1, kw-2, kh-2)

				surface.SetDrawColor(255, 0, 0, bool and 200 or 100)
				draw.SimpleText(v, k == 12 and "nutIconsSmall" or "nutKeypadFont", kx + kw/2 - 1, ky + kh/2 - 2, color_white, 1, 1)
			end

			local kkw, kkh = scale*3.5, scale*1.5
			for i = 0, 1 do
				kx, ky = p1 - kw/2 + 3 * scale*2 + scale*1.5, p2 - kkh/2 + (i) * kkh * 1.2
				local bool = self:cursorInBox(kx, ky, kkw, kkh)
				
				if (bool) then
					self.selection = "b" .. i
				end

				surface.SetDrawColor(46, 204, 113)
				surface.DrawRect(kx, ky, kkw, kkh)
				surface.SetDrawColor(0, 0, 0, 155)
				surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
				surface.DrawTexturedRect(kx, ky, kkw, kkh)
				surface.SetDrawColor(39, 174, 113)
				surface.DrawOutlinedRect(kx+1, ky+1, kkw-2, kkh-2)
				draw.SimpleText(L(btnCalls[i+1]), "nutSubNATMFont", kx+kkw/2, ky+kkh/2-2, color_white, 1, 1)
			end
		end
	end

	local donkatsu = false
	local function onMouseClick(self)
		if (self.selection) then
			if (self.status == STATUS_STANBY) then
				self.status = self.selection
			elseif (self.status == STATUS_DEPOSIT or self.status == STATUS_WITHDRAW) then
				local cursel = tonumber(string.Replace(self.selection, "b", ""))

				if (cursel == 1) then
					self.decimalText = ""
				elseif (cursel == 2) then
					local char = LocalPlayer():getChar()

					self.decimalText = tostring(
						math.Round(
								self.status == STATUS_DEPOSIT and char:getMoney() or char:getReserve()
							)
					)
				end
			end
		end
	end

	local donkatsu = false
	local function onMouseClick2(self)
		if (self.selection) then
			if (self.actualScreen.status == STATUS_DEPOSIT or self.actualScreen.status == STATUS_WITHDRAW) then
				if (self.selection[1] == "k") then
					if (IsValid(self.ent)) then 
						self.ent:EmitSound("ui/buttonclick.wav")
					end

					local cursel = tonumber(string.Replace(self.selection, "k", ""))

					if (cursel != 12) then
						self.actualScreen.decimalText = self.actualScreen.decimalText .. keypad[cursel]
					else
						self.actualScreen.decimalText = self.actualScreen.decimalText:sub(1, self.actualScreen.decimalText:len() - 1)
					end
				elseif (self.selection[1] == "b") then
					if (IsValid(self.ent)) then 
						self.ent:EmitSound("ui/buttonclick.wav")
					end

					local cursel = tonumber(string.Replace(self.selection, "b", ""))

					if (cursel == 1) then
						self.actualScreen.decimalText = ""
						self.actualScreen.status = STATUS_STANBY
					elseif (cursel == 0) then
						if (self.decimalText != "") then
							LocalPlayer():ConCommand(Format("say %s %s", 
								self.actualScreen.status == STATUS_DEPOSIT and "/bankdeposit" or "/bankwithdraw" 
							, self.actualScreen.decimalText))
						end

						self.actualScreen.status = STATUS_STANBY
					end
				end
			elseif (self.actualScreen.status == STATUS_INFO) then
				if (self.selection[1] == "b") then
					if (IsValid(self.ent)) then 
						self.ent:EmitSound("ui/buttonclick.wav")
					end

					local cursel = tonumber(string.Replace(self.selection, "b", ""))

					if (cursel == 1) then
						self.actualScreen.status = STATUS_STANBY
					elseif (cursel == 0) then
						self.actualScreen.status = STATUS_STANBY
					end
				end
			end
		end
	end

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:InitScreen()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(18, 16, .07)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.entity = self
		self.screen.status = STATUS_STANBY
		self.screen.renderCode = renderCode
		self.screen.onMouseClick = onMouseClick
		
	end

	function ENT:InitKeypad()
		-- Creates new Touchable Screen Object for this Entity.
		self.touch = nut.screen.new(11, 7.3, .05)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.touch.entity = self
		self.touch.status = STATUS_STANBY
		self.touch.actualScreen = self.screen

		self.touch.renderCode = renderCode2
		self.touch.onMouseClick = onMouseClick2
	end

	function ENT:Initialize()
		self:InitScreen()
		self:InitKeypad()
	end

	local gap = 4
	function ENT:DrawTranslucent()
		if (!self.screen) then
			self:InitScreen()
		end

		if (!self.touch) then
			self:InitKeypad()
		end

		local coPos, coAng = self:GetPos(), self:GetAngles()
		coAng:RotateAroundAxis(self:GetRight(), 23.33)
		coPos = coPos + self:GetForward() * 4.2
		coPos = coPos + self:GetRight() * 9.7
		coPos = coPos + self:GetUp() * 54.1

		self.screen.pos = coPos
		self.screen.ang = coAng
		self.screen.ent = self

		coPos, coAng = self:GetPos(), self:GetAngles()
		coAng:RotateAroundAxis(self:GetRight(), 80)
		coPos = coPos + self:GetForward() * 13
		coPos = coPos + self:GetRight() * 10
		coPos = coPos + self:GetUp() * 41
		
		self.touch.pos = coPos
		self.touch.ang = coAng
		self.touch.ent = self

		local dist = LocalPlayer():GetPos():Distance(self:GetPos())

		if (dist < 512) then
			self.screen:render()
			self.touch:render()
		else
			self.screen.status = 0
		end
	end

	function ENT:Think()
		if (self.screen) then
			self.screen:think()
		end

		if (self.touch) then
			self.touch:think()
		end
	end

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:OnRemove()
		self.screen = nil
		self.touch = nil
	end
end