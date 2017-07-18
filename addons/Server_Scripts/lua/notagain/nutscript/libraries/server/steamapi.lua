local decode  = util.JSONToTable

local apikey=file.Read("cfg/apikey.cfg",'GAME') or file.Read("steamapikey.txt",'DATA')
apikey=apikey and string.Trim(apikey) -- silly newlines
if not apikey or #apikey==0 then
	MsgC(Color(255, 127, 127), debug.getinfo(1).source .. " Need cfg/apikey.cfg with http://steamcommunity.com/dev \n")
	return
end

local apilist

local function GenAPIList(list)
	local l={}
	
	for k,v in next,list.apilist.interfaces do
		local tbl = {}
		l[v.name]=tbl
		
		for kk,vv in next,v.methods do
			local t=tbl[vv.name] or {}
			tbl[vv.name]=t
				vv.name=nil
			t[vv.version]=vv
				vv.version=nil
		end
		
	end
	apilist=l
	
end

local steam_api_list=file.Read("steam_api_list.txt",'DATA')
if steam_api_list and #steam_api_list>10 then
	local ok,list = pcall(decode,steam_api_list)
	if ok then GenAPIList(list) end
end

if not apilist then
	local err = function(err)
		ErrorNoHalt("Steam API List Failed: "..err)
		apilist = false
	end
	
	http.Fetch("http://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key="..apikey..'&format=json',function(content)
		if not content then return err("NODL") end
		local ok,list = pcall(decode,content)
		if not ok or not list then return err("JSONERR") end
		GenAPIList(list)
		file.Write("steam_api_list.txt",content)
	end,err)
end




local get={	key=apikey,	format="json" }

local enc=function(dat)
	if isentity(dat) then return dat:SteamID64() or util.SteamID64(dat:SteamID()) end
	return dat
end

local function getkeys(additional)
	if not istable(additional) then
		if isstring(additional) then return additional end
		if isentity(additional) then return enc(additional) end
		error"need a table as extra params"
	end
	local str
    local first=true
    local tbl={}
    for k,v in pairs(get) do
		if first then
			str=k..'='..v
			first=false
		else
			str=str..'&'..k..'='..v
		end
    end
	
    for k,v in pairs(additional or {}) do
		if isnumber(k) then
			if isstring(v) or isentity(v) then
				k='steamid'

			else
				error"wtf"
			end
		end
		if first then
			str=k..'='..enc(v)
			first=false
		else
			str=str..'&'..k..'='..enc(v)
		end
    end
    return str
end

local function API(interface,method,version,additional)
	if not apilist then error"apilist missing!?" end
	
	local iface = apilist[interface]
	if not iface then error("Invalid Interface: "..interface) end
	
    local methods=iface[method]
	if not methods then error("Invalid method: "..method) end
    
    local data = methods[tonumber(version)]
    if not data then error("Invalid method version: "..version) end
    
	-- check required params
	for k,v in next,data.parameters do
		if not v.optional then
			local txt = v.name
			if txt=="key" then continue end
			local found = false
			for k,v in next,additional do
				if txt:find(k,1,true) then
					found=true
					break
				end
			end
			if not found then
				error("Missing required parameter "..txt)
			end
		end
	end
	
	-- mangle POST requests
	local ispost = data.httpmethod=="POST"
	local postparam
	if ispost then
		postparam={}
		for k,v in next,additional do
			if istable(v) then
				for kk,vv in next,v do
					postparam[k..'['..(kk-1)..']']=tostring(vv)
				end
			else
				postparam[tostring(k)]=tostring(v)
			end
		end
	end

	--finally generate URL
	local add = getkeys(ispost and {} or additional)
    local url=string.format(
    	'http://api.steampowered.com/%s/%s/v%.4d/?%s',
								interface,method,version or 1,add)
	
	return url,postparam
end


local function SteamAPI(interface,method,version,additional,cb,err)
	local url,postparam = API(interface,method,version,additional)
	
	
	local function callback( body, bodylen, headers, code )
		if code~=200 or not body or bodylen==0 then
			return err and err(code,body)
		end
		local ok,dec = pcall(decode,body)
		if not ok then
			return err and err(dec)
		end
		cb(dec)
	end
			
	if not postparam then
		http.Fetch(url,callback,err)
	else
		http.Post(url,postparam,callback,err)
	end
	
end
_G.SteamAPI=SteamAPI

function GetPlayerBans(pl,cb,err)
	SteamAPI('ISteamUser','GetPlayerBans',1,{steamids=pl},cb,err)
end
function GetFriendList(pl,cb,err)
	SteamAPI('ISteamUser','GetFriendList',1,{steamid=pl},cb,err)
end



function GetPlayerSummaries(pl,cb,err)
	SteamAPI('ISteamUser','GetPlayerSummaries',2,{steamids=pl},cb,err)
end
function UpToDateCheck(cb,err)
	SteamAPI('ISteamApps','UpToDateCheck',1,{appid=4000,version=file.Read('steam.inf','GAME'):match("ersion=([%.%d]+)"):gsub("%.","")},function(resp)
		resp=resp and resp.response
		if not resp or resp.success==false or resp.error then
			return err and err(resp and resp.error,resp and resp.success)
		end
			
		cb(resp.up_to_date,resp.version_is_listable)
	end,err)
end
function GetNumberOfCurrentPlayers(cb,err,appid)
	SteamAPI('ISteamUserStats','GetNumberOfCurrentPlayers',1,{appid=appid or 4000},function(resp)
		resp=resp and resp.response
		if not resp or resp.result==0 or resp.error then
			return err and err(resp and resp.error,resp and resp.result)
		end
			
		cb(resp.player_count)
	end,err)
end

function GetServersAtAddress(addr,cb,err)
	SteamAPI('ISteamApps','GetServersAtAddress',1,{addr=addr},function(resp)
		resp=resp and resp.response or resp
		if not resp or resp.result==0 or resp.error then
			return err and err(resp and resp.error,resp and resp.result)
		end
			
		cb(resp)
	end,err)
end

function GetPublishedFileDetails(fileid,cb,err)
	SteamAPI('ISteamRemoteStorage','GetPublishedFileDetails',1,{itemcount=1,['publishedfileids[0]']=tostring(fileid)},function(resp)
		resp=resp and resp.response or resp
		if not resp or resp.result~=1 or resp.error then
			return err and err(resp and resp.error,resp and resp.result)
		end
			
		cb(resp.publishedfiledetails[1])
	end,err)
end


