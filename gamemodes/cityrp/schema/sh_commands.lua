-- This file contains all commands and chat types of Modern RP Schema.
nut.command.add("gunlicense", {
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (class == CLASS_MAYOR or class == CLASS_POLICELEADER) then
			traceData = {}
			traceData.start = client:GetShootPos()
			traceData.endpos = traceData.start + client:GetAimVector() * 256
			traceData.filter = client
			trace = util.TraceLine(traceData)

			local target = trace.Entity
			
			if (IsValid(target)) then
				hook.Run("OnPlayerLicensed", client, target, true)
			else
				client:notifyLocalized("plyNotValid")
			end
		else
			client:notifyLocalized("notLaw")
		end
	end,
	alias = {"건라", "건라이센스"}
})

nut.command.add("revokegunlicense", {
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (class == CLASS_MAYOR or class == CLASS_POLICELEADER) then
			traceData = {}
			traceData.start = client:GetShootPos()
			traceData.endpos = traceData.start + client:GetAimVector() * 256
			traceData.filter = client
			trace = util.TraceLine(traceData)

			local target = trace.Entity
			
			if (IsValid(target)) then
				hook.Run("OnPlayerLicensed", client, target, false)
			else
				client:notifyLocalized("plyNotValid")
			end
		else
			client:notifyLocalized("notLaw")
		end
	end,
	alias = {"건라뺏기", "건라취소"}
})

nut.command.add("drop", {
	onRun = function(client, arguments)
		local weapon = client:GetActiveWeapon()

		if (IsValid(weapon)) then
			local class = weapon:GetClass()
			local char = client:getChar()

			if (char) then
				local inv = char:getInv()
				local items = inv:getItems()

				for k, v in pairs(items) do
					if (v.isWeapon and v.class == class) then
						local dropFunc = v.functions.drop

						do
							v.player = client

							if (dropFunc.onCanRun and dropFunc.onCanRun(v) == false) then
								continue
							end
					
							local result
							
							if (v.hooks.drop) then
								result = v.hooks.drop(v)
							end
							
							if (result == nil) then
								result = dropFunc.onRun(v)
							end

							if (v.postHooks.drop) then
								v.postHooks.drop(v)
							end
							
							if (result != false) then
								v:remove()
							end

							v.player = nil
						end
					end
				end
			end
		end
	end,
	alias = {"드랍", "버리기"}
})

nut.command.add("lockdown", {
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()

		if (class == CLASS_MAYOR) then
			local bool = GetGlobalBool("lockdown", false)
			if (!bool and SCHEMA.nextLockdown and SCHEMA.nextLockdown > CurTime()) then
				client:notifyLocalized("classDelay", math.Round(SCHEMA.nextLockdown - CurTime()))

				return
			end

			SetGlobalBool("lockdown", !bool)

			hook.Run("OnLockdown", client, GetGlobalBool("lockdown"))
			SCHEMA.nextLockdown = CurTime() + 120
		end
	end,
	alias = {"계엄령"}
})

nut.command.add("refund", {
	onRun = function(client, arguments)
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)

		local entity = trace.Entity
		if (IsValid(entity)) then
			hook.Run("OnPlayerRefundEntity", client, entity)
		end
	end,
	alias = {"환불"}
})

UNSTUCK_DELAY = 15
UNSTUCK_PENALTY = 20
UNSTUCK_COOLDOWN = 1500
nut.command.add("stuck", {
	onRun = function(client, arguments)
		if (client:isWanted() or client:isArrested() or IsValid(client.nutRagdoll)) then
			return
		end
		
		if (client.nextStuck and client.nextStuck > CurTime()) then
			client:notifyLocalized("tryLater", math.Round(client.nextStuck - CurTime()))
			return
		end
		
		local timerName = client:SteamID() .. "_unstuckTimer"
		client:notifyLocalized("unstuckOngoing", UNSTUCK_DELAY)

		hook.Add("PlayerHurt", timerName, function()
			timer.Destroy(timerName)
			hook.Remove("PlayerHurt", timerName)
			client:notifyLocalized("unstuckInturrupted", UNSTUCK_PENALTY)
			client.nextStuck = CurTime() + UNSTUCK_PENALTY
		end)

		timer.Create(timerName, UNSTUCK_DELAY, 1, function()
			client.nextStuck = CurTime() + UNSTUCK_COOLDOWN
			client:Spawn()
		end)
	end,
	alias = {"자살", "끼임", "꼈음", "끼임탈출"}
})

nut.command.add("search", {
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData.law) then
			traceData = {}
			traceData.start = client:GetShootPos()
			traceData.endpos = traceData.start + client:GetAimVector() * 256
			traceData.filter = client
			trace = util.TraceLine(traceData)

			local target = trace.Entity
			
			if (IsValid(target)) then
				hook.Run("OnPlayerSearch", client, target)
				
				nut.log.add(client, "search", target)
			end
		else
			client:notifyLocalized("notLaw")
		end
	end,
	alias = {"수색"}
})

nut.command.add("lawboard", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]
				
		if (class != CLASS_MAYOR) then
			client:notifyLocalized("noPerm")
					
			return false
		end
			
		
		if (IsValid(client.lawboard)) then
			client.lawboard:Remove()
		end
		
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)
		

		local entity = ents.Create("nut_lawboard")
		entity:SetPos(trace.HitPos)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()
		entity:CPPISetOwner(client)
		entity:CallOnRemove("_imagroot", function(entity)
			if (IsValid(client)) then
				client.lawboard = nil
			end
		end)

		client.lawboard = entity
		
		client:notifyLocalized("spawnedLawboard")
	end,
	alias = {"법판"}
})

nut.command.add("lawboardremove", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local char = client:getChar()
		local class = char:getClass()
		local classData = nut.class.list[class]
				
		if (class != CLASS_MAYOR) then
			client:notifyLocalized("noPerm")
					
			return false
		end
			
		
		if (IsValid(client.lawboard)) then
			client.lawboard:Remove()
		end
		
		client:notifyLocalized("removedLawboard")
	end,
	alias = {"법판"}
})

nut.command.add("bankdeposit", {
	syntax = "<amount>",
	onRun = function(client, arguments)
		local atmEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:isBank()) then
				atmEntity = v
				break
			end
		end

		if (IsValid(atmEntity) and hook.Run("CanUseBank", client, atmEntity)) then
			local amount = tonumber(table.concat(arguments, ""))
			local char = client:getChar()

			if (amount and amount > 0 and char) then
				amount = math.Round(amount)
				if (char:hasMoney(amount)) then
					char:addReserve(amount)
					char:takeMoney(amount)
					client:notify(L("depositMoney", client, nut.currency.get(amount)))
				else
					client:notify(L("cantAfford", client))
				end
			else
				client:notify(L("provideValidNumber", client))
			end
		else
			client:notify(L("tooFar", client))
		end
	end,
	alias = {"입금"}
})

nut.command.add("bankwithdraw", {
	syntax = "<amount>",
	onRun = function(client, arguments)
		local atmEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:isBank()) then
				atmEntity = v
				break
			end
		end

		if (IsValid(atmEntity) and hook.Run("CanUseBank", client, atmEntity)) then
			local amount = tonumber(table.concat(arguments, ""))
			local char = client:getChar()

			if (amount and isnumber(amount) and amount > 0 and char) then
				amount = math.Round(tonumber(amount))

				if (char:hasReserve(amount)) then
					char:takeReserve(amount)
					char:giveMoney(amount)
					client:notify(L("withdrawMoney", client, nut.currency.get(amount)))
				else
					client:notify(L("cantAfford", client))
				end
			else
				client:notify(L("provideValidNumber", client))
			end
		else
			client:notify(L("tooFar", client))
		end
	end,
	alias = {"출금"}
})

nut.command.add("banktransfer", {
	syntax = "<amount>",
	onRun = function(client, arguments)
		local atmEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:isBank()) then
				atmEntity = v
				break
			end
		end

		local target = nut.command.findPlayer(client, arguments[1])

		if (IsValid(target) and target:getChar()) then
			if (IsValid(atmEntity) and hook.Run("CanUseBank", client, atmEntity)) then
				local amount = table.concat(arguments, "")
				local char = client:getChar()
				local tChar = target:getChar()
				amount = math.Round(tonumber(amount))

				if (char == tChar) then
					client:notify(L("sameChar", client))
					return
				end

				if (amount and isnumber(amount) and amount > 0 and char) then
					if (char:hasReserve(amount)) then
						tChar:addReserve(amount*.95)
						char:takeReserve(amount)
					end
				else
					client:notify(L("provideValidNumber", client))
				end
			end
		else
			client:notify(L("tooFar", client))
		end
	end,
	alias = {"송금"}
})

nut.command.add("setprice", {
	syntax = "<amount>",
	onRun = function(client, arguments)
			-- Get the Vehicle Spawn position.
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)

		local target = trace.Entity

		if (target and target:IsValid()) then
			local price = tonumber(table.concat(arguments, ""))

			if (!price or price < 0) then return end
			if (target.vending and price) then
				if (target:CPPIGetOwner() == client) then
					client:notifyLocalized("priceChanged", nut.currency.get(price))

					target:setPrice(math.Round(price))
				else
					client:notifyLocalized("notOwned")
				end
			end
		end
	end,
	alias = {"가격", "가격설정"}
})

nut.command.add("buyentity", {
	syntax = "<string classname>",
	onRun = function(client, arguments)
		local classname = table.concat(arguments, "")

		if (classname) then
			local entTable = nut.bent.list[classname]
			local char = client:getChar()

			if (!char) then
				return
			end

			if (entTable) then
				local price = entTable.price

				if (price and price > 0 and char) then
					price = math.Round(price)

					if (price < 0) then return end
					if (char:hasMoney(price) and entTable.condition(client)) then
						if (hook.Run("CanBuyEntity", client, char, classname, entTable) != false) then
							local data = {}
								data.start = client:GetShootPos()
								data.endpos = data.start + client:GetAimVector()*96
								data.filter = client
							local trace = util.TraceLine(data)

							local pos = trace.HitPos + trace.HitNormal * 5
							local ent = ents.Create(entTable.class)

							if (IsValid(ent)) then
								local ca, cb = ent:GetCollisionBounds()
								ent:SetPos(pos + cb)
								ent:Spawn()
								ent:Activate()

								char:giveMoney(-entTable.price)

								if (ent.OnSpawned) then
									ent.OnSpawned(client, char)
								end

								hook.Run("EntityPurchased", client, char, ent, entTable)

								client:notify(L("purchaseEntity", client, entTable.name, nut.currency.get(price)))
							end
						end
					else
						client:notify(L("cantAfford", client))
					end
				else
					client:notify(L("provideValidNumber", client))
				end
			end
		else

		end
	end,
	alias = {"구매"}
})

nut.command.add("beclass", {
	syntax = "<string class>",
	onRun = function(client, arguments)
		local class = table.concat(arguments, " ")
		local char = client:getChar()

		if (IsValid(client) and char) then
			if (client.nextBe and client.nextBe > CurTime()) then
				client:notifyLocalized("classDelay", math.Round(client.nextBe - CurTime()))

				return
			end

			local num = isnumber(tonumber(class)) and tonumber(class) or -1
			
			if (nut.class.list[num]) then
				local v = nut.class.list[num]

				if (char:joinClass(num)) then
					if (!v.vote) then
						client:notifyLocalized("becomeClass", L(v.name, client))
					end

					return
				else
					if (!v.vote) then
						client:notifyLocalized("becomeClassFail", L(v.name, client))
					end

					return
				end
			else
				for k, v in ipairs(nut.class.list) do
					if (nut.util.stringMatches(v.uniqueID, class) or nut.util.stringMatches(L(v.name, client), class)) then

						local v = nut.class.list[k]

						if (char:joinClass(k)) then
							if (!v.vote) then
								client:notifyLocalized("becomeClass", L(v.name, client))
							end

							return
						else
							if (!v.vote) then
								client:notifyLocalized("becomeClassFail", L(v.name, client))
							end

							return
						end
					end
				end
			end
			
			client:notifyLocalized("invalid", L("class", client))
		else
			client:notifyLocalized("illegalAccess")
		end
	end,
	alias = {"직업", "job"}
})

nut.command.add("demote", {
	syntax = "<string playername>",
	onRun = function(client, arguments)
		local char = client:getChar()
		local target = nut.command.findPlayer(client, arguments[1])
		local reason = table.concat(arguments, " ", 2)

		if !(target and IsValid(target)) then
			return
		end

		if (target.nextDemote and target.nextDemote > CurTime()) then
			client:notifyLocalized("demoteWait", math.ceil(target.nextDemote - CurTime()))

			return
		end

		if (IsValid(client) and char) then
			if (reason:len() < 4) then
				client:notifyLocalized("tooShort")

				return
			end

			if (target.onDemote) then
				client:notifyLocalized("alreadyDemote")

				return
			end

			local targetChar = target:getChar()
			local targetClass = targetChar:getClass()
			local targetClassData = nut.class.list[targetClass]

			if (!targetClassData or targetClassData.isDefault) then
				client:notifyLocalized("demoteInvalid")
			else
				-- POSSIBLE DEMOTE BUG
				local textWant = L("demoteContext", target, target:Name(), L(targetClassData.name, target), reason)

				target.onDemote = true

				target.nextDemote = CurTime() + 120
				nut.vote.simple(textWant, function(p, ye, no, su)
					if (IsValid(target) and targetChar) then
						target.onDemote = false

						if (targetClass == targetChar:getClass()) then
							local minimum = table.Count(p) * (nut.config.get("voteDemote", 25) / 100)

							if (ye >= minimum) then
								local lol = nut.class.list[CLASS_CIVILIAN]

								targetChar:joinClass(CLASS_CIVILIAN)
								
								hook.Run("OnPlayerDemoted", target, targetClass, targetClassData)
								return
							else
								for k, v in ipairs(player.GetAll()) do
									v:notifyLocalized("failedDemote", target:Name(), targetClassData.name)
								end
							end
						end
					end
				end)

				client:notifyLocalized("demoteVote")
			end
		else
			client:notifyLocalized("illegalAccess")
		end
	end,
	alias = {"탄핵", "getout", "강등"}
})

nut.command.add("jailpos", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData.law or client:IsAdmin()) then
			table.insert(SCHEMA.prisonPositions, client:GetPos())

			return L("prisonAdded", client, name)
		end
	end,
	alias = {"감옥추가"}
})

nut.command.add("setjailpos", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		local class = char:getClass()
		local classData = nut.class.list[class]

		if (classData.law or client:IsAdmin()) then
			SCHEMA.prisonPositions = {client:GetPos()}

			return L("prisonReset", client, name)
		end
	end,
	alias = {"감옥설정"}
})


local function fallover(client, arguments)
	if (client:isArrested()) then return end

	local time = tonumber(arguments[1])

	if (!isnumber(time)) then
		time = 5
	end

	if (time > 0) then
		time = math.Clamp(time, 1, 60)
	else
		time = nil
	end

	if (!IsValid(client.nutRagdoll)) then
		client:setRagdolled(true, time)
	end
end

nut.command.add("fallover", {
	syntax = "[number time]",
	onRun = fallover
})

nut.command.add("sleep", {
	syntax = "[number time]",
	onRun = fallover
})

nut.command.add("crappos", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		if (client:IsAdmin()) then
			table.insert(SCHEMA.crapPositions, client:GetPos())

			return L("crapAdded", client, name)
		end
	end,
	alias = {}
})

nut.command.add("setcrappos", {
	adminOnly = true,
	syntax = "",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		if (client:IsAdmin()) then
			SCHEMA.crapPositions = {client:GetPos()}

			return L("crapReset", client, name)
		end
	end,
	alias = {}
})

nut.command.add("hit", {
	syntax = "<string name> [string reason]",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local message = table.concat(arguments, " ", 2)

		if (message:len() < 6) then
			client:notifyLocalized("tooShort")

			return
		end

		local cost = nut.config.get("hitCost", 250)
		if (IsValid(target) and target:getChar()) then
			local hitman

			for k, v in ipairs(player.GetAll()) do
				local c = v:getChar()

				if (c) then
					local cls = c:getClass()

					if (cls == CLASS_HITMAN) then
						hitman = v
						break
					end
				end
			end

			if !(hitman and hitman:IsValid()) then
				client:notifyLocalized("noHitman")

				return
			end

			local char = client:getChar()
			if (!char:hasMoney(cost)) then
				client:notifyLocalized("cantAfford")

				return
			end

			if (client == hitman or target == hitman) then
				client:notifyLocalized("cantHit")

				return
			end

			local oldTarget = hitman:getNetVar("onHit")
			if (oldTarget and oldTarget:IsValid()) then
				client:notifyLocalized("hitOngoing")

				return
			end

			if (hitman and hitman:IsValid()) then
				if (hitman.onHitVote) then
					client:notifyLocalized("hitVote")

					return
				end

				client:notifyLocalized("hitRequested")

				netstream.Start(hitman, "nutHitman", target, client, message)

				hitman.onHitVote = true
				hitman.voteInfo = {
					target = target,
					client = client,
					reason = message,
				}

				timer.Create("hitVote_" .. hitman:UniqueID(), 5.5, 1, function()
					hitman.onHitVote = nil
					hitman.voteInfo = nil
				end)
				
				hook.Run("OnPlayerRequestedHit", client, target, hitman, message)
			end
		end
	end,
	alias = {"의뢰"}
})


nut.command.add("removelaw", {
	syntax = "<number index>",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		local class = char:getClass()
		local classData = nut.class.list[class]
		local index = tonumber(arguments[1])
		local message = table.concat(arguments, " ", 2)

		if (!index) then
			client:notifyLocalized("selectRow")

			return
		end

		if (classData.law or client:IsAdmin()) then
			if (index <= 10) then
				SCHEMA.laws[index] = ""

				netstream.Start(player.GetAll(), "nutLawSync", SCHEMA.laws, index, "")
				client:notifyLocalized("lawChanged")
			else
				client:notifyLocalized("indexInvalid")
			end
		end
	end,
	alias = {"법삭제"}
})

nut.command.add("addlaw", {
	syntax = "<number index> [string law]",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		local class = char:getClass()
		local classData = nut.class.list[class]
		local index = tonumber(arguments[1])
		local message = table.concat(arguments, " ", 2)

		if (!index) then
			client:notifyLocalized("selectRow")

			return
		end

		if (classData.law or client:IsAdmin()) then
			if (index <= 10) then
				SCHEMA.laws[index] = message

				hook.Run("OnLawChanged", index, message)
				netstream.Start(player.GetAll(), "nutLawSync", SCHEMA.laws, index, message)
				client:notifyLocalized("lawChanged")
				
				nut.log.add(client, "rule", message)
			else
				client:notifyLocalized("indexInvalid")
			end
		end
	end,
	alias = {"법추가"}
})


nut.command.add("broadcast", {
	syntax = "<string text>",
	onRun = function(client, arguments)
		local char = client:getChar()
		if (!char) then return end

		local class = char:getClass()
		local classData = nut.class.list[class]
		local message = table.concat(arguments, " ")

		if (class != CLASS_MAYOR) then
			client:notifyLocalized("noPerm")

			return
		end

		if (!message or message:len() < 5) then
			client:notifyLocalized("tooShort")

			return
		end

		for k,v in pairs(player.GetAll()) do
			v:BroadcastMSG(message, 60)
		end
	end,
	alias = {"방송"}
})

-- Advert Chat Type
nut.chat.register("cr", {
	onCanSay =  function(speaker, text)
		return 
	end,
	onCanHear = function(speaker, listener)		
		if (speaker == listener) then return true end

		local char = listener:getChar()

		if (char and char2) then
			local class = char:getClass()
			local classDat = nut.class.list[class]

			if (classDat.law) then
				return true
			end
		end	

		return false
	end,
	onChatAdd = function(speaker, text)
		chat.AddText(Color(255, 40, 40), "[911] ", nut.config.get("chatColor"), speaker:Name()..": "..text)
	end,
	prefix = {"/911"}
})

nut.command.add("unwanted", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local message = table.concat(arguments, " ", 2)
		local char = client:getChar()

		if (char and !client:IsAdmin()) then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (!classData.law) then
				client:notifyLocalized("noPerm")

				return
			end
		end

		if (IsValid(target) and target:getChar()) then
			if (!target:Alive()) then return false, "notAlive" end
			if (!target:isWanted()) then
				client:notifyLocalized("notWanted")

				return
			end

			target:wanted(false, message, client)
		end
	end,
	alias = {"수배해제", "현상수배해제"}
})

nut.command.add("wanted", {
	syntax = "<string name> <string reason>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local message = table.concat(arguments, " ", 2)
		local char = client:getChar()

		if (char and !client:IsAdmin()) then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (!classData.law) then
				client:notifyLocalized("noPerm")

				return
			end
		end

		if (target and target:IsValid()) then
			if (target:isWanted()) then
				if (!target:Alive()) then return false, "notAlive" end
				client:notifyLocalized("alreadyWanted")

				return
			end

			if (IsValid(target) and target:getChar()) then
				target:wanted(true, message, client)
			end
		end
	end,
	alias = {"수배", "현상수배"}
})

nut.command.add("searchwarrant", {
	syntax = "<string name> <string reason>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local message = table.concat(arguments, " ", 2)
		local char = client:getChar()

		if (char and !client:IsAdmin()) then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (!classData.law) then
				client:notifyLocalized("noPerm")

				return
			end
		end

		if (IsValid(target) and target:getChar()) then
			if (!target:Alive()) then return false, "notAlive" end

			if (target:getNetVar("searchWarrant", false) == true) then
				client:notifyLocalized("alreadySearch")

				return
			end

			netstream.Start(player.GetAll(), "nutSearchText", true, client, target, message)
			target:setNetVar("searchWarrant", true)

			local id = target:getChar():getID()
			timer.Create(id .. "_chewAss", 300, 1, function()
				if (IsValid(target)) then
					local char2 = target:getChar()
					
					if (char2:getID() == id) then
						target:setNetVar("searchWarrant", false)
					end
				end
			end)
		end
	end,
	alias = {"수색영장"}
})

nut.command.add("stopwarrant", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, arguments[1])
		local char = client:getChar()

		if (char and !client:IsAdmin()) then
			local class = char:getClass()
			local classData = nut.class.list[class]

			if (!classData.law) then
				client:notifyLocalized("noPerm")

				return
			end
		end

		if (IsValid(target) and target:getChar()) then
			if (!target:Alive()) then return false, "notAlive" end

			if (target:getNetVar("searchWarrant", false) != true) then
				client:notifyLocalized("notOnSearch")

				return
			end

			netstream.Start(player.GetAll(), "nutSearchText", false, client, target)
			target:setNetVar("searchWarrant", nil)

			local id = target:getChar():getID()
			timer.Destroy(id .. "_chewAss")
		end
	end,
	alias = {"수색영장해제"}
})

nut.command.add("password", {
	syntax = "<4-digit number>",
	onRun = function(client, arguments)
			-- Get the Vehicle Spawn position.
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)

		local target = trace.Entity

		if (target and target:IsValid()) then
			local password = table.concat(arguments, "")
			
			if (password:len() > 4 or !tonumber(password)) then
				client:notifyLocalized("illegalAccess")

				return 
			end

			if (target:GetClass() == "nut_keypad" and password) then
				if (target:CPPIGetOwner() == client) then
					client:notifyLocalized("passwordChanged", password)

					target:SetPassword(password)
				else
					client:notifyLocalized("notOwned")
				end
			end
		end
	end,
	alias = {"비번", "비밀번호"}
})

-- kek
nut.command.add("savemap", {
	onRun = function(client, arguments)
		if (client:IsSuperAdmin()) then
			hook.Run("SaveData")
		end
	end,
})

nut.command.add("sellall", {
	syntax = "",
	onRun = function(client, arguments)
		if (client:getChar()) then
			if (client.properties) then
				for entity, bool in pairs(client.properties) do
					entity:removeDoorAccessData()
				end
			end

			client:notifyLocalized("sellAll")
		end
	end,
})

hook.Add("InitializedSchema", "addMoreShit", function()
	timer.Simple(0, function()
		nut.chat.register("looc", {
			onCanSay =  function(speaker, text)
				return false
			end,
			onChatAdd = function(speaker, text)
			end,
			prefix = {"]]", "/looc"},
			noSpaceAfter = true,
			filter = "ooc"
		})

		nut.chat.register("ooc", {
			onCanSay =  function(speaker, text)
			end,
			onChatAdd = function(speaker, text)
				local icon = "icon16/user.png"
				local char = speaker:getChar()
				
				if (char) then
					local class = char:getClass()
					local classTable = nut.class.list[class]
					local color = classTable.color
					
					if (speaker:IsAdmin()) then
						if (speaker:IsSuperAdmin()) then
							if (speaker:SteamID() == "STEAM_0:0:19814083") then
								chat.AddText(Color(50, 255, 50), "[개발자] ", Color(255, 50, 50), "[OOC] ", color, speaker:Name(), color_white, ": "..text)
							else
								chat.AddText(Color(255, 50, 50), "[OOC] ", color, speaker:Name(), color_white, ": "..text)
							end
						else
							chat.AddText(Color(255, 50, 50), "[어드민]", Color(255, 50, 50), " [OOC] ", color, speaker:Name(), color_white, ": "..text)
						end
					else
						chat.AddText(Color(255, 50, 50), "[OOC] ", color, speaker:Name(), color_white, ": "..text)
					end
				end
			end,
			prefix = {"//", "/ooc"},
			noSpaceAfter = true,
			filter = "ooc"
		})
				
		nut.chat.register("ic", {
			onGetColor = function() return color_white end,
			onCanHear = nut.config.get("chatRange", 280),
			onChatAdd = function(speaker, text)
				local icon = "icon16/user.png"
				local char = speaker:getChar()
				
				if (char) then
					local class = char:getClass()
					local classTable = nut.class.list[class]
					local color = classTable.color
					chat.AddText(color, speaker:Name(), color_white, ": "..text)
				end
			end,
		})
	
		nut.chat.register("tc", {
			onGetColor = function() return color_white end,
			onCanHear = function(speaker, listener)
				local char, char2 = speaker:getChar(), listener:getChar()
	
				if (char and char2) then
					local class, class2 = char:getClass(), char2:getClass()
					local classDat, classDat2 = nut.class.list[class], nut.class.list[class2]

					if (classDat and classDat2) then
						if (classDat.team and classDat2.team) then
							if (classDat.team == classDat2.team) then
								return true
							end
						end
					end
				end	
	
				return false
			end,
			onChatAdd = function(speaker, text)
				local icon = "icon16/user.png"
				local char = speaker:getChar()
				
				if (char) then
					local class = char:getClass()
					local classTable = nut.class.list[class]
					local color = classTable.color
	
					chat.AddText(Color(255, 50, 50), "[팀]", color, speaker:Name(), color_white, ": "..text)
				end
			end,
			prefix = {"/t", "/팀", "/g"}
		})
	
		-- Advert Chat Type
		nut.chat.register("advert", {
			onCanSay =  function(speaker, text)
				local char = speaker:getChar()
				return (char:hasMoney(10) and char:takeMoney(10))
			end,
			onCanHear = 1000000,
			onChatAdd = function(speaker, text)
				chat.AddText(Color(180, 255, 10), L"advert", nut.config.get("chatColor"), speaker:Name()..": "..text)
			end,
			prefix = {"/advert", "/ad", "/광고"}
		})
	end)
end)