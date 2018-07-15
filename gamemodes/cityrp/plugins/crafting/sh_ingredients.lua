--[[
    I'm not going to make shit load of item files just for this shit
]]

local CHEM_MODEL = "models/rebel1324/mats/elec.mdl"
local ELEC_MODEL = "models/rebel1324/mats/chem.mdl"
local ETC_MODEL = "models/rebel1324/mats/etce.mdl"
local generateItems = {
    chem = {
        basic_adhesive = {
            name = "adhesiveBasic",
            price = 30000,
            model = CHEM_MODEL,
            maxQuantity = 50,
            desc = "craftDesc",
        },
    },
    elec = {

    },
    refill = {
        basic = {
            name = "refillBasic",
            price = 150000,
            model = ETC_MODEL,
            maxQuantity = 10,
            desc = "refillDesc",
        },
        advanced = {
            name = "refillAdvanced",
            price = 500000,
            model = ETC_MODEL,
            maxQuantity = 10,
            desc = "refillDesc",
        },
        expert = {
            name = "refillExpert",
            price = 1500000,
            model = ETC_MODEL,
            maxQuantity = 10,
            desc = "refillDesc",
        },
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
            if (itemInfo.dropModel) then
                ITEM.onGetDropModel = function() return itemInfo.dropModel end
            end
            if (itemInfo.iconCam) then
                ITEM.iconCam = itemInfo.iconCam
            end
            ITEM.isStackable = true
            ITEM.maxQuantity = itemInfo.maxQuantity or 100
        end
	end
end