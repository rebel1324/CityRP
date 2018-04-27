﻿local luadata = {}
local glon = requirex("glon")

luadata.EscapeSequences = {
    [("\a"):byte()] = [[\a]],
    [("\b"):byte()] = [[\b]],
    [("\f"):byte()] = [[\f]],
    [("\t"):byte()] = [[\t]],
    [("\r"):byte()] = [[\r]],
    [("\v"):byte()] = [[\v]]
}

local tab = 0

luadata.Types = {
    ["number"] = function(var) return ("%s"):format(var) end,
    ["string"] = function(var) return ("%q"):format(var) end,
    ["boolean"] = function(var) return ("%s"):format(var and "true" or "false") end,
    ["Vector"] = function(var) return ("Vector(%s, %s, %s)"):format(var.x, var.y, var.z) end,
    ["Angle"] = function(var) return ("Angle(%s, %s, %s)"):format(var.p, var.y, var.r) end,
    ["table"] = function(var)
        if type(var.r) == "number" and type(var.g) == "number" and type(var.b) == "number" and type(var.a) == "number" then return ("Color(%s, %s, %s, %s)"):format(var.r, var.g, var.b, var.a) end
        tab = tab + 1
        local str = luadata.Encode(var, true)
        tab = tab - 1

        return str
    end
}

function luadata.SetModifier(type, callback)
    luadata.Types[type] = callback
end

function luadata.Type(var)
    local t

    if IsEntity(var) then
        if var:IsValid() then
            t = "Entity"
        else
            t = "NULL"
        end
    else
        t = type(var)
    end

    if t == "table" then
        if var.LuaDataType then
            t = var.LuaDataType
        end
    end

    return t
end

function luadata.ToString(var)
    local func = luadata.Types[luadata.Type(var)]

    return func and func(var)
end

function luadata.Encode(tbl, __brackets)
    if luadata.Hushed then return end
    local str = __brackets and "{\n" or ""

    for key, value in pairs(tbl) do
        value = luadata.ToString(value)
        key = luadata.ToString(key)

        if key and value and key ~= "__index" then
            str = str .. ("\t"):rep(tab) .. ("[%s] = %s,\n"):format(key, value)
        end
    end

    str = str .. ("\t"):rep(tab - 1) .. (__brackets and "}" or "")

    return str
end

function luadata.Decode(str)
    local func = CompileString("return {\n" .. str .. "\n}", "luadata", false)

    if type(func) == "string" then
        MsgN("luadata decode error:")
        MsgN(err)

        return {}
    end

    local ok, err = pcall(func)

    if not ok then
        MsgN("luadata decode error:")
        MsgN(err)

        return {}
    end

    return err
end

-- file extension
do
    function luadata.WriteFile(path, tbl)
        file.Write(path, luadata.Encode(tbl))
    end

    function luadata.ReadFile(path)
        return luadata.Decode(file.Read(path) or "")
    end

    function luadata.SetKeyValueInFile(path, key, value)
        if luadata.Hushed then return end
        local tbl = luadata.ReadFile(path)
        tbl[key] = value
        luadata.WriteFile(path, tbl)
    end

    function luadata.AppendValueToFile(path, value)
        if luadata.Hushed then return end
        local tbl = luadata.ReadFile(path)
        table.insert(tbl, value)
        luadata.WriteFile(path, tbl)
    end

    function luadata.Hush(bool)
        luadata.Hushed = bool
    end
end

-- option extension
do
    function luadata.AccessorFunc(tbl, func_name, var_name, nw, def)
        tbl["Set" .. func_name] = function(self, val)
            self[nw and "SetLuaDataNWOption" or "SetLuaDataOption"](self, var_name, val or def)
        end

        tbl["Get" .. func_name] = function(self, val) return self[nw and "GetLuaDataNWOption" or "GetLuaDataOption"](self, var_name, def) end
    end

    local meta = FindMetaTable("Player")

    function meta:LoadLuaDataOptions()
        self.LuaDataOptions = luadata.ReadFile("luadata_options/" .. self:UniqueID() .. ".txt")

        for key, value in pairs(self.LuaDataOptions) do
            if key:sub(0, 3) == "_nw" then
                self:SetNWString("ld_" .. key:sub(4), glon.encode(value))
            end
        end
    end

    if SERVER then
        hook.Add("OnEntityCreated", "luadata_player_spawn", function(ply)
            if ply:IsValid() and FindMetaTable("Player") == getmetatable(ply) then
                ply:LoadLuaDataOptions()
            end
        end)
    end

    function meta:SaveLuaDataOptions()
        luadata.WriteFile("luadata_options/" .. self:UniqueID() .. ".txt", self.LuaDataOptions)
    end

    function meta:SetLuaDataOption(key, value)
        if not self.LuaDataOptions then
            self:LoadLuaDataOptions()
        end

        self.LuaDataOptions[key] = value
        self:SaveLuaDataOptions()
    end

    function meta:GetLuaDataOption(key, def)
        if not self.LuaDataOptions then
            self:LoadLuaDataOptions()
        end

        return self.LuaDataOptions[key] or def
    end

    function meta:SetLuaDataNWOption(key, value)
        self:SetLuaDataOption("_nw" .. key, value)
        self:SetNWString("ld_" .. key, glon.encode(value))
    end

    function meta:GetLuaDataNWOption(key, def)
        local value

        if SERVER then
            value = self:GetLuaDataOption("_nw" .. key)
            if value then return value end
        end

        value = self:GetNWString("ld_" .. key, false)

        return type(value) == "string" and glon.decode(value) or def
    end
end

return luadata