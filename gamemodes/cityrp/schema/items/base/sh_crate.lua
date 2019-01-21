ITEM.name = "Crate Base"
ITEM.model = "models/healthvial.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "Good crate to open shits"
ITEM.category = "Crate"
ITEM.price = 50000

-- Are you looking for lootboxes.
ITEM.functions = {}
ITEM.functions.open = { 
	name = "Open",
	tip = "useTip",
	icon = "icon16/bug.png",
	onRun = function(item)
		local client = item.player
		local char = client:getChar()
		
		return false
	end,

	onCanRun = function(item)
		return (!IsValid(item.entity))
	end
}