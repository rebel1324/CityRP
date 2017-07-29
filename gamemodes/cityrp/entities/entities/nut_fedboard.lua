AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Server Board"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Server"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/hunter/plates/plate2x5.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetColor(color_black)
		self:DrawShadow(false)
	end

	function ENT:OnRemove()
	end
else
		-- This fuction is 3D2D Rendering Code.
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local gradient2 = nut.util.getMaterial("vgui/gradient-u")

	surface.CreateFont("nutFedTitle", {
		font = "Calibri",
		extended = true,
		size = 66,
		weight = 1000
	})

	surface.CreateFont("nutFedSubTitle", {
		font = "Calibri",
		extended = true,
		size = 44,
		weight = 1000
	})

	local oldTime = RealTime()
	local curTime = 0

	local function renderCode(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			curTime = RealTime() - oldTime
			oldTime = RealTime()

			local scale = 1 / self.scale
			
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(0, 0, w, h)

			nut.util.drawText(L"serverBoard", scale*5, scale*10, color_white, 3, 1, "nutFedTitle")
			nut.util.drawText(L"serverBoardSub", scale*6, scale*22, color_white, 3, 1, "nutFedSubTitle")

			surface.SetDrawColor(255, 255, 255)

			local bdw = w*0.95
			surface.DrawRect(w/2 - bdw/2, scale*30, bdw, 5)

			local scroll = RealTime()*.05%1 * w*4*-1


				local laws = 0
				local players = 0
				do
					-- get police

					for k, v in ipairs(player.GetAll()) do
						local char = v:getChar()

						if (char) then
							local class = char:getClass()
							local classData = nut.class.list[class]

							if (classData and classData.law) then
								laws = laws + 1
							end

							players = players + 1
						end
					end
				end

				nut.util.drawText("Goverment Fund", w/2 + scroll
					, scale*52, color_white, 1, 1, "nutFedSubTitle")
				nut.util.drawText(nut.currency.get(100000), w/2 + scroll
					, scale*66, color_white, 1, 1, "nutFedTitle")

				nut.util.drawText("Citizens in the City", w/2 + w + scroll
					, scale*52, color_white, 1, 1, "nutFedSubTitle")
				local time = Format("%s Citizens", players)
				nut.util.drawText(time, w/2 + w + scroll
					, scale*66, color_white, 1, 1, "nutFedTitle")

				local text = "is Active"
				do
					if (laws < nut.config.get("raidLaws", 5)) then
						text = Format("Need more Police (%s/%s)", laws, nut.config.get("raidLaws", 5))
					end
				end

				nut.util.drawText("Bankrobbery", w/2 + w*2 + scroll
					, scale*52, color_white, 1, 1, "nutFedSubTitle")
				nut.util.drawText(text, w/2 + w*2 + scroll
					, scale*66, color_white, 1, 1, "nutFedTitle")

				local num = 0
				for k, v in ipairs(player.GetAll()) do
					local char = v:getChar()

					if (char) then
						if (char:getArrest()) then
							num = num + 1
						end
					end
				end

				nut.util.drawText("Arrested Convicts", w/2 + w*3 + scroll
					, scale*52, color_white, 1, 1, "nutFedSubTitle")
				nut.util.drawText(num .. "Convicts", w/2 + w*3 + scroll
					, scale*66, color_white, 1, 1, "nutFedTitle")

				nut.util.drawText("Goverment Fund", w/2 + w*4 + scroll
					, scale*52, color_white, 1, 1, "nutFedSubTitle")
				nut.util.drawText(nut.currency.get(100000), w/2 + w*4 + scroll
					, scale*66, color_white, 1, 1, "nutFedTitle")
				
		end
	end

	-- This function called when client clicked(Pressed USE, Primary/Secondary Attack).
	local function onMouseClick(self, key)

	end

	function ENT:Initialize()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(237, 95, .3)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.noClipping = false
		self.screen.fadeAlpha = 1
		self.screen.idxAlpha = {}

		-- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick
	end
	
	function ENT:Draw()
		-- Draw Model.
		--self:DrawModel()
	end

	local pos, ang, renderAng
	local mc = math.Clamp
	function ENT:DrawTranslucent()
		-- Render 3D2D Screen.
		local dist = LocalPlayer():GetPos():Distance(self:GetPos())

		if (dist < 1024) then
			self.screen:render()
		end
	end

	function ENT:Think()
		pos = self:GetPos()
		ang = self:GetAngles()

		-- Shift the Rendering Position.
		pos = pos + ang:Up() * 1.7
		pos = pos + ang:Right() * -0
		pos = pos + ang:Forward() * 00

		-- Rotate the Rendering Angle.
		renderAng = Angle(ang[1], ang[2], ang[3])
		renderAng:RotateAroundAxis(ang:Up(), 0)
		renderAng:RotateAroundAxis(ang:Right(), 90)

		-- Update the Rendering Position and angle of the Touchable Screen Object.
		self.screen.pos = pos
		self.screen.ang = renderAng
		self.screen.ent = self
		self.screen.renderCode = renderCode

		-- If The Screen has no Focus(If player is not touching it), Increase Idle Screen's Alpha.
		if (self.screen.hasFocus) then
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha - FrameTime()*4, 0, 1)
		else
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha + FrameTime()*2, 0, 1)
		end
	end
end
