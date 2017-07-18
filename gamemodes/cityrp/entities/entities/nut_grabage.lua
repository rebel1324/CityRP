AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Garbage"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.modelTable = {
	"models/props_junk/PopCan01a.mdl",
	"models/props_junk/plasticbucket001a.mdl",
	"models/props_junk/metal_paintcan001a.mdl",
	"models/props_c17/lamp001a.mdl",
	"models/props_c17/metalPot002a.mdl",
	"models/props_junk/garbage_milkcarton002a.mdl",
	"models/props_junk/garbage_milkcarton001a.mdl",
	"models/props_junk/garbage_metalcan002a.mdl",
	"models/props_junk/garbage_metalcan001a.mdl",
	"models/props_junk/garbage_glassbottle003a.mdl",
	"models/props_junk/garbage_glassbottle002a.mdl",
	"models/props_junk/garbage_glassbottle001a.mdl",
	"models/props_junk/garbage_coffeemug001a.mdl",
	"models/props_junk/garbage_plasticbottle001a.mdl",
	"models/props_junk/garbage_plasticbottle003a.mdl",
	"models/props_junk/garbage_takeoutcarton001a.mdl",
	"models/props_junk/GlassBottle01a.mdl",
}


if (SERVER) then
	CITYRP_JUNKS = CITYRP_JUNKS or {}
	function ENT:Initialize()
		self:SetModel(table.Random(self.modelTable))
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		self:PhysWake()
		CITYRP_JUNKS[self:EntIndex()] = self

		for k, v in ipairs(player.GetAll()) do
			local char = v:getChar()

			if (char) then
				local class = char:getClass()

				if (class != CLASS_HOBO) then
					self:SetPreventTransmit(v, true)
				end
			end
		end

		timer.Simple(100, function()
			if (self and self:IsValid()) then
				self:Remove()
			end
		end)
	end

	function ENT:Use(client)
		if (self:isVisible(client)) then
			self:EmitSound("physics/cardboard/cardboard_box_break"..math.random(1, 3)..".wav")
			client:setNetVar("garbage", client:getNetVar("garbage", 0) + math.random(10, 20))

			self:Remove()
		end
	end

	function ENT:OnTakeDamage(dmginfo)
	end

	function ENT:OnRemove()
		CITYRP_JUNKS[self:EntIndex()] = nil
	end

    -- CityRP only hook
    hook.Add("ResetVariables", "nutTransmitUpdate", function(client, signal)
		local char = client:getChar()

		if (char) then
			local class = char:getClass()

			if (class) then
				if (class == CLASS_HOBO) then
					for k, v in pairs(CITYRP_JUNKS) do
						v:SetPreventTransmit(client, false)
					end
				else
					for k, v in pairs(CITYRP_JUNKS) do
						v:SetPreventTransmit(client, true)
					end
				end
			end	
		end
    end)
else
	function ENT:Draw()
		if (self:isVisible()) then
			self:DrawModel()
		end
	end

	function ENT:onShouldDrawEntityInfo()
		return self:isVisible()
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:LocalToWorld(self:OBBCenter()) + self:GetUp()*25):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"garbage", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText(L"garbaseDesc", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end
end

function ENT:isVisible(client)
	if (CLIENT) then
		client = LocalPlayer()
	end

	local char = client:getChar()

	if (char) then
		local class = char:getClass()

		return (class == CLASS_HOBO)
	end

	return 
end
