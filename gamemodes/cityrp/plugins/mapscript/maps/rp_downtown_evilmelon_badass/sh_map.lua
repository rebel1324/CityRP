/*
	EVIL MELON MAP MODIFICATION SCRIPT
		1. ADD TEXT SCREENS 
			- Spawn MOTD
			- PD MOTD
		2. REPLACE EXISTING TEXTURES FOR INTERNATIONAL PURPOSES
		3. REMOVE FUCKOFF ENTITIES
*/
if (SERVER) then
	local ENT = {}
	ENT.Type = "point"
	function ENT:AcceptInput( inputName, activator, called, data )
		hook.Run("CustomTrigger", inputName, activator, data, called)
	end
	scripted_ents.Register(ENT, "hooker")
	ENT = nil

	local goAway = {
		[2746] = true,
		[2747] = true,
		[2748] = true,
		[2749] = true,
		[2750] = true,
		[2751] = true,
		[2752] = true,

		[2739] = true,
		[2740] = true,
		[2741] = true,
		[2742] = true,
		[2743] = true,
		[2744] = true,
		[2745] = true,

		[2732] = true,
		[2733] = true,
		[2734] = true,
		[2735] = true,
		[2736] = true,
		[2737] = true,
		[2738] = true,

		[1528] = true,
		[1529] = true,
		
		[2771] = true,
		[2752] = true,

		[2242] = function(v) v:Fire("open") end,
		[2043] = function(v) v:Fire("open") end,
	}
    
	BANK_ENTITY_LIST = {
		btn = 2040,
		on = 2041,
		off = 2042,
	}

	-- gets two vector and gives min and max vector for Vector:WithinAA(min, max)
	local function sortVector(vector1, vector2)
		local minVector = Vector(0, 0, 0)
		local maxVector = Vector(0, 0, 0)

		for i = 1, 3 do
			if (vector1[i] >= vector2[i]) then
				maxVector[i] = vector1[i]
				minVector[i] = vector2[i]
			else
				maxVector[i] = vector2[i]
				minVector[i] = vector1[i]
			end
		end

		return minVector, maxVector
	end

	-- Bank Bounding Box
	local minVector, maxVector = sortVector(Vector(-9232.017578125, 8098.2153320313, -13709.15625), Vector(-7522.03125, 7321.03125, -14317.768554688))
	local vault1, vault2 = sortVector(Vector(-8350.826172, 7914.296387, -14070.942383), Vector(-7490.396484, 7323.839844, -14353.764648))

	function PLUGIN:OnPlayerJoinClass(client, class, oldclass, silent)	
		local bool = client:GetPos():WithinAABox(vault1, vault2)
		if (client.FAGGOT) then -- 김치새끼들은 하면 또해
			bool = client:GetPos():WithinAABox(minVector, maxVector)
		end

		if (bool) then
			local ocData = nut.class.list[tonumber(oldclass)]
			local ncData = nut.class.list[tonumber(class)]

			if (ocData and ncData) then
				if (ocData.law and !ncData.law) then
					client:SetPos(Vector(-9251.191406, 8950.556641, -13668.351563))
					client:Freeze(true)
					
					for k, v in ipairs(player.GetAll()) do
						v:ChatPrint(client:Name() .. ": 저는 은행을 털려고 금고 안에서 직업을 바꿨습니다.") 
					end
					client:ChatPrint("불순한 시도로 인해 150초간 모든 활동을 정지시킵니다.") 

					timer.Simple(150, function()
						client:Freeze(false)
					end)
					client.FAGGOT = true
				end
			end
		end
	end

	function PLUGIN:OnBankAlarmed(fedora)
		for k, v in ipairs(ents.GetAll()) do
			local class = v:GetClass()

			if (class == "nut_rotlight") then
				if (v:GetPos():WithinAABox(minVector, maxVector)) then
					v:SetEnabled(fedora)
				end
			end
		end
	end

	function PLUGIN:CustomTrigger(inputName, activator, called, data)
		if (inputName == "BankAlarmOn") then
			hook.Run("OnBankAlarmed", true)
		elseif (inputName == "BankAlarmOff") then
			hook.Run("OnBankAlarmed", false)
		end
	end
	
	function PLUGIN:InitPostEntity()
		HOOKER = ents.Create("hooker")

		for k, v in ipairs(ents.GetAll()) do
			if (v:MapCreationID() == BANK_ENTITY_LIST.on) then
				v:SetKeyValue("OnTrigger", "hooker,BankAlarmOn,0,0,-1")
			end
			if (v:MapCreationID() == BANK_ENTITY_LIST.off) then
				v:SetKeyValue("OnTrigger", "hooker,BankAlarmOff,0,0,-1")
			end
			if (goAway[v:MapCreationID()] == true) then
				v:Remove()
			elseif (goAway[v:MapCreationID()] != nil) then
				goAway[v:MapCreationID()](v)
			end
		end
    end
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
		local scrSize = 10
		SCREEN_2 = SCREEN_2 or LuaScreen()
		SCREEN_2.pos = Vector(-8953.182617, 7687.031250, -13940.669922)
		SCREEN_2.ang = Angle(0, 90, 0)
		SCREEN_2.noClipping = false
		SCREEN_2.w = 16*scrSize
		SCREEN_2.h = 9*scrSize
		SCREEN_2.scale = .2

		-- Create Text Markup Object.
		timer.Simple(1, function()
			MRKPOBJ2 = nut.markup.parse(
					[[
<font=nutBigFont><color=200, 200, 80>은행털이전 주의사항!</font>
<font=nutMediumFont>다음 사항을 지키지 않으면 불이익을 받을 수 있습니다.</color>

이 글은 위쪽 테두리에서 아래쪽 테두리로 조준을 하여 천천히 스크롤해서 읽어 내려갈 수 있습니다. 

은행털이를 하기 위해서는 경찰이 0명 이상 있어야 합니다. <color=255, 80, 80>경찰은 도둑에게 매수될 수 없습니다!</color>
만약 경찰과 도둑간의 비리사항이 발견된 경우는 IC의 문제가 아닌 OOC의 문제로 처리되어서 게임 플레이상에 심각한 불이익을 초래할 수 있습니다.
그러니 위와 같은 행동을 하는 것을 지양해 주시길 바랍니다.

<color=255, 80, 80>은행 내부에 바리케이드를 설치할 수 없습니다!</color>
은행 내부에 바리케이트를 설치하는 순간 서버의 규칙에 따라서 처벌될 것입니다. ]]
			, SCREEN_2:getWide() - 20)
		end)

		SCREEN_2.scrollAmount = 0
		SCREEN_2.scrollPos = 0
		SCREEN_2.scrollTargetPos = 0
		SCREEN_2.renderCode = function(scr, ent, wide, tall)
			local dist = LocalPlayer():GetPos():Distance(SCREEN_2.pos)			
			if (dist > 450) then return end

			draw.RoundedBox(0, 0, 0, wide, tall, Color(0, 0, 0, 150))

			SCREEN_2.scrollAmount = math.max(MRKPOBJ2:getHeight() - tall + 20, 0)

			if (scr.hasFocus) then
				local mx, my = scr:mousePos()
				local prec = my/tall
				SCREEN_2.scrollTargetPos = (prec) * -SCREEN_2.scrollAmount
			else
				SCREEN_2.scrollTargetPos = (math.Clamp(((RealTime() / tall*10) % 1.7) - .2, 0, 1) * -SCREEN_2.scrollAmount)
			end

			SCREEN_2.scrollPos = Lerp(FrameTime()*7, SCREEN_2.scrollPos, SCREEN_2.scrollTargetPos)
			if (MRKPOBJ2) then
				MRKPOBJ2:draw(15, SCREEN_2.scrollPos + 10, 3, 2)
			end
		end
		SCREEN_2.onMouseClick = function(self, key)
		end
		table.insert(thinkit, SCREEN_2)

		local scrSize = 10
		SCREEN_3 = SCREEN_3 or LuaScreen()
		SCREEN_3.pos = Vector(-8856.178711, 10626.351563, -13899.375000)
		SCREEN_3.ang = Angle(0, 138, 0)
		SCREEN_3.noClipping = false
		SCREEN_3.w = 8*scrSize
		SCREEN_3.h = 6.3*scrSize
		SCREEN_3.scale = .15

		-- Create Text Markup Object.
		timer.Simple(1, function()
			MRKPOBJ3 = nut.markup.parse(
					[[
<font=nutBigFont><color=200, 200, 80>경찰 주의사항!</font>
<font=nutMediumFont>다음 사항을 지키지 않으면 불이익을 받을 수 있습니다.</color>

이 글은 위쪽 테두리에서 아래쪽 테두리로 조준을 하여 천천히 스크롤해서 읽어 내려갈 수 있습니다. 

라크 시티에서의 경찰은 범죄자들을 때려잡을수도 있고, 범죄자들에게 돈을 갈취할수도 있습니다. 
하지만, 뇌물을 받은 증거가 명확하다면 강등을 당할수도 있으니 매우 조심하여야 합니다.

체포를 하기위해서는 이유가 명확하여야 하고, 체포를 무슨 이유에서든 불응하는 사람이 있다면 사살해도 됩니다.
하지만, 꼬투리를 잡아서 살인을 하는것은 명백한 법의 위반입니다. 이 경우에도 강등됩니다.

하지만, IC에서의 강등이 매우 많아지면 OOC로써 취급되어 서버의 규칙에 따라 처벌받을 수 있습니다.]]
			, SCREEN_3:getWide() - 20)
		end)

		SCREEN_3.scrollAmount = 0
		SCREEN_3.scrollPos = 0
		SCREEN_3.scrollTargetPos = 0
		SCREEN_3.renderCode = function(scr, ent, wide, tall)
			local dist = LocalPlayer():GetPos():Distance(SCREEN_3.pos)			
			if (dist > 350) then return end

			draw.RoundedBox(0, 0, 0, wide, tall, Color(0, 0, 0, 150))

			SCREEN_3.scrollAmount = math.max(MRKPOBJ3:getHeight() - tall + 20, 0)

			if (scr.hasFocus) then
				local mx, my = scr:mousePos()
				local prec = my/tall
				SCREEN_3.scrollTargetPos = (prec) * -SCREEN_3.scrollAmount
			else
				SCREEN_3.scrollTargetPos = (math.Clamp(((RealTime() / tall*10) % 1.7) - .2, 0, 1) * -SCREEN_3.scrollAmount)
			end

			SCREEN_3.scrollPos = Lerp(FrameTime()*7, SCREEN_3.scrollPos, SCREEN_3.scrollTargetPos)
			if (MRKPOBJ3) then
				MRKPOBJ3:draw(15, SCREEN_3.scrollPos + 10, 3, 2)
			end
		end
		SCREEN_3.onMouseClick = function(self, key)
		end
		table.insert(thinkit, SCREEN_3)

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
				"decals/decalgraffiti001c_cs",
				"translation/decalgraffiti001c",
			},
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
			{
				"decals/decalposter007a",
				"translation/decalposter007a",
			},
			{
				"decals/decalgraffiti043a_cs",
				"translation/decalgraffiti043a_cs",
			},
			{
				"decals/decalgraffiti050a",
				"translation/decalgraffiti050a",
			},
			{
				"decals/decalgraffiti009a",
				"translation/decalgraffiti009a",
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