ITEM.name = "Blueprint Base"
ITEM.model = "models/props_lab/binderblue.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "Crafting's basic."
ITEM.price = 100
ITEM.isBlueprint = true

function ITEM:getDesc()
	if (!self.entity or !IsValid(self.entity)) then
		local strong = [[Requirements:%s
		Result:%s]]

		local reqString = ""
		for k, v in ipairs(self.requirements) do
			local item = nut.item.list[v[1]]

			if (item) then
				reqString = reqString .. Format("\n %s x %d", item.name, v[2])
			end
		end

		local resString = ""
		for k, v in ipairs(self.result) do
			local item = nut.item.list[v[1]]

			if (item) then
				resString = resString .. Format("\n %s x %d", item.name, v[2])
			end
		end

		return Format(strong, reqString, resString)
	else
		return "A blueprint that can be used for crafting stuffs"
	end
end

function ITEM:onRegistered()
	if (SERVER) then
		if (self.requirements and self.result) then
			if (!self.base) then
				ErrorNoHalt(self.uniqueID .. " does not have proper craft data!")
			end
		end
	end
end
