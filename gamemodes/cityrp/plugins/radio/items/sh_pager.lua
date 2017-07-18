ITEM.name = "Pager"
ITEM.model = "models/gibs/shield_scanner_gib1.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.category = "Communication"
ITEM.price = 80
ITEM.permit = "elec"

local function getText(togga)
	if (togga) then
		return "<color=39, 174, 96>" .. L"on" .. "</color>"
	else
		return "<color=192, 57, 43>" .. L"off" .. "</color>"
	end
end

function ITEM:getDesc()	
	if (!self.entity or !IsValid(self.entity)) then
		return L("srradioDesc", getText(self:getData("power")), self:getData("freq", "000.0"))
	else
		local data = self.entity:getData()
		
		return L("srradioDescEnt", (self.entity:getData("power") and "On" or "Off"), self.entity:getData("freq", "000.0"))
	end
end

if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("power")) then
			surface.SetDrawColor(110, 255, 110, 100)
		else
			surface.SetDrawColor(255, 110, 110, 100)
		end

		surface.DrawRect(w - 14, h - 14, 8, 8)
	end
end

// On player uneqipped the item, Removes a weapon from the player and keep the ammo in the item.
ITEM.functions.toggle = { -- sorry, for name order.
	name = "Toggle",
	tip = "useTip",
	icon = "icon16/connect.png",
	onRun = function(item)
		item:setData("power", !item:getData("power", false), nil, nil)
		item.player:EmitSound("buttons/button14.wav", 70, 150)

		return false
	end,
}

ITEM.functions.use = { -- sorry, for name order.
	name = "Freq",
	tip = "useTip",
	icon = "icon16/wrench.png",
	onRun = function(item)
		netstream.Start(item.player, "radioAdjust", item:getData("freq", "000,0"), item.id)

		return false
	end,
}
