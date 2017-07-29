AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Recycler"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup 		= RENDERGROUP_BOTH

if (CLIENT) then
	ENT.CurrencyShort = "tok"
end
if (SERVER) then
	local RecycleTargets = {
		"junk_ws",
		"junk_wj",
		"junk_be",
		"junk_bt",
		"junk_p",
		"junk_ss",
		"junk_bl",
		"junk_k",
		"junk_p",
		"junk_hp",
		"junk_ec",
		"junk_ej",
	}
	ENT.RecycleTime = 10
	ENT.TokenHoldTime = 60

	function ENT:Initialize()
		self:SetModel("models/props_wasteland/laundry_dryer002.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTInt(0, 0) -- recycle amount
		self:SetDTInt(0, 0) -- holding tokens
		self:SetDTBool(0, false) -- activated
		self:SetDTBool(0, false) -- holding
		self.timeGen = CurTime()
		self.timeHold = CurTime()
		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
	end

	function ENT:TurnOff()
		self:SetDTBool(0, false)
		self:SetDTBool(1, true)
		self:SetDTInt(1, 0)
		self:EmitSound("plats/elevator_stop.wav")
		self.loopsound:Stop()
		self.idle = true

		timer.Simple(1, function()
			self.idle = false

			self:EmitSound("hl1/fvox/deeoo.wav", 60, 150)
			self:SetDTBool(1, false)
		end)

		self.activator = nil
		return
	end

	function ENT:TurnOn(client)
		local n = client:getNetVar("garbage", 0)

		local reward = hook.Run("CalculateGarbage", client, n)
		
		if (reward and reward > 0) then
			local char = client:getChar()

			if (char) then
				char:giveMoney(reward)
				client:notifyLocalized("moneyTaken", nut.currency.get(reward))
			end
		end
		client:setNetVar("garbage", 0)
		
		self.loopsound = CreateSound( self, "ambient/machines/machine3.wav" ) -- weird issue.
		self.loopsound:Play()
		self:SetDTBool(0, true)
		self:SetDTInt(0, 0)
		self.timeGen = CurTime() + self.RecycleTime
	end

	function ENT:Think()
		if self:GetDTBool(0) then
			if self.timeGen < CurTime() then
				self:TurnOff()
			end
		else
			if self:GetDTBool(1) and self.timeHold < CurTime() then
				self:EmitSound("hl1/fvox/dadeda.wav", 60, 100)
				self:EmitSound("ambient/machines/combine_terminal_idle1.wav", 60, 100)
				self:SetDTBool(1, false)
				self.activator = nil
			end
		end
		self:NextThink(CurTime() + 1)
		return true
	end

	function ENT:CanTurnOn(client)
		return (!self:GetDTBool(0) and !self:GetDTBool(1)) -- machine is off
	end

	function ENT:CanUse(client)
		local char = client:getChar()

		if (char) then
			local class = char:getClass()

			return (class == CLASS_HOBO)

		end

		return 
	end

	function ENT:Use(client)
		if (!self:CanUse(client)) then
			return
		end

		local n = client:getNetVar("garbage", 0)

		if (n <= 0) then
			client:notifyLocalized("needGarbage", n)

			return
		end

		if self:CanTurnOn(client) then
			self.activator = client
			self:TurnOn(client)
			return
		else
			client:notifyLocalized("busyMachine")

			self:EmitSound("common/wpn_denyselect.wav", 80, 130)
			return
		end
	end
else

	ENT.modelData = {
		["cylinder"] = {
			model = "models/props_wasteland/laundry_washer001a.mdl",
			size = 0.6,
			angle = Angle(-90, 0, 0),
			position = Vector(5.7164611816406, 2.4400634765625, 5.051220703125),
			scale = Vector(1, 1, 1),
		},
		["card"] = {
			model = "models/props_lab/powerbox03a.mdl",
			size = 1,
			angle = Angle(0, 0, 0),
			position = Vector(17.266235351563, -27.982055664063, -8.01220703125),
			scale = Vector(1, 1, 1),
		},
		["comlock"] = {
			model = "models/props_combine/combine_lock01.mdl",
			size = 1,
			angle = Angle(0, -90, 0),
			position = Vector(18.120361328125, -30.808715820313, 7.033935546875),
			scale = Vector(1, 0.69999998807907, 1.2000000476837),
		},
	}

	function ENT:OnRemove()
		self.models = self.models or {}

		for k, v in pairs(self.modelData) do
			local drawingmodel = self.models[k] -- localize

			if drawingmodel and drawingmodel:IsValid() then
				drawingmodel:Remove()
			end
		end
	end

	function ENT:Draw()
		self:DrawModel()
		self.models = self.models or {}

		for k, v in pairs(self.modelData) do
			local drawingmodel = self.models[k] -- localize

			if !drawingmodel or !drawingmodel:IsValid() then		
				self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
				self.models[k]:SetColor( v.color or color_white )
				self.models[k]:SetNoDraw(true)
				if (v.scale) then
					local matrix = Matrix()
					matrix:Scale( (v.scale or Vector( 1, 1, 1 ))*(v.size or 1) )
					self.models[k]:EnableMatrix("RenderMultiply", matrix)
				end
				if (v.material) then
					self.models[k]:SetMaterial( v.material )
				end
			end

			if drawingmodel and drawingmodel:IsValid() then
				local pos, ang = self:GetPos() - self:GetForward()*-5, self:GetAngles()
				local ang2 = ang

				drawingmodel.offset = drawingmodel.offset or Vector(0, 0, 0)
				pos = pos + self:GetForward()*v.position.x + self:GetUp()*v.position.z + self:GetRight()*-v.position.y
				pos = pos + self:GetForward()*drawingmodel.offset.x + self:GetUp()*drawingmodel.offset.z + self:GetRight()*-drawingmodel.offset.y

				ang2:RotateAroundAxis( self:GetRight(), v.angle.pitch ) -- pitch
				ang2:RotateAroundAxis( self:GetUp(),  v.angle.yaw )-- yaw
				ang2:RotateAroundAxis( self:GetForward(), v.angle.roll )-- roll

				drawingmodel:SetRenderOrigin( pos )
				drawingmodel:SetRenderAngles( ang2 )
				drawingmodel:DrawModel()
			end
		end

		if self.models then
			local mdl = self.models.cylinder

			if mdl:IsValid() then
				mdl.offset = mdl.offset or Vector( 0, 0, 0 )
				if self:GetDTBool(0) then
					mdl.offset = LerpVector(FrameTime(), mdl.offset, Vector(-3, 0, 0))
				else
					mdl.offset = LerpVector(FrameTime(), mdl.offset, Vector(0, 0, 0))
				end
			end
		end
	end

	local sx, sy = 100, 50
	local ms = math.sin
	local mc = math.cos
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:DrawTranslucent()
		if self.models then
			local rt = RealTime()
			local mdl = self.models.comlock
			if mdl:IsValid() then
				local pos, ang = mdl:GetPos(), mdl:GetAngles()
				pos = pos + self:GetForward()*5.4
				pos = pos + self:GetUp()*-10.6
				pos = pos + self:GetRight()*-3.8
				if self:GetDTBool(0) then
					local alpha = math.Clamp(math.abs( ms(6*rt)+ms(14*rt)+mc(22*rt) )*500, 0, 255 )
					render.SetMaterial(GLOW_MATERIAL)
					render.DrawSprite(pos, 12, 12, Color( 44, 255, 44, alpha ) )
				else
					local alpha = math.Clamp(math.abs( ms(2*rt) )*255, 0, 255 )
					render.SetMaterial(GLOW_MATERIAL)
					if self:GetDTBool(1) then
						render.DrawSprite(pos, 12, 12, Color( 255, 150, 10, alpha ) )
					else
						render.DrawSprite(pos, 12, 12, Color( 255, 44, 44, alpha ) )
					end
				end
			end

			local mdl = self
			if mdl:IsValid() then
				local pos, ang = mdl:GetPos(), mdl:GetAngles()
				pos = pos + self:GetForward()*19.5
				pos = pos + self:GetUp()*-35
				pos = pos + self:GetRight()*0
				ang:RotateAroundAxis( self:GetRight(), -90 )
				ang:RotateAroundAxis( self:GetForward(), 90 )
				cam.Start3D2D(pos, ang, 0.3)
					nut.util.drawText("Recycling Machine", 0, 0, Color(255, 255, 255, distalpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "ChatFont")
				cam.End3D2D()
			end
		end
	end

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*25):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"garbageProcessorName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"garbageProcessorDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		nut.util.drawText(L("garbageProcessorClient", LocalPlayer():getNetVar("garbage", 0)), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)

		if (self:GetDTBool(0)) then
			nut.util.drawText(L"garbageProcessorUse", x, y + 48, ColorAlpha(Color(255, 0, 0), alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		end
	end
end