CLASS.name = "Hobo"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 30
CLASS.isDefault = false
CLASS.business = {}
CLASS.color = Color(100, 45, 0)
CLASS.limit = 4
CLASS.model = {
	"models/jessev92/player/l4d/m9-hunter.mdl"
}
CLASS.weapons = {
	"wowozela",
}

function CLASS:onLeave(client)
	client:setNetVar("garbage", 0)
end
function CLASS:onSet(client)
	for k, v in ipairs(self.weapons) do
		client:Give(v)
	end
end
CLASS_HOBO = CLASS.index