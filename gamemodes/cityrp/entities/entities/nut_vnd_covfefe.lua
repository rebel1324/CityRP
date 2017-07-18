AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Cook Coffee Vendor"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.defaultPrice = 250

if (CLIENT) then
	local EFFECT = {}
	function EFFECT:Init( data ) 
		self.pos = data:GetStart()	
		self.adj = data:GetOrigin()
		self.nextEmit = CurTime()
		self.scale = .5
		self.emitter = ParticleEmitter(Vector(0, 0, 0))
		self.lifetime = CurTime() + 0.25

		for i = 0, 2 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.pos + VectorRand()*1)
			smoke:SetVelocity(VectorRand()*3*self.scale)
			smoke:SetDieTime(math.Rand(.5,1))
			smoke:SetStartAlpha(math.Rand(111,50))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(5,10)*self.scale)
			smoke:SetEndSize(math.random(10,15)*self.scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(200, 130, 88)
			smoke:SetGravity( Vector( 0, 0, 1 ) )
			smoke:SetAirResistance(11)
		end
	end

	function EFFECT:Render()
	end

	function EFFECT:Think()

		if (self.nextEmit < CurTime()) then
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self.pos + self.adj)
			smoke:SetDieTime(math.Rand(.1,.2))
			smoke:SetStartAlpha(math.Rand(150,255))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(3,2)*self.scale)
			smoke:SetEndSize(math.random(1,2)*self.scale)
			smoke:SetStartLength(0)
			smoke:SetEndLength(20)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(200, 130, 88)
			smoke:SetGravity( Vector( 0, 0, -600) )
			smoke:SetAirResistance(11)
			
			self.nextEmit = CurTime() + .05
		end

		if (self.lifetime > CurTime()) then
			return true
		end
	end

	effects.Register( EFFECT, "vendorCoffeeGas" )
end

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
		ent:Activate()

		return ent
	end

	function ENT:Initialize()
		self:SetModel("models/props/commercial/coffeemachine01.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:setNetVar("price", math.Round(self.defaultPrice * 1.5))
		self.health = 200

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
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
		self:GiveBuff(client)
	end

	function ENT:GiveBuff(client)
		if (!self.nextAct or self.nextAct < CurTime()) then
			self.nextAct = CurTime() + 0.5
			
			local char = client:getChar()

			if (char) then
				local price = self:getPrice()

				if (char:hasMoney(price)) then
					local owner = self:getOwner()

					if (owner and owner:IsValid()) then
						local char = owner:getChar()
						local profit = price - self.defaultPrice

						if (profit <= 0) then
							if (char:getReserve() - profit < 0) then
								owner:notifyLocalized("cantAfford")

								return
							end
						end

						char:addReserve(profit)

						local effectData = EffectData()
						effectData:SetStart(
							self:GetPos() +
							self:GetForward() * 0 +
							self:GetRight() * 6 +
							self:GetUp() * 10
						)
						effectData:SetOrigin(self:GetUp() * 5)
						util.Effect("vendorCoffeeGas", effectData, true, true)

						if (profit < 0) then
							owner:notifyLocalized("purchasedCoffeeNonProfit", nut.currency.get(profit))
						elseif (profit != 0) then
							owner:notifyLocalized("purchasedCoffeeProfit", nut.currency.get(profit))
						end
					end

					client:notifyLocalized("purchasedCoffee")
					char:giveMoney(-price)
				else 
					client:notifyLocalized("cantAfford")
				end
			end
		end

		client:addAttribBoost("covfefe", "end", 3, 180)
	end
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*16):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"covfefeVendorName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"covfefeVendorDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		nut.util.drawText(L("covfefeVendorDescPrice", nut.currency.get(self:getPrice())), x, y + 32, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	function ENT:Draw()
		self:DrawModel()
	end

end

