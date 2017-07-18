PLUGIN.name = "Server Date Rewards"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds server date calculation rewards."

local function dateDifference(t1, t2)
	local d1 = string.Explode(" ", os.date("%y %m %d", t1), false)
	local d2 = string.Explode(" ", os.date("%y %m %d", t2), false)

	local dif = {}
	dif.y = d2[1] - d1[1]
	dif.m = d2[2] - d1[2]
	dif.d = d2[3] - d1[3]

	return dif.y * 365 + dif.m * 30 + dif.d * 1
end

if (CLIENT) then

else
	SCHEMA.dateChar = os.date("%d", os.time())

	timer.Create("nutWageManager", 1, 0, function()
		if (os.date("%d", os.time()) != SCHEMA.dateChar) then
			hook.Run("OnServerDateChanged")
			--char:giveMoney(wage * 1) -- hey, you're staying in the server. you can earn some more money!
		end

		SCHEMA.dateChar = os.date("%d", os.time())
	end)

	function PLUGIN:PlayerDisconnected(client)
		local char = client:getChar()

		if (char) then
			char:setData("lastStamp", os.time())
		end
	end

	function PLUGIN:PlayerLoadedChar(client, character, currentChar)
		character = character or client:getChar()

		if (!character) then return end

		local stamp = character:getData("lastStamp")

		if (stamp) then
			local dDiff = dateDifference(stamp, os.time())

			if (dDiff > 0) then
				hook.Run("OnCharDateDiffers", client, character, currentChar, dDiff)
				-- char:giveMoney(wage * dDiff)
			end
		end 

		character:setData("lastStamp", os.time())
	end 

	function PLUGIN:OnCharDateDiffers(client, character, currentChar)

	end

	function PLUGIN:OnServerDateChanged()
	end
end
