
local Player = FindMetaTable"Player"
Player.SetTimeScale=function(p,v)
	local v=tonumber(v) or 1
	v=v>50 and 50 or v<0 and 0 or v
	p:SetSaveValue("m_flLaggedMovementValue",v)
end

Player.GetTimeScale=function(p)
	return p:GetSaveTable().m_flLaggedMovementValue
end