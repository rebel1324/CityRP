AddCSLuaFile()

ENT.Base = "base_anim"
ENT.PrintName = "Keycard Reader"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - Security"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SpawnFunction(client, trace, className)
	if (!trace.Hit or trace.HitSky) then return end

	local spawnPosition = trace.HitPos + trace.HitNormal * 13

	local ent = ents.Create(className)
	local target = trace.Entity

	if (target and IsValid(target)) then
		local angles = trace.HitNormal:Angle()
		local axis = Angle(angles[1], angles[2], angles[3])
		angles:RotateAroundAxis(axis:Right(), 0)
		ent:SetParent(target)
		ent:SetPos(spawnPosition - trace.HitNormal*13)
		ent:SetAngles(angles)
		ent:Spawn()
		ent:Activate()
		ent:ManipulateBoneScale(0, Vector(1, 1, 1)*.5)

		target.keypad = ent
		target:setNetVar("locked", true)

		ent:CallOnRemove("removeParent", function()
			if (IsValid(target)) then
				target.keypad = nil
				target:setNetVar("locked", nil)
			end
		end)
	end
	
	return ent
end

function ENT:Initialize()
	self:SetModel("models/rebel1324/keycard_reader.mdl")


	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:Process(granted)
	self:GetData()
	
	local length, repeats, delay, initdelay, owner, key

	if(granted) then
		self:SetStatus(self.Status_Granted)

		length = self.KeypadData.LengthGranted
		repeats = math.min(self.KeypadData.RepeatsGranted, 50)
		delay = self.KeypadData.DelayGranted
		initdelay = self.KeypadData.InitDelayGranted
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.KeyGranted) or 0
	else
		self:SetStatus(self.Status_Denied)

		length = self.KeypadData.LengthDenied
		repeats = math.min(self.KeypadData.RepeatsDenied, 50)
		delay = self.KeypadData.DelayDenied
		initdelay = self.KeypadData.InitDelayDenied
		owner = self.KeypadData.Owner
		key = tonumber(self.KeypadData.KeyDenied) or 0
	end

	timer.Simple(math.max(initdelay + length * (repeats + 1) + delay * repeats + 0.25, 2), function() -- 0.25 after last timer
		if(IsValid(self)) then
			self:Reset()
		end
	end)

	if(granted) then
		self:EmitSound("buttons/button9.wav")

		local storage = self:GetParent()
		local bool = storage:getNetVar("locked", false)

		if (bool) then
			storage:setNetVar("locked", nil)
		else
			storage:setNetVar("locked", true)
		end
	else
		self:EmitSound("buttons/button11.wav")
	end
end