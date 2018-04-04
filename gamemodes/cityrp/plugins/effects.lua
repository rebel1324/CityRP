PLUGIN.name = "First Person Effects"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds more effects on First Person Perspective."

NUT_CVAR_EFFECTS = CreateClientConVar("nut_fpeffects", 0, true, true)

local langkey = "english"
do
	local langTable = {
		toggleEffects = "Toggle First Person Effects",
	}

	table.Merge(nut.lang.stored[langkey], langTable)
end

local playerMeta = FindMetaTable("Player")
function playerMeta:CanAddEffects()
	local entity = Entity(self:getLocalVar("ragdoll", 0))
	local ragdoll = self:GetRagdollEntity()
	if ((nut.gui.char and !nut.gui.char:IsVisible()) and
		(NUT_CVAR_EFFECTS and NUT_CVAR_EFFECTS:GetBool()) and
		!self:ShouldDrawLocalPlayer() and
		IsValid(self) and
		self:getChar() and
		!self:getNetVar("actAng") and
		!IsValid(entity) and
		self:Alive()
		) then
		return true
	end
end

if (SERVER) then
	function PLUGIN:EntityTakeDamage(target, dmgInfo)
		if (target:IsPlayer()) then
			local char = target:getChar()
	
			if (char) then
				netstream.Start(target, "injectImmersive™Screen")
				target:ViewPunch(AngleRand() * 0.1) -- actual distraction on aim
			end
		end
	end
else
	local ft
	local waterMaterial, waterFraction = "effects/water_warp01", 0
	local healthFactor, ppTab
	local clmp = math.Clamp
	local client
	
	local vel
	local sin = math.sin
	local cos = math.cos
	local curStep, rest, bobFactor = 0, 0, 0
	local newAng = Angle()
	local view = {}
	
	local painAlpha = 0
	local painAlphaRate = 0
	local suddenDistraction = 0
	local blurDistraction = 0
	local critialHealth = 20
	local healthFactor = 0
	
	local w, h = ScrW(), ScrH()
	local function fillScreen(color, alpha)
		surface.SetDrawColor(ColorAlpha(color, alpha))
		surface.DrawRect(0, 0, w, h)
	end

	netstream.Hook("injectImmersive™Screen", function()
		painAlpha = math.Rand(55, 155)
		painAlphaRate = math.Rand(3, 5)
		suddenDistraction = 1
		blurDistraction = 1

		client = LocalPlayer()

		if (IsValid(client)) then
			local weapon = client:GetActiveWeapon()

			if (IsValid(weapon) and weapon.BlendAng) then
				local pow = VectorRand()*1.5
				pow.x = pow.x * 3
				pow.z = pow.z * 0.2
				weapon.BlendAng = Vector(math.Rand(-1, 1) * 10, math.Rand(-1, 1) * 35, 0)
				weapon.BlendPos = pow
			end
		end
	end)

	function PLUGIN:HUDPaint()
		client = LocalPlayer()
		ft = FrameTime()
	
		if (client:CanAddEffects()) then
			healthFactor = (1 - math.Clamp(client:Health()/critialHealth, 0, 1))
	
			if (client:WaterLevel() <= 2) then
				waterFraction = clmp(waterFraction - ft*.2, 0, .2)
			else
				waterFraction = clmp(waterFraction + ft, 0, .2)
			end
	
			if (waterFraction > 0) then
				DrawMaterialOverlay(waterMaterial, waterFraction)
			end
	
			if (painAlpha > 0) then
				painAlpha = Lerp(ft * painAlphaRate, painAlpha, 0)
			end
	
			if (suddenDistraction > 0) then
				suddenDistraction = Lerp(ft * 4.6, suddenDistraction, 0)
			end
	
			if (healthFactor > 0 or blurDistraction > 0) then
				blurDistraction = Lerp(ft * 2, blurDistraction, 0)
			end
	
			fillScreen(Color(255, 1, 1), painAlpha)
		else
			painAlpha = 0
			suddenDistraction = 0
			blurDistraction = 0
		end
	end

	function PLUGIN:RenderScreenspaceEffects()
		if (blurDistraction > 0) then
			DrawMotionBlur( 0.1, blurDistraction, 0.01 )
		end
	
		if (healthFactor > 0) then
			local tab = {}
			tab["$pp_colour_colour"] = math.max(0, 1 - 1.5 * healthFactor)
			tab["$pp_colour_contrast"] = 1
			tab["$pp_colour_brightness"] = 0
		
			DrawColorModify( tab ) --Draws Color Modify effect
		end
	end

	function PLUGIN:CalcView(client, origin, angles, fov)
		if (client:CanAddEffects()) then
			local velLen = client:GetVelocity():Length2D()
	
			ft = FrameTime()
	
			if (client:OnGround()) then
				bobFactor = clmp(bobFactor + ft*4, 0, 1)
			else
				bobFactor = clmp(bobFactor - ft*2, 0, 1)
			end
	
			vel = clmp(velLen/client:GetWalkSpeed(), 0, 1.5)
			rest = 1 - clmp(velLen/40, 0, 1)
			curStep = curStep + (vel/math.pi)*(ft*2.15)
			
			newAng.p = angles.p + sin(curStep*15) * vel * .6 * bobFactor + sin(RealTime()) * rest * bobFactor
			newAng.y = angles.y + cos(curStep*7.5) * vel * .8 * bobFactor + cos(RealTime()*.5) * rest * .5 * (bobFactor * (5 * (vel/1)))
	
			if (suddenDistraction > 0) then
				newAng.p = newAng.p + sin(RealTime()*5) * (1 * suddenDistraction)
				newAng.y = newAng.y + cos(RealTime()*10) * (5 * suddenDistraction)
			end
	
			if (healthFactor > 0) then
				newAng.p = newAng.p + sin(RealTime()*2) * 2 * healthFactor
				newAng.y = newAng.y + cos(RealTime()*1) * 5 * healthFactor
			end
	
			view = {}
			view.origin = origin
			view.angles = newAng
			return view
		end
	end

	function PLUGIN:SetupQuickMenu(menu)
		 local button = menu:addCheck(L"toggleEffects", function(panel, state)
		 	if (state) then
		 		RunConsoleCommand("nut_fpeffects", "1")
		 	else
		 		RunConsoleCommand("nut_fpeffects", "0")
		 	end
		 end, NUT_CVAR_EFFECTS:GetBool())

		 menu:addSpacer()
	end
end