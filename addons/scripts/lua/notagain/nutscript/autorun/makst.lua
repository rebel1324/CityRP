local function fuckyou() -- because fuck you.

local DAYZ = false
local MODERNRP = false

if (engine.ActiveGamemode() == "cityrp") then
	MODERNRP = true
end

if (engine.ActiveGamemode() == "dayz") then
	DAYZ = true
end

signal = signal or {}
signal.list = {
	{	
		name = "quickGiveMoney",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			if (!target or !target:IsPlayer()) then return end
			local char = target:getChar()
			if (!char) then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest(L"setAmount", L"setAmountDesc", "", function(text)
				if (text and text != "") then
					client:ConCommand("say /give ".. tonumber(text) or "")
				end
			end, function() end)
		end,
	},
	{
		name = "quickDropMoney",
		canDisplay = function(client, target)
			local char = client:getChar()
			if (!char) then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest(L"setAmount", L"setAmountDesc", "", function(text)
				if (!text) then return end
				client:ConCommand("say /dropmoney ".. tonumber(text or "") or "")
			end, function() end)
		end,
	},
	{
		name = "quickUseTie",
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
		name = "quickUseSpray",
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
		name = "quickSearchPlayer",
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
		name = "quickSetPassword",
		canDisplay = function(client, target)
			if (!IsValid(target)) then return end
			if (target:CPPIGetOwner() != client) then return end 
			if (target:GetClass() != "nut_keypad") then return end

			return true
		end,
		onSelect = function(client, target)
			Derma_StringRequest(L"setPassword", L"setPasswordDesc", "", function(text)
				client:ConCommand("say /password ".. text)
			end, function() end)
		end,
	},
}

		if (MODERNRP) then
			table.insert(signal.list, {
				name = "quickRefund",
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
				name = "quickBuyDoor",
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
				name = "quickSellDoor",
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
				name = "quickCreateLawboard",
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
				name = "quickSetPrice",
				canDisplay = function(client, target)
					if (!IsValid(target)) then return end
					if (target:CPPIGetOwner() != client) then return end 
					if (!target.vending) then return end

					return true
				end,
				onSelect = function(client, target)
					Derma_StringRequest(L"setAmount", L"setAmountDesc", "", function(text)
						client:ConCommand("say /setprice ".. tonumber(text) or "")
					end, function() end)
				end,
			})
			table.insert(signal.list, {
				name = "quickGiveLicense",
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
				name = "quickRevokeLicense",
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
			name = "quickUseDrink",
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
			name = "quickUseFood",
			canDisplay = function(client, target)
				local char = client:getChar()
				if (!char) then return end

				return true
			end,
			onSelect = function(client, target)
				client:ConCommand("say /fastfood")
			end,
		})
			table.insert(signal.list, {
				name = "quickUseHeal",
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
				name = "quickUseAmmo",
				canDisplay = function(client, target)
					local char = client:getChar()
					if (!char) then return end
					
					return true
				end,
				onSelect = function(client, target)
					client:ConCommand("say /fastammo")
				end,
			})
		end

if (CLIENT) then

	signal.queue = {}

		surface.CreateFont("SignalFont", {
			font = "Arial",
			extended = true,
			size = 25,
			weight = 800,
			shadow = true,
		})

		surface.CreateFont("SignalFontBlur", {
			font = "Arial",
			extended = true,
			size = 25,
			weight = 800,
			shadow = true,
			blursize = 4,
		})

	hook.Add("LoadFonts", "nutFontKekeSignalasdasdkek", function(font, genericFont)
		surface.CreateFont("SignalFont", {
			font = genericFont,
			extended = true,
			size = 25,
			weight = 800,
			shadow = true,
		})

		surface.CreateFont("SignalFontBlur", {
			font = genericFont,
			extended = true,
			size = 25,
			weight = 800,
			shadow = true,
			blursize = 4,
		})
	end)

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

			local center = L"quickCenter" -- Fast Command
			surface.SetTextColor(Color(255, 255, 255, signalalpha))
			surface.SetFont("SignalFontBlur")
			local tw, th = surface.GetTextSize(center)
			surface.SetTextPos(w/2 - tw/2, h/2 - th/2)
			surface.DrawText(center)

			surface.SetFont("SignalFont")
			local tw, th = surface.GetTextSize(center)
			surface.SetTextPos(w/2 - tw/2, h/2 - th/2)
			surface.DrawText(center)

			local text = L"quickHelp"
			surface.SetTextColor(Color(255, 255, 255, math.max(0, signalalpha - ((RealTime()*400) % 200))))
			surface.SetFont("SignalFont")
			local tw, th = surface.GetTextSize(text) -- "명령어를 사용하려면 마우스를 대고 'C'키를 떼면 됩니다"
			surface.SetTextPos(w/2 - tw/2, h - ScreenScale(25) - th)
			surface.DrawText(text)

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
				
				local name = L(v.name)

				surface.SetFont("SignalFont")
				local tw, th = surface.GetTextSize(name)
				surface.SetTextColor(Color(255, 255, 255, signalalpha))
				
				v.curpos[1] = Lerp(FrameTime()*8, v.curpos[1], w/2-tw/2+math.sin(rad*-k)*distance)
				v.curpos[2] = Lerp(FrameTime()*8, v.curpos[2], h/2-th/2+math.cos(rad*k)*distance)

				if (selected == idx and x ~= 0 and y ~= 0) then
					surface.SetTextColor(Color(255, 111, 111, signalalpha))
					surface.SetFont("SignalFontBlur")
					local tw, th = surface.GetTextSize(name)
					surface.SetTextPos(math.Round(v.curpos[1]), math.Round(v.curpos[2]))
					surface.DrawText(name)
				end

				surface.SetFont("SignalFont")
				local tw, th = surface.GetTextSize(name)
				surface.SetTextPos(math.Round(v.curpos[1]), math.Round(v.curpos[2]))
				surface.DrawText(name)

			end
		end
	end
	hook.Add("HUDPaint", "signal", signal.draw)
end

if (SERVER) then	
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
		chat.AddText(Color(255,150,230),L("clientPlay", hour)) -- You're playing for X hours.
	end

	timer.Create("TimeAfter",3600,0,TimeAfter)
end

end
timer.Simple(2, fuckyou)