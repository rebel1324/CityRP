ENT.Type = "anim"
ENT.PrintName = "Machine Base"
ENT.Author = "Black Tea"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "NutScript - Machines"
ENT.RenderGroup 		= RENDERGROUP_BOTH

ENT.MaxEnergy = 100
ENT.Supply = "ms_example"
ENT.EntThinkTime = 2
ENT.NextItemGenerate = 10

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_lab/reciever_cart.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetDTInt(0, self.MaxEnergy)
		self:SetDTBool(0, false)
		self.timeGen = CurTime() + self.NextItemGenerate
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
		self:EmitSound("plats/elevator_stop.wav")
		self.loopsound:Stop()
	end

	function ENT:TurnOn()
		self.loopsound = CreateSound( self, "ambient/machines/machine3.wav" ) -- weird issue.
		self.loopsound:Play()
		self:SetDTBool(0, true)
	end

	function ENT:GetSupply()
		return self:GetDTInt(0)
	end

	function ENT:CanSupply(amt)
		return !(self:GetSupply()+amt > self.MaxEnergy)
	end
	
	
	function ENT:AddSupply(amt, supply)
		if supply then
			self:EmitSound("items/ammo_pickup.wav", 70, 80)
		end
		self:SetDTInt(0, math.Clamp(self:GetDTInt(0) + amt, 0, self.MaxEnergy))
	end

	function ENT:PhysicsCollide(ent)
		if ent.HitEntity:GetClass() == "nut_item" and self:CanSupply(20) then
			local itemTable = ent.HitEntity:GetItemTable()
			if itemTable.uniqueID == self.Supply then
				ent.HitEntity:Remove()
				self:AddSupply(20, true)
			end
		end
	end

	function ENT:GenerateItem()
		self:EmitSound("plats/elevator_stop.wav", 60, 140)
		local pos, ang = self:GetPos(), self:GetAngles()
		pos = pos + self:GetForward()*4
		pos = pos + self:GetUp()*-12
		pos = pos + self:GetRight()*-5
		self:AddSupply(1)
		--local item = nut.item.Spawn(pos, Angle(0,0,0), "ammo_ar2", {})
		local item = nut.currency.Spawn(1000, pos, Angle(0,0,0))
		local phys = item:GetPhysicsObject()
		phys:SetVelocity(self:GetForward()*phys:GetMass()*1000)

	end

	function ENT:Think()
		if self:GetDTBool(0) then
			self:AddSupply(-1)
			if self.timeGen < CurTime() and self:GetDTBool(0) then
				self:GenerateItem()
				self.timeGen = CurTime() + self.NextItemGenerate
			end
		end
		if (self:GetDTInt(0) == 0 and self:GetDTBool(0)) then
			self:TurnOff()
		end
		self:NextThink(CurTime() + self.EntThinkTime)
		return true
	end

	function ENT:CanTurnOn(client)
		return !(self:GetDTInt(0) <= 0) and !(self:GetDTBool(0)) 
	end

	function ENT:CanTurnOff(client)
		return (self:GetDTBool(0)) 
	end

	function ENT:Use(client)
		if self:CanTurnOff(client) then
			self:TurnOff()
			return
		end
		if self:CanTurnOn(client) then
			self.timeGen = CurTime() + self.NextItemGenerate
			self:TurnOn()
			return
		else
			self:EmitSound("hl1/fvox/buzwarn.wav", 60, 150)
			return
		end
	end
else

	function ENT:Initialize()
		self.switch_base = ClientsideModel("models/props_lab/powerbox02b.mdl")
		self.switch_lever = ClientsideModel("models/props_c17/TrapPropeller_Lever.mdl")
		self.switch_lever_z = 0
		self.switch_lever_to = 0
	end

	function ENT:OnRemove()
		self.switch_base:Remove()
		self.switch_lever:Remove()
	end

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:Draw()
		self:DrawModel()

		if self:GetDTBool(0) then
			self.switch_lever_z = 9
		else
			self.switch_lever_z = 0
		end
		self.switch_lever_to = Lerp( FrameTime()*5, self.switch_lever_to, self.switch_lever_z )

		local pos, ang = self:GetPos(), self:GetAngles()
		local drawingmodel = self.switch_base
		if drawingmodel:IsValid() then
			pos = pos + ang:Forward()*2.899 + ang:Up()*14.096 + ang:Right()*10.666
			local ang2 = ang
			ang2:RotateAroundAxis( ang:Right(), 0)
			ang2:RotateAroundAxis( ang:Up(),  -90 )-- yaw
			ang2:RotateAroundAxis( ang:Forward(), 0)-- roll
			drawingmodel:SetRenderOrigin( pos )
			drawingmodel:SetRenderAngles( ang )
			drawingmodel:DrawModel()
		end
		local drawingmodel = self.switch_lever
		if drawingmodel:IsValid() then
			pos = pos + ang:Forward()*2 + ang:Up()*(8-self.switch_lever_to) + ang:Right()*-5
			local ang2 = ang
			ang2:RotateAroundAxis( ang:Right(), 0)
			ang2:RotateAroundAxis( ang:Up(),  0 )-- yaw
			ang2:RotateAroundAxis( ang:Forward(), 0)-- roll
			drawingmodel:SetRenderOrigin( pos )
			drawingmodel:SetRenderAngles( ang )
			drawingmodel:DrawModel()
		end
	end

	local gradient = surface.GetTextureID("gui/gradient")
	function ENT:DrawBar( x, y, sx, sy, perc, lines, distalpha )
		lines = (lines) or 10

		surface.SetDrawColor(0, 200, 20, distalpha)
		surface.DrawRect(x, y, sx, sy)
		surface.SetDrawColor(200, 20, 20, distalpha)
		surface.SetTexture(gradient)
		surface.DrawTexturedRect(x, y, sx, sy)

		local prog = (perc / self.MaxEnergy)
		surface.SetDrawColor(16, 16, 16, distalpha)
		surface.DrawRect(sx+x, y, -sx*(1-prog), sy)

		surface.SetDrawColor(255, 255, 255, distalpha)
		surface.DrawOutlinedRect(x, y, sx, sy)
		local middle = math.floor(lines/2)
		for i=1, lines-1 do
			if i == middle then
				surface.DrawLine( x + sx/lines*i, y, x + sx/lines*i, y+20 )
			else
				surface.DrawLine( x + sx/lines*i, y, x + sx/lines*i, y+10 )
			end
		end
	end

	local sx, sy = 292, 93
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	local ms = math.sin
	local mc = math.cos
	local distance = 1000
	function ENT:DrawTranslucent()
		local rt = RealTime()
		local pos, ang = self:GetPos(), self:GetAngles()
		local dist = LocalPlayer():GetPos():Distance(pos)
		local distalpha = math.Clamp(distance-dist, 0, 255)
			if dist <= distance then
			pos = pos + self:GetForward() * 13
			pos = pos + self:GetUp()*27.9
			pos = pos + self:GetRight()*7.4
			ang:RotateAroundAxis( self:GetRight(), -90 )
			ang:RotateAroundAxis( self:GetForward(), 90 )

			cam.Start3D2D(pos, ang, .08)
				self:DrawBar( 5, 30, sx-10, sy-35, self:GetDTInt(0), 10, distalpha)

				nut.util.DrawText(sx/2, 15, "Resource", Color(255, 255, 255, distalpha), "nut_TargetFont", TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()

			pos = pos + self:GetForward() * 1.5
			pos = pos + self:GetUp()*-15
			pos = pos + self:GetRight()*-17
			if self:GetDTBool(0) then
				local alpha = math.Clamp(math.abs( ms(6*rt)+ms(14*rt)+mc(22*rt) )*500, 0, 255 )
				render.SetMaterial(GLOW_MATERIAL)
				render.DrawSprite(pos, 12, 12, Color( 44, 255, 44, alpha ) )
			else
				local alpha = math.Clamp(math.abs( ms(2*rt) )*255, 0, 255 )
				render.SetMaterial(GLOW_MATERIAL)
				render.DrawSprite(pos, 12, 12, Color( 255, 44, 44, alpha ) )
			end
		end
	end

end