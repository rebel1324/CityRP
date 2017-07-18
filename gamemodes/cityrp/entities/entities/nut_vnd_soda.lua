AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Drink Vendor"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.vending = true
ENT.item = "sodacan"

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/rebel1324/sodavendor.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		local item = nut.item.list[self.item]
		self:setNetVar("price", math.Round(item.price * 2))

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

	function ENT:GiveFood(client)
		if (!self.nextAct or self.nextAct < CurTime()) then
			self.nextAct = CurTime() + .5
			
			local char = client:getChar()

			if (char) then
				local price = self:getNetVar("price", 100)

				if (char:hasMoney(price)) then
					local item = nut.item.list[self.item]

					if (!item) then
						client:notifyLocalized("notValid")
					end

					local owner = self:getOwner()
					local e = EffectData()
					e:SetStart(self:GetPos() + self:OBBCenter())
					e:SetScale(0.1)
					util.Effect( "vendorGas", e )
					
					local char = owner:getChar()
					local profit = price - item.price

					if (profit <= 0) then
						if (char:getReserve() - profit < 0) then
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

	netstream.Hook("nutFoodVendor", function(client, target)
		if (client and client:IsValid()) then
			if (target and target:IsValid()) then
				local dist = client:GetPos():Distance(target:GetPos())

				if (dist < 256) then
					target:GiveFood(client)
				end
			end
		end
	end)
else
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*8):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"drinkVendorName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"drinkVendorDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	-- This fuction is 3D2D Rendering Code.
	local gradient = nut.util.getMaterial("vgui/gradient-d")
	local gradient2 = nut.util.getMaterial("vgui/gradient-u")

	local function renderCode(self, ent, w, h)
		local char = LocalPlayer():getChar()

		if (char) then
			local mx, my = self:mousePos()
			local scale = 1 / self.scale

			self.curSel = -1
			surface.SetFont("nutATMFont")

			local bp, bp2 = 0, 0
			local sp, sp2 = 8 * scale, 4 * scale
			local bool = self:cursorInBox(bp, bp2, sp, sp2)
			self.goodtogo = bool

			surface.SetDrawColor(46, 204, 113)
			surface.DrawRect(bp, bp2, sp, sp2)
			surface.SetDrawColor(0, 0, 0, 155)
			surface.SetMaterial((self.IN_USE and bool) and gradient2 or gradient)
			surface.DrawTexturedRect(bp, bp2, sp, sp2)
			surface.SetDrawColor(39, 174, 113)
			surface.DrawOutlinedRect(bp+2.5, bp2+2.5, sp-5, sp2-5)

			nut.util.drawText("음료 구매", bp + sp/2, bp2 + sp2/2 - 10, color_white, 1, 1, "nutATMFont")
			nut.util.drawText(nut.currency.get(self.ent:getNetVar("price", 100)), bp + sp/2, bp2 + sp2/2 + 15, color_white, 1, 1, "nutChatFont")

			if (self.ent:getOwner()) then
				local name = self.ent:getOwner():Name()
				nut.util.drawText(Format("소유자: %s", name), w/2, bp2 + sp2 + scale*1, color_white, 1, 1, "nutChatFont")
			end
		end
	end

	-- This function called when client clicked(Pressed USE, Primary/Secondary Attack).
	local function onMouseClick(self, key)
		if (self.goodtogo) then
			netstream.Start("nutFoodVendor", self.ent)
			self.ent:EmitSound("buttons/button14.wav", 70, 150)
		end
	end

	function ENT:Initialize()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(8, 6, .04)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.noClipping = false
		self.screen.fadeAlpha = 1
		self.screen.idxAlpha = {}

		-- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick
	end
	
	function ENT:Draw()
		-- Draw Model.
		self:DrawModel()
	end

	local pos, ang, renderAng
	local mc = math.Clamp
	function ENT:DrawTranslucent()
		-- Render 3D2D Screen.
		self.screen:render()
	end

	function ENT:EmitGas()
		local e = EffectData()
		e:SetStart(self:GetPos() + self:OBBCenter())
		e:SetScale(0.1)
		util.Effect( "vendorGas", e )
	end

	function ENT:Think()
		pos = self:GetPos()
		ang = self:GetAngles()

		-- Shift the Rendering Position.
		pos = pos + ang:Up() * 18
		pos = pos + ang:Right() * 0
		pos = pos + ang:Forward() * 15.4

		-- Rotate the Rendering Angle.
		renderAng = Angle(ang[1], ang[2], ang[3])

		-- Update the Rendering Position and angle of the Touchable Screen Object.
		self.screen.pos = pos
		self.screen.ang = renderAng
		self.screen.ent = self

		-- Default Think must be in this place to make Touchable Screen's Input works.
		self.screen:think()

		-- If The Screen has no Focus(If player is not touching it), Increase Idle Screen's Alpha.
		if (self.screen.hasFocus) then
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha - FrameTime()*4, 0, 1)
		else
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha + FrameTime()*2, 0, 1)
		end
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