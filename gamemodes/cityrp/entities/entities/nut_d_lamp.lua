AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Weed Lamp"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Crime"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.batteryCost = 100
ENT.batteryDuration = 100

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
		self:SetModel("models/gonzo/weedb/lamp2.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self.loopsound = CreateSound(self, "ambient/atmosphere/engine_room.wav")

		self:SetDTBool(0, false) -- soil
		self:SetDTBool(1, false) -- weed
		self:SetDTInt(0, 0) -- growth

		self.health = 100

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:Wake()
		end
	end

	function ENT:Use(client)
		if (!self:GetDTBool(0)) then
			local char = client:getChar()

			if (char:hasMoney(self.batteryCost)) then
				client:notifyLocalized("purchaseEntity", "Battery", nut.currency.get(self.batteryCost))
				char:giveMoney(-self.batteryCost)
			else	
				client:notifyLocalized("batteryCost", nut.currency.get(self.batteryCost))
				return
			end
			-- pay
			self:SetBodygroup(1, 1)
			self:SetDTBool(0, true)
			self.loopsound:Play()
			self:EmitSound("items/suitchargeok1.wav")

			timer.Simple(self.batteryDuration, function()
				if (self and self:IsValid()) then
					self:SetBodygroup(1, 0)
					self:SetDTBool(0, false)
					self.loopsound:Stop()
					self:EmitSound("items/suitchargeno1.wav")
				end
			end)

			return
		end
	end

	function ENT:Think()
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
	end

	timer.Create("nutWeedChecker", 1, 0, function()
		local wow = {}
		for _, pots in ipairs(ents.FindByClass("nut_d_pot")) do
			for _, lamps in ipairs(ents.FindByClass("nut_d_lamp")) do
				if (lamps:GetDTBool(0)) then
					local dist = pots:GetPos():Distance(lamps:GetPos())

					if (dist < 256) then
						table.insert(wow, pots)
					end
				end
			end

			pots:SetDTBool(4, false)
		end

		for _, neats in ipairs(wow) do
			neats:SetDTBool(4, true)
		end
	end)
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) ):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"weedLampName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"weedLampDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			
		if (!self:GetDTBool(0)) then
			nut.util.drawText(L("weedLampRefill", nut.currency.get(self.batteryCost)), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			return
		end
	end

	ENT.modelData = {}
	local MODEL = {}
	MODEL.model = "models/gonzo/weedb/battery.mdl"
	MODEL.angle = Angle(0, -90, 0)
	MODEL.position = Vector(-14.7, 8, 27)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["battery"] = MODEL

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

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")

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
				matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
				drawEntity:EnableMatrix("RenderMultiply", matrix)

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )

				if (self:GetDTBool(0) == true) then
					drawEntity:DrawModel()

					pos = pos + self:GetForward() * 10
					pos = pos + self:GetRight() * 5
					pos = pos + self:GetUp() * 80

					render.SetMaterial(GLOW_MATERIAL)
					render.DrawSprite(pos, 128, 128, Color( 44, 255, 44, 255 ) )
				end
			end
		end

		self:DrawModel()
	end
end