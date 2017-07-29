hook.Add("PlayerCanHearPlayersVoice", "voice3d", function(client, talker)
	if talker:GetPos():Distance( client:GetPos() ) > 500 then return false end
end)