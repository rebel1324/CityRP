ITEM.name = "Ammo Base"
ITEM.model = "models/Items/BoxSRounds.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.ammo = "pistol" // type of the ammo
ITEM.ammoAmount = 30 // amount of the ammo
ITEM.desc = "ammoDesc"
ITEM.category = "Ammunition"

function ITEM:getDesc()
	return L(self.desc, self.ammoAmount)
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		nut.util.drawText(item.ammoAmount, 4, h - 3, color, 0, 4, "nutSmallFont")
	end
end

// On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.use = { -- sorry, for name order.
	name = "Load",
	tip = "useTip",
	icon = "icon16/add.png",
	onRun = function(item)
		item.player:GiveAmmo(item.ammoAmount, item.ammo)
		item.player:EmitSound("items/ammo_pickup.wav", 110)
		
		return true
	end,
}
