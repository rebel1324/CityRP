file.CreateDir("emoticon_cache")

local col = Color(255, 200, 0, 255)
local Msg = function(...) MsgC(col, ...)  end

hook.Add("LoadFonts", "nutFontXPChatbox2", function(font, genericFont)
	surface.CreateFont("chathud_18", {
		font = genericFont,
		extended = true,
		size = 23,
		weight = 800,
	})

	surface.CreateFont("chathud_18_blur", {
		font = genericFont,
		extended = true,
		size = 23,
		weight = 800,
		blursize = 2,
	})
end)

chathud = {}

-- What's the difference between a PreTag and a Tag, I hear you ask.

-- A pretag is evaluated BEFORE all normal tags.
-- Pretags also only get evaluated ONCE due to their nature, making expression
-- arguments with variable data basicly useless.

-- Rather than providing functionality to the buffer, they change the data IN the buffer.

chathud.PreTags = {
	["rep"] = {
		args = {
			[1] = {type = "number", min = 0, max = 10, default = 1},
		},
		func = function(text, args)
			return text:rep(args[1])
		end
	},
}

if string.anime then
	chathud.PreTags["anime"] = {
		args = {
			-- no args
		},
		func = string.anime
	}
end

chathud.Tags = {
	["color"] = {
		args = {
			[1] = {type = "number", min = 0, max = 255, default = 255}, -- r
			[2] = {type = "number", min = 0, max = 255, default = 255}, -- g
			[3] = {type = "number", min = 0, max = 255, default = 255}, -- b
			[4] = {type = "number", min = 0, max = 255, default = 255}, -- a
		},
		TagStart = function(self, markup, buffer, args)
			self._fgColor = buffer.fgColor
		end,
		ModifyBuffer = function(self, markup, buffer, args)
			buffer.fgColor = Color(args[1] or 255, args[2] or 255, args[3] or 255, args[4] or 255)
		end,
		TagEnd = function(self, markup, buffer, args)
			buffer.fgColor = self._fgColor or Color(255, 255, 255, 255)
			self._fgColor = nil
		end,
	},
	["bgcolor"] = {
		args = {
			[1] = {type = "number", min = 0, max = 255, default = 255}, -- r
			[2] = {type = "number", min = 0, max = 255, default = 255}, -- g
			[3] = {type = "number", min = 0, max = 255, default = 255}, -- b
			[4] = {type = "number", min = 0, max = 255, default = 0}, -- a
		},
		TagStart = function(self, markup, buffer, args)
			self._bgColor = buffer.bgColor
		end,
		ModifyBuffer = function(self, markup, buffer, args)
			buffer.bgColor = Color(args[1] or 255, args[2] or 255, args[3] or 255, args[4] or 255)
		end,
		TagEnd = function(self, markup, buffer, args)
			buffer.bgColor = self._bgColor or Color(255, 255, 255, 0)
		end,
	},
	["font"] = {
		args = {
			[1] = {type = "string", default = "DermaDefault"}, -- fontname
		},
		TagStart = function(self, markup, buffer, args)
			self._font = buffer.font
		end,
		ModifyBuffer = function(self, markup, buffer, args)
			buffer.font = args[1]
		end,
		TagEnd = function(self, markup, buffer, args)
			buffer.font = self._font or "chathud_18"
		end,
	},
	["hsv"] = {
		args = {
			[1] = {type = "number", default = 0},					--h
			[2] = {type = "number", min = 0, max = 1, default = 1},	--s
			[3] = {type = "number", min = 0, max = 1, default = 1},	--v
		},
		TagStart = function(self, markup, buffer, args)
			self._fgColor = buffer.fgColor
		end,
		ModifyBuffer = function(self, markup, buffer, args)
			if not self._fgColor then self._fgColor = buffer.fgColor end
			buffer.fgColor = HSVToColor(args[1] % 360, args[2], args[3])
		end,
		TagEnd = function(self, markup, buffer, args)
			buffer.fgColor = self._fgColor or Color(255, 255, 255, 255)
		end,
	},
	["dev_hsvbg"] = {
		args = {
			[1] = {type = "number", default = 0},					--h
			[2] = {type = "number", min = 0, max = 1, default = 1},	--s
			[3] = {type = "number", min = 0, max = 1, default = 1},	--v
		},
		TagStart = function(self, markup, buffer, args)
			self._bgColor = buffer.bgColor
		end,
		ModifyBuffer = function(self, markup, buffer, args)
			buffer.bgColor = HSVToColor(args[1] % 360, args[2], args[3])
		end,
		TagEnd = function(self, markup, buffer, args)
			buffer.bgColor = self._bgColor or Color(255, 255, 255, 0)
		end,
	},
	["translate"] = {
		args = {
			[1] = {type = "number", default = 0},	-- x
			[2] = {type = "number", default = 0},	-- y
		},
		TagStart = function(self, markup, buffer, args)
			self.mtrx = Matrix()
		end,
		Draw = function(self, markup, buffer, args)
			self.mtrx:SetTranslation(Vector(chathud.x + args[1], markup.y + args[2]))
			cam.PushModelMatrix(self.mtrx)
		end,
		TagEnd = function(self)
			cam.PopModelMatrix()
		end,
	},
	["rotate"] = {
		args = {
			[1] = {type = "number", default = 0},	-- y
		},
		TagStart = function(self, markup, buffer, args)
			self.mtrx = Matrix()
		end,
		Draw = function(self, markup, buffer, args)
			self.mtrx:SetTranslation(Vector(chathud.x, markup.y))
			self.mtrx:SetAngles(Angle(0, args[1], 0))
			cam.PushModelMatrix(self.mtrx)
		end,
		TagEnd = function(self)
			cam.PopModelMatrix()
		end,
	},
	["scale"] = {
		args = {
			[1] = {type = "number", default = 1},	-- x
			[2] = {type = "number", default = 1},	-- y
		},
		TagStart = function(self, markup, buffer, args)
			self.mtrx = Matrix()
		end,
		Draw = function(self, markup, buffer, args)
			self.mtrx:SetTranslation(Vector(chathud.x, markup.y))
			self.mtrx:SetScale(Vector(args[1], args[2]))
			cam.PushModelMatrix(self.mtrx)
		end,
		TagEnd = function(self)
			cam.PopModelMatrix()
		end,
	},
}
chathud.Shortcuts = {}

chathud.x = 32
chathud.y = ScrH() - 200
chathud.w = 550

chathud.markups = {}

for _, icon in pairs(file.Find("materials/icon16/*.png", "GAME")) do
	chathud.Shortcuts[string.StripExtension(icon)] = "<texture=icon16/" .. icon .. ">"
end

function chathud.CreateSteamShortcuts(update)
    local tag = os.date("%Y%m%d")
    local latest = "steam_emotes_"..tag..".dat"

    local found = file.Find("emoticon_cache/steam_emotes_*.dat", "DATA")
    for k, v in next,found do
        if v ~= latest then file.Delete("emoticon_cache/" .. v) end
    end

    latest = "emoticon_cache/" .. latest

    if file.Exists(latest, "DATA") and not update then
        local data = file.Read(latest, "DATA")

        for name in data:gmatch('"name": ":(.-):"') do
            if not chathud.Shortcuts[name] then chathud.Shortcuts[name] = "<se=" .. name .. ">" end
        end
    else
        http.Fetch("http://cdn.steam.tools/data/emote.json", function(b)
            for name in b:gmatch('"name": ":(.-):"') do
                if not chathud.Shortcuts[name] then chathud.Shortcuts[name] = "<se=" .. name .. ">" end
            end

            file.Write(latest, b)
        end)
    end
end

chathud.CreateSteamShortcuts()

function chathud:AddMarkup()
	local markup = class:new("Markup")
	self.markups[#self.markups + 1] = markup
	self:CleanupOldMarkups()
	markup.w = self.w
	self:Invalidate(true)
	return markup
end

function chathud:CleanupOldMarkups()
	for _, m in pairs(self.markups) do
		if m.alpha <= 0 then
			table.RemoveByValue(self.markups, m)
		end
	end
end

function chathud:AddText(...)
	local markup = self:AddMarkup()
	markup:StartLife(10)
	markup:AddFont("chathud_18")
	markup:AddShadow(2)
	for i = 1, select("#", ...) do
		local var = select(i, ...)
		if isstring(var) then
			markup:Parse(var, chatexp.LastPlayer)
		elseif istable(var) and var.r and var.g and var.b and var.a then
			markup:AddFGColor(var)
		elseif isentity(var) and var:IsPlayer() then
			markup:AddFGColor(team.GetColor(var:Team()))
			markup:Parse(var:Nick())
		else
			markup:AddString(tostring(var))
		end
	end
	markup:EndLife()
end

function chathud:Think()
	for _, markup in pairs(self.markups) do
		markup:AlphaTick()
	end
end

function chathud:Invalidate(now)
	self.needs_layout = true
	if now then self:PerformLayout() end
end

function chathud:PerformLayout()
	local y = self.y
	for i = #self.markups, 1, -1 do
		local markup = self.markups[i]
		if markup.h then
			y = y - markup.h
		end
		markup.y = y
	end
end

function chathud:TagPanic()
	for _, markup in pairs(self.markups) do
		markup:TagPanic(false)
	end
end

local matrix = Matrix()
function chathud:Draw()
	if self.needs_layout then
		self:PerformLayout()
	end
	for _, markup in pairs(self.markups) do
		local alpha = markup.alpha
		if alpha > 0 then
			surface.SetAlphaMultiplier(alpha / 255)
			matrix:SetTranslation(Vector((pace and pace.IsActive() and pace.Editor:GetAlpha() ~= 0 and chathud.x + pace.Editor:GetWide() or chathud.x), markup.y or 0, 0))
			cam.PushModelMatrix(matrix)
			local ok, why = pcall(markup.Draw, markup)
			if not ok then
				Msg"ChatHUD " print("Drawing Error!")
				print(why, "\n", debug.traceback())
			end
			cam.PopModelMatrix()
		end
		surface.SetAlphaMultiplier(1)
	end
	if self.needs_layout then
		self:PerformLayout()
		self.needs_layout = nil
	end
end

-------------------------

local emoticon_cache = {}
local busy = {}

local function MakeCache(filename, emoticon)
	local mat = Material("data/" .. filename, "noclamp smooth")
	emoticon_cache[emoticon or string.StripExtension(string.GetFileFromFilename(filename))] = mat
end

local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function dec(data)
    data = string.gsub(data, "[^" .. b.. "=]", "")
    return (data:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1,8 do c = c + (x:sub(i,i) == "1" and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

file.CreateDir("emoticon_cache")
function chathud:GetSteamEmoticon(emoticon)
	emoticon = emoticon:gsub(":",""):Trim()
	if emoticon_cache[emoticon] then
		return emoticon_cache[emoticon]
	end
	if busy[emoticon] then
		return false
	end
	if file.Exists("emoticon_cache/" .. emoticon .. ".png", "DATA") then
		MakeCache("emoticon_cache/" .. emoticon .. ".png", emoticon)
	return emoticon_cache[emoticon] or false end
	Msg"ChatHUD " print("Downloading emoticon " .. emoticon)
	http.Fetch("http://steamcommunity-a.akamaihd.net/economy/emoticonhover/:" .. emoticon .. ":	", function(body, len, headers, code)
		if code == 200 then
			if body == "" then
				Msg"ChatHUD " print("Server returned OK but empty response")
			return end
			Msg"ChatHUD " print("Download OK")
			local whole = body
			body = body:match("src=\"data:image/png;base64,(.-)\"")
			if not body then Msg"ChatHUD " print("ERROR! (no body)", whole) return end
			local b64 = body
			body = dec(body)
			if not body then Msg"ChatHUD " print("ERROR! (not b64)", b64) return end
			file.Write("emoticon_cache/" .. emoticon .. ".png", body)
			MakeCache("emoticon_cache/" .. emoticon .. ".png", emoticon)
		else
			Msg"ChatHUD " print("Download failure. Code: " .. code)
		end
	end)
	busy[emoticon] = true
	return false
end

-------------------------

local Mcche = {}

local function MaterialCache(a, b)
	a = a:lower()
	if Mcche[a] then return Mcche[a] end
	local m = Material(a, b)
	Mcche[a] = m
	return m
end

chathud.Tags["se"] = {
	args = {
		[1] = {type = "string", default = "error"},
		[2] = {type = "number", min = 8, max = 128, default = 18},
	},
	Draw = function(self, markup, buffer, args)
		local image, size = args[1], args[2]
		image = chathud:GetSteamEmoticon(image)
		if image == false then image = MaterialCache("error") end
		surface.SetDrawColor(buffer.fgColor)
		surface.SetMaterial(image)
		surface.DrawTexturedRect(buffer.x, buffer.y, size, size)
	end,
	ModifyBuffer = function(self, markup, buffer, args)
		local image, size = args[1], args[2]
		buffer.h, buffer.x = size, buffer.x + size
		if buffer.x > markup.w then
			buffer.x = 0
			buffer.y = buffer.y + size
			buffer.h = buffer.y + size
		end
	end,
}

chathud.Tags["texture"] = {
	args = {
		[1] = {type = "string", default = "error"},
		[2] = {type = "number", min = 8, max = 128, default = 16},
	},
	Draw = function(self, markup, buffer, args)
		local image, size = args[1], args[2]
		image = MaterialCache(image)
		if image == false then image = MaterialCache("error") end
		local yoff = 0
		if size < 18 then yoff = 18 - size end
		surface.SetDrawColor(buffer.fgColor)
		surface.SetMaterial(image)
		surface.DrawTexturedRect(buffer.x, buffer.y + yoff, size, size)
	end,
	ModifyBuffer = function(self, markup, buffer, args)
		local image, size = args[1], args[2]
		buffer.h, buffer.x = size, buffer.x + size
		if buffer.x > markup.w then
			buffer.x = 0
			buffer.y = buffer.y + size
			buffer.h = buffer.h + size
		end
	end,
}

function chathud:DoArgs(str, argfilter)
	local argtb = str:Split(",")
	if argtb[1] == "" then argtb = {} end
	local t = {}
	for i = 1, #argfilter do
		local f = argfilter[i]
		local value
		local m = argtb[i]
		if m and m:match("%[.+%]") then
			local exp = class:new("Expression", m:sub(2, -2), function(res)
				if f.type == "number" then
					return number(res, f.min, f.max, f.default)
				else
					return res or f.default or ""
				end
			end)
			local res = exp:Compile()
			if res then
				Msg"ChatHUD " print("Expression error: " .. res)
				value = f.type == "number" and number(nil, f.min, f.max, f.default) or (f.default or "")
			else
				exp.altfilter = f
				value = function()
					return exp:Run()
				end
			end
		else
			if f.type == "number" then
				value = number(m, f.min, f.max, f.default)
			else
				value = m or f.default or ""
			end
		end
		t[i] = function()
			local a,b = _f(value)
			if a == false and isstring(b) then
				Msg"ChatHUD " print("Expression error: " .. b)
				return f.type == "number" and number(nil, f.min, f.max, f.default) or (f.default or "")
			end
			return a
		end
	end
	return t
end

return chathud
