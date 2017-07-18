ITEM.name = "Perfected Weed"
ITEM.model = "models/props_lab/box01a.mdl"
ITEM.desc = "weedDesc"
ITEM.duration = 100
ITEM.price = 200
ITEM.attribBoosts = {
	["end"] = -5,
	["stm"] = 5,
}

ITEM:hook("_use", function(item)
	item.player:EmitSound("items/battery_pickup.wav")
	item.player:ScreenFade(1, Color(255, 255, 255, 255), 3, 0)
end)

local weedestColor = Color(27, 150, 0)
local weedMat = Material("modernrp/dankweed.png")
function ITEM:drawEntity(entity, item)
	entity:SetColor(weedestColor)
	entity:DrawModel()
	entity.emitter = entity.emitter or ParticleEmitter(entity:GetPos())

	if (entity.emitter) then
		if (!entity.nextEmit or entity.nextEmit < CurTime()) then
			local smoke = entity.emitter:Add(weedMat, entity:GetPos() + entity:OBBCenter())
			smoke:SetVelocity(VectorRand()*20)
			smoke:SetDieTime(math.Rand(0.5,1.3))
			smoke:SetStartAlpha(255)
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(2,4))
			smoke:SetEndSize(math.random(8,12))
			smoke:SetRoll(math.Rand(0, 420))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetGravity(Vector( 0, 0, 15))
			smoke:SetAirResistance(120)

			entity.nextEmit = CurTime() + .4
		end
	end
end
