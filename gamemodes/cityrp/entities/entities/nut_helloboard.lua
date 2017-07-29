AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Hello Board"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Server"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.invType = "terminal"
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
		self:SetModel("models/props_lab/blastdoor001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetMaterial("phoenix_storms/wood_side")
		self:DrawShadow(false)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end

	function ENT:Use(client)
		client:SendLua("gui.OpenURL('http://steamcommunity.com/groups/cityrpdev/discussions/0/')")
	end
else
	local text = L"helloBoard"
	local textLen = utf8.len(text)
	local textTable = {}

	local text2 = L"helloBoardSub"
	local textLen2 = utf8.len(text2)
	local textTable2 = {}

	local function renderCode(self, ent, w, h)
		textTable = {}
		textTable2 = {}
		text = L"helloBoard"
		text2 = L"helloBoardSub"
		textLen = utf8.len(text)
		textLen2 = utf8.len(text2)
		for i = 1, textLen do
			table.insert(textTable, string.utf8sub(text, i, i))
		end
		for i = 1, textLen2 do
			table.insert(textTable2, string.utf8sub(text2, i, i))
		end
		
		local char = LocalPlayer():getChar()

		local scale = 1 / self.scale
		local bx, by, color, idxAlpha

		surface.SetDrawColor(0, 0, 0, 250)
		surface.DrawRect(0, 0, w, h+1)	


		local offset = 0
		surface.SetFont("nutBigFont")
		local tx, ty = surface.GetTextSize(text)

		for k, v in pairs(textTable) do
			surface.SetTextColor(255, 255, math.sin(RealTime()*2+k/2)*255, 255)
			local ax, ay = surface.GetTextSize(v)
			surface.SetTextPos(12 + w/2 - ax/2 - tx/2 + offset, -10 + h/2 - ay/2 + math.sin(RealTime()*5 + k) * 4)
			surface.DrawText(v)
			offset = offset + ax
		end

		local offset = 0
		surface.SetFont("nutSmallFont")
		local tx, ty = surface.GetTextSize(text2)

		for k, v in pairs(textTable2) do
			surface.SetTextColor(255, 255, math.sin(RealTime()*2+k/5)*255, 255)
			local ax, ay = surface.GetTextSize(v)
			surface.SetTextPos(5 + w/2 - ax/2 - tx/2 + offset, 20 + h/2 - ay/2 + math.sin(RealTime()*5 + k) * 3)
			surface.DrawText(v)
			offset = offset + ax
		end
	end

	local function onMouseClick(self)
	end

	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/hunter/plates/plate1x1.mdl"
	MODEL.angle = Angle(0, 90, 0)
	MODEL.position = Vector(0, 0, 60)
	MODEL.scale = Vector(1, 1, 2)
	MODEL.material = "phoenix_storms/wood_side"
	ENT.modelData["screen"] = MODEL

		
	local MODEL = {}
	MODEL.model = "models/props_c17/playgroundTick-tack-toe_post01.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(0, 0, 0)
	MODEL.scale = Vector(1, 1, 1)
	MODEL.material = "phoenix_storms/wood_side"
	ENT.modelData["cosin"] = MODEL

	local MODEL = {}
	MODEL.model = "models/props_rooftop/dome005.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(0, 0, 80)
	MODEL.scale = Vector(.2, 1.1, .6)*.2
	MODEL.material = "phoenix_storms/wood_side"
	ENT.modelData["roof"] = MODEL

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:Initialize()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(100, 100, .5)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.noClipping = false
		self.screen.fadeAlpha = 1
		self.screen.idxAlpha = {}
		self.screen.dorp = 1
		self.screen.entity = self

		-- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick

		self.lerp = 0
		self.models = {}
		
		for k, v in pairs(self.modelData) do
			self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
			self.models[k]:SetColor( v.color or color_white )
			self.models[k]:SetNoDraw(true)

			if (v.material) then
				self.models[k]:SetMaterial( v.material )
			end
		end
	end

	function ENT:OnRemove()
		for k, v in pairs(self.models) do
			if (v and v:IsValid()) then
				v:Remove()
			end
		end
	end

	local gap = 4
	function ENT:DrawTranslucent()
		local drawEntity = self.models["screen"]

		if (drawEntity and drawEntity:IsValid()) then
			local coPos, coAng = drawEntity:GetRenderOrigin(), drawEntity:GetRenderAngles()

			coPos = coPos + self:GetForward() * 3.5
			coPos = coPos + self:GetRight() * 0
			coPos = coPos + self:GetUp() * 0

			-- Update the Rendering Position and angle of the Touchable Screen Object.
			self.screen.pos = coPos
			self.screen.ang = coAng
			self.screen.ent = self

			coAng:RotateAroundAxis(coAng:Right(), -90)
			self.screen.w, self.screen.h, self.screen.scale = 50, 50, .2

			-- fuckoff
			self.screen.renderCode = renderCode

			local dist = LocalPlayer():GetPos():Distance(self:GetPos())

			if (dist < 1024) then
				self.screen:render()
			end
		end
	end

	function ENT:Draw()
		for uid, dat in pairs(self.modelData) do
			local drawEntity = self.models[uid]

			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = self:GetPos(), self:GetAngles()
				local ang2 = ang

				pos = pos + self:GetForward() * dat.position[1]
				pos = pos + self:GetRight() * dat.position[2]
				pos = pos + self:GetUp() * dat.position[3]

				ang:RotateAroundAxis(self:GetForward(), dat.angle[1])
				ang:RotateAroundAxis(self:GetRight(), dat.angle[2])
				ang:RotateAroundAxis(self:GetUp(), dat.angle[3])

				if (dat.scale) then
					local matrix = Matrix()
					matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
					drawEntity:EnableMatrix("RenderMultiply", matrix)
				end

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )
				drawEntity:DrawModel()
			else
				self.models[uid] = ClientsideModel(dat.model, RENDERGROUP_BOTH )
				self.models[uid]:SetColor( dat.color or color_white )
				self.models[uid]:SetNoDraw(true)

				if (v.material) then
					self.models[uid]:SetMaterial( dat.material )
				end
			end
		end
	end

	function ENT:OnRemove()
	end
end