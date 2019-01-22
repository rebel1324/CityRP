ITEM.name = "Medical Stuff"
ITEM.model = "models/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "A Medical Stuff"
ITEM.healAmount = 50
ITEM.healSeconds = 10
ITEM.category = "Medical"

function ITEM:getDesc()
	if (self.entity and IsValid(self.entity)) then
		return L("medicalDescEntity", self.healAmount or 50, self.healSeconds or 10)
	end

	return L("medicalDesc", self.healAmount or 50, self.healSeconds or 10)
end

local function healPlayer(item, client, target, amount, seconds)
	local d = deferred.new()

	if (IsValid(client) and client:IsPlayer()) then
		if (IsValid(target) and target:IsPlayer()) then
			if (target:Alive()) then
				hook.Run("OnPlayerHeal", item, client, target, amount, seconds)
			
				local id = "nutHeal_"..FrameTime()
				timer.Create(id, 1, seconds, function()
					if (!target:IsValid() or !target:Alive()) then
						timer.Destroy(id)	
					end

					target:SetHealth(math.Clamp(target:Health() + (amount/seconds), 0, target:GetMaxHealth()))
				end)

				d:resolve()
			else
				d:reject("notAlive")
			end
		else
			d:reject("noTarget")
		end
	else
		d:reject("error")
	end

	return d
end

local function onUse(client)
	client:EmitSound("items/medshot4.wav", 80, 110)
	client:ScreenFade(1, Color(0, 255, 0, 100), .4, 0)
end

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = { -- sorry, for name order.
	name = "Use",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		local client = item.player
		healPlayer(item, client, client, item.healAmount, item.healSeconds):next(function()
			onUse(client)
			item:remove()
		end, function(error)
			client:notifyLocalized(error)
		end)

		return false
	end,
}

-- On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.usef = { -- sorry, for name order.
	name = "Use Forward",
	tip = "useTip",
	icon = "icon16/arrow_up.png",
	onRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor() -- We don't need cursors.
		local target = trace.Entity

		healPlayer(item, client, target, item.healAmount, item.healSeconds):next(function()
			onUse(target)
			item:remove()
		end, function(error)
			client:notifyLocalized(error)
		end)

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}
