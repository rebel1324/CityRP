ITEM.name = "Security Keycard Reader"
ITEM.desc = "keycardDesc"
ITEM.model = "models/props_lab/keypad.mdl"
ITEM.price = 500

ITEM.functions.use = { -- sorry, for name order.
	name = "lock",
	tip = "useTip",
	icon = "icon16/arrow_up.png",
	onRun = function(item)
		local client = item.player
		local trace = client:GetEyeTraceNoCursor() -- We don't need cursors.
		local target = trace.Entity

		local dist = client:GetPos():Distance(target:GetPos())
		if (dist > 96) then client:notifyLocalized("tooFar") return false end

		if (target and target:IsValid()) then
			if (target:GetClass() == "nut_storage" or target.lockable) then
				if (!IsValid(target.keypad)) then
					client:notifyLocalized("keypadSetup") 
					client:notifyLocalized("keypadSetup2") 

					local spawnPosition = trace.HitPos + trace.HitNormal * 16
					local ent = ents.Create("nut_sec_keycard")
					local angles = trace.HitNormal:Angle()
					local axis = Angle(angles[1], angles[2], angles[3])
					angles:RotateAroundAxis(axis:Right(), 0)
					ent:SetParent(target)
					ent:SetPos(spawnPosition - trace.HitNormal*13)
					ent:SetAngles(angles)
					ent:Spawn()
					ent:Activate()
					ent:ManipulateBoneScale(0, Vector(1, 1, 1)*.5)
					ent:CPPISetOwner(client)

					target.keypad = ent
					target:setNetVar("locked", true)

					ent:CallOnRemove("removeParent", function()
						if (IsValid(target)) then
							target.keypad = nil
							target:setNetVar("locked", nil)
						end
					end)

					return true
				else
					client:notifyLocalized("alreadyKeypad") 
				end
			else
				client:notifyLocalized("notStorage") 
			end
		end

		return false
	end,
	onCanRun = function(item)
		if (IsValid(item.entity)) then return false end

		local client = item.player
		if (CLIENT) then client = LocalPlayer() end

		return true
	end
}
