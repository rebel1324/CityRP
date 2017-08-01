function SCHEMA:CanCreateCharInfo()
	return {
		faction = true,
	}
end

hook.Add("BuildHelpMenu", "nutBasicHelp", function(tabs)
	tabs["commands"] = function(node)
		local body = ""

		for k, v in SortedPairs(nut.command.list) do
			local allowed = false

			if (v.adminOnly and !LocalPlayer():IsAdmin()or v.superAdminOnly and !LocalPlayer():IsSuperAdmin()) then
				continue
			end

			if (v.group) then
				if (type(v.group) == "table") then
					for k, v in pairs(v.group) do
						if (LocalPlayer():IsUserGroup(v)) then
							allowed = true

							break
						end
					end
				elseif (LocalPlayer():IsUserGroup(v.group)) then
					return true
				end
			else
				allowed = true
			end

			if (allowed) then
				body = body.."<h2>/"..k.."</h2><strong>Syntax:</strong> <em>"..v.syntax.."</em><br /><br />"
			end
		end

		return body
	end

	tabs["plugins"] = function(node)
		local body = ""

		for k, v in SortedPairsByMemberValue(nut.plugin.list, "name") do
			body = (body..[[
				<p>
					<span style="font-size: 22;"><b>%s</b><br /></span>
					<span style="font-size: smaller;">
					<b>%s</b>: %s<br />
					<b>%s</b>: %s
			]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", L"author", v.author)

			if (v.version) then
				body = body.."<br /><b>"..L"version".."</b>: "..v.version
			end

			body = body.."</span></p>"
		end

		return body
	end
end)

--[[This hook adds up some new stuffs in F1 Menu.
function SCHEMA:BuildHelpMenu(tabs)
	tabs["homepage"] = "http://183.106.89.97:8002/indexutil.html"
	tabs["motd"] = "http://183.106.89.97:8002/motd.html"
	tabs["updated"] = "http://183.106.89.97:8002/update.html"
	tabs["mod"] = function(node)
		local body = ""

		for title, text in SortedPairs(self.helps) do
			body = body.."<h1>"..title.."</h1><b>"..text.."</b><br /><br />"
		end

		return body
	end
end--]]

-- This hook loads the fonts
function SCHEMA:LoadFonts(font)
	font = "Consolas"
	surface.CreateFont("nutATMTitleFont", {
		font = font,
		extended = true,
		size = 72,
		weight = 1000
	})
	
	surface.CreateFont("nutATMFont", {
		font = font,
		extended = true,
		size = 36,
		weight = 1000
	})

	surface.CreateFont("nutATMFontBlur", {
		font = font,
		extended = true,
		size = 36,
		blursize = 6,
		weight = 1000
	})
end

-- This hook replaces the bar's look.
BAR_HEIGHT = 15
local gradient = nut.util.getMaterial("vgui/gradient-d")
function nut.bar.draw(x, y, w, h, value, color, barInfo)
	nut.util.drawBlurAt(x, y, w, h)

	surface.SetDrawColor(255, 255, 255, 15)
	surface.DrawRect(x, y, w, h)
	surface.DrawOutlinedRect(x, y, w, h)

	local bw = w
	x, y, w, h = x + 2, y + 2, (w - 4) * math.min(value, 1), h - 4

	surface.SetDrawColor(color.r, color.g, color.b, 250)
	surface.DrawRect(x, y, w, h)

	surface.SetDrawColor(0, 0, 0, 150)
	surface.SetMaterial(gradient)
	surface.DrawTexturedRect(x, y, w, h)

	nut.util.drawText(L(barInfo.identifier or "noname"), x + bw/2, y + h/2, ColorAlpha(color_white, color.a), 1, 1, nil, color.a)
end	

function SCHEMA:ShouldDrawCrosshair()
	local client = LocalPlayer()
	local weapon = client:GetActiveWeapon()

	if (weapon and weapon:IsValid()) then
		local class = weapon:GetClass()
		
		if (class:find("cw_") or class:find("wf_")) then
			return false
		end
	end
end

function nut.bar.drawAll()
	nut.bar.drawAction()
end

local jailTimer = CurTime()
local jailTime = 0

local function addJailTimer(time)
	jailTime = time
	jailTimer = CurTime() + jailTime
end

netstream.Hook("nutJailTimer", function(time)
	time = time or 0
	
	addJailTimer(time)
end)

local gap = 4
local perc = 0
function SCHEMA:drawJailed(w, h)
	if (jailTimer > CurTime()) then
		local bw, bh = w/3, 20
		local bx, by = w/2 - bw/2, h/3
		perc = (jailTimer - CurTime()) / jailTime

		surface.SetDrawColor(255, 255, 255, 15)
		surface.DrawRect(bx, by, bw, bh)
		surface.DrawOutlinedRect(bx, by, bw, bh)

		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawRect(bx + gap, by + gap, (bw - gap*2)*perc, bh - gap*2)

		draw.SimpleText(L("arrested"), "ChatFont", bx + 2, by - bh - 5, color_white, 3, 2)
	end
end

local font = "Myriad Pro"
surface.CreateFont("nutGarbageFontSmall", {
	font = font,
	extended = true,
	size = ScreenScale(15),
	weight = 500
})

surface.CreateFont("nutGarbageFontIcon", {
	font = "fontello",
	extended = true,
	size = ScreenScale(40),
	weight = 500
})

local cir = {}
local cir2= setmetatable({},{__index=function(self,key)
	local t = {}
	self[key]=t
	return t
end})

local function drawCircle( x, y, radius, seg,angle,offset )
	for i = 1, seg+1 do
		cir[i] = cir2[i]
	end

	for i=#cir,seg+2,-1 do
		cir[i]=nil
	end
	
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * angle + offset )
		local sa = math.sin( a )
		local ca = math.cos( a )
		local t = cir[i+1]
		t.x = x + sa * radius
		t.y = y + ca * radius
		t.u = sa * 0.5 + 0.5
		t.v = ca * 0.5 + 0.5
	end
	
	surface.DrawPoly( cir )
end

local dispLerp = 0
local currentStat = 0
local displayGo = false
local size = 30

local oldTime = RealTime()
local curTime = 0
local curScrap = 0
local pokeGo = 0
local remember = 0

function SCHEMA:drawHobo(w, h)
	local client = LocalPlayer()
	local w, h = ScrW(), ScrH()
	local scraps = client:getNetVar("garbage", 0)
	local char = client:getChar()

	if (!char) then
		displayGo = false
		dispLerp = 0

		return
	end

	local class = char:getClass()
	if (class != CLASS_HOBO) then
		displayGo = false
		dispLerp = 0

		return
	end

	if (remember != scraps) then
		displayGo = true
	end

	curTime = RealTime() - oldTime
	oldTime = RealTime()

	if (displayGo) then
		dispLerp = Lerp(curTime*5, dispLerp, 1 )
	else
		dispLerp = Lerp(curTime*5, dispLerp, 0 )
	end

	local minus = ScreenScale(size)*1.3
	local dx, dy = w/2, h + minus
	dy = h - h/4*dispLerp + minus - minus * dispLerp

	if (dispLerp > 0.99) then
		curScrap = Lerp(curTime*5, curScrap, scraps )

		if (scraps == math.Round(curScrap) and pokeGo < CurTime()) then
			remember = scraps

			displayGo = false
		end
	else
		pokeGo = CurTime() + 3
	end

	surface.SetDrawColor(0, 0, 0, 200)
	drawCircle(dx, dy, ScreenScale(size), 25, -360, 0)

	local tx, ty = nut.util.drawText("d", dx, dy, nil, 1, 1, "nutGarbageFontIcon")
	nut.util.drawText(math.Round(curScrap), dx, dy + ty, nil, 1, 1, "nutGarbageFontSmall")
end

function SCHEMA:drawLockdown(w, h)
	if (GetGlobalBool("lockdown", false)) then
		nut.util.drawText(L("lockdownOngoing"), w/2, 50, nil, 1, 1, "nutMediumFont")
	end
end

function SCHEMA:HUDPaint()
	local w, h = ScrW(), ScrH()

	self:drawJailed(w, h)
	self:drawHobo(w, h)
	self:drawLockdown(w, h)
end

surface.CreateFont("nutJailBig", {
	font = font,
	size = ScreenScale(8),
	extended = true,
	weight = 500
})

netstream.Hook("nutJailChat", function(arrester, arrested)
	CHAT_CLASS = {font = "nutJailBig"}
		local name = arrester:Name()
		local name2 = arrested:Name()

		chat.AddText(L("arrestNotify", name, name2, nut.config.get("jailTime")))
	CHAT_CLASS = nil
end)

surface.CreateFont("nutWantedBig", {
	font = font,
	size = ScreenScale(8),
	extended = true,
	weight = 500
})

netstream.Hook("nutWantedText", function(bool, a, b, c)
	CHAT_CLASS = {font = "nutWantedBig"}
		if (bool) then
			chat.AddText(Color(200, 10, 10), L("wantedNotify", b:Name(), c))
		else
			chat.AddText(Color(200, 10, 10), L("unwantedNotify", b:Name()))
		end
	CHAT_CLASS = nil
end)

netstream.Hook("nutHitText", function(a, b, c)
	CHAT_CLASS = {font = "nutJailBig"}
		chat.AddText(color_white, L("hitNotify", b:Name(), c))
	CHAT_CLASS = nil
end)

netstream.Hook("nutSearchText", function(a, b, c)
	CHAT_CLASS = {font = "nutJailBig"}
		chat.AddText(color_white, L("warrantNofity", a:Name(), b))
	CHAT_CLASS = nil
end)


netstream.Hook("nutHitman", function(target, client, message)
	/*
		local localman = LocalPlayer()
		local char = localman:getChar()
		if (!char) then return end

		local class = char:getClass()
		if (class != CLASS_HITMAN) then return end
	*/
	local what = vgui.Create("voteRequired")
	what:SetTitle(L("hitRequestTitle", client:Name()))
	what.name:SetText(L("hitRequestMsg", target:Name(), message))

	function what:sendResult(yes)
		netstream.Start("nutHitmanAccept", yes)

		self:Close()
	end
end)



function SCHEMA:CreateCharInfoText(panel)
	panel.playTime = panel.info:Add("DLabel")
	panel.playTime:Dock(TOP)
	panel.playTime:SetFont("nutMediumFont")
	panel.playTime:SetTextColor(color_white)
	panel.playTime:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	panel.playTime:DockMargin(0, 10, 0, 0)

	panel.wage = panel.info:Add("DLabel")
	panel.wage:Dock(TOP)
	panel.wage:SetFont("nutMediumFont")
	panel.wage:SetTextColor(color_white)
	panel.wage:SetExpensiveShadow(1, Color(0, 0, 0, 150))
	panel.wage:DockMargin(0, 10, 0, 0)
end

function SCHEMA:OnCharInfoSetup(panel)	
	local format = "%A, %d %B %Y %X"
	local client = LocalPlayer()
	local time = 0
	local tt = string.FormattedTime(time)

	panel.playTime:SetText(L("timePlayed", tt.h, tt.m, tt.s))
	panel.playTime.Think = function(this)
		time = 0

		if ((this.nextTime or 0) < CurTime()) then
			tt = string.FormattedTime(time)

			this:SetText(L("timePlayed", tt.h, tt.m, tt.s))
			this.nextTime = time + 0.5
		end
	end

	local char = client:getChar()
	local class = char:getClass()
	local classData = nut.class.list[class]
	if (class and classData) then
		panel.wage:SetText(L("wage", nut.currency.get(classData.salary)))
	end
end

-- supress shits
list.Set("DesktopWindows", "PlayerEditor", {})

local function addInfoText(text2)
	local template1 = "<font=ChatFont>%s</font>"
	
	chat.AddText(Format(template1, text2))
end

NUT_CVAR_TIPS = CreateClientConVar("nut_tips", 1, true, true)

timer.Create("nutTips", 200, 0 ,function()
	if (!NUT_CVAR_TIPS:GetBool()) then return end

	addInfoText(table.Random(nut.tips))
end)

function SCHEMA:SetupQuickMenu(menu)
	 local button = menu:addCheck(L"toggleTips", function(panel, state)
	 	if (state) then
	 		RunConsoleCommand("nut_tips", "1")
	 	else
	 		RunConsoleCommand("nut_tips", "0")
	 	end
	 end, NUT_CVAR_TIPS:GetBool())

	 menu:addSpacer()
end

local ShowCursor
local function CanDisplayCursor()
	return (RewardsMainWindow or (nut.vote.list and table.Count(nut.vote.list) > 0))
end

-- This is for chatbox
function SCHEMA:OnChatReceived(client, chatType, text, anonymous)
	if (!client:IsAdmin()) then
		return "<noparse>" .. text .. "</noparse>"
	end
end

function SCHEMA:ShouldDrawEntityInfo(entity)
	if (entity:IsPlayer() or IsValid(entity:getNetVar("player"))) then
		return false
	end
end

function SCHEMA:PlayerBindPress( ply, bind, down )
	local bnd = string.match(string.lower(bind), "gm_[a-z]+[12]?")

	if (bnd and bnd:find("gm_showteam")) then
		if (!CanDisplayCursor()) then 
			if (ShowCursor) then
				ShowCursor = !ShowCursor
				gui.EnableScreenClicker(ShowCursor)
			end
		else
			local settings = {}
				ShowCursor = !ShowCursor
				gui.EnableScreenClicker(ShowCursor)
		end
	end
end

netstream.Hook("nutUpdateWeed", function(entity, scale)
	entity.scale = scale
	local self = nut.gui.vendor

	if (self and SELECTED_ITEM) then
		local price = self.entity:getPrice(SELECTED_ITEM.item, SELECTED_ITEM.isLocal)

		if (SELECTED_ITEM.isLocal) then
			self.vendorBuy:SetText(L"sell".." ("..nut.currency.get(price)..")")
		else
			self.vendorSell:SetText(L"purchase".." ("..nut.currency.get(price)..")")
		end
	end
end)

netstream.Hook("nutLawSync", function(data)
	SCHEMA.laws = data
end)

function SCHEMA:CanPlayerViewInventory()
	if (IsValid(LocalPlayer():getNetVar("searcher"))) then
		return false
	end
end

netstream.Hook("searchPly", function(target, index)
	-- 솔직히 이거 뜯어내서 netstream한다면 내가 인정하고 아무말도 안할게
	-- 배포하지만 마라
	local inventory = nut.item.inventories[index]

	if (!inventory) then
		return netstream.Start("searchExit")
	end

	nut.gui.inv1 = vgui.Create("nutInventory")
	nut.gui.inv1:ShowCloseButton(true)
	nut.gui.inv1:setInventory(LocalPlayer():getChar():getInv())
	nut.gui.inv1:viewOnly(true)

	local panel = vgui.Create("nutInventory")
	panel:ShowCloseButton(true)
	panel:SetTitle(target:Name())
	panel:setInventory(inventory)
	panel:MoveLeftOf(nut.gui.inv1, 4)
	panel.OnClose = function(this)
		if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
			nut.gui.inv1:Remove()
		end

		netstream.Start("searchExit")
	end
	panel:viewOnly(true)

	local oldClose = nut.gui.inv1.OnClose
	nut.gui.inv1.OnClose = function()
		if (IsValid(panel) and !IsValid(nut.gui.menu)) then
			panel:Remove()
		end

		netstream.Start("searchExit")
		nut.gui.inv1.OnClose = oldClose
	end

	nut.gui["inv"..index] = panel	
end)

local lockdown = "npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav"

netstream.Hook("nutLockdown", function(bool)
	if (bool) then
		surface.PlaySound(lockdown)
	end

	CHAT_CLASS = {font = "nutJailBig"}
		chat.AddText(color_red, bool and L"lockdownOn" or L"lockdownOff")
	CHAT_CLASS = nil
end)

function SCHEMA:PostDrawInventory(pnl)
	if (pnl and pnl:IsVisible()) then
		local x, y = pnl:GetPos()
		local w, h = pnl:GetSize()
		local color = nut.config.get("color")
		local tx, ty = nut.util.drawText(L("ctrlInv"), x + 5, y + h, ColorAlpha(color, 255))
	end
end

function SCHEMA:ShouldDrawEntityInfo()
	if (LocalPlayer():getChar()) then
		if (IsValid(entity)) then
			if (entity:IsVehicle()) then
				return true
			end
		end
	end
end

function SCHEMA:DrawEntityInfo()
	if (LocalPlayer():InVehicle() != true) then
		if (IsValid(entity)) then
			if (entity:IsVehicle()) then
				if (entity:CPPIGetOwner()) then
					local position = (entity:LocalToWorld(entity:OBBCenter())):ToScreen()
					local x, y = position.x, position.y

					nut.util.drawText(L"vehicleName", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
					nut.util.drawText(L("vehicleOwner", entity:CPPIGetOwner():Name()), x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
				end
			end
		end
	end
end

-- Override all wack ass things
local GM = GM or GAMEMODE
function GM:DrawEntityInfo()
end
