AddCSLuaFile()

if( CLIENT ) then
	SWEP.PrintName = "Illegal Entity Detector";
	SWEP.Slot = 1;
	SWEP.SlotPos = 0;
end

SWEP.HoldType = "camera"

SWEP.Category = "Co-op"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.UseHands = true

SWEP.ViewModel = Model("models/weapons/c_arms_animations.mdl")
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.ViewModelFOV	= 55
SWEP.Primary.Delay			= 1
SWEP.Primary.Recoil			= 0	
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone			= 0 	
SWEP.Primary.ClipSize		= -1	
SWEP.Primary.DefaultClip	= -1	
SWEP.Primary.Automatic   	= false	
SWEP.Primary.Ammo         	= "none"
 
SWEP.Secondary.Delay		= 0.9
SWEP.Secondary.Recoil		= 0
SWEP.Secondary.Damage		= 0
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic   	= true
SWEP.Secondary.Ammo         = "none"

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:Think()
end

function SWEP:Deploy()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if (CLIENT) then
	local dotSize = 6
	local circleSize = 128
	local scanDist = 512
	local radarMat = Material("particle/Particle_Ring_Wave_Additive")
	local savedDots = {}
	local drawDots = {}
	local lifeTime = 1
	local sw, sh = 150, 140

	SWEP.vmData = {}
	local MODEL = {}
	MODEL.model = "models/props_lab/monitor01b.mdl"
	MODEL.angle = Angle(0, -30, 180)
	MODEL.position = Vector(30, 0, -10)
	MODEL.scale = Vector(1, 1, 1)
	SWEP.vmData["screen"] = MODEL

	SWEP.wmData = {}
	local MODEL = {}
	MODEL.model = "models/props_lab/monitor01b.mdl"
	MODEL.angle = Angle(10, 180, 0)
	MODEL.position = Vector(3, 5, -2)
	MODEL.scale = Vector(1, 1, 1) * .7
	SWEP.wmData["screen"] = MODEL

	WORLDEMITTER = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))

	function SWEP:Initialize()
		self:SetHoldType(self.HoldType)
		self.models = {}
	end

	function SWEP:Think()
		local client = LocalPlayer()

		local lv = 35
		if (client:ShouldDrawLocalPlayer() or client != self.Owner) then
			lv = 320
		end
			if (!self.nextBeep or self.nextBeep < CurTime()) then
				self.Owner:EmitSound("common/warning.wav", lv, 200)

				self.nextBeep = CurTime() + 1
			end
	end

	function SWEP:DrawWorldModel()
		local client = self.Owner
		local viewmodel = self.Owner:GetViewModel()
		for uid, dat in pairs(self.wmData) do
			local drawEntity = self.models[uid]
			
			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = client:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand") or 1)
				
				if (dat.bone) then
					pos, ang = client:GetBonePosition(dat.bone or 0)
				end
				
				if (!pos or !ang) then continue end
					
				local ang2 = ang

				pos = pos + ang:Forward() * dat.position[1]
				pos = pos + ang:Right() * dat.position[2]
				pos = pos + ang:Up() * dat.position[3]

				ang:RotateAroundAxis(ang:Forward(), dat.angle[1])
				ang:RotateAroundAxis(ang:Right(), dat.angle[2])
				ang:RotateAroundAxis(ang:Up(), dat.angle[3])

				local matrix = Matrix()
				matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
				drawEntity:EnableMatrix("RenderMultiply", matrix)

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )

				drawEntity:DrawModel()
			else
				self.models[uid] = ClientsideModel(dat.model, RENDERGROUP_BOTH )
				self.models[uid]:SetColor( dat.color or color_white )
				self.models[uid]:SetNoDraw(true)

				if (dat.material) then
					self.models[uid]:SetMaterial( dat.material )
				end
			end
		end
	end

	local hacks = Material("vgui/gradient-u")
	function SWEP:ViewModelDrawn()
		if (!self.Owner) then return end

		local client = self.Owner
		local viewmodel = self.Owner:GetViewModel()
		for uid, dat in pairs(self.vmData) do
			local drawEntity = self.models[uid]
			
			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = viewmodel:GetPos(), client:GetAimVector():Angle()

				if (dat.bone) then
					pos, ang = viewmodel:GetBonePosition(dat.bone or 0)
				end

				local ang2 = ang

				pos = pos + ang:Forward() * dat.position[1]
				pos = pos + ang:Right() * dat.position[2]
				pos = pos + ang:Up() * dat.position[3]

				ang:RotateAroundAxis(ang:Forward(), dat.angle[1])
				ang:RotateAroundAxis(ang:Right(), dat.angle[2])
				ang:RotateAroundAxis(ang:Up(), dat.angle[3])

				local matrix = Matrix()
				matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
				drawEntity:EnableMatrix("RenderMultiply", matrix)

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )

				drawEntity:DrawModel()
			else
				self.models[uid] = ClientsideModel(dat.model, RENDERGROUP_BOTH )
				self.models[uid]:SetColor( dat.color or color_white )
				self.models[uid]:SetNoDraw(true)

				if (dat.material) then
					self.models[uid]:SetMaterial( dat.material )
				end
			end
		end

		local drawEnts = {}
		for k, v in ipairs(ents.GetAll()) do
			local dist = v:GetPos():Distance(LocalPlayer():GetPos())

			if (dist < scanDist and ILLEGAL_ENTITY and ILLEGAL_ENTITY[v:GetClass()]) then
				table.insert(drawEnts, {v, dist})
			end
		end

		local screenEnt = self.models["screen"]
		if (screenEnt and IsValid(screenEnt)) then
			local pos, ang = screenEnt:GetRenderOrigin(), screenEnt:GetRenderAngles()
			if !(pos and ang) then return end
			
			pos = pos + ang:Forward() * 7.3
			pos = pos + ang:Right() * 1
			pos = pos + ang:Up() * 0.8
			ang:RotateAroundAxis(ang:Right(), -90)
			ang:RotateAroundAxis(ang:Up(), -90)

			cam.Start3D2D(pos, ang, 0.06)
				surface.SetDrawColor(0, 0, 0, 250)
				surface.DrawRect(-sw/2, -sh/2, sw, sh)

				surface.SetMaterial(hacks)
				surface.SetDrawColor(111, 111, 111, 111)
				surface.DrawTexturedRect(-sw/2, -sh/2, sw, sh)

				surface.SetMaterial(radarMat)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(-circleSize/2 * 1.1, -circleSize/2 * 1.1, circleSize * 1.1, circleSize * 1.1)

				surface.DrawLine(-circleSize/2, 0, circleSize/2, 0)
				surface.DrawLine(0, -circleSize/2, 0, circleSize/2)

				local progress = math.Clamp(RealTime() % 2 - 1, 0, 1)
				local newSize = circleSize * progress * 1.1
				surface.SetMaterial(radarMat)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(-newSize/2, -newSize/2, newSize, newSize)

				local aimDir = LocalPlayer():GetAimVector()
				for _, e in ipairs(drawEnts) do
					local dir = (e[1]:GetPos() - LocalPlayer():GetPos()):Angle()
					local rad = math.AngleDifference(dir.y, aimDir:Angle().y)/180 * math.pi
					local distVal = e[2]/scanDist
					local x, y = math.sin(rad) * circleSize/2 * distVal, math.cos(rad) * circleSize/2 * distVal

					if (distVal <= progress and !savedDots[e[1]]) then
						savedDots[e[1]] = true -- saved
						table.insert(drawDots, {x, y, CurTime() + lifeTime})
						LocalPlayer():EmitSound("HL1/fvox/bell.wav", 40, 150)
					end
				end

				if (progress == 0) then
					savedDots = {}
				end

				for k, v in pairs(drawDots) do
					local x, y, t = v[1], v[2], v[3]

					if (t < CurTime()) then
						drawDots[k]= nil

						continue
					end

					local alpha = math.max(t - CurTime() / lifeTime, 0)
					surface.SetDrawColor(255, 0, 0, 255 * alpha)
					surface.DrawRect(x, y, dotSize, dotSize)
				end
			cam.End3D2D()
		end
	end
end
