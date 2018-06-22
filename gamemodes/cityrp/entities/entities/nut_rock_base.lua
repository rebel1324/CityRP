AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Mining Rock"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = false
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.Model = "models/props_canal/rock_riverbed01a.mdl"

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 20)
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)

		local physObj = self:GetPhysicsObject()
		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
		end
	end
else
	function ENT:Draw()
		self:DrawModel()
	end
end