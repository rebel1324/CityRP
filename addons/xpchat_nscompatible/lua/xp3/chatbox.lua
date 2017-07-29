local chatbox = {}

chatbox.settings = {
	--[[test = {
		["Wake me up"] = {ty = "Bool", get = function() return false end, set = print},
		["Wake ur mom up"] = {ty = "string", get = function() return "cock" end, set = print}
	}]]
}

hook.Add("LoadFonts", "nutFontXPChatbox", function(font, genericFont)
	surface.CreateFont("MalgunGothicEntry", {
		font = genericFont,
		size = 20,
		weight = 500,
		extended = true,	
	})
	surface.CreateFont("MalgunGothic", {
		font = genericFont,
		size = 13,
		weight = 500,
		extended = true,	
	})

	surface.CreateFont("TrackFont", {
		font = genericFont,
		size = 20,
		weight = 500,
		extended = true,	
	})
end)

local box_font = CreateClientConVar("xp_chat_box_font","MalgunGothic",true,false,"Changes the Fonts of the chatbox itself.")
cvars.AddChangeCallback("xp_chat_box_font",function(cv,_,new) chatbox.box_font = new end)
 chatbox.box_font = "MalgunGothic"
 
local feed_font = CreateClientConVar("xp_chat_feed_font","TrackFont",true,false,"Changes the Font of the text displayed inside the chatbox.")
cvars.AddChangeCallback("xp_chat_feed_font",function(cv,_,new) chatbox.feed_font = new end)

chatbox.accent_color = Color(255, 192, 203, 255)
chatbox.back_color   = Color(000, 000, 000, 200)
chatbox.input_color  = Color(000, 000, 000, 150)
chatbox.box_font     = box_font:GetString()
chatbox.feed_font    = feed_font:GetString()

local CONFIG_FILE = "xp_chat_config.lua"
do
	local config = file.Read(CONFIG_FILE, "DATA")

	if config and luadata then
		local data = luadata.Decode(config)

		if data then
			for k, v in next, data do
				chatbox[k] = v
			end
		end
	end
end

function chatbox.WriteConfig()
	if luadata then
		local data = {
			accent_color = chatbox.accent_color,
			back_color = chatbox.back_color,
			input_color = chatbox.input_color,
			box_font = chatbox.box_font,
			feed_font = chatbox.feed_font,
		}

		data = luadata.Encode(data)
		file.Write(CONFIG_FILE, data)
	end

	local x, y, w, h = chatbox.frame:GetBounds()
	chatbox.frame:SetCookie("x", x)
	chatbox.frame:SetCookie("y", y)
	chatbox.frame:SetCookie("w", w)
	chatbox.frame:SetCookie("h", h)
end

function chatbox.IsOpen()
	return IsValid(chatbox.frame) and chatbox.frame:IsVisible()
end

-- Link code is from qchat/EPOE.
local function CheckFor(tbl, a, b)
	local a_len = #a
	local res, endpos = true, 1

	while res and endpos < a_len do
		res, endpos = a:find(b, endpos)

		if res then
			tbl[#tbl + 1] = {res, endpos}
		end
	end
end

local function AppendTextLink(a, callback)
	local result = {}

	CheckFor(result, a, "https?://[^%s%\"]+")
	CheckFor(result, a, "ftp://[^%s%\"]+")
	CheckFor(result, a, "steam://[^%s%\"]+")

	if #result == 0 then return false end

	table.sort(result, function(b, c) return b[1] < c[1] end)

	-- Fix overlaps
	local _l, _r
	for k, tbl in ipairs(result) do
		local l = tbl[1]

		if not _l then
			_l, _r = tbl[1], tbl[2]
			continue
		end

		if l < _r then table.remove(result, k) end

		_l, _r = tbl[1], tbl[2]
	end

	local function TEX(str) callback(false, str) end
	local function LNK(str) callback(true, str) end

	local offset = 1
	local right

	for _, tbl in ipairs(result) do
		local l, r = tbl[1], tbl[2]
		local link = a:sub(l, r)
		local left = a:sub(offset, l - 1)
		right = a:sub(r + 1, -1)
		offset = r + 1

		TEX(left)
		LNK(link)
	end

	TEX(right)

	return true
end

local function quick_parse(txt)
	return markup_quickParse(txt, chatexp.LastPlayer)
end

function chatbox.ParseInto(feed, ...)
	local tbl = {...}

	feed:InsertColorChange(120, 219, 87, 255)

	if #tbl == 1 and isstring(tbl[1]) then
		feed:AppendText(quick_parse(tbl[1]))
		feed:AppendText("\n")

		return
	end

	for i, v in next, tbl do
		if IsColor(v) or istable(v) then
			feed:InsertColorChange(v.r, v.g, v.b, 255)
		elseif isentity(v) then
			if v:IsPlayer() then
				local col = GAMEMODE:GetTeamColor(v)
				feed:InsertColorChange(col.r, col.g, col.b, 255)

				feed:AppendText(quick_parse(v:Nick()))
			else
				local name = (v.Nick and v:Nick()) or v.PrintName or tostring(v)
				feed:AppendText(quick_parse(name))
			end
		elseif v ~= nil then
			local function linkAppend(islink, text)
				if islink then
					feed:InsertClickableTextStart(text)
						feed:AppendText(text)
					feed:InsertClickableTextEnd()
				return end

				feed:AppendText(text)
			end

			local res = AppendTextLink(tostring(v), linkAppend)

			if not res then
				feed:AppendText(quick_parse(tostring(v)))
			end
		end
	end

	feed:AppendText("\n")
end

local function tab_paint(w, h)
	-- Looks better without
end

local function input_type(enter, tab, all)
	return function(pan, key)
		local txt = pan:GetText():Trim()
		all(pan, txt)

		if key == KEY_ENTER then
			if txt ~= "" then
				pan:AddHistory(txt)
				pan:SetText("")

				pan.HistoryPos = 0
			end

			enter(pan, txt)
		end

		if key == KEY_TAB then
			tab(pan, txt)
		end

		if key == KEY_UP then
			pan.HistoryPos = pan.HistoryPos - 1
			pan:UpdateFromHistory()
		end

		if key == KEY_DOWN then
			pan.HistoryPos = pan.HistoryPos + 1
			pan:UpdateFromHistory()
		end
	end
end

local function paint_back(pan, w, h, a)
	surface.SetDrawColor(a and chatbox.input_color or chatbox.back_color)
	surface.DrawRect(0, 0, w, h)
end

local function input_paint(pan, w, h)
	paint_back(pan, w, h, true)

	pan:DrawTextEntryText(chatbox.accent_color, pan:GetHighlightColor(), chatbox.accent_color)
end

local function feed_layout(pan)
	pan:SetFontInternal(chatbox.feed_font)
end

function chatbox.GetModeString()
	local text = chatbox and chatbox.frame and chatbox.frame.chat and chatbox.frame.chat.input:GetValue()

	return (text:sub(1, 1) == "/" or text:sub(1, 1) == "!") and L"command" or L"chat"
end

function chatbox.BuildTabChat(self, a)
	self.chat = vgui.Create("DPanel", self.tabs)
		function self.chat:Paint(w, h) end
		self.chat:Dock(FILL)

		self.chat.text_feed = vgui.Create("RichText", self.chat)
			self.chat.text_feed:Dock(FILL)

			self.chat.text_feed.PerformLayout = feed_layout

		self.chat.input_base = vgui.Create("DPanel", self.chat)
			function self.chat.input_base:Paint(w, h) end
			self.chat.input_base:Dock(BOTTOM)

			self.chat.input = vgui.Create("DTextEntry", self.chat.input_base)
				self.chat.input:SetFont("MalgunGothicEntry")
				self.chat.input:Dock(FILL)

				self.chat.input:SetHistoryEnabled(true)
				self.chat.input.HistoryPos = 0

				self.chat.input.OnKeyCodeTyped = input_type(
				function(pan, txt)
					if txt ~= "" then
						local team = (chatexp and chatbox.mode == CHATMODE_TEAM) or (not chatexp and chatbox.mode == true)

						if chatexp and hook.Run("ChatShouldHandle", "chatexp", txt, chatbox.mode) ~= false then
							chatexp.Say(txt, chatbox.mode)
						elseif chitchat and chitchat.Say and hook.Run("ChatShouldHandle", "chitchat", txt, chatbox.mode and 2 or 1) ~= false then
							chitchat.Say(txt, team and 2 or 1)
						else
							LocalPlayer():ConCommand((team and "say_team \"" or "say \"") .. txt .. "\"")
						end
					end

					chatbox.Close()
				end,
				function(pan, txt)
					local tab = hook.Run("OnChatTab", txt)

					if tab and isstring(tab) and tab ~= txt then
						pan:SetText(tab)
					end

					timer.Simple(0, function() pan:RequestFocus() pan:SetCaretPos(pan:GetText():len()) end)
				end,
				function(pan, txt)
					hook.Run("ChatTextChanged", txt)
				end)

				self.chat.input.Paint = input_paint

				function self.chat.input:OnChange()
					hook.Run("ChatTextChanged", self:GetText() or "")
				end

				function self.chat.input.Think(pan) pan:SetFont(chatbox.box_font) end

			self.chat.mode = vgui.Create("DPanel", self.chat.input_base)
				self.chat.mode:Dock(LEFT)
				self.chat.mode:SetWide(48)

				function self.chat.mode.Paint(pan, w, h)
					paint_back(pan, w, h, true)

					local text = chatbox.GetModeString()
					draw.SimpleText(text, chatbox.box_font, w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end

		a = self.tabs:AddSheet(L"chat", self.chat)
		a.Tab.Paint = tab_paint
		function a.Tab.Think(pan) pan:SetFont(chatbox.box_font) end
end

function chatbox.GetDMFeed(ply)
	if not chatexp or not IsValid(ply) then return end
	local sid = ply:SteamID()

	local self = chatbox.frame.direct_messages
	if not IsValid(self.tabs[sid]) then return end

	return self.tabs[sid].feed
end

local cache = {}
local function get_player(sid)
	if IsValid(cache[sid]) then return cache[sid] end

	for k, v in next, player.GetAll() do
		if v:SteamID() == sid then cache[sid] = v return v end
	end

	return NULL
end

function chatbox.AddDMTab(ply)
	if not chatexp or not IsValid(ply) then return end
	local sid = ply:SteamID()

	local self = chatbox.frame.direct_messages
	if IsValid(self.tabs[sid]) then return end

	self.tabs[sid] = vgui.Create("DPanel", self)
	local tab = self.tabs[sid]

	function tab:Paint(w, h) end
	tab:Dock(FILL)

	tab.feed = vgui.Create("RichText", tab)
		tab.feed:Dock(FILL)

		tab.feed.PerformLayout = feed_layout

	tab.input_base = vgui.Create("DPanel", tab)
		function tab.input_base:Paint(w, h) end
		tab.input_base:Dock(BOTTOM)

		tab.input = vgui.Create("DTextEntry", tab.input_base)
			tab.input:SetFont("MalgunGothic")
			tab.input:Dock(FILL)

			tab.input:SetHistoryEnabled(true)
			tab.input.HistoryPos = 0

			tab.input.OnKeyCodeTyped = input_type(
			function(pan, txt)
				if txt ~= "" then
					if IsValid(get_player(sid)) then chatexp.DirectMessage(txt, get_player(sid)) else chatbox.ParseInto(tab.feed, "User is offline!") end
				else
					chatbox.Close()
				end
			end,
			function(pan, txt)
			end,
			function(pan, txt)
			end)

			tab.input.Paint = input_paint

			function tab.input.Think(pan) pan:SetFont(chatbox.box_font) end

		tab.mode = vgui.Create("DPanel", tab.input_base)
			tab.mode:Dock(LEFT)
			tab.mode:SetWide(48)

			function tab.mode.Paint(pan, w, h)
				paint_back(pan, w, h, true)

				local text = "Direct"
				draw.SimpleText(text, chatbox.box_font, w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end

	local a = self:AddSheet(ply:Nick(), tab)
	a.Tab.Paint = tab_paint
	function a.Tab.Think(pan)
		if IsValid(get_player(sid)) then pan:SetText(get_player(sid):Nick()) end
		pan:SetFont(chatbox.box_font)
	end
end

function chatbox.BuildTabDMs(self, a)
	if not chatexp then return end
	self.direct_messages = vgui.Create("DPropertySheet", self.tabs)
		function self.direct_messages:Paint(w, h) end
		self.direct_messages:Dock(FILL)

		self.direct_messages.tabs = {}

		a = self.tabs:AddSheet("DMs", self.direct_messages)
		a.Tab.Paint = tab_paint
		function a.Tab.Think(pan) pan:SetFont(chatbox.box_font) end
end

local function build_settings_from_table(self, tbl)
	for cat, i in next, tbl do
		local c_pan = vgui.Create("DLabel", self)
			--self:AddItem(c_pan)

			c_pan:SetText("Cuntagory:" .. cat)

		for item, data in next, i do
			local pan = vgui.Create("Panel", self)
			pan:Dock(TOP)
			pan:DockMargin(0, 8, 0, 8)

			local tag = vgui.Create("DLabel", pan)
			tag:Dock(LEFT)

			tag:SetText(item)

			if data.ty == "Number" then
				local slide = vgui.Create("DNumberScratch", pan)

				slide:SetValue(data.get())
				slide:SetMin(data.min)
				slide:SetMax(data.max)

				slide.OnValueChanged = data.set
			elseif data.ty == "Color" then
				local color = vgui.Create("DColorMixer", pan)

				color.ValueChanged = data.set
			elseif data.ty == "String" then
				local text = vgui.Create("DTextEntry", pan)
				text:SetFont("MalgunGothic")
				text:Dock(LEFT)

				text.OnEnter = function() data.set(text:GetValue()) end
			elseif data.ty == "Bool" then
				local check = vgui.Create("DCheckBox", pan)
				check:Dock(LEFT)

				check:SetChecked(data.get())

				check.OnChange = data.set
			end
		end
	end
end

function chatbox.BuildTabSettings(self, a)
	self.settings = vgui.Create("DScrollPanel", self.tabs)
		function self.settings:Paint(w, h) end
		self.settings:Dock(FILL)

		build_settings_from_table(self.settings, chatbox.settings)

		a = self.tabs:AddSheet("Settings", self.settings)
		a.Tab.Paint = tab_paint
		function a.Tab.Think(pan) pan:SetFont(chatbox.box_font) end
end

function chatbox.Build()
	if IsValid(chatbox.frame) then return end

	chatbox.frame = vgui.Create("DFrame")
	local self = chatbox.frame
		self:SetCookieName("qchat") -- Backwards/alt compatability

		local x = self:GetCookie("x", 20)
		local y = self:GetCookie("y", ScrH() - math.min(650, ScrH() - 350))
		local w = self:GetCookie("w", 600)
		local h = self:GetCookie("h", 350)

		self:SetPos(x, y)
		self:SetSize(w, h)

		self:SetTitle(GetHostName())
		self:SetIcon("icon16/application_xp_terminal.png")

		self:SetSizable(true)
		self:SetMinHeight(145)
		self:SetMinWidth(275)

		self:ShowCloseButton(false)

		function self.lblTitle.Think(pan) pan:SetFont(chatbox.box_font) end

		function self:PerformLayout()
			local titlePush = 0

			if IsValid(self.imgIcon) then
				self.imgIcon:SetPos(5, 5)
				self.imgIcon:SetSize(16, 16)
				titlePush = 18
			end

			self.btnClose:SetPos(0,0)
			self.btnClose:SetSize(0,0)

			self.btnMaxim:SetPos(0,0)
			self.btnMaxim:SetSize(0,0)

			self.btnMinim:SetPos(self:GetWide() - 31 - 4, 4)
			self.btnMinim:SetSize(32, 18)

			self.lblTitle:SetPos(10 + titlePush, 3)
			self.lblTitle:SetSize(self:GetWide() - 25 - titlePush, 20)
			self.lblTitle:SetColor(chatbox.accent_color)

			if self.direct_messages then
				self.direct_messages.new:SetPos(self:GetWide() - self.direct_messages.new:GetWide() - 8, 30)
			end
		end

		function self:Paint(w, h)
			surface.SetDrawColor(chatbox.back_color)
			surface.DrawRect(0, 0, w, h)
		end

	self.tabs = vgui.Create("DPropertySheet", self)
		function self.tabs:Paint(w, h) end
		self.tabs:Dock(FILL)

		local a = {}

		chatbox.BuildTabChat(self, a)
		--chatbox.BuildTabDMs(self, a)
		--chatbox.BuildTabSettings(self, a)

		chatbox.Close(true)
end

function chatbox.GetChatFeed()
	return chatbox.frame.chat.text_feed
end

function chatbox.GetChatInput()
	return chatbox.frame.chat.input
end

function chatbox.GiveChatFocus()
	if not chatbox.IsOpen() then return end

	chatbox.frame.tabs:SwitchToName(L"chat")
	chatbox.frame.chat.input:RequestFocus()
end

function chatbox.GiveDMFocus(ply)
	if not chatbox.IsOpen() or not chatexp or not IsValid(ply) then return end

	chatbox.AddDMTab(ply)

	chatbox.frame.tabs:SwitchToName("DMs")
	chatbox.frame.direct_messages:SwitchToName(ply:Nick())
	chatbox.frame.direct_messages.tabs[ply:SteamID()].input:RequestFocus()
end

function chatbox.Close(no_hook)
	chatbox.WriteConfig()
	chatbox.GetChatInput():SetText("")
	chatbox.frame:SetVisible(false)

	if IsValid(chatbox.frame.dmSelector) then
		chatbox.frame.dmSelector:Remove()
	end

	if not no_hook then hook.Run("FinishChat") end
end

function chatbox.Open(t)
	chatbox.Build()

	if chatexp then
		chatbox.mode = t and CHATMODE_TEAM or CHATMODE_DEFAULT
	else
		chatbox.mode = t
	end

	chatbox.frame:SetVisible(true)
	chatbox.frame:MakePopup()

	chatbox.GiveChatFocus()

	hook.Run("StartChat", t)
	hook.Run("ChatTextChanged", "")
end

return chatbox
