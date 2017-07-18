ITEM.name = "Watermelon"
ITEM.model = "models/props_junk/watermelon01.mdl"
ITEM.hungerAmount = 50
ITEM.cookable = false
ITEM.foodDesc = "watermelonDesc"
ITEM.quantity = 6
ITEM.width = 2
ITEM.height = 2
ITEM.price = 100

ITEM:hook("use", function(item)
	item.player:EmitSound("physics/body/body_medium_break2.wav", 90, 150)
end)