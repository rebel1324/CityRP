ITEM.name = "Drug Base"
ITEM.model = "models/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "Makes you love dank memes"
ITEM.category = "Illegal"
ITEM.duration = 30

-- sorry, for name order.
ITEM.functions._use = { 
	name = "Use",
	tip = "useTip",
	icon = "icon16/bug.png",
	onRun = function(item)
		local client = item.player
		local char = client:getChar()
		if (char and client:Alive()) then
			if (item.attribBoosts) then
				for k, v in pairs(item.attribBoosts) do
					char:addBoost(item.uniqueID, k, v)
				end
			end
			
			local charID = char:getID()
			local name = item.name
			timer.Create("DrugEffect_" .. item.uniqueID .. "_" .. client:EntIndex(), item.duration, 1, function()
				if (client and IsValid(client)) then
					local curChar = client:getChar()
					if (curChar and curChar:getID() == charID) then
						client:notifyLocalized("drugWornout", name)

						if (item.attribBoosts) then
							for k, v in pairs(item.attribBoosts) do
								char:removeBoost(item.uniqueID, k)
							end
						end
					end
				end
			end)
			
			return true
		end

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}

list.Set("DesktopWindows", "PlayerEditor", {})