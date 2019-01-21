AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Evidence"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	CITYRP_JUNKS = CITYRP_JUNKS or {}
	function ENT:Initialize()
		self:SetModel("models/props_junk/metal_paintcan001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		timer.Simple(20, function()
			if (self and self:IsValid()) then
				self:Remove()
			end
		end)

		local timerName = self:EntIndex() .. "_EVIDENCE"

		for k, v in ipairs(player.GetAll()) do
			local char = v:getChar()

			if (char) then
				local class = char:getClass()

				if (class != CLASS_DETECTIVE) then
					self:SetPreventTransmit(v, true)
				end
			end
		end

		timer.Create(timerName, 2, 0, function()
			if (!IsValid(self)) then
				timer.Remove(timerName)
			end

			for k, v in ipairs(player.GetAll()) do
				local char = v:getChar()

				if (char) then
					local class = char:getClass()

					if (class != CLASS_DETECTIVE) then
						self:SetPreventTransmit(v, true)
					else
						self:SetPreventTransmit(v, false)
					end
				end
			end
		end)

		self:CallOnRemove("removeTimer", function()
			timer.Remove(timerName) 
		end)

		self.deathTime = os.date()
	end

	function ENT:Use(client)
		if (IsValid(client) and self:isVisible(client)) then
			local char = client:getChar()

			if (char) then
				local inv = char:getInv()

				if (inv) then
					-- singular item. so i don't give a shit.
					inv:add("evidence"):next(function(item)
						local victim, attacker, inflictor, deathTime = self.victim, self.attacker, self.inflictor, self.deathTime

						if (IsValid(victim)) then
							if (victim:IsPlayer()) then
								item:setData("victim", victim:Name())
							else
								item:setData("victim", victim:GetClass())
								item:setData("shitDeath", true)
							end
						end

						if (IsValid(attacker)) then
							if (attacker:IsPlayer()) then
								item:setData("attacker", attacker:Name())
							else
								item:setData("attacker", attacker:GetClass())
								item:setData("shitDeath", true)
							end
						else
							item:setData("attacker", "미상의 공격자")
							item:setData("shitDeath", true)
						end

						item:setData("inflictor", inflictor and inflictor:GetClass() or "무기 없음")
						item:setData("deathTime", deathTime or "미상 시간")

						self:Remove()
					end, function(error)
						client:notifyLocalized(error)
					end)
				end
			end
		end
	end

	function ENT:OnTakeDamage(dmginfo)
	end

	function ENT:OnRemove()
	end
else
	function ENT:Draw()
	end

	function ENT:DrawTranslucent()

		if (IsValid(self.emitter) and self.nextEmit < CurTime()) then
			local pos = self:GetPos()
			local smoke = self.emitter:Add("effects/yellowflare", pos)
			smoke:SetVelocity(Vector(0, 0, 0))
			smoke:SetDieTime(.3)
			smoke:SetStartAlpha(100)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(22)
			smoke:SetEndSize(22)
			smoke:SetGravity(Vector(0, 0, 0))

			local smoke = self.emitter:Add("effects/yellowflare", pos + VectorRand()*5)
			smoke:SetVelocity(Vector(0, 0, math.random(5, 10)) + VectorRand())
			smoke:SetDieTime(math.Rand(.5,1))
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(5,11))
			smoke:SetEndSize(0)
			smoke:SetGravity(Vector(0, 0, 60))

			self.nextEmit = CurTime() + .1
		end
	end

	function ENT:Initialize()
		self.emitter = ParticleEmitter(self:GetPos())
		self.nextEmit = CurTime()
	end

	function ENT:OnRemove()
		if (IsValid(self.emitter)) then
			self.emitter:Finish()
		end
	end

	function ENT:onShouldDrawEntityInfo()
		return self:isVisible()
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*2):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"evidence", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"evidenceDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end

function ENT:isVisible(client)
	if (CLIENT) then
		client = LocalPlayer()
	end

	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		return (class == CLASS_DETECTIVE)
	end

	return 
end
