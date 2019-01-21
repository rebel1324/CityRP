--[[
	EVIL MELON MAP MODIFICATION SCRIPT
		1. ADD TEXT SCREENS 
			- Spawn MOTD
			- PD MOTD
		2. REPLACE EXISTING TEXTURES FOR INTERNATIONAL PURPOSES
		3. REMOVE BAD ENTITIES
--]]
if (SERVER) then
	local ENT = {}
	ENT.Type = "point"
	function ENT:AcceptInput( inputName, activator, called, data )
		hook.Run("CustomTrigger", inputName, activator, data, called)
	end
	scripted_ents.Register(ENT, "hooker")
	ENT = nil
end

JAIL_CONTROLLER_POS = Vector(-9268.977930, 11073.68750, -13900.974609)
if (SERVER) then
	local jailDoors = {
		[1] = 1589,
		[2] = 1590,
		[3] = 1593,
		[4] = 1601,
		[5] = 1595,
		[6] = 1597,
		[7] = 1600,
	}

	JAIL_CONTROLLER_DELAY = CurTime()
	netstream.Hook("nutJailDoor", function(client, arg)
		if (JAIL_CONTROLLER_DELAY > CurTime()) then return end
		JAIL_CONTROLLER_DELAY = CurTime() + .2

		local dist = client:GetPos():Distance(JAIL_CONTROLLER_POS)
		if (dist > 256) then return end

		local jailNum = tonumber(arg[1])
		if (jailDoors[jailNum]) then
			local ocBool = arg[2] == "a" and true or false

			local ent
			for k, v in ipairs(ents.GetAll()) do
				if (v:MapCreationID() == jailDoors[jailNum]) then
					ent = v

					break
				end
			end

			if (IsValid(ent)) then
				sound.Play("buttons/button3.wav", JAIL_CONTROLLER_POS)
				sound.Play("ambient/alarms/klaxon1.wav", ent:GetPos())

				ent:Fire(ocBool and "open" or "close", "", "1")
			end
		end
	end)
end

if (CLIENT) then
	local thinkit = {}

	do
		local scrSize = 5
		JAIL_CONTROLLER = JAIL_CONTROLLER or LuaScreen()
		JAIL_CONTROLLER.pos = JAIL_CONTROLLER_POS
		JAIL_CONTROLLER.ang = Angle(0, -90, 0)
		JAIL_CONTROLLER.noClipping = false
		JAIL_CONTROLLER.w = 4.65*scrSize
		JAIL_CONTROLLER.h = 9.4*scrSize
		JAIL_CONTROLLER.scale = .083
		table.insert(thinkit, JAIL_CONTROLLER)

		local background = color_white

		local function paintButton(x, y, w, h, text, alpha, bool)
			local key = LocalPlayer():KeyDown(IN_ATTACK)
			surface.SetDrawColor((bool and key) and 200 or (bool and 50 or 30), bool and 50 or 30, bool and 50 or 30, alpha)
			surface.DrawRect(x, y, w, h)

			surface.SetDrawColor(0, 0, 0, 180)
			surface.DrawOutlinedRect(x, y, w, h)

			surface.SetDrawColor(180, 180, 180, 2)
			surface.DrawOutlinedRect(x + 1,y + 1, w - 2, h - 2)

			nut.util.drawText(text, x + w/2, y + h/2, color_white, 1, 1, "nutMediumFont")
		end

		JAIL_CONTROLLER.renderCode = function(scr, ent, wide, tall)
			local dist = LocalPlayer():GetPos():Distance(JAIL_CONTROLLER_POS)
			local alpha = math.max(0, (dist - 100)/156*255)
			
			if (alpha > 255) then return end
			for i = 0, 6 do
				local x, y = 10, 20 + i*80
				nut.util.drawText("감옥" .. (i + 1), x, y, color_white, 3, 1, "nutBigFont", alpha * 0.65)

				local bx, by, bw, bh = x, y + 20, wide/2 - 15, 30
				local bool = scr:cursorInBox(bx, by, bw, bh)
				paintButton(bx, by, bw, bh, "열기", 255, bool)
				if (bool) then
					scr.curSel = (i+1) .. "a"
				end

				bx, by, bw, bh = wide/2 - 5+ x, y + 20, wide/2 - 10, 30
				bool = scr:cursorInBox(bx, by, bw, bh)
				paintButton(bx, by, bw, bh, "닫기", 255, bool)
				if (bool) then
					scr.curSel = (i+1) .. "b"
				end
			end

			draw.RoundedBox(0, 0, 0, wide, tall, Color(0, 0, 0, alpha))
		end
		JAIL_CONTROLLER.onMouseClick = function(self, key)
			netstream.Start("nutJailDoor", self.curSel)
		end

		hook.Add("Think", "nutMapScript", function()
			for k, v in ipairs(thinkit) do
				v:think()
			end
		end)

		hook.Add("PostDrawTranslucentRenderables", "nutMapScript", function()
			for k, v in ipairs(thinkit) do
				v:render()
			end
		end)
	end
	
	do
		local labelChange = {
			dir = {"cm_textures/", "translation/"},
			files = {
				"cell1",
				"cell2",
				"cell3",
				"cell4",
				"cell5",
				"cell6",
				"cell7",
				"info1",
				"info2",
				"jailbutton",
			}
		}

		local decalChange2 = {
			{
				"decals/decal_signprotection009a",
				"translation/decal_signprotection009a",
			},
			{
				"de_train/train_security_decal_01",
				"translation/train_security_decal_01",
			},
			{
				"de_train/train_security_decal_02",
				"translation/train_security_decal_02",
			},
			{
				"decals/decal_posters006a",
				"translation/decal_posters006a",
			},
			{
				"decals/decal_posterbreen",
				"translation/decal_posterbreen",
			},
			{
				"cs_assault/assault_parking_decal01",
				"translation/assault_parking_decal01",
			},
		}

		local propChange = {
			dir = {"props/", "translation/"},
			files = {
				"metalsign001i", -- 기념품
				"sign_cafe01a", -- 카페 발틱
				"signhostel001a", -- 호텔
				"sign_foto01a", -- 뽀토
			}
		}

        timer.Simple(3, function()
            for k, v in pairs(labelChange.files) do
                local cMat, rMat
                cMat = Material(labelChange.dir[1] .. v)
                rMat = Material(labelChange.dir[2] .. v)

                if (cMat and rMat) then
                    cMat:SetTexture("$basetexture", rMat:GetTexture("$basetexture"))
                end
            end

            -- 간판 한글화
            for k, v in pairs(propChange.files) do
                local cMat, rMat
                cMat = Material(propChange.dir[1] .. v)
                rMat = Material(propChange.dir[2] .. v)

                if (cMat and rMat) then
                    cMat:SetTexture("$basetexture", rMat:GetTexture("$basetexture"))
                end
            end

            -- 데칼 한글화
            for k, v in pairs(decalChange2) do
                local cMat, rMat
                cMat = Material(v[1])
                rMat = Material(v[2])

                if (cMat and rMat) then
                    cMat:SetTexture("$basetexture", rMat:GetTexture("$basetexture"))
                end
            end
        end)
	end
end