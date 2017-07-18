if _G.chathud_image_html and _G.chathud_image_html:IsValid() then
	_G.chathud_image_html:Remove()
end
	
_G.chathud_image_html = NULL

local urlRewriters =
{
	{ "^https?://imgur%.com/([a-zA-Z0-9_]+)$",      "http://i.imgur.com/%1.png" },
	{ "^https?://www%.imgur%.com/([a-zA-Z0-9_]+)$", "http://i.imgur.com/%1.png" }
}

local allowed = {
	gif = true,
	jpg = true,
	jpeg = true,
	png = true,
}

local queue = {}

local busy

local sDCvar = CreateClientConVar("chathud_image_slideduration","0.5")
local hDCvar = CreateClientConVar("chathud_image_holdduration","5")

local function show_image(url)
	busy = true
	if chathud_image_html:IsValid() then
		chathud_image_html:Remove()
	end
	
	chathud_image_html = vgui.Create("DHTML")
	chathud_image_html:SetVisible(false)
	chathud_image_html:SetSize(ScrW(), ScrH())
	chathud_image_html:ParentToHUD()
	chathud_image_html:SetHTML(
		[[
			<body>
				<img src="]] .. url .. [[" height="30%" />
			</body>
		]]
	)
	
	-- Animation parameters
	local slideDuration = sDCvar:GetFloat()
	local holdDuration = hDCvar:GetFloat()
	local totalDuration = slideDuration * 2 + holdDuration
	
	-- Returns a value from 0 to 1
	-- 0: Fully off-screen
	-- 1: Fully on-screen
	local function getPositionFraction(t)
		if t < slideDuration then
			-- Slide in
			local normalizedT = t / slideDuration
			return math.cos((1 - normalizedT) * math.pi / 4)
		elseif t < slideDuration + holdDuration then
			-- Hold
			return 1
		else
			-- Slide out
			local t = t - slideDuration - holdDuration
			local normalizedT = t / slideDuration
			return math.cos(normalizedT * math.pi / 4)
		end
	end
	
	local start = nil
	hook.Add("Think", "chathud_image_url", function()
		if not chathud_image_html:IsValid() or chathud_image_html:IsLoading() then return end
		
		if not chathud_image_html:IsVisible() then
			start = RealTime()
			chathud_image_html:SetVisible(true)
		end
		
		local t = RealTime() - start
		if t > totalDuration then
			if chathud_image_html:IsValid() then
				chathud_image_html:Remove()
			end
			hook.Remove("Think", "chathud_image_url")
			table.remove(queue, 1)
			busy = false
			return
		end
		
		chathud_image_html:SetPos(ScrW() * (getPositionFraction(t) - 1), 200)
	end)
end

timer.Create("chathud_image_url_queue", 0.25, 0, function()
	if busy then return end
	local url = queue[1]
	if url then
		show_image(url)
	end
end)

local cvar = CreateClientConVar("chathud_image_url", "1")

hook.Add("OnChatReceived", "chathud_image_url", function(ply, te, str)
	if (!ply:IsAdmin()) then return end
	if (te != "ooc") then return end

	if not IsValid(ply) or str=="" then return end
	
	local num = cvar:GetInt()

	/*
		if num == 0 then return end
		
		if num == 1 and ply.IsFriend and not ply:IsFriend(LocalPlayer()) and ply ~= LocalPlayer() then
			return
		end

		if str == "sh" then
			if chathud_image_html:IsValid() then
				chathud_image_html:Remove()
			end
			hook.Remove("Think", "chathud_image_url")
			queue = {}
			
			return
		end
	*/

	if str:find("http") then
		str = str:gsub("https:", "http:")
		
		str = str .. " "
		local url = str:match("(http://.-)%s")
		if not url then return end
		
		for _, rewriteRule in ipairs(urlRewriters) do
			url = string.gsub(url, rewriteRule[1], rewriteRule[2])
		end
		
		local ext = url:match(".+%.(.+)")
		if not ext then return end
		
		if not allowed[ext] then return end
		
		for k,v in pairs(queue) do
			if v == url then return end
		end

		table.insert(queue, url)
	end
end)