AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Weed pot"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Crime"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.maxGrowth = 2200
ENT.soilPrice = 850
ENT.seedPrice = 110

--models/props_debris/wood_board02a.mdl

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		return entity
	end


	function ENT:setHealth(amount)
		self.health = amount
	end
	
	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0 and !self.onbreak) then
			self.onbreak = true
			self:Remove()
		end
	end

	function ENT:Initialize()
		self:SetModel("models/gonzo/weedb/pot2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self:SetDTBool(0, false) -- soil
		self:SetDTBool(1, false) -- weed

		self:SetDTInt(0, 0) -- growth

		self.health = 88

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:Use(client)
		local char = client:getChar()

		if (!self:GetDTBool(0)) then
			-- pay
			self:SetBodygroup(1, 1)
			self:SetDTBool(0, true)


			if (char:hasMoney(self.soilPrice)) then
				char:giveMoney(-self.soilPrice)
				client:notifyLocalized("purchaseEntity", "토양", nut.currency.get(self.soilPrice))
			else	
				client:notifyLocalized("soilCost", nut.currency.get(self.soilPrice))
				return
			end

			return
		end

		if (self:GetDTBool(0) and !self:GetDTBool(1)) then
			if (char:hasMoney(self.seedPrice)) then
				char:giveMoney(-self.seedPrice)
				client:notifyLocalized("purchaseEntity", "씨앗", nut.currency.get(self.seedPrice))
			else	
				client:notifyLocalized("seedCost", nut.currency.get(self.seedPrice))
				return
			end

			self:SetDTBool(1, true)
			return
		end

		if (self:GetDTBool(1) and self:GetDTInt(0) == self.maxGrowth) then
			local inv = char:getInv()
			local wow = inv:add("raweed")

			if (wow) then
				self:SetDTBool(1, false)
				self:SetDTInt(0, 0)

				client:notifyLocalized("moneyTaken", "생 대마")
			end

			return
		end
	end

	function ENT:Think()
		if (self:GetDTBool(1) == true and self:GetDTBool(4) == true) then
			self:SetDTInt(0, math.min(self.maxGrowth, self:GetDTInt(0) + 1)) -- growth
		end

		return 
	end

	function ENT:Toggle()
	end

	function ENT:OnRemove()
	end
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*16):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"weedPotName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)

		if (!self:GetDTBool(0)) then
			nut.util.drawText(L("weedPotSoil", nut.currency.get(self.soilPrice)), x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			return
		end

		if (self:GetDTBool(0) and !self:GetDTBool(1)) then
			nut.util.drawText(L("weedPotSeed", nut.currency.get(self.seedPrice)), x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			return
		end
	end

	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/rottweiler/drugs/cannabis.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(0, 0, 15)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["weed"] = MODEL

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

				local matrix = Matrix()
				matrix:Scale((dat.scale or Vector( 1, 1, 1 )) * (.1 + self.lerp))
				drawEntity:EnableMatrix("RenderMultiply", matrix)

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )

				if (self:GetDTBool(1) == true) then
					drawEntity:DrawModel()
				end

				if (uid == "weed") then
					if (self:GetDTInt(0, 0) == self.maxGrowth) then
						drawEntity:SetModel("models/rottweiler/drugs/cannabis_flowering.mdl")
					else
						drawEntity:SetModel("models/rottweiler/drugs/cannabis.mdl")
					end
				end
			else
				self.models[uid] = ClientsideModel(dat.model, RENDERGROUP_BOTH )
				self.models[uid]:SetColor( dat.color or color_white )
				self.models[uid]:SetNoDraw(true)

				if (dat.material) then
					self.models[uid]:SetMaterial( dat.material )
				end
			end
		end

		self:DrawModel()
	end

	function ENT:Think()
		if (self:GetDTBool(1)) then
			self.lerp = Lerp(FrameTime()*8, self.lerp, self:GetDTInt(0, 0) / self.maxGrowth)
		else
			self.lerp = 0
		end
	end
end