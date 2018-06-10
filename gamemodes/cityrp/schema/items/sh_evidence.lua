ITEM.name = "Evidence"
ITEM.model = "models/props_lab/clipboard.mdl"
ITEM.exRender = true
ITEM.removeOnDeath = true
ITEM.iconCam = {
	pos = Vector(132.36241149902, 110.41911315918, 80.376136779785),
	ang = Angle(25, 220, 0),
	entAng = Angle(45.418865203857, 19.908807754517, 0),
	fov = 4.5100308156223,
	outline = true,
	outlineColor = Color(255, 232, 232)
}
function ITEM:getDesc()
    if (IsValid(self.entity)) then
        return L"evidenceWorldDesc"
    else
        return L("evidenceItemDesc", self:getData("victim", "ERROR"), self:getData("attacker", "ERROR"), self:getData("inflictor", "ERROR"), self:getData("deathTime", "ERROR"))
    end
end

ITEM.functions.discard = {
	icon = "icon16/cross.png",
	onCanRun = function(item)
		return true
	end,
	onRun = function(item, data)
		return true
	end,
}

ITEM.functions.doWanted = {
	icon = "icon16/wrench.png",
	onCanRun = function(item)
		return true
	end,
	onRun = function(item, data)
		local attacker = item:getData("attacker")

		if (attacker) then
			local client = nut.util.findPlayer(attacker)

			if (IsValid(client)) then
				hook.Run("OnPlayerReportItem", item, item.player, client)
			end
		end

		return true
	end,
}