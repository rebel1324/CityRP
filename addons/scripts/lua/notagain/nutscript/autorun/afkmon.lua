-- AFKMON NUTSCRIPT ONLY

local Tag = "AFKMon"
local Now = SysTime

local MAX_AFK = CreateConVar("mp_afktime","60",{ FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_GAMEDLL },"Seconds until flagged as afk")
local LocalPlayer = LocalPlayer

local ignoreinput = false

local function inp()
	ignoreinput = false
end

local function secToTime( t )
	if (t < 0) then
		return "?"
	elseif (t < 60) then
		return math.floor(t) .."초"
	elseif (t < 3600) then
		return math.floor(t / 60) .."분 "..math.floor(t )%60 .."초"
	elseif (t < 24 * 3600) then
		return math.floor(t / 3600) .. "시 "..math.floor(t / 60)%60 .."분 "..math.floor(t)%60 .."초"
	elseif (t < 7 * 24 * 3600) then
		return math.floor(t / 3600 / 24) .. "일 "..math.floor(t / 3600)%24 .."시 "..math.floor(t / 60)%60 .."분 "
	else
		return math.floor(t / 3600 / 24 / 7) .. "주 "..math.floor(t / 3600 / 24)%7 .. "일 "..math.floor(t / 3600)%24 .."시"
	end
end		

local tstamp = {}
local function ModeChanged(id, isafk)
	client = id
	id = client:UserID()
	
	local tstamp_old = tstamp[id] and (Now() - tstamp[ id ]) or 0
	local tstamp_new = Now() - (isafk and MAX_AFK:GetInt() or 0)
	tstamp[id] = tstamp_new
	
	-- to make any AFK inputs go away
	if (CLIENT and client == LocalPlayer()) then
		ignoreinput = true
		timer.Simple(0.1, inp)
	end

	hook.Run("AFK", client, isafk, id, tstamp_old, tstamp_new)
end

local playerMeta = FindMetaTable("Player")

function playerMeta:IsAFK()
	return (self:getNetVar("afk"))
end

function playerMeta:AFKTime()
	return (Now() - (tstamp[self:UserID() or -1] or Now()))
end

hook.Add("AFK",Tag,function(client, afk, id, len)
	if (SERVER) then
		if (afk) then
			timer.Create("AFKDEMOTE_" .. client:SteamID64(), nut.config.get("afkDemote", 1), 1,function() 
				hook.Run("OnPlayerAFKLong", client)
			end)

			--client:EmitSound("ui/boop.wav")
		else
			timer.Remove("AFKDEMOTE_" .. client:SteamID64())

			--client:EmitSound("ui/boop.wav")
		end
		return
	end
	
	/*
	Msg"[AFK] "
	local name = (IsValid(client) and client:Name() or id)
	local niceTime = string.NiceTime(len or 0)

	if (afk) then
		print(Format("%s님은 이제 잠수중입니다. (%s 동안 있었음)", name, niceTime))
	else
		print(Format("%s님은 이제 활동중입니다. (%s 동안 잠수였음)", name, niceTime))
	end

	if (client != LocalPlayer()) then return end

	if (!afk) then
		chat.AddText(Color(100,255,100,255),"돌아오셨군요",Color(50,200,50,255),"!",Color(255,255,255,255)," 돌아오는데 걸린시간은 ",Color(200,200,255,255),secToTime(len).." 입니다",Color(100,255,100,255),".")	
	end*/
end)

hook.Add("AFKMonChanged",Tag,function(pl, isafk)
	if (isafk == true or isafk == false or isafk == nil) then
		ModeChanged(pl, isafk)
	end
end)

if (SERVER) then
	hook.Add("InitializedSchema", "ass", function()
		netstream.Hook("AFKMonGoner", function(client, bool)
			client:setNetVar("afk", bool)
			hook.Run("AFKMonChanged", client, bool)
		end)
	end)
else
	local function SetAFKMode(client, afk)
		local bool = (afk and true) or falses
		netstream.Start("AFKMonGoner", bool)
		hook.Run("AFKMonChanged", client, bool)
	end

	local local_afk	
	local last_input = Now()+5 -- mouse coords
	local last_focus = Now() + 5
	local function InputReceived()
		if ignoreinput then return end
		last_input = Now()
	end

	local last_mouse = Now()+5

	local oldmouse = 1
	local mx,my = gui.MouseX,gui.MouseY
	local function Think()

		local newmouse = mx() + my()
		if (newmouse != oldmouse) then
			oldmouse = newmouse
			last_mouse = Now()
		end
		if (system.HasFocus()) then
			last_focus = Now()
		end
	
		local max = MAX_AFK:GetInt()
		local var = Now()-max
		local client = LocalPlayer()
		if (last_mouse < var and last_input < var) or last_focus < var then
			if not local_afk then
				local_afk = true
				SetAFKMode(client, true )
			end
		elseif (local_afk) then
			local_afk = false
			SetAFKMode(client, false )
		end

	end

	timer.Simple(10,function() -- waiting a bit
		timer.Create(Tag,0.2,0,Think)
	end)

	-- The following is for view input
	hook.Add( "KeyPress", Tag, InputReceived )
	hook.Add( "KeyRelease", Tag, InputReceived )
	hook.Add( "PlayerBindPress", Tag, InputReceived )

	do -- some hacky key checking
		local oldkeys = nil
		local old_y   = nil
		local last_32 = false
		local last_33 = false
		local last_27 = false
		local last_29 = false
		local last_31 = false
		local last_19 = false
		local last_11 = false
		local last_14 = false
		local last_15 = false
		local last_25 = false
		local last_79 = false
		local last_65 = false

		local isdown=input.IsKeyDown
		local function CheckStuff(UCMD)

			if (oldkeys != UCMD:GetButtons() )then
				InputReceived()
				oldkeys = UCMD:GetButtons()
			end

			if (old_y != UCMD:GetMouseX()) then
				InputReceived()
				old_y = UCMD:GetMouseX()
			end

			-- Unrolled loop for maximum efficiency
			-- Checking only some keys so we don"t bloat the game with these.
			if isdown(33)~=last_33 then
				last_33 = isdown(33)
				InputReceived()
				return
			end
			if isdown(27)~=last_27 then
				last_27 = isdown(27)
				InputReceived()
				return
			end
			if isdown(29)~=last_29 then
				last_29 = isdown(29)
				InputReceived()
				return
			end
			if isdown(31)~=last_31 then
				last_31 = isdown(31)
				InputReceived()
				return
			end
			if isdown(19)~=last_19 then
				last_19 = isdown(19)
				InputReceived()
				return
			end
			if isdown(11)~=last_11 then
				last_11 = isdown(11)
				InputReceived()
				return
			end
			if isdown(14)~=last_14 then
				last_14 = isdown(14)
				InputReceived()
				return
			end
			if isdown(15)~=last_15 then
				last_ = isdown(15)
				InputReceived()
				return
			end
			if isdown(25)~=last_25 then
				last_25 = isdown(25)
				InputReceived()
				return
			end
			if isdown(32)~=last_32 then
				last_32 = isdown(32)
				InputReceived()
				return
			end
			if isdown(79)~=last_79 then
				last_79 = isdown(79)
				InputReceived()
				return
			end
			if isdown(65)~=last_65 then
				last_65 = isdown(65)
				InputReceived()
				return
			end
		end
		hook.Add("CreateMove", Tag, CheckStuff)
	end
end
