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
	local client, oldclass = self:getPlayer(), self:getClass()
	local oldclassData, classData = nut.class.list[oldclass], nut.class.list[class]

	if (hook.Run("CanPlayerChangeJob", client) == false) then
		return
	end

	if (classData.vote and oldclassData.team != classData.team) then
		client.onVote = false
		if (client.nextVote and client.nextVote > CurTime()) then
			client:notifyLocalized("voteWait", math.Round(client.nextVote - CurTime()))
			return
		end

		if (client.onVote) then
			client:notifyLocalized("alreadyClassVote")
			return
		end

		if (!nut.class.canBe(client, class)) then
			return false
		end

		client.onVote = true
		client.nextVote = CurTime() + 300

		local textWant = L("jobVoteContext", client, client:Name(), L(classData.name, client))

		nut.vote.simple(textWant):next(function(context)
			client.onVote = false

			local voteTotal, voteAgree, voteSurrender, voteDisagree = unpack(context)
			local minimum = voteTotal * (nut.config.get("voteJob", 25) / 100)

			if (voteAgree >= minimum) then
				if (not class) then
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
		if (not class) then
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