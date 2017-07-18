CLASS.name = "Hitman"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 180
CLASS.business = {
}
CLASS.weapons = {
	"nut_m_pipe",
}
CLASS.limit = 1
CLASS.color = Color(255, 50, 0)

function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end

function CLASS:onLeave(client)
	client.onVote = nil
	client.voteInfo = nil
end

CLASS_HITMAN = CLASS.index