if (!FPP_MySQLConfig) then
	Msg"what"
end

nut.vote.list = nut.vote.list or {}
nut.vote.incr = nut.vote.incr or 0

function nut.vote.start(title, recipient, callback)
	local id = nut.vote.incr
	nut.vote.list[id] = {
		players = {},
		callback = callback,
	}

	for k, v in ipairs(recipient) do
		nut.vote.list[id].players[v:UniqueID()] = -1
	end

	timer.Create("nutVote_"..id, 10, 1, function()
		nut.vote.list[id].callback(nut.vote.list[id])
	end)

	netstream.Start(recipient, "voteRequired", id, title)

	nut.vote.incr = id + 1
end

netstream.Hook("nutVote", function(client, id, response)
	if (nut.vote.list[id]) then
		nut.vote.list[id].players[client:UniqueID()] = tonumber(response)
	end

	local votedPlayers = nut.vote.list[id].players
	local unVoted = 0

	for k, v in pairs(votedPlayers) do
		if (v == -1) then
			unVoted = unVoted + 1
		end
	end

	if (unVoted == 0) then
		nut.vote.list[id].callback(nut.vote.list[id])
		timer.Remove("nutVote_"..id)
	end
end)

function nut.vote.simple(title, newCallback)
	nut.vote.start(title, player.GetAll(), function(vote)
		local poll = vote.players
		local min = #poll / 2
		local agree, disagree, surrender = 0, 0, 0

		for k, v in pairs(poll) do
			if (v == 1) then
				agree = agree + 1
			elseif (v == 0) then
				disagree = disagree + 1
			elseif (v == -1) then
				surrender = surrender + 1
			end
		end

		newCallback(poll, agree, disagree, surrender)
	end)
end

netstream.Hook("nutHitmanAccept", function(hitman, response)
	local char = hitman:getChar()
	if (!char) then return end

	local class = char:getClass()
	if (class != CLASS_HITMAN) then return end

	if (response == 1) then
		local info = hitman.voteInfo
		local cost = nut.config.get("hitCost", 250)

		if (info) then
			hitman.onHitVote = false
			hitman:setHitTarget(info.target, info.client, info.reason)
			info.client:getChar():giveMoney(-cost)
		end
		
		hitman.voteInfo = nil
	end
end)

function SCHEMA:UpdateWeedVendors()
	for k, v in ipairs(ents.GetAll()) do
		if (v:GetClass() == "nut_vendor") then
			v.scale = math.min(v.scale + 0.4, WEEDTABLE.max)
		end
	end
end
timer.Create("nutVendorWeedSell", nut.config.get("vendorWeedInterval", 3600), 0, SCHEMA.UpdateWeedVendors)

function SCHEMA:OnCharTradeVendor(client, entity, uniqueID, isSellingToVendor)
	if (isSellingToVendor) then
		nut.log.add(client, "sell", uniqueID)
	else
		nut.log.add(client, "buy", uniqueID)
	end

	if (isSellingToVendor) then
		if (entity:getNetVar("name") == "Narcotic") then
			if (entity.items and entity.items["raweed"]) then
				entity.scale = math.max(entity.scale - 0.03, WEEDTABLE.min)

				netstream.Start(client, "nutUpdateWeed", entity, entity.scale)
			end
		end
	end
end

function SCHEMA:UpdateVendors()
	for k, v in ipairs(ents.GetAll()) do
		if (v:IsPlayer()) then
			v:notifyLocalized("vendorUpdated")
		end

		if (v:GetClass() == "nut_vendor") then

			if (v:getNetVar("name") == "Black Market Dealer") then
				v.currentStock = v.currentStock or 0
				v.currentStock = (v.currentStock + 1) % #WEAPON_STOCKS

				local data = WEAPON_STOCKS[v.currentStock + 1] or WEAPON_STOCKS[1]

				if (data) then
					v:setNetVar("desc", data.desc)
					v.items = {}

					for itemID, stockData in pairs(data.stocks) do
						v.items[itemID] = v.items[itemID] or {}

						v.items[itemID][VENDOR_MODE] = VENDOR_SELLONLY
						v.items[itemID][VENDOR_PRICE] = stockData.price
						v.items[itemID][VENDOR_MAXSTOCK] = stockData.amount
						v.items[itemID][VENDOR_STOCK] = stockData.amount
					end
				end
			end
		end
	end
end
timer.Create("nutVendorSell", nut.config.get("vendorInterval", 3600), 0, SCHEMA.UpdateVendors)

local whitelist = {
	["Text"] = true,
	["Font"] = true,
	["Type"] = true,
	["FontSize"] = true,
	["OutSize"] = true,
	["AnimSpeed"] = true,
	["Neon"] = true,
	["ColorBack"] = true,
	["ColorText"] = true,
	["ColorOut"] = true,
}
	
netstream.Hook("nutBingle", function(client, entity, mod, value)
	if (IsValid(entity) and whitelist[mod]) then
		if (entity:CPPIGetOwner() != client and !client:IsAdmin()) then
			return true
		end

		local func = entity["Set" .. mod]

		if (value and type(value) == "table") then
			value = Vector(value.r, value.g, value.b)
		end

		if (func) then	
			func(entity, value)
		end
	end
end)


function saveall()
	for k, v in ipairs(player.GetAll()) do
		local char = v:getChar()
		
		if (char) then
			char:save()
		end
	end
end
