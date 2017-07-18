PLUGIN.name = "Item Seller"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "A Script that run on map"

local langkey = "english"
do
	local langTable = {
		priceDesc = "This item's price is %s.",
		cashierPurchased = "You purchased this item for %s.",
		cashierSold = "You sold item for %s.",
		checkoutName = "Cashier Machine",
		checkoutDesc = "You can sell your items with this machine",
		checkoutDesc2 = "This machine is owned by %s.",
		priceSet = "Drop with Price",
		cashierTip = "You can sell your dropped items with this machine.",
		changePrice = "Change Price",
		cashierList = "Items Currently Being Sold",
		changedPrice = "You changed item's price to %s",
	}

	table.Merge(nut.lang.stored[langkey], langTable)
end

langkey = "korean"
do
	local langTable = {
		priceDesc = "이 물건은 %s에 판매되고 있습니다.",
		cashierPurchased = "물건을 %s에 구매하였습니다.",
		cashierSold = "물건을 %s에 판매하였습니다.",
		checkoutName = "계산대",
		checkoutDesc = "물건을 돈을 받고 팔게해주는 계산대입니다",
		checkoutDesc2 = "현재 이 계산대의 주인은 %s님입니다.",
		priceSet = "가격 설정후 진열",
		cashierTip = "이 기계로 물건에 가격을 설정해서 바닥에 놓고 팔 수 있습니다.",
		changePrice = "가격 변경",
		cashierList = "현재 판매중인 물건",
		changedPrice = "물건의 가격을 %s으로 변경했습니다.",
	}

	table.Merge(nut.lang.stored[langkey], langTable)
end

if (SERVER) then
	netstream.Hook("nutCashMachinePrice", function(client, text, entity, itemEntity)
		local cashierOwner = entity:CPPIGetOwner()
		local itemOwner = itemEntity:getNetVar("sellOwner")
		
		if (cashierOwner == client) then
			if (itemOwner == client) then
				local price = math.Round(math.max(tonumber(text) or 0, 0))

				itemEntity:setNetVar("sellPrice", price)
				client:notifyLocalized("changedPrice", nut.currency.get(price))
				netstream.Start(client, "nutCashUpdate")
			end
		end
	end)

	netstream.Hook("sellerSetPrice", function(client, text, entity, itemID)
		if (entity:GetPos():Distance(client:GetPos()) > 512) then
			return client:notifyLocalized("tooFar")
		end

		local item = nut.item.instances[itemID]
		if (item) then
			local item = item:transfer()
			if (!IsValid(item)) then
				return client:notifyLocalized("illegalAccess")
			end
			-- fucker
			local price = math.Round(math.max(0, tonumber(text) or 0))
			
			item:setNetVar("sellPrice", price)
			item:setNetVar("sellOwner", client)
			item:CPPISetOwner(client)

			entity.stocks = entity.stocks or {}
			table.insert(entity.stocks, item)
		else
			return client:notifyLocalized("illegalAccess")
		end
	end)
end

function PLUGIN:CanPlayerInteractItem(client, action, item)
	if (type(item) == "Entity") then
		local itemTable
		if (IsValid(item)) then
			itemTable = nut.item.instances[item.nutItemID]
			
			local price, owner = item:getNetVar("sellPrice"), item:getNetVar("sellOwner")
			if (price and owner and owner != client) then
				if (IsValid(owner)) then
					if (action == "take") then
						local char = client:getChar()
						if (char) then
							return char:hasMoney(price)
						end
						return false
					else
						client:notifyLocalized("notOwned")
						return false
					end
				end
			end
		end
	end
end

function PLUGIN:OnPlayerInteractItem(client, action, item, result)
	if (IsValid(item.entity)) then
		local entity = item.entity
		local char = client:getChar()
		
		if (char) then
			local price, owner = entity:getNetVar("sellPrice"), entity:getNetVar("sellOwner")
			if (price and owner) then
				if (owner == client) then return end
				char:takeMoney(price)
				if (IsValid(owner)) then
					local ownerChar = owner:getChar()
					if (ownerChar) then
						ownerChar:giveMoney(price)
						client:notifyLocalized("cashierPurchased", nut.currency.get(price))
						owner:notifyLocalized("cashierSold", nut.currency.get(price))
					end
				end
			end
		end
	end
end

function PLUGIN:OnCreateItemInteractionMenu(panel, menu, itemTable)
	local inventory = panel:GetParent()
	-- lol, kanbare clientss!
	local nearCashier, entity
	for k, v in ipairs(ents.FindInSphere(EyePos(), 512)) do
		if (v:GetClass() == "nut_seller" and v:CPPIGetOwner() == LocalPlayer()) then
			nearCashier = true
			entity = v
			break
		end
	end
	
	if (nearCashier) then
		menu:AddOption(L("priceSet"), function()
			local itemID = itemTable:getID()
			Derma_StringRequest(L("enterPrice"), L("enterPrice"), "", function(text)
				netstream.Start("sellerSetPrice", text, entity, itemID)
			end)
		end):SetImage("icon16/money.png")
	end
end

function PLUGIN:DrawItemDescription(entity, x, y, color, alpha)
	local price, owner = entity:getNetVar("sellPrice"), entity:getNetVar("sellOwner")
	if (price and owner) then
		y = y + 16
		nut.util.drawText(L("priceDesc", nut.currency.get(price), owner), x, y, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
			
		return x, y
	end
end