AddCSLuaFile()

local col = Color(200, 0, 255, 255)
local Msg = function(...) MsgC(col, ...)  end

chatexp = chatexp or {}
chatexp.NetTag = "chatexp" -- Do not change this unless you experience some very strange issues
chatexp.AbuseMode = "Kick" -- Kick or EarRape, this is what happens to people who try and epxloit the system

-- This is basicly chitchat3
-- Max message length is now 0x80000000 (10^31)
-- Filters are fixed, better mode handling.

local color_red = Color(225, 0, 0, 255)
local color_greentext = Color(0, 240, 0, 255)
local color_green = Color(0, 200, 0, 255)
local color_hint = Color(240, 220, 180, 255)

function net.HasOverflowed()
    return (net.BytesWritten() or 0) >= 65536
end

chatexp.Modes = {
	{
			Name = "Default",
			Filter = function(send, ply)
				return true
			end,
			Handle = function(tbl, ply, msg, dead, mode_data)
				if dead then
					tbl[#tbl + 1] = color_red
					tbl[#tbl + 1] = "*DEAD* "
				end

				tbl[#tbl + 1] = ply -- ChatHUD parses this automaticly
				tbl[#tbl + 1] = color_white
				tbl[#tbl + 1] = ": "
				tbl[#tbl + 1] = color_white

				if msg:StartWith(">") and #msg > 1 then
					tbl[#tbl + 1] = color_greentext
				end

				tbl[#tbl + 1] = msg
			end,
	},
	{
			Name = "Team",
			Filter = function(send, ply)
				return send:Team() == ply:Team()
			end,
			Handle = function(tbl, ply, msg, dead, mode_data)
				if dead then
					tbl[#tbl + 1] = color_red
					tbl[#tbl + 1] = "*DEAD* "
				end

				tbl[#tbl + 1] = color_green
				tbl[#tbl + 1] = "(TEAM) "

				tbl[#tbl + 1] = ply -- ChatHUD parses this automaticly
				tbl[#tbl + 1] = color_white
				tbl[#tbl + 1] = ": "
				tbl[#tbl + 1] = color_white

				if msg:StartWith(">") and #msg > 1 then
					tbl[#tbl + 1] = color_greentext
				end

				tbl[#tbl + 1] = msg
			end,
	},
	{
			Name = "DM",
			-- No Filter.
			Handle = function(tbl, ply, msg, dead, mode_data)
				if ply == LocalPlayer() then
					tbl[#tbl + 1] = color_hint
					tbl[#tbl + 1] = "You"
					tbl[#tbl + 1] = color_white
					tbl[#tbl + 1] = " -> "
					tbl[#tbl + 1] = Player(mode_data)

					hook.Run("SendDM", Player(mode_data), msg)
				else
					tbl[#tbl + 1] = ply
					tbl[#tbl + 1] = color_white
					tbl[#tbl + 1] = " -> "
					tbl[#tbl + 1] = color_hint
					tbl[#tbl + 1] = "You"

					hook.Run("ReceiveDM", ply, msg)
				end

				tbl[#tbl + 1] = color_white
				tbl[#tbl + 1] = ": "

				tbl[#tbl + 1] = color_white
				tbl[#tbl + 1] = msg
			end,
	},
}

for k, v in next, chatexp.Modes do
	_G["CHATMODE_"..v.Name:upper()] = k
end

if CLIENT then

	function chatexp.Say(msg, mode, mode_data)
		local cdata = util.Compress(msg)

		local suc, err = pcall(function()
		net.Start(chatexp.NetTag)
			net.WriteUInt(#cdata, 16)
			net.WriteData(cdata, #cdata)

			net.WriteUInt(mode, 8)
			net.WriteUInt(mode_data or 0, 16)
		net.SendToServer()
		end)

		if not suc then
			Msg"CEXP " print("Not installed correctly!\n" .. err)

			if mode ~= CHATMODE_DM then
				LocalPlayer():ConCommand((mode == CHATMODE_TEAM and "say_team \"" or "say \"") .. msg .. "\"")
			end -- fallback
		end
	end

	function chatexp.SayChannel(msg, channel)
		chatexp.Say(msg, CHATMODE_CHANNEL, channel)
	end

	function chatexp.DirectMessage(msg, ply)
		chatexp.Say(msg, CHATMODE_DM, ply:UserID())
	end

	net.Receive(chatexp.NetTag, function()
		local ply 	= net.ReadEntity()

		local len 	= net.ReadUInt(16)
		local data 	= net.ReadData(len)

		local mode 	= net.ReadUInt(8)
		local mode_data = net.ReadUInt(16)

		data = util.Decompress(data)

		if not data then
			Msg"CEXP " print"Failed to decompress message."
			return
		end

		local dead = ply:IsValid() and ply:IsPlayer() and not ply:Alive()
		hook.Run("OnPlayerChat", ply, data, mode, dead, mode_data)
	end)

else -- CLIENT

	util.AddNetworkString(chatexp.NetTag)

	-- function chatexp.FuckOff(ply)
	-- 	local m = chatexp.AbuseMode

	-- 	if m == "EarRape" then
	-- 		ply:SendLua[[local d=vgui.Create'DHTML'd:OpenURL'https://www.youtube.com/watch?v=WevymH75pW8'chat.AddText'dont fuck with chat']]
	-- 	elseif m == "Kick" then
	-- 		ply:Kick("Please refrain from touching *bzzzt*")
	-- 	end
	-- end

	function chatexp.SayAs(ply, data, mode, mode_data)
		if #data > 1024 then
			-- chatexp.FuckOff(ply)
			Msg"CEXP " print"too much Data!"
			return
		end

		local ret = hook.Run("PlayerSay", ply, data, mode)

		if ret == "" or ret == false then return end
		if isstring(ret) then data = ret end

		local msgmode = chatexp.Modes[mode]

		local filter = {}
		if mode == CHATMODE_DM then
			filter = {Player(mode_data)}
		elseif msgmode.Filter then
			for k, v in next,player.GetHumans() do
				if msgmode.Filter(ply, v) ~= false then filter[#filter+1] = v end
			end
		else
			filter = player.GetHumans()
		end

		if #filter == 0 then return end
		if not table.HasValue(filter, ply) then filter[#filter+1] = ply end

		local cdata = util.Compress(data)
		if not cdata then
			Msg"CEXP " print"Failed to re-compress message."
			return
		end

		net.Start(chatexp.NetTag)
			net.WriteEntity(ply)

			net.WriteUInt(#cdata, 16)
			net.WriteData(cdata, #cdata)

			net.WriteUInt(mode, 8)
			net.WriteUInt(mode_data, 16)

			if net.HasOverflowed() then
				Msg"CEXP " print("Net overflow -> '" .. data .. "'")
				return
			end
		net.Send(filter)
	end

	net.Receive(chatexp.NetTag, function(_, ply)
		local len		= net.ReadUInt(16)
		local cdata	= net.ReadData(len)

		local mode	= net.ReadUInt(8)
		local mode_data = net.ReadUInt(16)

		local data = util.Decompress(cdata)

		if not data then
			Msg"CEXP " print"Failed to decompress message."
			return
		end

		chatexp.SayAs(ply, data, mode, mode_data)
	end)

end -- SERVER
