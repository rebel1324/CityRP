local PLAYER = FindMetaTable("Player")

-- serious rp turned up
PLAYER.oldRaised = PLAYER.isWepRaised
function PLAYER:isWepRaised()
	if (SCHEMA.serious) then
		return self:oldRaised()
	else
		return true
	end
end

function PLAYER:isArrested()
	local char = self:getChar()

	if (char) then
		return char:getData("arrest")
	end

	return false
end

function PLAYER:arrest(doArrest, arrester, seconds)
	local char = self:getChar()

	if (char) then
		if (doArrest) then
			local jailTime = seconds or nut.config.get("jailTime")
			char:setData("arrest", true, nil, player.GetAll())
			self:setNetVar("jailTime", CurTime() + jailTime)

			netstream.Start(self, "nutJailTimer", jailTime)

			local id = char:getID()
			timer.Create("nutJailTimer_"..self:UniqueID(), jailTime, 1, function()
				if (self and self:IsValid()) then
					if (id == self:getChar():getID()) then
						self:arrest(false, nil)
					end
				end
			end)

			hook.Run("OnPlayerArrested", arrester, self, true)
		else
			if (self:isArrested()) then
				timer.Remove("nutJailTimer_"..self:UniqueID())
				netstream.Start(self, "nutJailTimer", 0)

				char:setData("arrest", false, nil, player.GetAll())
				self:setNetVar("jailTime", nil)

				hook.Run("OnPlayerArrested", arrester, self, false)
			end
		end
	end
end

function PLAYER:isProtected()
	local char = self:getChar()

	if (char) then
		local inv = char:getInv():getItems()

		if (inv) then
			for k, v in pairs(inv) do
				if (v:getData("equip")) then
					if (v.uniqueID == "advest") then
						return 0.35, "advest"
					end

					if (v.uniqueID == "balivest") then
						return 0.2, "balivest"
					end

					if (v.uniqueID == "polivest") then
						return 0.25, "polivest"
					end
				end
			end

		 	local class = char:getClass()
		 	local classData = nut.class.list[class]
		 	
		 	if (classData) then
		 		if (classData.law) then
		 			return 0.1, "class"
		 		end
		 	end
		 end
 	end

 	return 0
end

function PLAYER:isWanted()
	local char = self:getChar()

	if (char) then
		return char:getData("wanted")
	end

	return
end

function PLAYER:wanted(bool, reason, who, silence)
	local char = self:getChar()

	if (char) then
		if (bool) then
			char:setData("wanted", true, nil, player.GetAll())

			hook.Run("OnPlayerWanted", bool, self, reason, who, silence)
		else
			char:setData("wanted", false, nil, player.GetAll())

			hook.Run("OnPlayerWanted", bool, self, reason, who, silence)
		end
	end
end

function PLAYER:setHitTarget(target, request, reason)
	if (self == target) then return end

	local oldTarget = self:getNetVar("onHit")
	if (oldTarget and oldTarget:IsValid()) then return end

	self:setNetVar("onHit", target)
	target:setNetVar("hitman", self)

	hook.Run("OnRequestHit", self, target, request, reason)
end

if (SERVER) then
    function PLAYER:addAttribBoost(uniqueID, attrib, amount, time)
        local char = self:getChar()

        if (char) then
            if (uniqueID and attrib and amount and time) then
                char:addBoost(uniqueID, attrib, amount)

                timer.Create(uniqueID, time, 1, function()
					if (IsValid(self) and char) then
                   		char:removeBoost(uniqueID, attrib)
					end
                end)
                self.curTimedBoosts = self.curTimedBoosts or {}
                self.curTimedBoosts[uniqueID] = {attrib, amount, time, CurTime() + time}
                netstream.Start(self, "nutSyncBoost", uniqueID, self.curTimedBoosts[uniqueID])
            end
        end
    end

    function PLAYER:resetAllAttribBoosts()
        local char = self:getChar()

        if (char) then
			self.curTimedBoosts = self.curTimedBoosts or {}
            for k, v in pairs(self.curTimedBoosts) do
                timer.Destroy(k)
                char:removeBoost(k, v[1])
            end
            
            netstream.Start(self, "nutSyncBoostReset")
        end
    end

    function PLAYER:removeAttribBoost(uniqueID)
        local char = self:getChar()

        if (char) then
            local info = self.curTimedBoosts[uniqueID]

            timer.Destroy(uniqueID)
            char:removeBoost(uniqueID, info[1])
        end
    end

    -- There is no way to remove the fucking stacked shit
    function PLAYER:addAttribBoostStack(attrib, amount, time)
        local uniqueID = RealTime()
        local char = self:getChar()

        if (char) then
            if (uniqueID and attrib and amount and time) then
                char:addBoost(uniqueID, attrib, amount)

                timer.Create(uniqueID, time, 1, function()
					if (IsValid(self) and char) then
                    	char:removeBoost(uniqueID, attrib)
					end
                end)
                self.curTimedBoosts = self.curTimedBoosts or {}
                self.curTimedBoosts[uniqueID] = {attrib, amount, time, CurTime() + time}
                netstream.Start(self, "nutSyncBoost", uniqueID, self.curTimedBoosts[uniqueID])
            end
        end
    end
else
    netstream.Hook("nutSyncBoost", function(uniqueID, boostTable)
        local client = LocalPlayer()

        client.curTimedBoosts = client.curTimedBoosts or {}
        client.curTimedBoosts[uniqueID] = boostTable
    end)

    netstream.Hook("nutSyncBoostReset", function(uniqueID, boostTable)
        local client = LocalPlayer()

        -- lol cunt
        client.curTimedBoosts = {}
    end)
end

if (SERVER) then
    function PLAYER:breakLegs(time)
        self:setNetVar("legBroken", true)
        
        local char = self:getChar()
        local charID = char:getID()

        timer.Create("breakLeg" .. self:SteamID(), time or 300, 1, function()
            if (IsValid(self)) then
                if (char) then
                    self:setNetVar("legBroken", nil)
                end
            end
        end)
    end
    function PLAYER:healLegs()
        self:setNetVar("legBroken", nil)
        timer.Remove("breakLeg" .. self:SteamID())
    end
end

function PLAYER:isLegBroken()
    return self:getNetVar("legBroken", false)
end
