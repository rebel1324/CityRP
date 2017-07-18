ITEM.name = "Book Base"
ITEM.model = "models/props_lab/binderblue.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.attribute = "stm"
ITEM.attributeAmount = 1
ITEM.price = 100000
ITEM.category = "Education"

function ITEM:getDesc()
	local attribInfo = nut.attribs.list[self.attribute]

	if (attribInfo) then
		local attrib = L(attribInfo.name) or "FAILED"

		if (self.entity and IsValid(self.entity)) then
			return L("attribookDescEntity", attrib)
		end

		local str = L("attribookDesc", attrib) .. '\n"' .. L(self.bookDesc) .. '"'
		return str
	else
		return "ERROR DESC2"
	end
end

ITEM:hook("use", function(item)
	item.player:EmitSound("ui/extended.wav", 60, 120)
end)

ITEM.functions.use = { 
	name = "Read",
	tip = "useTip",
	icon = "icon16/book.png",
	onRun = function(item)
		local attrib = item.attribute

		if (item.player and item:getData("read", false) == false) then
			if (attrib and nut.attribs.list[attrib]) then
				local char = item.player:getChar()

				char:updateAttrib(attrib, item.attributeAmount)
				return true
			end
		end

		return false
	end,
	onCanRun = function(item)
		local client = item.player or LocalPlayer()
		
		return (!IsValid(item.entity))
	end
}
