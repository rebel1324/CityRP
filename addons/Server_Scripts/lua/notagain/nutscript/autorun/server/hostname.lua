local ip = GetConVarString("ip")
local port = GetConVarString"hostport"

local function nowtime()
	local hour=os.date("%H")
	local APM =" AM"
	if(tonumber(hour)>=12)then
		APM = " PM"
	end
	if(tonumber(hour)>12)then
		hour = hour%12
	end
	local str=hour..os.date(":%M:%S")..APM
	return str
end

local hostname
local function DoMsg(...)Msg"[SERVER] " MsgN(...)end
local nhname = "RealGaming.kr 라크알피 시즌5  "

local gamemode_name=nil

local slogans = [[
24시간 라크서버!
있을건 다있다!
ATM이자로 돈벌자
마약팔아서 돈벌기
도박으로 돈벌어보자
서버파일 허용 필수
은행털기|ATM|인벤토리
MOTD 필독바랍니다
한국 RP서버의 종착역
]]

slogans=string.Explode("\n",slogans)
local _slogans={}
for k,v in pairs(slogans) do
	local slogan=v:Trim()
	
	if slogan:len()>1 then 
		table.insert(_slogans,slogan)
	end
end
slogans = _slogans

if ip == "localhost" then
	if port=="27018" or port=="27017" or port=="27019" then 
		DoMsg("RealGaming.kr LacRP Season5")
		hostname = {}
		
		for k,slogan in pairs(slogans) do
			hostname[k]= nhname.."["..slogan.."]"
		end
	end	
	gamemode_name="라크알피 시즌5"
else
	return 
end



local sv_gamename=CreateConVar( "sv_gamename", "", { FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL } )
hook.Add('GetGameDescription',"custdesc",function() 
		
		local mode=sv_gamename:GetString()
		local ret = mode:len()>0 and mode or gamemode_name
		if ret then return "NS - CityRP Dev Server [Ask Password to join]" or ret end
end)

local function AssignHostname()
	hostname = hostname or {"NS - CityRP Dev Server [Ask Password to join]"}
	--local hostranname = type(hostname)=="string" and hostname or math.Rand(0,100) < (100/#slogans) and nhname.."[현재시간 "..nowtime().."]" or table.Random(hostname)
	local hostranname =  table.Random(hostname)
	RunConsoleCommand('hostname',"NS - CityRP Dev Server [Ask Password to join]" or hostranname)
end


function AssignNames(host)
	AssignHostname()
end

AssignNames()
timer.Simple(1,AssignNames)
timer.Simple(4,AssignNames)

if type(hostname)=="string" then return end
timer.Create('DynHostname',10,0,AssignHostname)