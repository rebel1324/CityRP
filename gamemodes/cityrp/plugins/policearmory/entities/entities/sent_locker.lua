DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Police Armory"
ENT.Author = "Black Tea"
ENT.Information = "Visual locker cabinet only"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH


if SERVER then
	AddCSLuaFile()
end

function ENT:Initialize()
	self:SetModel("models/drover/bigarmory2.mdl")
	if (SERVER) then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.nextuses={0,0,0}
end

local armory = {
	{
		name = "AR-15 제식 소총",
		weapon = "cw_ar15_si",
	},
	{
		name = "UMP-45 기관단총",
		weapon = "cw_ump45",
	},
	{
		name = "M3 산탄총",
		weapon = "cw_m3super90",
	},
	{
		name = "MR96 리볼버",
		weapon = "cw_mr96",
	},
}

ENT.isArmory = true
if (SERVER) then
	netstream.Hook("nutArmoryBuy", function(client, index, entity)
		if (IsValid(entity) and IsValid(client)) then
			if (entity.isArmory and entity.orderArmory) then
				entity:orderArmory(client, index)
			end
		end
	end)

	function ENT:orderArmory(client, index)
		local char = client:getChar()

		if (char) then
			local class = char:getClass()

			if (class) then
				local classInfo = nut.class.list[class]

				if (!classInfo.law) then
					return
				end
			end
		end
		local dist = self:GetPos():Distance(client:GetPos())
		if (dist < 512) then
			local weaponInfo = armory[index]
			if (index and weaponInfo) then
				local weapons = client:GetWeapons()

				for k, weapon in pairs(weapons) do
					if (weapon:GetClass() == weaponInfo.weapon) then
						continue
					end

					if (weapon.policeProperty) then
						weapon:Remove()
					end
				end	

				local weapon = client:Give(weaponInfo.weapon)
				timer.Simple(0.25, function()
					weapon.policeProperty = true
					client:SelectWeapon(weaponInfo.weapon)
				end)
			end
		end
	end
end
if (CLIENT) then
	local pos, ang, renderAng
	local mc = math.Clamp

	local function renderCode(self, ent, w, h)
		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawRect(0, 0, w, h)

		local scale = 1 / self.scale
		local ax, ay = scale*4, scale*8
		local tw, th = nut.util.drawText(L"armory", ax, ay, color_white, 3, 1, "nutATMTitleFont")
		ay = ay + th*.5
		local tw, th = nut.util.drawText(L"armoryDesc", ax, ay, color_white, 3, 1, "nutSmallFont")
		ay = ay + th
		local mx, my = self:mousePos()

		local entity = self.entity
		local bc, bd = scale * 53, scale * 12.5
		
		self.currentButton = nil
		for k, v in pairs(armory) do
			local bool = self:cursorInBox(ax, ay, bc, bd)

			if (bool) then
				surface.SetDrawColor(60, 70, 110)
				self.currentButton = k
			else
				surface.SetDrawColor(80, 89, 123)
			end

			surface.DrawRect(ax, ay, bc, bd)
			local tx, ty = nut.util.drawText(v.name, ax + scale * 2, ay + scale * 3.5, color_white, 3, 1, "nutBigFont" )
			local tx, ty = nut.util.drawText(L"clickToBuy", ax + scale * 2, ay + scale * 1 + ty, color_white, 3, 1, "nutSmallFont" )
			ay = ay + bd * 1.1
		end
		
		if (self.hasFocus) then
			surface.SetDrawColor(255, 255, 255)
			surface.DrawRect(mx, my, 5, 5)
		end
	end

	-- This function called when client clicked(Pressed USE, Primary/Secondary Attack).
	local function onMouseClick(self, key)
		if (self.currentButton) then
			netstream.Start("nutArmoryBuy", self.currentButton, self.entity)
		end
	end

	function ENT:Initialize()
		-- Creates new Touchable Screen Object for this Entity.
		self.screen = nut.screen.new(400, 200, .3)
		
		-- Initialize some variables for this Touchable Screen Object.
		self.screen.noClipping = false
		self.screen.fadeAlpha = 1
		self.screen.idxAlpha = {}

		-- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick
	end

	function ENT:Think()
		pos = self:GetPos()
		ang = self:GetAngles()

		-- Shift the Rendering Position.
		pos = pos + ang:Up() * 42
		pos = pos + ang:Right() * 0
		pos = pos + ang:Forward() * 9

		-- Rotate the Rendering Angle.
		renderAng = Angle(ang[1], ang[2], ang[3])
		renderAng:RotateAroundAxis(self:GetForward(), 0)
		renderAng:RotateAroundAxis(self:GetRight(), 0)
		renderAng:RotateAroundAxis(self:GetUp(), 0)

		-- Update the Rendering Position and angle of the Touchable Screen Object.
		self.screen.pos = pos
		self.screen.ang = renderAng
		self.screen.entity = self

		self.screen.w, self.screen.h, self.screen.scale = 60, 85, .2

		-- fuckoff
		self.screen.renderCode = renderCode

		-- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
		self.screen.onMouseClick = onMouseClick

		-- If The Screen has no Focus(If player is not touching it), Increase Idle Screen's Alpha.
		if (self.screen.hasFocus) then
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha - FrameTime()*4, 0, 1)
		else
			self.screen.fadeAlpha = mc(self.screen.fadeAlpha + FrameTime()*2, 0, 1)
		end
	end


	function ENT:DrawTranslucent()
		-- Render 3D2D Screen.
		local dist = LocalPlayer():GetPos():Distance(self:GetPos())

		if (dist < 512) then
			self.screen:render()

			self.screen:think()
		end
	end
end