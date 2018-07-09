--[[
    I'm not going to make shit load of item files just for this shit
]]

local generateItems = {
    mineral = {

    },
    chem = {

    },
    elec = {

    }
}

function PLUGIN:InitializedPlugins()
    for prefix, items in pairs(generateItems) do
        for uniqueID, itemInfo in pairs(items) do
            local uniqueID = prefix .. "_" .. uniqueID

            local ITEM = nut.item.register(uniqueID, nil, nil, nil, true)
            ITEM.name = itemInfo.name
            ITEM.price = itemInfo.price * itemInfo.maxQuantity
            ITEM.model = itemInfo.model
			ITEM.onGetDropModel = function() return itemInfo.dropModel end
            ITEM.isStackable = true
            ITEM.maxQuantity = ammoInfo.maxQuantity
        end
	end
end