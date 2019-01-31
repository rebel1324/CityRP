print("this is getting loaded just before CityRP loaded.")
-- This hook prevents default Nutscript plugins to load.
local noLoad = {
	act = false, -- dont load old act.
	chatbox  = false, -- CityRP is using XPChat as default chat.
	wepselect = false, -- CityRP does not use Nutscript's Weapon Selection.
	thirdperson = false, -- CityRP does not use Thridperson.
	spawnsaver = false, -- CityRP does not use spawnsaver (returning back to defualt location)
	saveitems = false, -- CityRP does not save any items on the map.
	recognition = false, -- CityRP does not need recognition.
}
-- 2019-01-20 Loading order has changed, sacrificing the code consistency.
hook.Add("PluginShouldLoad", "CityRPSupressor", function(uniqueID) 
	return noLoad[uniqueID] -- true = don't load the specified plugin.
end)

local GME = gmod.GetGamemode()
function GME:MouthMoveAnimation() // sorry, you're blocked.
end
function GME:GrabEarAnimation() // sorry, you're blocked.
end
