ITEM.name = "Shipment Base"
ITEM.itemID = "ammo_ar2"
ITEM.price = 200
ITEM.width = 3
ITEM.height = 3
ITEM.model = "models/rebel1324/chest.mdl"
ITEM.isStackable = true
ITEM.maxQuantity = 10
ITEM.canSplit = false
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(327.86834716797, 273.31521606445, 210.98059082031),
	ang = Angle(25, 220, 0),
	entAng = Angle(0, 0, 0),
	fov = 6.1035808677348,
}

function ITEM:getDesc()
	local quantity = self.getQuantity and self:getQuantity() or 1
	local itemTable = nut.item.list[self.itemID]
	local name = itemTable.getName and itemTable:getName() or L(itemTable.name)

	return "특정 물건이 여러개 들어있는 상자 (" .. name .. "x" .. quantity .. ")"
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		local quantity = item:getQuantity()
		local itemTable = nut.item.list[item.itemID]

		nut.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "nutChatFont")
		if (itemTable) then
			nut.util.drawText(itemTable.getName and itemTable:getName() or L(itemTable.name), w - 5, h - math.max(ScreenScale(7), 17) - 5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, "nutChatFont")
		end
	end
end

ITEM.functions.use = {
	name = "꺼내기",
	tip = "useTip",
	icon = "icon16/wrench.png",
	onCanRun = function(item, data)
		if (IsValid(item.entity)) then return false end
		
		return true
	end,
	onRun = function(item, data)
		local client = item.player
		local char = client:getChar()

		if (char) then
			local inventory = char:getInv()

			if (inventory) then
				local spawnItemTable = nut.item.list[item.itemID]

				if (spawnItemTable) then
					inventory:add(item.itemID):next(function(spawnedItem)
						if (item:getQuantity() <= 1) then
							item:remove()
						else
							item:setQuantity(item:getQuantity() - 1)
						end
					end, function(error)
						client:notify("something gone wrong.")
					end)
				end				
			end
		end

		return false
	end,
}

ITEM.functions.spawn = {
	name = "꺼내기",
	tip = "useTip",
	icon = "icon16/wrench.png",
	onCanRun = function(item, data)
		if (!IsValid(item.entity)) then return false end
		
		return true
	end,
	onRun = function(item, data)
		local client = item.player
		local char = client:getChar()

		if (char) then
			local spawnItemTable = nut.item.list[item.itemID]

			if (spawnItemTable) then
				local itemEntity = item.entity
				
				if (IsValid(itemEntity)) then 

					nut.item.spawn(item.itemID, itemEntity:GetPos() + itemEntity:GetUp() * 20):next(function(spawnedItem)
						if (item:getQuantity() <= 1) then
							item:remove()
						else
							item:setQuantity(item:getQuantity() - 1)
						end
					end, function(error)
						client:notify("something gone wrong.")
					end)
				end
			end
		end

		return false
	end,
}