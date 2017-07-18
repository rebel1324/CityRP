AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Microwave"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript"
ENT.invType = "microwave"
nut.item.registerInv(ENT.invType, 2, 1)

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props/cs_office/microwave.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:setNetVar("active", false)
		self:SetUseType(SIMPLE_USE)
		self.loopsound = CreateSound(self, "plats/elevator_move_loop1.wav")
		self.receivers = {}
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		nut.item.newInv(0, self.invType, function(inventory)
			self:setInventory(inventory)
			inventory.noBags = true

			function inventory:onCanTransfer(client, oldX, oldY, x, y, newInvID)
				return hook.Run("StorageCanTransfer", inventory, client, oldX, oldY, x, y, newInvID)
			end
		end)
	end

	function ENT:setInventory(inventory)
		if (inventory) then
			self:setNetVar("id", inventory:getID())

			inventory.onAuthorizeTransfer = function(inventory, client, oldInventory, item)
				if (IsValid(client) and IsValid(self) and self.receivers[client]) then
					return true
				end
			end

			inventory.getReceiver = function(inventory)
				local receivers = {}

				for k, v in pairs(self.receivers) do
					if (IsValid(k)) then
						receivers[#receivers + 1] = k
					end
				end

				return #receivers > 0 and receivers or nil
			end
		end
	end
	
	function ENT:activate(seconds)
		if (self:getNetVar("gone")) then
			return
		end

		local timerName = self:GetClass():lower() .. "_" .. self:EntIndex() .. "_stoveThink"
		if (seconds != 0 and !self:getNetVar("active")) then
			seconds = math.abs(seconds)

			timer.Create(timerName, seconds, 1, function()
				if (self and self:IsValid()) then
					self:activate(0)
				end
			end)
		else
			timer.Destroy(timerName)
		end

		self:setNetVar("active", !self:getNetVar("active"))
		self:EmitSound("buttons/lightswitch2.wav")

		if (self:getNetVar("active")) then
			self.loopsound:Play()
			self.loopsound:ChangeVolume(.05, 0)
		else
			self.loopsound:Stop()
		end
	end
	
	function ENT:Use(activator)
		if (self:getNetVar("gone")) then
			return
		end

		local inventory = self:getInv()

		if (inventory and (activator.nutNextOpen or 0) < CurTime()) then
			if (activator:getChar()) then
				activator:setAction("Opening...", 1, function()
					if (activator:GetPos():Distance(self:GetPos()) <= 100) then
						self.receivers[activator] = true
						activator.nutBagEntity = self
						
						inventory:sync(activator)
						netstream.Start(activator, "stvOpen", self, inventory:getID())
					end
				end)
			end

			activator.nutNextOpen = CurTime() + 1.5
		end
	end

	function ENT:OnRemove()
		self.loopsound:Stop()
		
		local index = self:getNetVar("id")

		if (!nut.shuttingDown and !self.nutIsSafe and index) then
			local item = nut.item.inventories[index]

			if (item) then
				nut.item.inventories[index] = nil

				nut.db.query("DELETE FROM nut_items WHERE _invID = "..index)
				nut.db.query("DELETE FROM nut_inventories WHERE _invID = "..index)

				hook.Run("StorageItemRemoved", self, item)
			end
		end
	end

	function ENT:getInv()
		return nut.item.inventories[self:getNetVar("id", 0)]
	end

	function ENT:explode()
		self:setNetVar("gone", true)
		self:setNetVar("active", false)
		self.loopsound:Stop()

		local effectData = EffectData()
		effectData:SetStart(self:GetPos())
		effectData:SetOrigin(self:GetPos())

		self:EmitSound("ambient/explosions/explode_1.wav", 120, 200)
		self:Ignite(3)
		util.Effect("Explosion", effectData, true, true)
		util.BlastDamage( self, self or self, self:GetPos() + Vector( 0, 0, 1 ), 256, 120 )

		timer.Simple(60, function()
			if (self and self:IsValid()) then
				self:Remove()
			end
		end)
	end

	local heatCooks = {
		{0, 3, 1},
		{3, 10, 3},
		{10, 25, 4},
	}
	function ENT:Think()
		if (self:getNetVar("gone")) then
			return
		end

		if (self:getNetVar("active")) then
			local items = self:getInv():getItems(true)

			for k, v in pairs(items) do
				v:setData("heat", v:getData("heat", 0) + 1)

				if (v.ammo) then
					if (v:getData("heat") > 3) then
						self:explode()
					end
				end

				if (v.isFood and v.cookable) then
					local heat = v:getData("heat")
					local cookLevel = v:getData("cooked", 0)
					local overheat = true

					for _, range in ipairs(heatCooks) do
						if (heat >= range[1] and heat < range[2]) then
							if (cookLevel != range[3]) then
								v:setData("cooked", range[3])
							end
							overheat = false

							break
						end
					end

					if (overheat) then
						if (cookLevel != 2) then
							v:setData("cooked", 2)
						end
					end
				end
			end

			self:NextThink(CurTime() + 1)
			return true
		end
	end

	netstream.Hook("stvActive", function(client, entity, seconds)
		local distance = client:GetPos():Distance(entity:GetPos())
		
		if (entity:IsValid() and client:IsValid() and client:getChar() and
			distance < 128) then
			entity:activate(seconds)
		end
	end)
else
	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	local COLOR_ACTIVE = Color(0, 255, 0)
	local COLOR_INACTIVE = Color(255, 0, 0)

	function ENT:Initialize()
		self.emitter = ParticleEmitter(self:GetPos())
		self.nextEmit = 0
	end

	function ENT:DrawTranslucent()
		if (self:getNetVar("gone")) then
			if (self.nextEmit < CurTime()) then
				local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), self:GetPos() + self:OBBCenter() + self:GetRight() * -13)
				smoke:SetVelocity(Vector( 0, 0, 120))
				smoke:SetDieTime(math.Rand(0.2,1.3))
				smoke:SetStartAlpha(math.Rand(150,200))
				smoke:SetEndAlpha(0)
				smoke:SetStartSize(math.random(4,14))
				smoke:SetEndSize(math.random(40,60))
				smoke:SetRoll(math.Rand(180,480))
				smoke:SetRollDelta(math.Rand(-3,3))
				smoke:SetColor(50,50,50)
				smoke:SetGravity( Vector( 0, 0, 120 ) )
				smoke:SetAirResistance(200)

				self.nextEmit = CurTime() + .1
			end
		end

		local position = self:GetPos() + self:GetForward() * -12 + self:GetUp() * 13 + self:GetRight() * -11.5

		render.SetMaterial(GLOW_MATERIAL)
		render.DrawSprite(position, 14, 14, self:getNetVar("active", false) and COLOR_ACTIVE or COLOR_INACTIVE)
	end
	
	function ENT:Draw()
		self:DrawModel()
	end
end
