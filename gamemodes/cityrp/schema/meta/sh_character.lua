local CHAR = nut.meta.character

function CHAR:getReserve()
	return self:getVar("reserve", 0)
end

function CHAR:setReserve(amt)
	self:setVar("reserve", amt)
	hook.Run("OnReserveChanged", self, amt, true)
end

function CHAR:addReserve(amt)
	nut.log.add(self:getPlayer(), "reserve", amt)
	self:setVar("reserve", self:getReserve() + amt)
	hook.Run("OnReserveChanged", self, amt)
end

function CHAR:takeReserve(amt)
	nut.log.add(self:getPlayer(), "reserve", -amt)
	self:setVar("reserve", self:getReserve() - amt)
	hook.Run("OnReserveChanged", self, amt)
end

function CHAR:hasReserve(amt)
	return (amt > 0 and self:getReserve() >= amt)
end

function CHAR:joinClass(class)
	local client = self:getPlayer()
	local oldclass = self:getClass()
	local oldclassData = nut.class.list[oldclass]
	local classData = nut.class.list[class]

	if (classData.vote and oldclassData.team != classData.team) then
		if (client.onVote) then
			client:notifyLocalized("alreadyClassVote")

			return
		end

		client.onVote = true
		
		local textWant = L("jobVoteContext", client, client:Name(), L(classData.name, client))

		nut.vote.simple(textWant, function(p, ye, no, su)
			client.onVote = false

			local minimum = table.Count(p) * (nut.config.get("voteJob", 25) / 100)

			if (ye >= minimum) then
				if (!class) then
					self:kickClass()

					return
				end

				local oldClass = self:getClass()

				if (nut.class.canBe(client, class)) then
					self:setClass(class)
					client:notifyLocalized("becomeClass", L(classData.name, client))
					
					hook.Run("OnPlayerJoinClass", client, class, oldClass)
				else
					client:notifyLocalized("becomeClassFail", L(classData.name, client))
				end
			else
				client:notifyLocalized("becomeClassFail", L(classData.name, client))
			end
		end)
	else
		if (!class) then
			self:kickClass()

			return
		end

		local oldClass = self:getClass()
		local client = self:getPlayer()

		if (nut.class.canBe(client, class)) then
			self:setClass(class)
			hook.Run("OnPlayerJoinClass", client, class, oldClass)

			return true
		else
			return false
		end
	end
end