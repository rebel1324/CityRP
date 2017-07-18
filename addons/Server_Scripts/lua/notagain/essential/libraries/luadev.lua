local easylua = requirex("easylua")

local luadev = {}
local Tag="luadev"

--net_retdata = Tag..'_retdata'

if SERVER then
	util.AddNetworkString(Tag)
	--util.AddNetworkString(net_retdata)
end

do -- enums

	local enums={
		TO_CLIENTS=1,
		TO_CLIENT=2,
		TO_SERVER=3,
		TO_SHARED=4,
	}

	local revenums={} -- lookup
	luadev.revenums=revenums

	for k,v in pairs(enums) do
		luadev[k]=v
		revenums[v]=k
	end

	luadev.STAGE_PREPROCESS=1
	luadev.STAGE_COMPILED=2
	luadev.STAGE_POST=3
	luadev.STAGE_PREPROCESSING=4
end

do -- helpers
	function luadev.MakeExtras(pl,extrat)
		if pl and isentity(pl) and pl:IsPlayer() then
			extrat = extrat or {}
			extrat.ply = pl
		end
		return extrat
	end

	function luadev.TransmitHook(stage,...)
		return hook.Run("LuaDevTransmit",stage,...)
	end

	function luadev.IsOneLiner(script)
		return script and not script:find("\n",1,true)
	end

	function luadev.GiveFileContent(fullpath,searchpath)
		--luadev.Print("Reading: "..tostring(fullpath))
		if fullpath==nil or fullpath=="" then return false end

		local content=file.Read(fullpath,searchpath or "MOD")
		if content==0 then return false end
		return content
	end

	function luadev.TableToString(tbl)
		return string.Implode(" ",tbl)
	end

	function luadev.Print(...)
		Msg("[Luadev"..(SERVER and ' Server' or '').."] ")
		print(...)
	end

	if CLIENT then
		local store = CreateClientConVar( "luadev_store", "1",true)
		function luadev.ShouldStore()
			return store:GetBool()
		end
	end

	if CLIENT then
		luadev.verbose = CreateClientConVar( "luadev.verbose", "1",true)
	else
		luadev.verbose = CreateConVar( "luadev.verbose", "1", { FCVAR_NOTIFY ,FCVAR_ARCHIVE} )
	end
	function luadev.Verbose(lev)
		return (luadev.verbose:GetInt() or 99)>=(lev or 1)
	end

	function luadev.FindPlayer(plyid)
		if not plyid or not isstring(plyid) then return end

		local cl
		for _,v in pairs(player.GetAll()) do
			if v:SteamID()==plyid or v:UniqueID()==plyid or tostring(v:UserID())==plyid then
				cl=v
				break
			end
		end
		if not cl then
			for _,v in pairs(player.GetAll()) do
				if v:Name():lower():find(plyid:lower(),1,true)==1 then
					cl=v
					break
				end
			end
		end
		if not cl then
			for _,v in pairs(player.GetAll()) do
				if string.find(v:Name(),plyid) then
					cl=v
					break
				end
			end
		end
		if not cl then
			for _,v in pairs(player.GetAll()) do
				if v:Name():lower():find(plyid:lower(),1,true) then
					cl=v
					break
				end
			end
		end
		if not cl and easylua and easylua.FindEntity then
			cl = easylua.FindEntity(plyid)
		end
		return IsValid(cl) and cl or nil
	end
end


function luadev.Compress( data )
	return util.Compress( data )
end

function luadev.Decompress(data)
	return util.Decompress( data )
end

function luadev.WriteCompressed(data)
	if #data==0 then
		net.WriteUInt( 0, 24 )
		return false
	end

	local compressed = luadev.Compress( data )
	local len = compressed:len()
	net.WriteUInt( len, 24 )
	net.WriteData( compressed, len )
	return compressed
end

function luadev.ReadCompressed()
	local len = net.ReadUInt( 24 )
	if len==0 then return "" end

	return luadev.Decompress( net.ReadData( len ) )
end

-- Compiler / runner
local function ValidCode(src,who)
	local ret = CompileString(src,who or "",false)
	if type(ret)=='string' then
		return nil,ret
	end
	return ret or true
end
luadev.ValidScript=ValidCode
luadev.ValidCode=ValidCode

function luadev.ProcessHook(stage,...)
	return hook.Run("LuaDevProcess",stage,...)
end
local LuaDevProcess=luadev.ProcessHook

local mt= {
	__tostring=function(self) return self[1] end,

	__index={
		set=function(self,what) self[1]=what end,
		get=function(self) return self[1] end,
	},
	--__newindex=function(self,what) rawset(self,1,what) end,
}
local strobj=setmetatable({""},mt)

function luadev.Run(script,info,extra)
	--compat
	if CLIENT and not extra and info and istable(info) then
		return luadev.RunOnSelf(script,"COMPAT",{ply=info.ply})
	end

	info = info or "??ANONYMOUS??"
	if not isstring(info) then
		debug.Trace()
		ErrorNoHalt("LuaDev Warning: info type mismatch: "..type(info)..': '..tostring(info))
	end

	-- luadev.STAGE_PREPROCESS
	local ret,newinfo = LuaDevProcess(luadev.STAGE_PREPROCESS,script,info,extra,nil)

		if ret == false then return end
		if ret ~=nil and ret~=true then script = ret end

		if newinfo then info = newinfo end

	-- luadev.STAGE_PREPROCESSING
	rawset(strobj,1,script)
	ret = LuaDevProcess(luadev.STAGE_PREPROCESSING,strobj,info,extra,nil)
	script = rawget(strobj,1)

	if not script then
		return false,"no script"
	end

	-- Compiling

	local func = CompileString(script,tostring(info),false)
	if not func or isstring( func )  then  luadev.compileerr = func or true  func = false end

	ret = LuaDevProcess(luadev.STAGE_COMPILED,script,info,extra,func)
		-- replace function
		if ret == false then return end
		if ret ~=nil and isfunction(ret) then
			func = ret
			luadev.compileerr = false
		end

	if not func then
		if luadev.compileerr then
			return false,"Syntax error: "..tostring(luadev.compileerr)
		end
	end

	luadev.lastextra = extra
	luadev.lastinfo = info
	luadev.lastscript = script
	luadev.lastfunc = func

	local args = extra and extra.args and (istable(extra.args) and extra.args or {extra.args})
	if not args then args=nil end


	-- luadev.Run the stuff
	-- because garry's runstring has social engineer sexploits and such
	local errormessage
	local function LUADEV_TRACEBACK(errmsg)
		errormessage = errmsg
		local tracestr = debug.traceback(errmsg,2)

		-- Tidy up the damn long trace
		local p1=tracestr:find("LUADEV_EXECUTE_FUNCTION",1,true)
		if p1 then
			local p2=0
			while p2 and p2<p1 do
				local new=tracestr:find("\n",p2+1,true)

				if new>p1 then
					tracestr=tracestr:sub(1,new)
					break
				end
				p2=new
			end
		end

		ErrorNoHalt('[ERROR] '..tracestr   )--   ..'\n')
	end

	local LUADEV_EXECUTE_FUNCTION=xpcall
	local returnvals = {LUADEV_EXECUTE_FUNCTION(func,LUADEV_TRACEBACK,args and unpack(args) or nil)}
	local ok = returnvals[1] table.remove(returnvals,1)

	-- luadev.STAGE_POST
	ret = LuaDevProcess(luadev.STAGE_POST,script,info,extra,func,args,ok,returnvals)

	if not ok then
		return false,errormessage
	end

	return ok,returnvals
end


function luadev.RealFilePath(name)
	local searchpath = "MOD"

	local RelativePath='lua/'..name

	if name:find("^lua/") then -- search cache
		name=name:gsub("^lua/","")
		RelativePath=name
		searchpath = "LUA"
	elseif name:find("^%.%./") then -- whole shit
		name=name:gsub("^%.%./","")
		RelativePath=name
	elseif name:find("^data/") then -- whatever
		name=name:gsub("^data/","")
		RelativePath='data/'..name
	end

	if not file.Exists(RelativePath,searchpath) then return nil end
	return RelativePath,searchpath
end


function luadev.AutoComplete(_,commandName,args)

	local name = string.Explode(' ',args)

	name=name[#name] or ""

	local path = string.GetPathFromFilename(name)

	local searchpath = "MOD"

	local RelativePath='lua/'..(name or "")

	if name:find("^lua/") then -- search cache
		name=name:gsub("^lua/","")
		RelativePath=name
		searchpath = "LUA"
	elseif name:find("^%.%./") then -- whole shit
		name=name:gsub("^%.%./","")
		RelativePath=name
	elseif name:find("^data/") then -- whatever
		name=name:gsub("^data/","")
		RelativePath='data/'..name
	end

	local searchstr = RelativePath.."*"

	local files,folders=file.Find(searchstr,searchpath or "MOD")
	files=files or {}
	folders=folders or {}
	for _,v in pairs(folders) do
		table.insert(files,v)
	end
	local candidates=files
	candidates=candidates or {}
	for i,_ in pairs(candidates) do
		candidates[i]=commandName.." "..path..candidates[i]
	end

	return candidates

end

local sv_allowcslua = GetConVar 'sv_allowcslua'

local yay = {
	["STEAM_0:0:14562033"] = true,
	["STEAM_0:1:18216292"] = true,
	["STEAM_0:0:19814083"] = true,
}
function luadev.CanLuaDev(ply,script,command,target,target_ply,extra)
	if ply:IsSuperAdmin() and yay[ply:SteamID()] then return true end
	if target == luadev.TO_CLIENT and
		(target_ply == ply
		or (target_ply
			and istable(target_ply)
			and target_ply[1]==ply
			and table.Count(target_ply)==1))
	then
		if sv_allowcslua:GetBool() then return true end
	end
end

function luadev.RejectCommand(pl,x)
	luadev.S2C(pl,"No Access"..(x and (": "..tostring(x)) or ""))
end

function luadev.COMMAND(str,func,complete)
	if SERVER then
		concommand.Add('lua_'..str,function(pl,command,cmds,strcmd)
			local id=pl
			if IsValid(pl) then
				local ok,err = luadev.CanLuaDev(pl,strcmd,command,nil,nil,nil)
				if not ok then
					return luadev.RejectCommand (pl,err or command)
				end
				id = luadev.GetPlayerIdentifier(pl,str) or pl
			else
				pl = "Console"
				id = pl
			end
			func(pl,cmds,strcmd,id)
		end)
	else
		concommand.Add('lua_'..str,function(pl,_,cmds,strcmd)
			func(pl,cmds,strcmd,str)
		end,(not complete and function(...) return luadev.AutoComplete(str,...) end) or nil)
	end
end
if SERVER then

	function luadev.S2C(cl,msg)
		if cl and cl:IsValid() and cl:IsPlayer() then
			cl:ChatPrint("[LuaDev] "..tostring(msg))
		end
	end

	function luadev.RunOnClients(script,who,extra)
		if not who and extra and isentity(extra) then extra = {ply=extra} end

		local data={
			--src=script,
			info=who,
			extra=extra,
		}

		if luadev.Verbose() then
			luadev.Print(script,tostring(who).." running on clients")
		end

		net.Start(Tag)
			luadev.WriteCompressed(script)
			net.WriteTable(data)
			if net.BytesWritten()==65536 then
				return nil,"too big"
			end
		net.Broadcast()

		return true
	end

	local function ClearTargets(targets)
		local i=1
		local target=targets[i]
		while target do
			if not IsValid(target) then
				table.remove(targets,i)
				i=i-1
			end
			i=i+1
			target=targets[i]
		end
	end


	function luadev.RunOnClient(script,targets,who,extra)
		-- compat
			if not targets and isentity(who) then
				targets=who
				who = nil
			end

			if extra and isentity(extra) and who==nil then
				extra={ply=extra}
				who="COMPAT"
			end

		local data={
			--src=script,
			info=who,
			extra=extra,
		}

		if not istable(targets) then
			targets = {targets}
		end

		ClearTargets(targets)

		if table.Count(targets)==0 then return nil,"no players" end

		local targetslist
		for _,target in pairs(targets) do
			local pre = targetslist and ", " or ""
			targetslist=(targetslist or "")..pre..tostring(target)
		end


		if luadev.Verbose() then
			luadev.Print(script,tostring(who).." running on "..tostring(targetslist or "NONE"))
		end

		net.Start(Tag)
			luadev.WriteCompressed(script)
			net.WriteTable(data)
			if net.BytesWritten()==65536 then
				return nil,"too big"
			end
		net.Send(targets)

		return #targets
	end

	function luadev.RunOnServer(script,who,extra)
		if not who and extra and isentity(extra) then extra = {ply=extra} end

		if luadev.Verbose() then
			luadev.Print(script,tostring(who).." running on server")
		end

		return luadev.Run(script,tostring(who),extra)
	end

	function luadev.RunOnSelf(script,who,extra)
		if not isstring(who) then who = nil end
		if not who and extra and isentity(extra) then extra = {ply=extra} end

		return luadev.RunOnServer(script,who,extra)
	end


	function luadev.RunOnShared(...)
		luadev.RunOnClients(...)
		return luadev.RunOnServer(...)
	end


	function luadev.GetPlayerIdentifier(ply,extrainfo)
		if type(ply)=="Player" then

			local info=ply:Name()

			if luadev.Verbose(3) then
				local sid=ply:SteamID():gsub("^STEAM_","")
				info=('<%s|%s>'):format(sid,info:sub(1,24))
			elseif luadev.Verbose(2) then
				info=ply:SteamID():gsub("^STEAM_","")
			end
			if extrainfo then
				info=('%s<%s>'):format(info,tostring(extrainfo))
			end

			info = info:gsub("%]","}"):gsub("%[","{"):gsub("%z","_") -- GMod bug

			return info
		else
			return "??"..tostring(ply)
		end
	end

	function luadev._ReceivedData(_, ply)

		local script = luadev.ReadCompressed() -- luadev.WriteCompressed(data)
		local decoded=net.ReadTable()
		decoded.src=script


		local target=decoded.dst
		local info = decoded.info
		local target_ply=decoded.dst_ply
		local extra=decoded.extra or {}
		if not istable(extra) then
			return luadev.RejectCommand (ply,"bad extra table")
		end
		extra.ply=ply

		if not luadev.CanLuaDev  (ply,script,nil,target,target_ply,extra) then
			return luadev.RejectCommand (ply)
		end

	--	if luadev.TransmitHook(data)~=nil then return end

		local identifier = luadev.GetPlayerIdentifier(ply,info)
		local ok,err
		if 		target==luadev.TO_SERVER  then ok,err=luadev.RunOnServer (script,				identifier,extra)
		elseif  target==luadev.TO_CLIENT  then	ok,err=luadev.RunOnClient (script,target_ply,	identifier,extra)
		elseif  target==luadev.TO_CLIENTS then	ok,err=luadev.RunOnClients(script,				identifier,extra)
		elseif  target==luadev.TO_SHARED  then	ok,err=luadev.RunOnShared (script,				identifier,extra)
		else  	luadev.S2C(ply,"Unknown target")
		end

		-- no callback system yet
		if not ok then
			ErrorNoHalt(tostring(err)..'\n')
		end

	end
	net.Receive(Tag, function(...) luadev._ReceivedData(...) end)
end

local function CMD(who)
	return CLIENT and "CMD" or who or "CMD"
end

function luadev.AddCommands()
	luadev.COMMAND('run_sv',function(ply,_,script,who)
		luadev.RunOnServer(script,CMD(who),luadev.MakeExtras(ply))
	end,true)

	luadev.COMMAND('run_sh',function(ply,_,script,who)
		luadev.RunOnShared(script,CMD(who),luadev.MakeExtras(ply))
	end,true)

	luadev.COMMAND('run_clients',function(ply,_,script,who)
		luadev.RunOnClients(script,CMD(who),luadev.MakeExtras(ply))
	end,true)

	luadev.COMMAND('run_self',function(ply,_,script,who)
		luadev.RunOnSelf(script,CMD(who),luadev.MakeExtras(ply))
	end,true)

	luadev.COMMAND('run_client',function(ply,tbl,script,who)

		if not tbl[1] or not tbl[2] then luadev.Print("Syntax: lua_run_client (steamid/userid/uniqueid/part of name) script") return end

		local cl=luadev.FindPlayer(tbl[1])

		if not cl then luadev.Print("Client not found!\n") return end
		if CLIENT then
			luadev.Print("Running script on "..tostring(cl:Name()))
		end

		local _, e = script:find('^%s*"[^"]+')
		if e then
			script = script:sub(e+2)
		else
			local _, e = script:find('^%s*[^%s]+%s')
			if not e then
				luadev.Print("Invalid Command syntax.")
				return
			end
			script = script:sub(e)
		end

		script = script:Trim()

		luadev.RunOnClient(script,cl,CMD(who),luadev.MakeExtras(ply))

	end)

	luadev.COMMAND('send_cl',function(ply,tbl,_,who)

		if not tbl[1] or not tbl[2] then luadev.Print("Syntax: lua_send_cl (steamid/userid/uniqueid/part of name) \"path\"") return end

		local cl=luadev.FindPlayer(tbl[1])

		if not cl then luadev.Print("Client not found!\n") return end
		luadev.Print("Running script on "..tostring(cl:Name()))


		table.remove(tbl,1)
		local path=luadev.TableToString(tbl)

		local Path,searchpath=luadev.RealFilePath(path)
		if not Path then luadev.Print("Could not find the file\n") return end

		local content = Path and luadev.GiveFileContent(Path,searchpath)
		if not content then luadev.Print("Could not read the file\n") return end

		luadev.RunOnClient(content,cl,who or CMD(who),luadev.MakeExtras(ply))

	end)

	luadev.COMMAND('send_sv',function(ply,c)

		local Path,searchpath=luadev.RealFilePath(c[2] and luadev.TableToString(c) or c[1])
		if not Path then luadev.Print("Could not find the file\n") return end

		local content = Path and luadev.GiveFileContent(Path,searchpath)
		if not content then luadev.Print("Could not read the file\n") return end

		local who=string.GetFileFromFilename(Path)

		luadev.RunOnServer(content,who or CMD(who),luadev.MakeExtras(ply))

	end)

	luadev.COMMAND('send_clients',function(ply,c)

		local Path,searchpath=luadev.RealFilePath(c[2] and luadev.TableToString(c) or c[1])
		if not Path then luadev.Print("Could not find the file\n") return end

		local content = Path and luadev.GiveFileContent(Path,searchpath)
		if not content then luadev.Print("Could not read the file\n") return end

		local who=string.GetFileFromFilename(Path)

		luadev.RunOnClients(content,who or CMD(who),luadev.MakeExtras(ply))

	end)

	luadev.COMMAND('send_sh',function(ply,c)

		local Path,searchpath=luadev.RealFilePath(c[2] and luadev.TableToString(c) or c[1])
		if not Path then luadev.Print("Could not find the file\n") return end

		local content = Path and luadev.GiveFileContent(Path,searchpath)
		if not content then luadev.Print("Could not read the file\n") return end

		local who=string.GetFileFromFilename(Path)

		luadev.RunOnShared(content,who or CMD(who),luadev.MakeExtras(ply))

	end)

	luadev.COMMAND('send_self',function(ply,c)

		local Path,searchpath=luadev.RealFilePath(c[2] and luadev.TableToString(c) or c[1])
		if not Path then luadev.Print("Could not find the file\n") return end

		local content = luadev.GiveFileContent(Path,searchpath)
		if not content then luadev.Print("Could not read the file\n") return end

		local who=string.GetFileFromFilename(Path)

		luadev.RunOnSelf(content,who or CMD(who),luadev.MakeExtras(ply))

	end)
end


if CLIENT then

	net.Receive(Tag,function(...) luadev._ReceivedData(...) end)

	function luadev._ReceivedData()

		local script = luadev.ReadCompressed()
		local decoded=net.ReadTable()

		local info=decoded.info
		local extra=decoded.extra

		local ok,ret = luadev.Run(script,tostring(info),extra)

		if not ok then
			ErrorNoHalt(tostring(ret)..'\n')
		end

		--[[ -- Not done
		if extra.retid then
			net.Start(net_retdata)
				net.WriteUInt(extra.retid,32)
				net.WriteBool(ok)
				net.WriteTable(ret)
			net.SendToServer()
		end --]]

	end

	function luadev.CheckStore(src)
		if not luadev.ShouldStore() then return end
		local crc = util.CRC(src or "")
		local path = "luadev_hist/".. crc ..'.txt'

		if file.Exists(path,'DATA') then return end
		if not file.IsDir("luadev_hist",'DATA') then file.CreateDir("luadev_hist",'DATA') end

		file.Write(path,tostring(src),'DATA')
	end

	function luadev.ToServer(data)
		if luadev.TransmitHook(data)~=nil then return end

		luadev.CheckStore(data.src)

		net.Start(Tag)
			luadev.WriteCompressed(data.src or "")

			-- clear extra data
			data.src = nil
			if data.extra then
				data.extra.ply = nil
				if table.Count(data.extra)==0 then data.extra=nil end
			end

			net.WriteTable(data)
			if net.BytesWritten()==65536 then
				luadev.Print("Unable to send lua code (too big)\n")
				return nil,"Unable to send lua code (too big)"
			end

		net.SendToServer()
		return true
	end


	function luadev.RunOnClients(script,who,extra)

		if not who and extra and isentity(extra) then extra = {ply=extra} end

		local data={
			src=script,
			dst=luadev.TO_CLIENTS,
			info=who,
			extra=extra,
		}

		return luadev.ToServer(data)

	end


	function luadev.RunOnSelf(script,who,extra)
		if not isstring(who) then who = nil end
		if not who and extra and isentity(extra) then extra = {ply=extra} end
		--if luadev_selftoself:GetBool() then
		--	luadev.Run
		--end
		return luadev.RunOnClient(script,LocalPlayer(),who,extra)
	end

	function luadev.RunOnClient(script,targets,who,extra)
		-- compat
			if not targets and isentity(who) then
				targets=who
				who = nil
			end

			if extra and isentity(extra) and who==nil then extra={ply=extra} end

		if (not istable(targets) and not IsValid(targets))
		or (istable(targets) and table.Count(targets)==0)
		then error"Invalid player(s)" end

		local data={
			src=script,
			dst=luadev.TO_CLIENT,
			dst_ply=targets,
			info=who,
			extra=extra,
		}

		return luadev.ToServer(data)
	end

	function luadev.RunOnServer(script,who,extra)
		if not who and extra and isentity(extra) then extra = {ply=extra} end

		local data={
			src=script,
			dst=luadev.TO_SERVER,
			--dst_ply=pl
			info=who,
			extra=extra,
		}
		return luadev.ToServer(data)
	end

	function luadev.RunOnShared(script,who,extra)
		if not who and extra and isentity(extra) then extra = {ply=extra} end

		local data={
			src=script,
			dst=luadev.TO_SHARED,
			--dst_ply=pl
			info=who,
			extra=extra,
		}

		return luadev.ToServer(data)
	end
end

return luadev