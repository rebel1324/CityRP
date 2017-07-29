PLUGIN.name = "Realistic Flashlight"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin makes your flashlight feels like it's from L4D2"


	local badWeapons = {
		tfa_csgo_mp5 = function(ang) return ang:Forward():Angle() end,
		tfa_csgo_revolver = function(ang) return ang:Forward():Angle() end
	}

	local meleeWeapons = {
	
	}

	local meta = FindMetaTable("Player")

	 if (CLIENT) then
	 	if (FLASHES) then
			for k, v in pairs(FLASHES) do
				v:Remove()
			end
		end

		local flashType = {
			{"effects/flashlight001", 512, 1},
			{"effects/flashlight001", 512, 3},
			{"effects/flashlight/flight04", 600, 2},
			{"effects/flashlight/hard", 512, 1},
			{"effects/flashlight/hard", 512, .5},
			{"effects/flashlight/soft", 600, 3},
			{"effects/flashlight/soft", 600, 1},
			{"effects/flashlight/flight01", 700, 3},
			{"effects/flashlight/flight03", 600, 1},
			{"effects/flashlight/flight04", 600, 1},
			{"effects/flashlight/flight05", 600, 1},
			{"effects/flashlight/flight06", 600, 1},
			{"effects/flashlight/flight07", 600, 1},
		}

		function meta:getFlashType()
			return 1
		end


		FLASHES = {}

		local matLight = Material( "sprites/light_ignorez" )
		local matBeam = Material( "effects/lamp_beam" )

		local function TFA_CSGO(wep, vm)
			local att = vm:GetAttachment(1)

			local borke = badWeapons[wep:GetClass()] 
			if (borke) then
				return att.Pos, borke(att.Ang)
			else
				return att.Pos, att.Ang:Up():Angle()
			end
		end

		local function flashlightThink(client)
			if (client:GetNWBool("customFlashlight") != true) then 
				if (flash) then
					 flash:Remove()
				 end
				 
				 return
			end

			if (NV_Status and NV_NIGHTTYPE > 1) then
				if (IsValid(client.flash)) then
					client.flash:Remove()
				end

				return
			end

			if (client == LocalPlayer() and NV_Status) then
				if (IsValid(client.flash)) then
					client.flash:Remove()
				end

				return
			end

			if (!IsValid(client.flash)) then
				client.flash = ProjectedTexture()
				FLASHES[client] =  client.flash
			end

			if (!client.flash) then return end

			local pos, ang = client:GetShootPos(), client:EyeAngles()
			local wep = client:GetActiveWeapon()
			pos = pos + ang:Forward() * 10

			if (LocalPlayer() == client and !client:ShouldDrawLocalPlayer()) then
				local wep = client:GetActiveWeapon()
				if (wep:IsValid()) then
					local vm = wep.CW20Weapon and
					(IsValid(wep.CW_VM) and wep.CW_VM or client:GetViewModel()) or
					(IsValid(wep.Wep) and wep.Wep) or
					client:GetViewModel()
				    
					if (wep.IsTFA and wep:IsTFA()) then
						if (!wep.___ACECOOLED) then
							-- I don't want to check every string for every single time
							if (wep:GetClass():find("tfa_csgo")) then
								wep.CSGO = true
							end

							wep.___ACECOOLED  = true
						end
					end
					
					if (IsValid(vm) and
						((wep.CW_VM and vm:GetNoDraw() or !vm:GetNoDraw()) or 
						(wep.Wep and vm:GetNoDraw() or !vm:GetNoDraw()))
					) then
						if (wep.CSGO) then
							local att = vm:GetAttachment(1)

							if (att) then
								pos, ang = TFA_CSGO(wep, vm)
							end
						else
							if (!meleeWeapons[wep:GetClass()]) then
								local att = vm:GetAttachment(1)

								if (att) then
									pos, ang = att.Pos, att.Ang
								end
							end
						end
					end
				 end
			end
			 
			local flashlightInfo = client:getFlashType()
			client.flash:SetFOV(60)
			client.flash:SetFarZ(flashType[flashlightInfo or 1][2])
			client.flash:SetNearZ(1)
			client.flash:SetPos(pos)
			client.flash:SetAngles(ang)
			client.flash:SetTexture(flashType[flashlightInfo or 1][1])
			client.flash:SetColor(Color(255, 255, 255))

			if ((RealTime()+client:EntIndex()) % 250 < 1) then
				client.flash:SetBrightness(math.abs(
					math.sin(RealTime()*80)*.5 + 
					math.cos(RealTime()*22)*.5
				))
			else
				client.flash:SetBrightness(flashType[flashlightInfo or 1][3])
			end

			client.flash:SetEnableShadows(false)
			client.flash:Update()

			if (SURPRESS_FROM_STENCIL) then return end
			if (!client:GetNoDraw()) then
				if (client:GetNWBool("customFlashlight") == true) then
					if (LocalPlayer() == client and !client:ShouldDrawLocalPlayer()) then return end
					
					local bpos, bang = client:GetBonePosition(client:LookupBone("ValveBiped.Bip01_R_Hand") or 1)
					if (!bpos or !bang) then return end
					
					local lightNormal = ang:Forward()
					local viewNormal = bpos - EyePos()
					local dist = viewNormal:Length()
					viewNormal:Normalize()
					local viewDot = math.max(viewNormal:Dot( lightNormal * -1 ), 0)
					local lightPos = bpos + lightNormal * 5

					client.pxvs = client.pxvs or util.GetPixelVisibleHandle()
					local isVisible = util.PixelVisible( lightPos + lightNormal, 16, client.pxvs )
					if ( !isVisible ) then return end
					local size = math.Clamp( dist * isVisible * viewDot * 2, 0, 32 )

					render.SetMaterial( matLight )
					render.DrawSprite( bpos, size, size, Color(255, 255, 255) )
									
					render.SetMaterial( matBeam )

					viewDot = 1 - viewDot
					render.StartBeam( 3 )
						render.AddBeam( bpos + lightNormal * 1, 16, 0.0, Color( 255, 255, 255, 150 - 100*viewDot ) )
						render.AddBeam( bpos + lightNormal * 20, 16, 0.5, Color( 255, 255, 255, 40 - 20*viewDot ) )
						render.AddBeam( bpos + lightNormal * (80 - 40*viewDot), 16, 1, Color( 255, 255, 255, 0) )
					render.EndBeam()
				end
			end
		end
		
		function PLUGIN:PostPlayerDraw(client)
			flashlightThink(client)
		end

		function PLUGIN:PreDrawTranslucentRenderables()
			if (LocalPlayer() and LocalPlayer():getChar() and !LocalPlayer():ShouldDrawLocalPlayer()) then
				flashlightThink(LocalPlayer())
			end

		    for client, flash in pairs(FLASHES) do
				if (!client or !IsValid(client) or !client:IsPlayer()) then
					 flash:Remove()
					 FLASHES[client] = nil
					 
					 continue
				 end

				if (client:GetNWBool("customFlashlight") != true) then 
					if (flash) then
						flash:Remove()
					end
					
					continue
				end

				local dist = client:GetPos():Distance(LocalPlayer():GetPos())

				if (dist > 512) then
					if (IsValid(client.flash)) then
						client.flash:Remove()
					end

					continue
				end

				if (!client:Alive()) then
					if (client.flash and client.flash.Remove) then
						client.flash:Remove()
					end

					continue
				end

				if (client:GetNWBool("customFlashlight") != true) then
					if (client.flash and client.flash.Remove) then
						client.flash:Remove()
					end

					continue
				end
			end
		end
	else
		function PLUGIN:PlayerDeath(client)
			 client:SetNWBool("customFlashlight", false)
		end
		
		-- it's all about kek
		local a = GM or GAMEMODE

		function meta:FlashlightIsOn()
			return self:GetNWBool("customFlashlight", false)
		end

		function a:PlayerSwitchFlashlight(ply, on)
			if not IsValid(ply) then return false end

			-- on = Player toggled the flashlight
			if (!on) then
			 	ply:SetNWBool("customFlashlight", false)
				return
			else
				ply:EmitSound("items/flashlight1.wav")
				ply:SetNWBool("customFlashlight", !ply:FlashlightIsOn())
			end
		end
	 end