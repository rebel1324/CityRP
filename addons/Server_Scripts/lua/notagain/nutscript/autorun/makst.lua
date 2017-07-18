local function fuckyou() -- because fuck you.
local DAYZ = false
local MODERNRP = false

if (engine.ActiveGamemode() == "darkrp") then
	MODERNRP = true
end

if (engine.ActiveGamemode() == "dayz") then
	DAYZ = true
end

signal = signal or {}
signal.list = {
	{	
		name = "돈 주기",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			if (!target or !target:IsPlayer()) then return end
			local char = target:getChar()
			if (!char) then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest("줄 돈 설정", "줄 돈을 적어주세요", "", function(text)
				if (text and text != "") then
					client:ConCommand("say /give ".. tonumber(text) or "")
				end
			end, function() end)
		end,
	},
	{
		name = "돈 버리기",
		canDisplay = function(client, target)
			local char = client:getChar()
			if (!char) then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest("버릴 돈 설정", "버릴 돈을 적어주세요", "", function(text)
				if (!text) then return end
				client:ConCommand("say /dropmoney ".. tonumber(text or "") or "")
			end, function() end)
		end,
	},
	{
		name = "수갑 묶기",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			if (!target:IsPlayer()) then return end
			local char = client:getChar()
			if (!char) then return end
			local inv = char:getInv()
			if (!inv) then return end
			local hasItem = inv:hasItem("tie")
			if (!hasItem) then return end
			
			return true
		end,
		onSelect = function(client, target)
			local char = client:getChar()
			local inv = char:getInv()
			local item = inv:hasItem("tie")

			netstream.Start("invAct", "Use", item.id, item.invID)
		end,
	},
	{
		name = "스프레이",
		canDisplay = function(client, target)
			if (IsValid(target)) then return end
			local char = client:getChar()
			if (!char) then return end
			local inv = char:getInv()
			if (!inv) then return end
			local hasItem = inv:hasItem("spraycan")
			if (!hasItem) then return end
			
			return true
		end,
		onSelect = function(client, target)
			client:ConCommand("say /spraymesh")
		end,
	},
	{
		name = "몸 수색",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			local char = client:getChar()
			if (!char) then return end
			local class = char:getClass()
			if (!class) then return end
			local classData = nut.class.list[class]
			if (!classData or !classData.law) then return end
			if (!target:IsPlayer()) then return end

			return true
		end,
		onSelect = function(client, target)
			client:ConCommand("say /search")
		end,
	},
	{
		name = "비밀번호 설정",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			if (target:CPPIGetOwner() != client) then return end 
			if (target:GetClass() != "nut_keypad") then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest("버릴 돈 설정", "4자리 수 이하의 비밀번호를 설정하세요", "", function(text)
				client:ConCommand("say /password ".. text)
			end, function() end)
		end,
	},
}

		if (MODERNRP) then
			table.insert(signal.list, {
				name = "환불",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					if (target:CPPIGetOwner() != client) then return end 
					if (!nut.bent.list[target:GetClass()]) then return end

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /refund")
				end,
			})
			table.insert(signal.list, {
				name = "문 사기",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					if (!target:isDoor()) then return end
					if (IsValid(target:GetDTEntity(0))) then return end 

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /doorbuy")
				end,
			})
			table.insert(signal.list, {
				name = "문 팔기",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					if (!target:isDoor()) then return end
					if (target:GetDTEntity(0) != client) then return end 

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /doorsell")
				end,
			})
			table.insert(signal.list, {
				name = "법판 생성",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end
					local class = char:getClass()
					if (!class) then return end
					if (class != CLASS_MAYOR) then return end

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /lawboard")
				end,
			})
			table.insert(signal.list, {
				name = "가격 설정",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					if (target:CPPIGetOwner() != client) then return end 
					if (!target.vending) then return end

					return true
				end,
				onSelect = function(client, target)
					Derma_StringRequest("가격 설정", "설정할 가격을 적어주세요", "", function(text)
						client:ConCommand("say /setprice ".. tonumber(text) or "")
					end, function() end)
				end,
			})
			table.insert(signal.list, {
				name = "건라이센스 발급",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					local char = client:getChar()
					if (!char) then return end
					local class = char:getClass()
					if (!class) then return end
					local classData = nut.class.list[class]
					if (!classData or !classData.law) then return end
					if (!target:IsPlayer()) then return end
					if (target:getNetVar("license")) then return end

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /gunlicense")
				end,
			})
			table.insert(signal.list, {
				name = "건라이센스 취소",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					local char = client:getChar()
					if (!char) then return end
					local class = char:getClass()
					if (!class) then return end
					local classData = nut.class.list[class]
					if (!classData or !classData.law) then return end
					if (!target:IsPlayer()) then return end
					if (!target:getNetVar("license")) then return end

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /revokegunlicense")
				end,
			})
		end

		if (DAYZ) then
			table.insert(signal.list, {
				name = "빠른 탄약",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end
					
					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /fastammo")
				end,
			})
			table.insert(signal.list, {
				name = "빠른 치료",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end
					
					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /fastheal")
				end,
			})
			table.insert(signal.list, {
				name = "빠른 음료",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end
					
					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /fastdrink")
				end,
			})
			table.insert(signal.list, {
				name = "빠른 음식",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end

					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /fastfood")
				end,
			})
		end

if (CLIENT) then

	signal.queue = {}

	surface.CreateFont("SignalFont", {
		font = "Malgun Gothic",
		extended = true,
		size = 25,
		weight = 800,
		shadow = true,
	})

	surface.CreateFont("SignalFontBlur", {
		font = "Malgun Gothic",
		extended = true,
		size = 25,
		weight = 800,
		shadow = true,
		blursize = 4,
	})

	local w, h = ScrW(), ScrH()
	local selected = 0
	signal.open = false

	for k, v in pairs(signal.list) do
		v.curpos = {w/2, h/2}
		v.curalpha = 0
	end

	function signal.opensignal()
		signal.open = true

		for k, v in pairs(signal.list) do
			v.curpos = {w/2, h/2}
		end

		surface.PlaySound("common/wpn_select.wav")
	end
	hook.Add("OnContextMenuOpen", "signal", signal.opensignal)

	function signal.closesignal()
		signal.open = false

		local x, y = gui.MousePos( )
		x, y = (x-w/2), (y-h/2)
		if (x == 0 and y == 0) then 
			surface.PlaySound("common/wpn_denyselect.wav")
			gui.EnableScreenClicker(signal.open)
			return 
		end

		local func = signal.list[selected]
		if (func) then
			local trace = LocalPlayer():GetEyeTraceNoCursor()
			
			if (func.onSelect) then
				func.onSelect(LocalPlayer(), trace.Entity)
			end
		end

		surface.PlaySound("common/wpn_hudoff.wav")
	end
	hook.Add("OnContextMenuClose", "signal", signal.closesignal)

	local signalalpha = 0
	local distance = w*.1
	local icons = {
		[1] = surface.GetTextureID("vgui/notices/error"),
		[2] = surface.GetTextureID("vgui/notices/generic"),
		[3] = surface.GetTextureID("vgui/notices/hint"),
		[4] = surface.GetTextureID("vgui/notices/undo"),
		[5] = surface.GetTextureID("vgui/notices/cleanup"),
	}

	function signal.draw()
		if signal.open then
			signalalpha = Lerp(FrameTime()*9, signalalpha, 255)
		else
			signalalpha = Lerp(FrameTime()*20, signalalpha, 0)
		end

		if signalalpha > 0 then
			local x, y = gui.MousePos( )
			x, y = (x-w/2), (y-h/2)

			local dist = Vector(0, 0, 0):Distance(Vector(x, y, 0))

			local seldeg = -math.deg(math.atan2(x, y))
			if seldeg < 0 then
				seldeg = 360+seldeg
			end

			local center = "빠른 명령어"
			surface.SetTextColor(Color(255, 255, 255, signalalpha))
			surface.SetFont("SignalFontBlur")
			local tw, th = surface.GetTextSize(center)
			surface.SetTextPos(w/2 - tw/2, h/2 - th/2)
			surface.DrawText(center)

			surface.SetFont("SignalFont")
			local tw, th = surface.GetTextSize(center)
			surface.SetTextPos(w/2 - tw/2, h/2 - th/2)
			surface.DrawText(center)


			surface.SetTextColor(Color(255, 255, 255, math.max(0, signalalpha - ((RealTime()*400) % 200))))
			surface.SetFont("SignalFont")
			local tw, th = surface.GetTextSize("명령어를 사용하려면 마우스를 대고 'C'키를 떼면 됩니다")
			surface.SetTextPos(w/2 - tw/2, h - ScreenScale(25) - th)
			surface.DrawText("명령어를 사용하려면 마우스를 대고 'C'키를 떼면 됩니다")

			local allowed = {}
			local client = LocalPlayer()
			local trace = client:GetEyeTraceNoCursor()

			for k, v in ipairs(signal.list) do
				if (v.canDisplay) then
					if (v.canDisplay(client, trace.Entity)) then
						table.insert(allowed, {v, k})
					end
				end
			end

			local rad = math.rad(360/#allowed)
			local deg = math.deg(rad)

			for k, v in ipairs(allowed) do
				v, idx = v[1], v[2]

				local rdeg = deg*k
				local min = (rdeg - deg/2)
				local max = (rdeg + deg/2)
				if max > 360 then
					max = max - 360
					if min < seldeg or max > seldeg then
						selected = idx
					end 
				else
					if min < seldeg and max > seldeg then
						selected = idx
					end 
				end
			
				if (dist < distance * 0.8 or dist > distance * 1.2) then 
					selected = nil
				end 

				surface.SetFont("SignalFont")
				local tw, th = surface.GetTextSize(v.name)
				surface.SetTextColor(Color(255, 255, 255, signalalpha))
				
				v.curpos[1] = Lerp(FrameTime()*8, v.curpos[1], w/2-tw/2+math.sin(rad*-k)*distance)
				v.curpos[2] = Lerp(FrameTime()*8, v.curpos[2], h/2-th/2+math.cos(rad*k)*distance)

				if (selected == idx and x ~= 0 and y ~= 0) then
					surface.SetTextColor(Color(255, 111, 111, signalalpha))
					surface.SetFont("SignalFontBlur")
					local tw, th = surface.GetTextSize(v.name)
					surface.SetTextPos(math.Round(v.curpos[1]), math.Round(v.curpos[2]))
					surface.DrawText(v.name)
				end

				surface.SetFont("SignalFont")
				local tw, th = surface.GetTextSize(v.name)
				surface.SetTextPos(math.Round(v.curpos[1]), math.Round(v.curpos[2]))
				surface.DrawText(v.name)

			end
		end
	end
	hook.Add("HUDPaint", "signal", signal.draw)
end

if SERVER then	
	local function BotTimeOut()
		for k,v in pairs(player.GetBots()) do
			if not v.BotEndTime then v.BotEndTime = CurTime() + 1800 
			elseif v.BotEndTime < CurTime() then v:Kick("Bot TimeOut") end
		end
	end
	timer.Create("bottimeout",60,0,BotTimeOut)
else
	local hour = 0
	local function TimeAfter()
		hour = hour + 1
		chat.AddText(Color(255,150,230),"귀하는 "..hour.."시간동안 플레이중입니다.")
	end

	timer.Create("TimeAfter",3600,0,TimeAfter)
end
end
timer.Simple(1, fuckyou)