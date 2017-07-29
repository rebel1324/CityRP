ITEM.name = "Handcuffs"
ITEM.desc = "A tool used to restrain a person, typically used by law enforcement."
ITEM.price = 50
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.functions.Use = {
	onRun = function(item)
		if (item.beingUsed) then
			return false
		end

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (hook.Run("CanPlayerUseTie", client) == false) then return false end

		if (IsValid(target) and target:IsPlayer() and target:getChar() and !target:getNetVar("cuffing") and !target:getNetVar("cuffed")) then
			item.beingUsed = true

			client:EmitSound("physics/plastic/plastic_barrel_strain"..math.random(1, 3)..".wav")
			client:setAction("@cuffing", 5)
			client:doStaredAction(target, function()
				item:remove()

				target:setRestricted(true)
				target:setNetVar("cuffing")

				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 5, function()
				client:setAction()

				target:setAction()
				target:setNetVar("cuffing")

				item.beingUsed = false
			end)

			target:setNetVar("cuffing", true)
			target:setAction("@beingTied", 5)
			--target:SetNetVar( "Float", 1, "Cuffed" )
		else
			item.player:notifyLocalized("plyNotValid")
		end

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}

function ITEM:onCanBeTransfered(inventory, newInventory)
	return !self.beingUsed
end