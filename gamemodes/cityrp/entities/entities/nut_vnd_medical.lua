AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Medical Supply Vendor"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.AutomaticFrameAdvance = true
ENT.item = "aidkit"

function ENT:getOwner()
	return self:CPPIGetOwner()
end

function ENT:getPrice()
	return self:getNetVar("price", 0)
end

if (SERVER) then
	function ENT:SpawnFunction(client, trace, className)
		if (!trace.Hit or trace.HitSky) then return end

		local pos = trace.HitPos + trace.HitNormal * -1

		local ent = ents.Create(className)
		ent:SetPos(pos)
		ent:Spawn()
		ent:SetAngles(trace.HitNormal:Angle())
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/rebel1324/medicvendor.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local item = nut.item.list[self.item]
		self:setNetVar("price", math.Round(item.price * 2))

		self.health = 200

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Sleep()
		end

		if (IS_INTERNATIONAL) then
			self:SetSkin(1)
		end
	end

	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0) then
			self.onbreak = true
			self:Remove()
		end
	end

	function ENT:OnRemove()
		if (self.onbreak) then
			local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
			util.Effect("Explosion", effectData, true, true)
			
			util.BlastDamage(self, self, self:GetPos() + Vector( 0, 0, 1 ), 256, 120 )
		end
	end

	function ENT:setHealth(amount)
		self.health = amount
	end
	
	function ENT:setInterval(amount)
		self.interval = amount
	end

	function ENT:setPrice(price)
		self:setNetVar("price", price)
	end

	function ENT:Use(client)
		self:GiveFood(client)
	end

	function ENT:GiveFood(client)
		if (!self.nextAct or self.nextAct < CurTime()) then
			self.nextAct = CurTime() + 2.1
			
			local char = client:getChar()

			if (char) then
				local price = self:getNetVar("price", 100)

				if (char:hasMoney(price)) then
					local item = nut.item.list[self.item]

					if (!item) then
						client:notifyLocalized("notValid")
					end

					local owner = self:getOwner()
					/*
					local e = EffectData()
					e:SetStart(self:GetPos() + self:OBBCenter())
					e:SetScale(0.1)
					util.Effect( "vendorGas", e )
					*/

					local ownerChar = owner:getChar()
					local profit = price - item.price

					if (profit <= 0) then
						if (ownerChar:getReserve() - profit < 0) then
							owner:notifyLocalized("cantAfford")

							return
						end
					end

					if (char:getInv():add(self.item)) then
						if (owner and owner:IsValid()) then
							char:addReserve(profit)

							local seq = self:LookupSequence("open")
							self:ResetSequence(seq)

							timer.Simple(2, function()
								if (self and IsValid(self)) then
									local seq = self:LookupSequence("closed")
									self:ResetSequence(seq)
								end
							end)

							if (profit < 0) then
								owner:notifyLocalized("purchasedFoodNonProfit", nut.currency.get(profit))
							elseif (profit != 0) then
								owner:notifyLocalized("purchasedFoodProfit", nut.currency.get(profit))
							end
						end

						client:notifyLocalized("purchasedFood")
						char:giveMoney(-price)
					else
						client:notifyLocalized("noSpace")
					end
				else 
					client:notifyLocalized("cantAfford")
				end
			end
		end
	end
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter())):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"medicalVendorName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"medicalVendorDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		nut.util.drawText(L("medicalVendorDescPrice", nut.currency.get(self:getPrice())), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end