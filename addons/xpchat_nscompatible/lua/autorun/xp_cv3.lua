local function includec(...) AddCSLuaFile(...) return include(...) end
class	= includec"xp3/class.lua"
luadata	= includec"xp3/luadata.lua"

function _f(d)
	return isfunction(d) and d() or d
end

function number(d, min, max, default)
	local m = tonumber(_f(d)) or tonumber(default) or 0
	if tonumber(min) then
		m = math.max(min, m)
	end
	if tonumber(max) then
		m = math.min(max, m)
	end
	return m
end

function utf_totable(str)
	local tbl = {}
	for uchar in string.gmatch(str, "([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
	end
	return tbl
end

includec"xp3/chatexp.lua"

local convar_custom_handle = CreateConVar("xp_chat_force_source_handle", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE})
local convar_limited_tags = CreateConVar("xp_chat_limited_tags", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

hook.Add("ChatShouldHandle", "chatexp.compat", function(handler, msg, mode)
	if SCHEMA then return false end
	if convar_custom_handle:GetBool() then return false end
end)

if SERVER then
	AddCSLuaFile"xp3/markup.lua"
	AddCSLuaFile"xp3/chathud.lua"
	AddCSLuaFile"xp3/chatbox.lua"
return end

hook.Add("CanPlayerUseTag", "chathud.restrict", function(ply, tag, args)
	if tag:StartWith("dev_") and not ply:IsAdmin() then return false end
	if convar_limited_tags:GetBool() and tag ~= "color" then return ply:IsAdmin() end
end)

local function do_hook()
	local gm = GM or GAMEMODE
	if not gm then return end

	chatexp._oldGamemodeHook = chatexp._oldGamemodeHook or gm.OnPlayerChat
	function gm:OnPlayerChat(ply, msg, mode, dead, mode_data)
		chatexp.LastPlayer = ply

		if hook.Run("ChatShouldHandle", "chatexp", msg, mode) == false then
			return chatexp._oldGamemodeHook(self, ply, msg, mode, dead)
		end

		if mode == true  then mode = CHATMODE_TEAM end
		if mode == false then mode = CHATMODE_DEFAULT end

		local msgmode = chatexp.Modes[mode]
		local tbl = {}

		local ret
		if msgmode.Handle then
			ret = msgmode.Handle(tbl, ply, msg, dead, mode_data)
		else -- Some modes may just be a filter
			ret = chatexp.Modes[CHATMODE_DEFAULT].Handle(tbl, ply, msg, dead, mode_data)
		end

		if ret == false then return true end

		chat.AddText(unpack(tbl))
		return true
	end
end

do_hook()
hook.Add("InitPostEntity", "xp.do_hook", do_hook)


if chatbox and IsValid(chatbox.frame) then chatbox.frame:Close() end

include"xp3/markup.lua"
chathud	= include"xp3/chathud.lua"

do -- chathud
	hook.Add("HUDPaint", "chathud.draw", function()
		chathud:Draw()
	end)

	hook.Add("HUDShouldDraw", "chathud.disable", function(ch)
		if ch == "CHudChat" then return false end
	end)

	hook.Add("Think", "chathud", function()
		chathud:Think()
	end)

	hook.Add("OnPlayerChat", "chathud.tagpanic", function(_,txt)
		if txt:lower():Trim() == "sh" then chathud:TagPanic() end
	end)
end

chatbox	= include"xp3/chatbox.lua"
chatgui = setmetatable({}, {__index = chatbox})

do -- chatbox
	hook.Add("PreRender", "chatbox.close", function()
		if (gui.IsGameUIVisible() or input.IsKeyDown(KEY_ESCAPE)) and chatbox.IsOpen() then
			if input.IsKeyDown(KEY_ESCAPE) then
				gui.HideGameUI()
			end

			chatbox.Close()
		end
	end)

	hook.Add("SendDM", "chatbox.dm_send", function(ply, text)
		if not IsValid(chatbox.frame) then chatbox.Build() end

		chatbox.AddDMTab(ply)
		chatbox.ParseInto(chatbox.GetDMFeed(ply), LocalPlayer(), color_white, ": ", text)
	end)

	hook.Add("ReceiveDM", "chatbox.dm_receive", function(ply, text)
		if not IsValid(chatbox.frame) then chatbox.Build() end

		chatbox.AddDMTab(ply)
		chatbox.ParseInto(chatbox.GetDMFeed(ply), ply, color_white, ": ", text)
	end)

	hook.Add("PlayerBindPress", "chatbox.bind", function(ply, bind)
		if not IsValid(chatbox.frame) then chatbox.Build() end

		local team_chat = false

		if bind == "messagemode2" then
			team_chat = true
		elseif bind ~= "messagemode" then return end

		chatbox.Open(team_chat)
		return true
	end)
end

chat.old_text = chat.old_text or chat.AddText
function chat.AddText(...)
	if not IsValid(chatbox.frame) then chatbox.Build() end

	chatbox.ParseInto(chatbox.GetChatFeed(), ...)
	chat.old_text(...)

	chathud:AddText(...)

	chat.PlaySound()
end

local green = Color(120, 219, 87)

hook.Add("ChatText", "xp.receive", function(idx, name, text, type)
	if not IsValid(chatbox.frame) then chatbox.Build() end

	if type == "chat" then
		chatbox.ParseInto(chatbox.GetChatFeed(), green, name, color_white, ": " .. text)
		chathud:AddText(green, name, color_white, ": " .. text)
	return end

	if type == "darkrp" then return end -- Compat for some weird stuff with darkrp

	chatbox.ParseInto(chatbox.GetChatFeed(), green, text)
	chathud:AddText(green, text)
end)

-- Start compatability for addons

chat.old_pos = chat.old_pos or chat.GetChatBoxPos
function chat.GetChatBoxPos()
	if not IsValid(chatbox.frame) then chatbox.Build() end

	return chatbox.frame:GetPos()
end

chat.old_size = chat.old_size or chat.GetChatBoxSize
function chat.GetChatBoxSize()
	if not IsValid(chatbox.frame) then chatbox.Build() end

	return chatbox.frame:GetSize()
end

chat.old_open = chat.old_open or chat.Open
function chat.Open(mode)
	chatbox.Open(mode == 1)
end

chat.old_close = chat.old_close or chat.Close
function chat.Close()
	chatbox.Close()
end

function chatbox.GetPos()
	return chat.GetChatBoxPos()
end

function chatbox.GetSize()
	return chat.GetChatBoxSize()
end
