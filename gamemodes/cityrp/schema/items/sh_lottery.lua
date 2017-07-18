ITEM.name = "Lottery Ticket"
ITEM.desc = "A Lottey Ticket"
ITEM.model = "models/weapons/w_pist_usp.mdl"
ITEM.price = 300
ITEM.width = 2
ITEM.height = 1
ITEM.exRender = true
ITEM.iconCam = {
	ang	= Angle(-6.3331274986267, 236.70753479004, 0),
	fov	= 5.7623634959197,
	pos	= Vector(87.048370361328, 129.38723754883, -13.545074462891)
}
ITEM.forceRender = true

ITEM.functions._use = { 
	name = "Check",
	tip = "checkTip",
	icon = "icon16/coins.png",
	onRun = function(item)
		local client = item.player
		local char = client:getChar()
		local money = hook.Run("LotteryEvent", client, item) or item.price

		if (money <= 0) then
			client:notify(L("lotteryFail", client))
		else
			client:notify(L("lotteryProfit", client, nut.currency.get(money)))
			char:giveMoney(money)
		end

		return true
	end,
	onCanRun = function(item)
		return (!item.entity or !IsValid(item.entity))
	end
}