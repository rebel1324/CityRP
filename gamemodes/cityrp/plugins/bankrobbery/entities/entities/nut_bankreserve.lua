AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Bank Reserve"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.isFire = true
ENT.maxSteal = 20
ENT.useCooldown = 1.6

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/Items/ammoCrate_Rockets.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTBool(0, false)
		self:SetDTInt(1, self.maxSteal)
		self:SetMaterial("phoenix_storms/gear")
		self:setNetVar("nextSteal", CurTime())

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end

	function ENT:Use(client)
		local rob, why = hook.Run("CanDoRobbery", client)
		if (rob == false) then
			client:notifyLocalized(why)
			return
		end
		if (self:getNetVar("nextSteal") > CurTime()) then return end
		if (self:GetDTInt(1) <= 0) then return end

		local seq = self:LookupSequence("Close")
		self:ResetSequence(seq)

		timer.Create(self:EntIndex() .. "_crateAnimation", 5, 1, function()
			if (self and IsValid(self)) then
				local seq = self:LookupSequence("Open")

				self:ResetSequence(seq)
				self:EmitSound("items/ammocrate_close.wav")
			end
		end)
		
		client:addStolenMoney(nut.config.get("raidMoneyWorth", 500))
		self:EmitSound("items/ammocrate_open.wav")
		self:SetDTInt(1, math.max(0, self:GetDTInt(1) - 1))
		self:setNetVar("nextSteal", CurTime() + self.useCooldown)
		hook.Run("OnPlayerStealMoney", client, self)

		timer.Create(self:EntIndex() .. "_refillBank", nut.config.get("raidSpawn", 150), 1, function()
			if (self and self:IsValid()) then
				self:SetDTInt(1, self.maxSteal)
			end
		end)
	end

	function ENT:OnRemove()
	end
else
	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/hunter/plates/plate4x8.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(0, 0, 10)
	MODEL.scale = Vector(1, 0.89, .1) * .165
	MODEL.material = "models/props/cs_assault/moneytop"
	ENT.modelData["money"] = MODEL

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function ENT:Initialize()
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
		self.stopEverything = true

		for k, v in pairs(self.models) do
			if (v and v:IsValid()) then
				v:Remove()
			end
		end
	end

	local gap = 4
	function ENT:DrawTranslucent()
		local pos, ang = self:GetPos(), self:GetAngles()

		pos = pos + self:GetForward()*17
		pos = pos + self:GetUp()*9
		pos = pos + self:GetRight()*0
		
		ang:RotateAroundAxis( self:GetUp(), 90 )
		ang:RotateAroundAxis( self:GetRight(), -90 )
		
		local dist = pos:Distance(LocalPlayer():GetPos())
		local alpha = math.max((math.min(2, dist / 60) - 1), 0) * 255

		if (alpha != 255) then
			cam.Start3D2D(pos, ang, .2)
				if (self:GetDTInt(1) > 0) then
					local tx, ty = nut.util.drawText("COOLTIME", 0, 0, Color(255, 255, 255, 255 - alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "nutBigFont")

					perc = math.max(0, (self:getNetVar("nextSteal") - CurTime()) / self.useCooldown)
					surface.SetDrawColor(255, 255, 255, 15 - alpha / 255 * 15)
					surface.DrawRect(-tx/2, ty/2, tx, 5)
					surface.DrawOutlinedRect(-tx/2 , ty/2, tx, 15)

					surface.SetDrawColor(255, 255, 255, 255 - alpha)
					surface.DrawRect(-tx/2 + gap, ty/2 + gap, (tx - gap*2)*perc, 15 - gap*2)
				else
					local colAlpha = 44 + 211 * math.abs(math.sin(RealTime()*5))

					local tx, ty = nut.util.drawText("EMPTY", 0, 0, Color(222, 44, 44, colAlpha - alpha / 255 * colAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "nutBigFont")
				end
			cam.End3D2D()
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

				if (uid == "money") then
					local perc = math.max(0, self:GetDTInt(1)) / self.maxSteal

					pos = pos + self:GetUp() * - (6 * (1 - perc))


					if (self:GetDTInt(1) == 0) then
						drawEntity:SetMaterial("phoenix_storms/gear")
					else
						drawEntity:SetMaterial("models/props/cs_assault/moneytop")
					end
				end

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
			end
		end

		self:DrawModel()
	end

	function ENT:OnRemove()
	end
end