AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Emergency Light"
ENT.Author = "MetaMan"
ENT.Category = "NutScript - Server"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true
ENT.m_tblToolsAllowed = {}

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
else
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos + trace.HitNormal * 0)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_c17/light_cagelight01_off.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_NONE)

		self.Spotlight1 = ents.Create("point_spotlight")
		self.Spotlight1:SetKeyValue("spotlightwidth", "500")
		self.Spotlight1:SetKeyValue("spotlightlength", "1000")
		self.Spotlight1:SetKeyValue("rendercolor", "255 0 0")
		self.Spotlight1:SetKeyValue("spawnflags", "0")
		self.Spotlight1:SetMoveParent(self)
		self.Spotlight1:SetLocalPos(self:GetUp() * -5)
		self.Spotlight1:Spawn()
		self.Spotlight1:Activate()

		self.Spotlight2 = ents.Create("point_spotlight")
		self.Spotlight2:SetKeyValue("spotlightwidth", "500")
		self.Spotlight2:SetKeyValue("spotlightlength", "1000")
		self.Spotlight2:SetKeyValue("rendercolor", "255 0 0")
		self.Spotlight2:SetKeyValue("spawnflags", "0")
		self.Spotlight2:SetMoveParent(self.Spotlight1)
		self.Spotlight2:SetLocalAngles(Angle(180, 0, 0))
		self.Spotlight2:Spawn()
		self.Spotlight2:Activate()
	end

	function ENT:OnRemove()
		self:SetEnabled(false)

		local spotends = ents.FindByClass("spotlight_end")
		for i = 1, #spotends do
			local spotend = spotends[i]
			local owner = spotend:GetSaveTable().m_hOwnerEntity
			if owner == self.Spotlight1 or owner == self.Spotlight2 then
				spotend:Remove()
			end
		end
	end

	function ENT:Think()
		if self:GetEnabled() then
			local angles = self.Spotlight1:GetAngles()
			angles:RotateAroundAxis(self:GetUp(), 10)
			self.Spotlight1:SetAngles(angles)
			self:NextThink(CurTime() + 0.05)
		else
			self:NextThink(CurTime() + 0.2)
		end

		return true
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Enabled")

	if SERVER then
		self:NetworkVarNotify("Enabled", function(ent, name, old, new)
			if old == new then
				return
			end

			if new then
				ent.Spotlight1:Fire("LightOn", "", 0)
				ent.Spotlight2:Fire("LightOn", "", 0)
				ent:SetModel("models/props_c17/light_cagelight01_on.mdl")
			else
				ent.Spotlight1:Fire("LightOff", "", 0)
				ent.Spotlight2:Fire("LightOff", "", 0)
				ent:SetModel("models/props_c17/light_cagelight01_off.mdl")
			end
		end)
	end
end
