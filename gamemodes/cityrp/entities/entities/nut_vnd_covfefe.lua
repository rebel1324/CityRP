AddCSLuaFile()

ENT.Base = "nut_vnd_food"
ENT.PrintName = "Cook Coffee Vendor"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.defaultPrice = 250
ENT.model = "models/props/commercial/coffeemachine01.mdl"

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

if (SERVER) then
else
	local w, h = 920, 500

	-- customizable functions
	function ENT:drawThink()
		-- Draw Model.
		local blurRender = nut.blur3d2d.get(self:EntIndex())
		if (blurRender) then
			blurRender.pos = self.pos
			blurRender.ang = self.ang
			blurRender.scale = (self.curScale) * .025
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
				nut.util.drawText("", 0, h*.05, color_white, 1, 5, "nutBlurIcon", 100)
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
		self.pos = self.pos + rotAng:Up() * 20
		self.pos = self.pos + rotAng:Right() * 16
		self.pos = self.pos + rotAng:Forward() * 00

		-- Rotate the Rendering Angle.
		self.ang = rotAng
		self.ang:RotateAroundAxis(self:GetUp(), 0)
		self.ang:RotateAroundAxis(self:GetForward(), 70)
		self.ang:RotateAroundAxis(self:GetRight(), 0)
	end
end

