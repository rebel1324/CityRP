
if (CLIENT) then
	ac = {}
	ac.text = ""
	ac.last_search = "+"
	ac.arguments = {}
	ac.searchResult = {}
	ac.display = {}
	ac.chatting = false

	local chatsounds_autocomplete = CreateClientConVar("chatsounds_autocomplete", "1", true)

	function ac.visible()
		return ac.chatting and ac.last_search ~= "" and chatsounds_autocomplete:GetBool()
	end

	function ac.clean(text)
		text = text:gsub("æ", "ae"):gsub("ø", "oe"):gsub("å", "aa")
		return text:lower():gsub("[^%w ]+", ""):gsub("  +", " "):Trim()
	end
	
	local COLOR_FADED = Color(200, 200, 200, 100)
	local COLOR_ACTIVE = color_white
	local COLOR_WRONG = Color(255, 100, 80)
	
	local disComm = 5
	local fadeComm = 5
	function ac.render(x, y, w, h)
		local color = nut.config.get("color")
		local negAlpha = 0
		for k, v in ipairs(ac.display) do
			if (k >= disComm + disComm) then continue end
			
			negAlpha = math.max(k-disComm, 0)/fadeComm * 255
			local tx, ty = nut.util.drawText(v[1].."  ", x, y + (k - 1) * 20, ColorAlpha(color, 255 - (negAlpha)))
			
			if (v[2]) then
				local atto = 0
				for a, b in ipairs(v[2]) do
					local tx, ty = nut.util.drawText(b.."  ", x + tx + atto * (a-1) + 2 * (a-1), y, ColorAlpha(COLOR_FADED, 255 - (negAlpha)))
					atto = atto + tx
				end
			end
		end
	end

	local bad = {
		["!"] = true,
		["/"] = true,
		["\\"] = true,
		["."] = true,
		["-"] = true,
	}
	function ac.isbad(text)
		return bad[(text or ""):sub(1,1)]
	end

	hook.Add("StartChat", "chatsounds_autocomplete", function()
		--if not chatsounds_autocomplete:GetBool() then return end
		ac.chatting = true
		ac.randommode = true
	end)

	hook.Add("FinishChat", "chatsounds_autocomplete", function()
		ac.chatting = false
		ac.display = {}
	end)

	hook.Add("ChatTextChanged", "chatsounds_autocomplete", function(tt, lua_tab_change)
		local text = tt
		
		if (text:sub(1, 1) == "/") then
			ac.display = {}
			ac.arguments = nut.command.extractArgs(text:sub(2)) or {}
			local arguments = ac.arguments
			local command = string.PatternSafe(arguments[1] or ""):lower()
			local i = 0
			
			if (text:len() >= 1) then
				for k, v in SortedPairs(nut.command.list) do
					local k2 = "/"..k
					
					if (k2:match(command)) then
						local aaa = {}
						aaa[1] = k2
						
						if (k == command and v.syntax) then
							ac.display = {}
							local aaoa = {}
							local i2 = 0
							for argument in v.syntax:gmatch("([%[<][%w_]+[%s][%w_]+[%]>])") do
								i2 = i2 + 1
								
								table.insert(aaoa, argument)
							end
							
							if (#aaoa > 0) then
								aaa[2] = aaoa
							end
						end
						
						table.insert(ac.display, aaa)	
						
						i = i + 1
					end
				end
			end
		elseif (text:sub(1, 1) == "!") then
			ac.display = {}
			ac.arguments = nut.command.extractArgs(text:sub(2)) or {}
			local arguments = ac.arguments
			local command = string.PatternSafe(arguments[1] or ""):lower()
			local i = 0
			
			if (ulx) then
				local aabb =  ulx.cmdsByCategory
				for category, cmds in SortedPairs(aabb) do
					for k, args in pairs(cmds) do
						local cmd = args.cmd:Replace("ulx ", "")
						local k2 = "!"..cmd
						
						if (k2:match(command)) then
							local aaa = {}
							aaa[1] = k2
							if (cmd == command and args.helpStr) then
								ac.display = {}
								local aaoa = {}
								local i2 = 0
								table.insert(aaoa, args.helpStr)
								
								if (#aaoa > 0) then
									aaa[2] = aaoa
								end
							end
							
							table.insert(ac.display, aaa)	
							
							i = i + 1
						end
					end
				end
			elseif (aowl) then
				/*
					aowl.cmds[cmd] = {callback = callback, group = group or "players", cmd = cmd, hidechat = hidechat }
				*/

				local aabb =  aowl.cmds
				for cmd, data in SortedPairs(aabb) do
					local k2 = "!"..cmd
					
					if (k2:match(command)) then
						local aaa = {}
						aaa[1] = k2
						
						table.insert(ac.display, aaa)	
						
						i = i + 1
					end
				end
			end
		end
	end)

	hook.Add("PostRenderVGUI", "chatsounds_autocomplete", function()
		if ac.visible() then
			local x, y, w, h

			if chatgui then
				x, y = chatgui:GetPos()
				w, h = chatgui:GetSize()
				y, h = y + h, surface.ScreenHeight() - y - h
			else
				x, y = chat:GetChatBoxPos()
				w, h = 480, 180
				y, h = 0, y
			end

			ac.render(x, y, w, h)
		end
	end)

	hook.Add("ChatsoundsUpdated", "chatsounds_autocomplete", ac.update)
end