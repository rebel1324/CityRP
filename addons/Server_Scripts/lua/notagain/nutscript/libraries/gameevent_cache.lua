local metatable={__index={}}
local PLAYER=function(t)
	setmetatable(t,metatable)
	return t
end
	
local __index=metatable.__index -- okay, this was a bad idea
	 -- __index.Name=function(s) return s.name end
	  __index.GetName=__index.Name
	 -- __index.Nick=__index.Name

	/*  __index.SteamID=function(s) return s.networkid end
	  __index.SteamID64=function(s) return s.communityid end
	  __index.UserID=function(s) return s.userid end
	  __index.Team=function(s) return s.teamid end
	  __index.EntIndex=function(s) return s.index+1 end
	  __index.Team=function(s) return s.teamid end
	  __index.GetTable=function(s) return s end
	  __index.IsValid=function(s) return IsValid(s.Entity) end
	  __index.IsPlayer=function(s) return s.Entity and s.Entity:IsPlayer() end
	  __index.IsBot=function(s) return tobool(s.bot) end
	
	*/

local gameevent=gameevent

-- enums
	local Tag="gameevent"
	
	local player_connect	=	1
	local player_info		=	2
	local player_spawn		=	3
	local player_disconnect	=	4
	local player_activate	=	5
	
	
-- Hooking
	local hooks = {
		"player_connect",
		"player_info",
		"player_spawn",
		"player_disconnect",
		"player_activate",
	}
	for k,v in pairs(hooks) do gameevent.Listen( v ) end

-- Event caching
	local eventcache=gameevent.eventcache or {}
	gameevent.eventcache=eventcache

-- Cache flattening/ merging
	local Now=RealTime
	local function MergeInfo(data,state,noreplace,silent,ignorename)
		
		if data.UserID then -- Garry somehow mangles AT LEAST this in gameevent.Listen
			data.userid=data.userid or data.UserID
			data.UserID=nil
		end
		
		local uid = data.userid
		
		assert(uid~=nil)
		local info = eventcache[uid]
		if not info then
			info = PLAYER{} -- new
			eventcache[uid]=info
		end
		for k,v in pairs(data) do
			
			local prev = info[k]
			
			local empty = prev==nil
			local changed = prev~=v
			
			local noreplace = noreplace
			local silent = silent
			
			-- replace this anyway
			if k=="name" and (prev=="Unconnected" or prev=="unconnected") then
				ErrorNoHalt("unconn: "..tostring(prev)..' - '..tostring(v).."\n")
				noreplace = false
				silent = true
			end
			
			-- Ignore disconnect nick, but only if it's not missing
			if k=="name" and (prev=="Unconnected" or prev=="unconnected") and ignorename then
				ErrorNoHalt("unconn:: "..tostring(prev)..' - '..tostring(v).."\n")
				noreplace = true
				silent = true
			end
			
			-- apply information to cache
			if empty or (changed and not noreplace) then
				if not empty and changed then
					hook.Run("player_info_change",uid,k,prev,v,silent) -- userid, what, prev value, new value, silent update?
				end
				info[k] = v
			end
			
			
		end
		if state then
			info.state=state
			info.statetime=Now()
		end
		info.statetime=info.statetime or Now()
		return info
	end

-- Entity caching
	local entcache={}
	local function GetCache(ply)
		if not ply then return eventcache,entcache end
		return entcache[ply] or eventcache[ply]
	end

-- Extend gameevent table
	gameevent.GetCache=GetCache
	gameevent.MergeInfo=MergeInfo


-- Hooking
	hook.Add('player_connect',Tag,function(data)
		data.teamid=data.teamid or 0
		MergeInfo(data,player_connect)
	end)
	hook.Add('player_activate',Tag,function(data)
		MergeInfo(data,player_activate)
	end)

	hook.Add('player_info',Tag,function(data)
		MergeInfo(data)
	end)
	local function OnEntityCreated(ply)
		if ply:IsPlayer() then
			local data={
				userid=ply:UserID(),
				name=ply:Name(),
				index=ply:EntIndex()-1,
				networkid=ply:SteamID(),
				teamid=ply:Team(),
				communityid=ply:SteamID64() or "BOT",
				Entity=ply,
				bot=ply:IsBot() and 1 or 0,
			}
			local user=MergeInfo(data,nil--[[player_info]],true) -- noreplace as our data may be shit
			entcache[ply]=user
		end
	end

	hook.Add('OnEntityCreated',Tag,OnEntityCreated) -- Assuming fully reliable

	hook.Add('player_spawn',Tag,function(data)
		MergeInfo(data,player_spawn)
	end)
	hook.Add('player_disconnect',Tag,function(data)
		-- Nulling name because we should already have it by now
		MergeInfo(data,player_disconnect,nil,nil,true)
	end)
	
-- Reload
	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			OnEntityCreated(v)
		end
	end

-- Nick Overrides since we do it better
	local Player = FindMetaTable("Player")
	gameevent.EngineNick=gameevent.EngineNick or Player.Nick
	local function GetName(ply)
		if not ply then error "no player?" end
		local info=GetCache(ply)
		return info and info.name or ply and ply.IsValid and ply:IsValid() and gameevent.EngineNick(ply) or tostring(ply)
	end

	Player.GetName = GetName
	Player.GetNick = GetName
	Player.Nick = GetName
	Player.Name = GetName
	
	-- For overriding nick
	gameevent.ChangeNick=function(userid,name,silent)
		if SERVER and isentity(userid) and userid:IsPlayer() then userid=userid:UserID() end
		if not isnumber(userid) then error("#1 parameter is UserID",1) end
		
		local data = {
			userid=userid,
			name=name,
		}
		
		MergeInfo(data,nil--[[player_info]],false,silent) -- noreplace as our data may be shit
		
	end
	