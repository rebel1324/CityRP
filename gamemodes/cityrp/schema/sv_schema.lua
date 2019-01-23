if (!FPP_MySQLConfig) then
	Msg"what"
end

nut.vote.list = nut.vote.list or {}

function nut.vote.start(title, recipient, callback)
	local d = deferred.new()
	local id = string.format("%08d", math.random(0, 99999999))

	nut.vote.list[id] = {}

	for k, v in ipairs(recipient) do
		nut.vote.list[id][v:UniqueID()] = -1
	end

	netstream.Start(recipient, "voteRequired", id, title)
	timer.Create("nutVote_"..id, NUT_VOTE_TIME, 1, function()
		local result = table.Copy(nut.vote.list[id])
		nut.vote.list[id] = nil

		d:resolve(result)
	end)

	return d
end

netstream.Hook("nutVote", function(client, id, response)
	if (nut.vote.list[id]) then
		nut.vote.list[id][client:UniqueID()] = tonumber(response)
	end
end)

function nut.vote.simple(title)
	local d = deferred.new()

	nut.vote.start(title, player.GetAll()):next(function(poll)
		local context = {table.Count(poll), 0, 0, 0}

		for k, v in pairs(poll) do
			if (v == 1) then
				context[2] = context[2] + 1 -- agree
			elseif (v == 0) then
				context[3] = context[3] + 1 -- surrender
			elseif (v == -1) then
				context[4] = context[4] + 1 -- disagree
			end
		end

		d:resolve(context)
	end, function(err)
		d:reject(err)
	end)

	return d
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

nut.map = nut.map or {}
nut.map.ents = {}

function nut.map.sync(client)
	netstream.Start(client, "nutMapSync", nut.map.ents)
end

function nut.map.add(entity)
	nut.map.ents[entity:EntIndex()] = entity
end

function nut.map.remove(entity)
	nut.map.ents[entity:EntIndex()] = nil
end

function nut.map.removeInvalid()
	for k, v in pairs(nut.map.ents) do
		if (!IsValid(v)) then
			nut.map.ents[k] = nil
		end
	end
end