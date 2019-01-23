AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Food Vendor"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.vending = true
ENT.item = "burger"
ENT.model = "models/props_wasteland/kitchen_stove002a.mdl"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel(self.model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local item = nut.item.list[self.item]
		self:SetNW2Int("price", math.Round(item.price * 2))

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

	function ENT:setPrice(price)
		self:SetNW2Int("price", price)
	end

	function ENT:Use(client)
		if (client and client:IsValid()) then
			if (self and self:IsValid()) then
				local dist = client:GetPos():Distance(self:GetPos())

				if (dist < 256) then
					self:dispenseItem(client)
				end
			end
		end
	end

	function ENT:onDispenseItem(client)
		local e = EffectData()
		e:SetStart(self:GetPos() + self:OBBCenter())
		e:SetScale(0.1)
		util.Effect( "vendorGas", e )
	end

	function ENT:dispenseItem(client)
		if (!self.nextAct or self.nextAct < CurTime()) then
			self.nextAct = CurTime() + .5
			
			local char = client:getChar()
			if (char) then
				local inventory = char:getInv()

				if (inventory) then
					local price = math.Clamp(self:GetNW2Int("price", 100), NUT_MIN_PRICE, NUT_MAX_PRICE)
					
					if (char:hasMoney(price)) then
						local itemType = nut.item.list[self.item]
						
						if (itemType) then
							local entityOwner = self:getOwner()

							if (IsValid(entityOwner)) then
								local ownerChar = entityOwner:getChar()

								if (ownerChar) then
									local profit = price - itemType.price

									if (profit <= 0) then
										if (ownerChar:getReserve() - profit < 0) then
											entityOwner:notifyLocalized("cantAfford")
										end
									end

									inventory:add(self.item):next(function()
										self:onDispenseItem(client)
										ownerChar:giveMoney(profit)

										if (profit < 0) then
											entityOwner:notifyLocalized("purchasedItemNonProfit", nut.currency.get(profit))
										elseif (profit != 0) then
											entityOwner:notifyLocalized("purchasedItemProfit", nut.currency.get(profit))
										end

										client:notifyLocalized("purchasedItem")
										char:giveMoney(-price)
									end, function(error)
										client:notifyLocalized("noSpace")
									end)
								else
									client:notifyLocalized("notValid")
								end	
							else
								client:notifyLocalized("notValid")
							end
						else
							client:notifyLocalized("notValid")
						end
					else
						client:notifyLocalized("cantAfford")
					end
				end
			end
		end
	end
else
	local w, h = 920, 500

	function ENT:Initialize()
		self:declarePanels()

		self.displayFraction = 0
		self.curScale = 0
		self.curHeight = 0
		self.renderIdle = 0
		self.stareDeploy = 0
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

	hook.Add("LoadFonts", "nutNoticeFont", function(font, genericFont)
		surface.CreateFont("nutBlurText", {
			font = font,
			size = 555,
			extended = true,
			weight = 500
		})

		surface.CreateFont("nutBlurIcon", {
			font = "nsicons",
			size = 555,
			extended = true,
			weight = 500
		})

		surface.CreateFont("nutBlurSubText", {
			font = font,
			size = 70,
			extended = true,
			weight = 500
		})
	end)


	function ENT:Draw()
		local spd = FrameTime() * 0.5
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
			local text = L("purchaseItem", name)

			if (isOverlay) then
				-- stencil overlay (something you want to draw)
				local tx, ty = nut.util.drawText(text, 0, h*-.1, color_white, 1, 4, "nutBlurText", 100)
				nut.util.drawText(nut.currency.get(self:GetNW2Int("price")), 0, h*.01, color_white, 1, 4, "nutBlurSubText", 100)
				nut.util.drawText("", 0, h*.05, color_white, 1, 5, "nutBlurIcon", 100)
			else
				surface.SetFont("nutBlurText")
				local sizex = surface.GetTextSize(text)
				-- stencil background (blur area)
				local w = sizex + 200
				local x, y = -w/2, -h/2
				surface.SetDrawColor(0, 91, 0, 55)
				surface.DrawRect(x, y, w, h)
			end
		end)
	end

	function ENT:adjustPosition()
		-- make a copy of the angle.
		local rotAng = self.ang*1

		-- Shift the Rendering Position.
		self.pos = self.pos + rotAng:Up() * 61
		self.pos = self.pos + rotAng:Right() * 0
		self.pos = self.pos + rotAng:Forward() * 22

		-- Rotate the Rendering Angle.
		self.ang = rotAng
		self.ang:RotateAroundAxis(self:GetUp(), 90)
		self.ang:RotateAroundAxis(self:GetRight(), -80)
	end
end


if (CLIENT) then
	local EFFECT = {}
	function EFFECT:Init( data ) 
		self:SetNoDraw(true)
		local pos = data:GetStart()	
		local scale = 3
		self.emitter = ParticleEmitter(Vector(0, 0, 0))

		for i = 0, 5 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
			smoke:SetVelocity(VectorRand()*22*scale)
			smoke:SetDieTime(math.Rand(.5,1))
			smoke:SetStartAlpha(math.Rand(222,255))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(5,10)*scale)
			smoke:SetEndSize(math.random(10,15)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(88, 88, 88)
			smoke:SetGravity( Vector( 0, 0, 50 ) )
			smoke:SetAirResistance(11)
		end
	end

	effects.Register( EFFECT, "vendorGas" )
end

function ENT:getOwner()
	return self:CPPIGetOwner()
end