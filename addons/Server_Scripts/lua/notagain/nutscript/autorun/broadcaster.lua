

if SERVER then
	util.AddNetworkString("BlackTea_DisplayMSG")
else
	surface.CreateFont("ObjectiveFont", {
		font = "Gungsuh",
		size = ScreenScale(18),
		weight = 800,
		shadow = true,
		extended = true,
	})
	
	local w, h = ScrW(), ScrH()
	local math_clamp = math.Clamp
	local math_round = math.Round
	function CL_FT()
		return math.Clamp(FrameTime(), 1/(60*4), 1)
	end
	
	local objstring = "Activate the button."
	local objalpha = 0
	local objtime = 0
	local objmark = markup.Parse("")
	
	function DisplayObjective( str, t )
		objstring = "<font=ObjectiveFont>".. str .."</font>"
		objalpha = 0
		objtime = CurTime() + (t or 5)
		objmark = markup.Parse(objstring)
		surface.PlaySound("HL1/fvox/blip.wav")

	end
	net.Receive("BlackTea_DisplayMSG", function(len)
		DisplayObjective( net.ReadString(), net.ReadFloat() or 5 )
	end)
	
	local function objectivedisplay()
		if objtime < CurTime() then
			objalpha = math_clamp(Lerp(CL_FT()*2, objalpha, 0), 0, 255)	
		else	
			objalpha = math_clamp(Lerp(CL_FT()*1, objalpha, 255), 0, 255)	
		end
		
		if objalpha <= 0 then return end
		objmark:Draw(math_round(w/2), math_round(h/10*3.3), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, objalpha)
	end
	
	hook.Add("HUDPaint", "BlackTea_Notice", objectivedisplay)
end

local playerMeta = FindMetaTable("Player")
function playerMeta:PrintMessage(tp, msg, t)
	if tp == HUD_PRINTCENTER then
		net.Start("BlackTea_DisplayMSG")
			net.WriteString(msg)
			net.WriteFloat(t or 10)
		net.Send(self)
	elseif tp == HUD_PRINTTALK then
		self:ChatPrint(msg)
	else
		
	end
end


if SERVER then
	hook.Add("Think","darkRP_Regi_mb",function()
		if not DarkRP then return end
		local function MayorBroadcast(ply, args)
			if args == "" then
				DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
				return ""
			end
			if not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].mayor then DarkRP.notify(ply, 1, 4, "You have to be mayor") return "" end
			local DoSay = function(text)
				if text == "" then
					DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))
					return
				end
				for k,v in pairs(player.GetAll()) do
					v:BroadcastMSG(text, 60)
				end
			end
			return args, DoSay
		end
		DarkRP.defineChatCommand("broadcast", MayorBroadcast, 1.5)
		hook.Remove("Think","darkRP_Regi_mb")
	end)
end

if CLIENT then
	local gd = surface.GetTextureID("gui/gradient_up")
	local gd2 = surface.GetTextureID("gui/gradient_down")
	local w, h = ScrW(), ScrH()
	
	surface.CreateFont("NotifierFont", {
		font = "Gungsuh",
		size = 35,
		weight = 1000,
		antialias = true,
		extended = true,
	})
		
	local lifetime = CurTime()
	local standtime = 10
	local alerttime = CurTime()
	local beeptime = CurTime()
	local beepdelay = .7
	local nx = 0
	broadcasty = -50
	local notitext = "Test"
	
	function StandOut( str, len )
		len = len or 20
		notitext = str
		lifetime = CurTime() + len
		alerttime = CurTime() + 2
	end
	
	local function Draw()
		if alerttime < CurTime() then
			if lifetime < CurTime() then
				broadcasty = Lerp(math.Clamp(FrameTime(), 1/60, 1)*1.5, broadcasty, -50)
			else
				broadcasty = Lerp(math.Clamp(FrameTime(), 1/60, 1)*1.5, broadcasty, 0)
			end
			
			if math.Round(broadcasty) > -49 then
				surface.SetDrawColor(255, 255, 255, 255)
				surface.DrawRect(0, math.Round(broadcasty), w, 50)
				surface.SetTexture(gd)
				surface.SetDrawColor(0, 0, 0, 200)
				surface.DrawTexturedRect(0, math.Round(broadcasty) + 50-10, w, 10)
				surface.SetTexture(gd2)
				surface.DrawTexturedRect(0, math.Round(broadcasty) + 0, w, 10)
				
				surface.SetFont( "NotifierFont" )
				local tx, ty = surface.GetTextSize( notitext )
				surface.SetTextColor( 0, 0, 0 )
				surface.SetTextPos( RealTime()*-150%(w+tx)-tx, 50/2 - ty/2 + math.Round(broadcasty) )
				surface.DrawText( notitext )
			end
		else
			if lifetime > CurTime() then
				if beeptime < CurTime() then
					surface.PlaySound("hl1/fvox/bell.wav")
					beeptime = CurTime() + beepdelay
				end
			end
		end
	end
	
	hook.Add("HUDPaint", "BlackTea_Notifier", Draw)
	
	net.Receive("BlackTea_AgendaMSG", function(len)
		StandOut( net.ReadString(), net.ReadFloat() or 5 )
	end)
else	
	util.AddNetworkString("BlackTea_AgendaMSG")
	
	local META = FindMetaTable("Player")	
	function META:BroadcastMSG(msg, t)
		net.Start("BlackTea_AgendaMSG")
			net.WriteString(msg)
			net.WriteFloat(t or 5)
		net.Send(self)
	end
end