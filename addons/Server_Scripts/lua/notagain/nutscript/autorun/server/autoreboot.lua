local emptyDelay = 10 * 60
local rebootDelay = 8 * 60 * 60 -- reboot instead of restart if the srcds uptime is longer than this because memory leaks and shit
local TAG = "Automagix_RESTART"
local plids = {}
local killtime = true
local callback

local function isEmpty(uid)
	for k,v in next,player.GetHumans() do
		plids[v:UserID()] = true
	end
	if uid then plids[uid] = nil end
	return next(plids) == nil
end

local function reboot()
	Msg("[Restart] ")print("Rebooting")
	game.ConsoleCommand("exit\n")
	game.ConsoleCommand("shutdown\n")
end

local function restart()
	Msg("[Restart] ")print("Restarting")
	RunConsoleCommand("changelevel", game.GetMap())
end

hook.Add("Think",TAG,function()
	killtime = false
	hook.Remove("Think",TAG)
end)

local function Think()
	if not killtime then
		hook.Remove("Think",TAG)
		return
	end
	local now = SysTime()
	if killtime <= now then
		killtime = false
		callback = callback or restart
		if isEmpty() then
			callback()
		end
	end
end

local function setup_kill(time,cb)
	if not killtime then
		hook.Add("Think",TAG,Think)
	end
	killtime = time and SysTime()+time
	callback = cb
end

local function abort()
	if killtime then
		Msg("[Restart] ")print("Aborted")
	end

	setup_kill()
end
local RealTime=RealTime

local function countdown()
	if killtime then return end
	Msg("[Restart] ")print("Server will restart in " .. emptyDelay .. "s")

	setup_kill(emptyDelay,function()
		if RealTime() > rebootDelay then
			reboot()
		else
			restart()
		end
	end)
end

gameevent.Listen("player_connect")
hook.Add("player_connect",TAG, function(data)
	local uid = data.userid or data.UserID
	if not uid then error"this is bad" end

	if data.bot==1 then return end

	plids[uid] = true

	abort()
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect",TAG, function(data)
	local uid = data.userid or data.UserID
	if not uid then error"this is bad" end

	if data.bot==1 then return end

	if isEmpty(uid) then
		countdown()
	end
end)

concommand.Add('cancelrestart',function()
	abort()
end)
