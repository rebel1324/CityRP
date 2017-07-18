--[[
	Family Account Blocker(FAB) : Version 1.1
	Development by L7D (http://steamcommunity.com/profiles/76561198011675377/)
]]--

if ( CLIENT ) then return end

FAB = FAB or { config = { } }

FAB.config.Enable = true // FAB 시스템을 활성화 또는 비 활성화 합니다.
FAB.config.STEAM_APIKey = "09C5F81FFBE071171AD94ABE9EE11506" // 스팀 API 키를 설정합니다. (http://steamcommunity.com/dev/apikey)
FAB.config.FamilyAccountCallBack = function( pl ) // 플레이어가 가족 계정을 사용해서 접속할 시 실행할 함수를 설정합니다. (일반적인 상황에서는 건드릴 필요가 없습니다.)
	pl:Kick( "[FAB] 이 서버는 가족 공유 계정으로 접속할 수 없습니다." )
	
	FAB.AddLog( pl:Name( ) .. "/" .. pl:SteamID( ) .. " user are kicked by using Family account!" )
	MsgC( Color( 255, 255, 0 ), "[FAB] " .. pl:Name( ) .. "/" .. pl:SteamID( ) .. " user are kicked by using Family account!\n" )
end

if ( !FAB.config.Enable or !FAB.config.STEAM_APIKey or !FAB.config.FamilyAccountCallBack ) then return end

local apiURL = "http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&steamid=%s&appid_playing=4000&format=json"

function FAB.CheckFamilyAccount( pl )
	http.Fetch( Format( apiURL, FAB.config.STEAM_APIKey, pl:SteamID64( ) ), function( data )
			if ( data:find( "Internal Server Error" ) ) then
				MsgC( Color( 255, 0, 0 ), "[FAB ERROR] Can't fetch Information ... [Internal Server Error]\n" )
				return
			end
			
			local dataTable = util.JSONToTable( data )
			
			if ( dataTable and dataTable.response and dataTable.response.lender_steamid ) then
				if ( dataTable.response.lender_steamid != "0" ) then
					if ( FAB.config.FamilyAccountCallBack ) then
						FAB.config.FamilyAccountCallBack( pl )
					end
				end
			else
				MsgC( Color( 255, 0, 0 ), "[FAB ERROR] Can't convert Information ...\n" )
			end
		end, function( err )
			MsgC( Color( 255, 0, 0 ), "[FAB ERROR] Can't fetch Information ...[" .. err .. "]\n" )
		end
	)
end

function FAB.AddLog( str )
	local time = os.date( "*t" )
	local logName = time.year .. "-" .. time.month .. "-" .. time.day
	
	file.Append( "fab/log/" .. logName .. ".txt", "[ " .. logName .. " | " .. time.hour .. "-" .. time.min .. "-" .. time.sec .. " ] " .. str .. "\r\n" )
end

function FAB.Initialize( )
	if ( !FAB.config.Enable ) then return end
	
	file.CreateDir( "fab" )
	file.CreateDir( "fab/log" )
end

function FAB.PlayerAuthed( pl )
	if ( !FAB.config.Enable ) then return end

	timer.Simple( 3, function( )
		if ( IsValid( pl ) ) then
			FAB.CheckFamilyAccount( pl )
		end
	end )
end

hook.Add( "Initialize", "FAB.Initialize", FAB.Initialize )
hook.Add( "PlayerAuthed", "FAB.PlayerAuthed", FAB.PlayerAuthed )