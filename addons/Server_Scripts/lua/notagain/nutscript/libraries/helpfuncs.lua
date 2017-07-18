---------------------------------------
-- Decompiles decimal ips
---------------------------------------
local dot='.'
local floor=math.floor
util=util or {}
function util.DecimalToIP( iIP )
	local t1 = iIP	%	16777216
	local t2 = t1	%	65536
	return	floor( iIP	/	16777216 )	..dot..
			floor( t1	/	65536 )		..dot..
			floor( t2	/	256 )		..dot..
			floor( t2	%	256 )
end

function ServerIP( cidr )
	local cidr=tonumber(cidr or GetConVarString"hostip")
	if !cidr then return false end
	return util.DecimalToIP( cidr )
end

---------------------------------------
-- Re-requires if it can
---------------------------------------
rerequire = rerequire or function (name)
	unrequire(name)
	require(name)
end

---------------------------------------
-- Unrequires if possible
---------------------------------------
unrequire=unrequire or function(name)
	package.loaded[name]=nil
end


---------------------------------------
-- Name & Path
---------------------------------------
GetScriptName = GetScriptName or function()

	return debug.getinfo( debug.getinfo( 2, "f" ).func ).short_src

end

GetScriptPath = GetScriptPath or function ()

	local name	= debug.getinfo( debug.getinfo( 2, "f" ).func ).short_src
	local pos	= 0

	while true do

		local src = string.find( name, "/", ( pos or 0 ) + 1 )

		if ( !src ) then break end

		pos = src

	end

	if ( pos ) then return string.sub( name, 1, pos - 1 ) end

	return ""

end


function ents.FindInsideRotatedBox(centre, min, max, ang) -- thanks avon
	local entities = ents.FindInSphere(centre,(min-max):Length()/2)
	local directions = {}
	local RotationMatrix = MMatrix.EulerRotationMatrix(ang.p,ang.y,ang.r)
	for _,v in pairs(entities) do
		directions[v] = RotationMatrix*(v:GetPos()-centre)
	end
	for k,v in pairs(entities) do
		local pos = directions[v]

		if not (
			(pos.x >= min.x and pos.x <= max.x) and
			(pos.y >= min.y and pos.y <= max.y) and
			(pos.z >= min.z and pos.z <= max.z)
		) then
			entities[k] = nil
		end
	end
	return entities
end



function FindError(str,wide)
	local path,linenum

	path,linenum= string.gmatch(str,"(.+)%.lua:(%d+):")()

	path= path or string.gmatch(str,"(.+)%.lua")()
	if !path then
		error("Path not found") end
	path=string.Trim(path)

	linenum=linenum or string.gmatch(str,":(%d+):")()
	linenum=linenum or string.gmatch(str,":(%d+)")()
	linenum=linenum or string.gmatch(str,"(%d+)")() -- wow...
	if !linenum then
		error("linenum not found") end
	linenum=tonumber(linenum)
	if !linenum then
		error("linenum conversion failed") end
	MsgN("Error Path='"..tostring(path).."' Line='"..tostring(linenum).."'")
	local content=file.Read("../"..path..".lua")
	if !content then
		error("Could not read file") end
	content=string.Explode("\n",content)

	local line=content[linenum]
	if !line then
		error("Could not read line") end

	local wide=tonumber(wide) or 2

	for i=linenum-wide,linenum+wide do
		local line=content[i]
		if line then
			if i==linenum then
				Msg("/* ERR\t*/ "..tostring(line).."\n")
			else
				Msg("/* "..i.."\t*/ "..tostring(line).."\n")
			end
		end

	end

end

function PrintKeys(tbl)
    for k,v in pairs(tbl) do
        MsgN(tostring(k))
    end
end

function PrintKV(tbl)
    for k,v in pairs(tbl) do
        MsgN(tostring(k)..' = '..tostring(v))
    end
end

---------------------------------------
-- get params using debug stuff...
---------------------------------------
function debug.getparams(func)
    local params = {}
	
	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end


------------------------
-- Might be useful
------------------------
local inf,ninf = math.huge,-math.huge
function math.BadNumber(v)
	return !v or v==inf or v==ninf or !(v>=0 or v<=0) --(ind==ind) == false :(
end
math.badnum=math.BadNumber


function getsrc(func)
	return debug.getinfo(func).source
end



local Player=FindMetaTable"Player"

function Player:BotMimic(stop)
	if stop==false then
		return  RunConsoleCommand("bot_mimic",tostring(-1))
	end
	RunConsoleCommand("bot_mimic",tostring(self:EntIndex()-1))
end

local Entity=FindMetaTable"Entity"

Entity.Physics = function(ent)
	local count=ent:GetPhysicsObjectCount()
	local function ipairs_it(ent, i)
		i = i+1
		if i<count+1 then
			--MsgN("GetPhysicsObjectNum(",i-1,")")
			local v = ent:GetPhysicsObjectNum(i-1)
			return i,v
		else
			return nil
		end
	end
	return ipairs_it, ent, 0
end