ITEM.name = "Doorbust Charge"
ITEM.model = "models/props_c17/consolebox05a.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.price = 600
ITEM.desc = "A Money Printer that you can print money"

-- You can use hunger table? i guess? 
ITEM.functions = ITEM.functions or {}
ITEM.functions.throw = {
	name = "Charge",
	tip = "useTip",
	icon = "icon16/brick.png",
	onRun = function(item)
		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)

		local ent = ents.Create("nut_dcharge")
		local target = trace.Entity

		if (target and IsValid(target) and target:isDoor()) then
			local angles = trace.HitNormal:Angle()
			local axis = Angle(angles[1], angles[2], angles[3])
			angles:RotateAroundAxis(axis:Right(), 90)
			ent:SetParent(target)
			ent:SetPos(trace.HitPos + trace.HitNormal * 3)
			ent:SetAngles(angles)
			ent:Spawn()
			ent:Activate()
			ent:ManipulateBoneScale(0, Vector(1, 1, 1)*.5)

			return true
		end

		return false
	end,
}