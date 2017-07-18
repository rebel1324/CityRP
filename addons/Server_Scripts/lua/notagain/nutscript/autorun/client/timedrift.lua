timer.Simple(5,function()
	if system.SteamTime()<100000000 then ErrorNoHalt"Steam time is fucked up, bailing out\n" return end
	local diff = os.time()-(system.SteamTime() or os.time())
	diff = math.Round(diff)
	local absdiff=math.abs(diff)
	if absdiff>120 then
		chat.AddText("Your clock differs with server over "..absdiff.." seconds "..(diff>0 and "(You're playing in future)" or "(You're playing in past)")..". Using steam server time instead.")
		ErrorNoHalt("[TIME] Timedrift over "..absdiff..'s'..(diff>0 and " (playing in future)" or " (playing in past)")..', replacing os.time\n')
		os._time = os.time
		os.time = system.SteamTime
	end
end)