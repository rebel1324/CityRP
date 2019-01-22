AddCSLuaFile()

ENT.Base = "nut_storage"
ENT.PrintName = "Microwave"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript"
ENT.isCooker = true
ENT.StorageInfo = {
	name = "microwave",
	desc = "microwaveDesc",
	invType = "grid",
	invData = {
		w = 2,
		h = 1
	}
}
ENT.cookerModel = "models/props_wasteland/prison_shelf002a.mdl"

function ENT:getStorageInfo()
	return self.StorageInfo
end

if (SERVER) then
	function ENT:PostInitialize()
		self:SetModel(self.cookerModel)
		self:setNetVar("active", false)
		self.loopsound = CreateSound(self, "ambient/fire/fire_small_loop1.wav")

		local data = self:getStorageInfo()
		nut.inventory.instance(data.invType, data.invData)
			:next(function(inventory)
				if (IsValid(self)) then
					inventory.isStorage = true
					self:setInventory(inventory)
					if (isfunction(data.onSpawn)) then
						data.onSpawn(storage)
					end
				end
			end, function(err)
				ErrorNoHalt(
					"Unable to create storage entity for "..client:Name().."\n"..
					err.."\n"
				)
				if (IsValid(storage)) then
					self:Remove()
				end
			end)
	end

	local heatCooks = {
		{0, 3, 1},
		{3, 10, 3},
		{10, 25, 4},
	}

	local function tryCook(entity)
		local d = deferred.new()

		if (not entity:getNetVar("gone")) then
			if (entity:getNetVar("active")) then
				local inventory = entity:getInv()

				if (inventory) then
					local items = inventory:getItems()

					for id, item in pairs(items) do
						item:setData("heat", item:getData("heat", 0) + 1)

						if (item.ammo) then
							if (item:getData("heat") > 3) then
								self:explode()
							end
						elseif (item.isFood and item.cookable) then
							if (item.specialCooker) then
								if (self:canCookThis(item) == false) then
									continue
								end
							end

							local heat = item:getData("heat")
							local cookLevel = item:getData("cooked", 0)
							local overheat = true

							for _, range in ipairs(heatCooks) do
								if (heat >= range[1] and heat < range[2]) then
									if (cookLevel != range[3]) then
										item:setData("cooked", range[3])
									end
									overheat = false

									break
								end
							end

							if (overheat) then
								if (cookLevel != 2) then
									item:setData("cooked", 2)
								end
							end
						end
					end

					d:resolve()
				else
					d:reject("Inventory is not valid.")
				end
			else
				d:reject("Cooker is not active.")
			end
		end

		return d:reject("Cooker is not valid")
	end

	function ENT:canCookThis(item)
		return false
	end

	function ENT:activate(seconds)
		if (self:getNetVar("gone")) then
			return
		end

		local timerName = self:GetClass():lower() .. "_" .. self:EntIndex() .. "_stoveThink"
		local timerNameCooker = self:GetClass():lower() .. "_" .. self:EntIndex() .. "_stoveThink_cooker"

		if (seconds != 0 and !self:getNetVar("active")) then
			seconds = math.abs(seconds)

			timer.Create(timerNameCooker, 1, 0, function()
				if (IsValid(self)) then
					tryCook(self):next(function()
						--print("COOKING IN PROGRESS")
					end, function(error)
						--print("STOVE ERROR" .. error)
						timer.Destroy(timerNameCooker)
					end)
				else
					timer.Destroy(timerNameCooker)
				end
			end)

			timer.Create(timerName, seconds, 1, function()
				if (self and self:IsValid()) then
					self:activate(0)
				end
			end)
		else
			timer.Destroy(timerName)
			timer.Destroy(timerNameCooker)
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
		--util.BlastDamage( self, self or self, self:GetPos() + Vector( 0, 0, 1 ), 256, 120 )

		timer.Simple(15, function()
			if (self and self:IsValid()) then
				self:Remove()
			end
		end)
	end

	local function toggleStove(entity, client)
		local d = deferred.new()

		if (IsValid(entity) and IsValid(client) and client:getChar()) then
			local distance = client:GetPos():Distance(entity:GetPos())

			if (distance < 128) then
				return d:resolve()
			else
				return d:reject("tooFar")
			end
		else
			return d:reject("notValid")
		end

		return d:reject("unknown")
	end

	netstream.Hook("stvActive", function(client, entity, seconds)
		toggleStove(entity, client):next(function()
			if (IsValid(entity)) then
				entity:activate(seconds)
			end
		end, function(error)
			if (IsValid(client)) then
				client:notifyLocalized(error)
			end
		end)
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