AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Outfitter"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Server"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/rebel1324/outfitter.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.health = 100

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	local chillman = CurTime()
	function ENT:Use(client)
		if (chillman and chillman > CurTime()) then return end
		chillman = CurTime() + 1
		netstream.Start(client, "nutOutfitShow")
	end
else
	netstream.Hook("nutOutfitShow", function()
		vgui.Create("nutOutfit")
	end)
	
	local w, h = 920, 500

	function ENT:Initialize()
		self:declarePanels()

		self.displayFraction = 0
		self.curScale = 0
		self.curHeight = 0
		self.renderIdle = 0
		self.stareDeploy = 0

		hook.Add("GetMapEntities", self, function(entity, dataList)
			table.insert(dataList, {
				pos = entity:GetPos(),
				id = "outfitter",
				entity = entity
			})
		end)
	end

	-- universial
	function ENT:Think()
		self.pos = self:GetPos()
		self.ang = self:GetAngles()

		self:adjustPosition()

		-- optimization process.
		if (self.curScale < .15 or self.renderIdle < CurTime() or self:GetNoDraw() == true) then
			nut.blur3d2d.pause(self:EntIndex())
		else
			nut.blur3d2d.resume(self:EntIndex())
		end
		
		return true
	end

	-- ofc this should be done.
	function ENT:OnRemove()
		nut.blur3d2d.remove(self:EntIndex())
	end
	
	surface.CreateFont("nutBlurSubText", {
		font = "Bahnschrift",
		size = 70,
		extended = true,
		weight = 500
	})

	function ENT:Draw()
		local spd = FrameTime()
		local target

		if (self.stareDeploy > CurTime()) then
			self.displayFraction = math.Approach(self.displayFraction, 1, spd*.5)
			self.curScale = nut.ease.easeOutElastic(self.displayFraction, 1, 0, 1)
		else
			self.displayFraction = math.Approach(self.displayFraction, 0, spd * 5)
			self.curScale = Lerp(FrameTime() * 15, self.curScale, 0)
		end
		
		self:drawThink()

		self:DrawModel()
		self.renderIdle = CurTime() + .1
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		self.stareDeploy = CurTime() + FrameTime()*10
	end

	function ENT:emitGas()
		local e = EffectData()
		e:SetStart(self:GetPos() + self:OBBCenter())
		e:SetScale(0.1)
		util.Effect( "vendorGas", e )
	end

	-- customizable functions
	function ENT:drawThink()
		-- Draw Model.
		local blurRender = nut.blur3d2d.get(self:EntIndex())
		if (blurRender) then
			blurRender.pos = self.pos
			blurRender.ang = self.ang
			blurRender.scale = (self.curScale) * .04
		end
	end

	function ENT:declarePanels()
		local itemTable = nut.item.list[self.item]
		local name
		if (itemTable) then
			name = itemTable.name
		end

		nut.blur3d2d.add(self:EntIndex(), Vector(), Angle(), .15,
		function(isOverlay) 
			local text = L("outfit", name)
			local text2 = L("outfitterDesc", name)

			if (isOverlay) then
				-- stencil overlay (something you want to draw)
				local tx, ty = nut.util.drawText(text, 0, h*-.1, color_white, 1, 4, "nutBlurText", 100)
				nut.util.drawText(text2, 0, h*.01, color_white, 1, 4, "nutBlurSubText", 100)
				nut.util.drawText("", 0, h*.05, color_white, 1, 5, "nutBlurIcon", 100)
			else
				surface.SetFont("nutBlurSubText")
				local sizex = surface.GetTextSize(text2)
				-- stencil background (blur area)
				local w = sizex + 200
				local x, y = -w/2, -h/2
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(x, y, w, h)
			end
		end)
	end

	function ENT:adjustPosition()
		-- make a copy of the angle.
		local rotAng = self.ang*1

		-- Shift the Rendering Position.
		self.pos = self.pos + rotAng:Up() * 61
		self.pos = self.pos + rotAng:Right() * 30
		self.pos = self.pos + rotAng:Forward() * 0

		-- Rotate the Rendering Angle.
		self.ang = rotAng
		self.ang:RotateAroundAxis(self:GetUp(), 0)
		self.ang:RotateAroundAxis(self:GetForward(), 80)
	end
end