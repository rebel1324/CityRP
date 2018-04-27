﻿local dummy = function() end
local a = debug.getmetatable(dummy) or {}
a.__index = a.__index or a -- assuming __index is not a function
local meta = a.__index
debug.setmetatable(dummy, a)

local eek = {
    ["init.lua"] = true,
    ["shared.lua"] = true,
    ["cl_init.lua"] = true
}

meta.__old_tostring = meta.__tostring

meta.__tostring = function(func)
    local str = "Func:("

    if func then
        local info = debug.getinfo(func)

        if info.what then
            if info.what == "C" then
                str = str .. "External"
            elseif info.linedefined and info.lastlinedefined then
                if info.source:sub(1, 1) == "@" then
                    local file = string.GetFileFromFilename(info.source)

                    if file and file:len() > 0 then
                        if not eek[file] then
                            str = str .. file:gsub("^lua/", "")
                        else
                            str = str .. tostring(info.short_src):gsub("^lua/", "")
                        end
                    else
                        str = str .. tostring(info.short_src):gsub("^lua/", "")
                    end
                else
                    str = str .. "NF: " .. tostring(info.source)
                end

                if info.linedefined >= 0 and info.lastlinedefined >= 0 then
                    if info.linedefined == info.lastlinedefined then
                        str = str .. ": " .. info.linedefined
                    else
                        str = str .. ": " .. info.linedefined .. "-" .. info.lastlinedefined
                    end
                end
            else
                str = str .. "EEK"
            end
        end

        local fenv = debug.getfenv(func)

        if fenv then
            if fenv == _G then
                -- print nothing
            else
                local key

                for k, v in pairs(_G) do
                    if v == fenv then
                        key = k == func and "" or tostring(k)
                        break
                    end
                end

                str = str .. " " .. (key and "F:" .. key or "FEnv")
            end
        end
    end

    str = str .. ")"

    return str
end

-- meta.info=debug.getinfo
-- meta.getinfo=debug.getinfo
-- meta.getparams=debug.getparams
-- meta.params=debug.getparams
-- meta.setfenv=debug.setfenv
-- meta.getfenv=debug.getfenv -- major exploit here
-- meta.setupvalue=debug.setupvalue
-- meta.getupvalue=debug.getupvalue
meta.source = function(f)
    local a = debug.getinfo(f).source:gsub("^@", "")

    return a
end

meta.Source = meta.source
meta.file = meta.source
meta.File = meta.source

-- meta.pcall=pcall
-- meta.xpcall=xpcall
meta.decompile = function(f)
    if GLib and GLib.Lua.BytecodeReader then return GLib.Lua.BytecodeReader(f):ToString() end

    return false
end

meta.src = function(f)
    local src = f:source()
    if not src:find(".lua", 1, true) then return false, f:decompile() end
    local fpath = CLIENT and src:gsub("^lua/", "") or src
    src = file.Exists(fpath, CLIENT and 'LUA' or 'GAME') and src
    if not src then return false, f:decompile() end
    src = file.Read(fpath, CLIENT and 'LUA' or 'GAME')
    if not src then return false, f:decompile() end
    local info = debug.getinfo(f)
    local beginning, ending = info.linedefined - 1, info.lastlinedefined
    local i, pos = 0, 0

    while i < beginning do
        i = i + 1
        pos = pos + 1
        pos = string.find(src, '\n', pos, true)
    end

    local start = pos

    --	local i,pos=0,0
    while i < ending do
        i = i + 1
        pos = pos + 1
        pos = string.find(src, '\n', pos, true)
    end

    local stop = pos or #src

    --..assert(start)
    --..assert(stop)
    return src:sub(start + 1, stop - 1)
end
--[[meta.findval=function(f,str,regex)
	local i=0
	while true do
		i=i+1
		local key,val=debug.getupvalue(f,i)
		if not key then break end
		if key==a then
			return val
		end
	end
	
	local i=0
	while true do
		i=i+1
		local key,val=debug.getupvalue(f,i)
		if not key then break end
		if string.find(tostring(key),str,1,not regex) then
			return val,key
		end
	end
end--]]
--[[meta.upvalues=function(f)
	local i,t=0,{}
	while true do
		i=i+1
		local key,val=debug.getupvalue(f,i)
		if not key then break end
		t[key]=val
	end
	return t
end--]]
-- meta.getupvalues = meta.upvalues