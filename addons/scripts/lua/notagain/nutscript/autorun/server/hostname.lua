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



local sv_gamename=CreateConVar( "sv_gamename", "", { FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL } )
hook.Add('GetGameDescription',"custdesc",function() 
	if ret then return "NS - CityRP" or ret end
end)

local function AssignHostname()
	RunConsoleCommand('hostname',"Official Nutscript CityRP Test Server" or hostranname)
end


function AssignNames(host)
	AssignHostname()
end

AssignNames()
timer.Simple(1,AssignNames)
timer.Simple(4,AssignNames)

if type(hostname)=="string" then return end
timer.Create('DynHostname',10,0,AssignHostname)