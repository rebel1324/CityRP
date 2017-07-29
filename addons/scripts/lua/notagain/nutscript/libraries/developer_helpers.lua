-- helper stuff for live development
-- DO NOT USE IN LIVE CODE

local delayid = -1337.7331
function delayload(delay,param)
	if param==delayid then
		return false
	elseif param==nil then
		local func = debug.getinfo(2,'f').func
		timer.Simple(delay,function()
			func(delayid)
		end)
		
		return true
	end
	
	error("singularity prevented: "..tostring(param))
	
end

-- So we catch at least the early errors of using these "helpers"
if delayload(1,...) then return end

local CONVAR = FindMetaTable("ConVar")
local VECTOR = FindMetaTable("Vector")
local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")


local cl=PLAYER.ConCommand
function cmd(str)
    return SERVER and (game.ConsoleCommand(str.."\n") or true) or cl(nil,str,true)
end

-- TODO: Someone add a comment here pls
ENTITY.DataTbl=function(ent)
	local dt = ent:GetSaveTable()
	for k,v in pairs(dt) do
		if k:find"_GMOD" then
			dt[k]=nil
		end
	end
	
	local m={}
	m.__index=m
	local t=setmetatable(dt,m)
	
	function m.set(self,k,v)
		local ret = ent:SetSaveValue(k,v)
		if not ret then
			local oldv=ent:GetSaveTable()[k]
			if oldv then
				if type(old)~=type(v) then
					error("assignment failed, type mismatch? "..type(old)..' vs. '..type(v) )
				end
			else
			error("assignment failed. Key not found?")
			end
			error("assignment failed")
		end
	end
	m.Set=m.set
	
	m.filter=function(s,what)
		local t=s:find(what)
		for k,v in pairs(t) do
			s[k]=nil
		end
		return s
	end
	
	m.find=function(s,what)
		local t={}
		local c=0
		what=what:lower()
		for k,v in pairs(s) do
			if k:lower():find(what) then
				t[k]=v
				c=c+1
			end
		end
		setmetatable(t,m)
		return t
	end
	m.dump=function(s)
		local dump={}
		for k,v in pairs(s) do
			table.insert(dump,{k,v})
		end
		table.sort(dump,function(a,b) return a[1]>b[1] end)
		for k,v in pairs(dump) do
			Msg(v[1],"\t\t ")
			local p=v[2]
			
			if type(p) == "string" then
				p="'"..p:gsub("'","\\'").."'"
			elseif istable(p) then
				p=tostring(p[1])..'\t->\t'..tostring(p[2])
			end
			print(p)
		end
	end
	
	local function _dodiff(diff,s,f,rev,k,v)
		
		local f=f[k]
		if f==nil then
			local tt =rev and {v,"<not found>"} or {"<not found>",v}
			diff [k]=tt
		elseif f~=v then
			if isvector(f) then
				if f.x==v.x
				and	f.y==v.y
				and	f.z==v.z
				then return end
			elseif isangle(f) then
				if f.p==v.p
				and	f.y==v.y
				and	f.r==v.r
				then return end
			end
			
			diff [k]={v,f}
			
		end
	end
	
	local function dodiff(diff,s,f,rev)
		for k,v in pairs(s) do
			_dodiff(diff,s,f,rev,k,v)
		end
	end
	
	m.diff=function(s,f)
		if isentity(f) then
			f=f:DataTbl()
		end
		
		local diff={}

		dodiff(diff,s,f,false)
		dodiff(diff,f,s,true)
		setmetatable(diff,m)
		return diff
	end
	return t
end

ENTITY.AddPos = function(ent, v, y, z)
	if y and z and v then
		v = Vector(v, y, z)
	end
	ent:SetPos(ent:GetPos() + v)
end
ENTITY.Translate = ENTITY.AddPos

-- TODO: Someone add a comment here pls
local rawget=rawget
local rawset=rawset
function asraw(t)
	local mt = {}
	mt.__index = function(self,k)
		return rawget(t,k)
	end
	mt.__newindex = function(self,k,v)
		rawset(t,k,v)
	end
	return setmetatable({},mt)
end

-- IEEE floating point values
inf = math.huge
nan = 0 / 0

-- PhysObjs
ENTITY.GetPhysicsObjects = function (self)
	local physicsObjects = {}
	
	if self:IsValid() then
		for i = 0, self:GetPhysicsObjectCount () - 1 do
			physicsObjects [#physicsObjects + 1] = self:GetPhysicsObjectNum (i)
		end
	end
	
	if functional then
		physicsObjects = functional.list (physicsObjects)
	end
	
	return physicsObjects
end

ENTITY.GPO  = ENTITY.GetPhysicsObject
ENTITY.GPOs = ENTITY.GetPhysicsObjects

-- Player weapons
PLAYER.Wep    = PLAYER.GetActiveWeapon
PLAYER.Weapon = PLAYER.GetActiveWeapon

-- ConVars
CONVAR.Set = function(a,b,...) RunConsoleCommand(a:GetName(),b,...) end

CONVAR.__tostring=function(self)
    return 'GetConVar("'..(self.GetName and self:GetName() or "unknown")..'"):Set("'..(self.GetString and self:GetString() or "")..'")'
end

cvar = GetConVar
CVar = GetConVar
Cvar = GetConVar

-- typomod
Hook=hook
Timer=timer
File=file
str=tostring
int=tonumber

-- TODO: Someone add a comment here pls
local function addmetatable(thing,tbl)
	local meta = getmetatable(thing)
	if not meta then
		meta = tbl
		setmetatable(thing,meta)
	else
		for k,v in pairs(tbl) do
			if not meta[k] then
				meta[k]=v
			end
		end
	end
end

addmetatable(ents,{__call=function(tbl,a)
    if a and a~="" then
        return pairs(ents.FindByClass(a))
    else
        return pairs(ents.GetAll())
    end
end})


addmetatable(player,{__call=function(tbl,a)
    --if a and a~="" then
    --    return pairs(player.FindByClass(a))
    --else
        return pairs(player.GetAll())
   -- end
end})


addmetatable(hook,{__call=function(tbl,a,b,c)
    if c then
        hook.Add(a,b,c)
    else
        hook.Remove(a,b)
    end
end})


local func=function(tbl,a,b,c,d,...)
    if a~=nil and b and c and d and type(b)=="number" and type(c)=="number" then
        tbl.Create(a,b,c,d,...)
        return a
    elseif a~=nil and not b and not c and not d then
        tbl.Remove(a)
    elseif a and b and type(a)=="number" then
        tbl.Simple(a,b,c,d,...)
    else
        error"Ambiguous parameters"
    end
end
addmetatable(timer,{__call=func})
Timer=function(...) return func(timer,...) end


addmetatable(coroutine,{__call=function(tbl,a,...)
	return coroutine.create(a,...)
end})


True  = function() return true  end
False = function() return false end
Nil   = function()              end

