PLUGIN.name = "Grenade Throwables"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Grenade Throwables."

function PLUGIN:Move(client, mv)
	if client:GetMoveType() != MOVETYPE_WALK then return end

	local teargas = client:getNetVar("teargas")

	if (teargas and teargas > CurTime()) then
		local m = .25
		local f = mv:GetForwardSpeed() 
		local s = mv:GetSideSpeed() 
		mv:SetForwardSpeed( f * .005 )
		mv:SetSideSpeed( s * .005 )
	end
end

if (SERVER) then
	function PLUGIN:PlayerSpawn(client)
		client:setNetVar("teargas", 0)
	end

	function PLUGIN:PlayerDeath(client)
		client:setNetVar("teargas", 0)
	end
else
	local trg = 0
	local cur = 0
	local icon = {
		[1] = "R",
		[2] = "Z",
		[3] = "a",
		[4] = "b",
	}
	local w, h
	local lclient
	local myChar 
	function PLUGIN:HUDPaint()
		w, h = ScrW(), ScrH()
		lclient = LocalPlayer()
		myChar = lclient:getChar()
		
		if (myChar) then
			if (!lclient:Alive()) then
				return
			end
			
			local teargas = lclient:getNetVar("teargas")

			if (teargas and teargas > CurTime()) then
				trg = 120 + math.abs(math.sin( RealTime()*2 )*70)
			else
				trg = 0
			end

			cur = Lerp(FrameTime()*3, cur, trg)
			surface.SetDrawColor(255, 255, 255, cur)
			surface.DrawRect(0, 0, w, h)
			
			-- Nice optimizaion, Ass.
			for _, entity in pairs(GLOBAL_BEACONS) do
				local pos = entity:GetPos() + entity:OBBCenter()
				local scr = (pos):ToScreen()
				local dis = pos:Distance(lclient:GetPos())
				local what = entity:GetDTInt(0)

				local owner = entity:CPPIGetOwner()
				if (!owner) then return end

				local char = owner:getChar()

				if (char and myChar) then
					local team = nut.class.list[myChar:getClass()].team
					
					if ((myChar == char) or (team and nut.class.list[char:getClass()].team == team)) then
						local matrix = Matrix()
						local scale = math.max(1, 1.5 - RealTime()*3%1.5)
						matrix:Translate(Vector(math.Clamp(scr.x - 20*scale, w*.1, w*.9), math.Clamp(scr.y - 20*scale, h*.1, h*.9)))
						matrix:Rotate(Angle(0, 0, 0))
						matrix:Scale(Vector(scale, scale))

						cam.PushModelMatrix(matrix)
							local tx, ty = nut.util.drawText(icon[what], 0, 0, color_white, 3, 5, "nutIconsBig")
							nut.util.drawText(math.Round(dis/10) .. " m", tx/2, 0 + ty*0.9, color_white, 1, 5, "nutSmallFont")
						cam.PopModelMatrix()
					end
				end
			end
		end
	end

	-- Local function for condition.
	local function canEffect(client)
		return (
			client:getChar() and
			client:getNetVar("gasMaskOn", false) and
			!client:ShouldDrawLocalPlayer() and
			(!nut.gui.char or !nut.gui.char:IsVisible())
		)
	end

	local gasmaskTexture2 = Material("gasmask_fnl")
	local gasmaskTexture = Material("shtr_01")

	-- Draw the Gas Mask Overlay. But other essiential stuffs must be visible.
	function PLUGIN:HUDPaintBackground()
		if (canEffect(LocalPlayer())) then
			w, h = ScrW(), ScrH()
			gw, gh = h/3*4, h

			surface.SetMaterial(gasmaskTexture)

			render.UpdateScreenEffectTexture()
			surface.SetMaterial(gasmaskTexture2)
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(w/2 - gw/2, h/2 - gh/2, gw, gh)

			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(0, 0, w/2 - gw/2, h)
			surface.DrawRect(0, 0, w, h/2 - gh/2)
			surface.DrawRect(0, h/2 + gh/2, w, h/2 - gh/2)
			surface.DrawRect(w/2 + gw/2, 0, w/2 - gw/2, h)
		end
	end

	function PLUGIN:PlayerPostThink(client)
		if (client:getChar()) then
			if (client:Alive() and client:getNetVar("gasMaskOn", false)) then
				healthFactor = math.Clamp(client:Health()/client:GetMaxHealth(), 0, 1)

				if (!client.nextBreath or client.nextBreath < CurTime()) then
					print(client)
					client:EmitSound(
						!client.exhale and "gmsk_in.wav" or "gmsk_out.wav", 
						(LocalPlayer() == client and client:ShouldDrawLocalPlayer()) and 20 or 50, math.random(90, 100) + 15*(1 - healthFactor)
					)
					
					local f = healthFactor*.5
					client.nextBreath = CurTime() + 1 + f + (client.exhale and f or 0)
					
					client.exhale = !client.exhale
				end
			end
		
			local teargas = client:getNetVar("teargas")

			if (teargas and teargas > CurTime() and client:Alive()) then
				if (!client.nextCough or client.nextCough < CurTime()) then
					client.nextCough = CurTime() + math.random(2, 5)

					client:EmitSound( Format( "ambient/voices/cough%d.wav", math.random( 1, 4 ) ) )
				end
			end
		end
	end
end