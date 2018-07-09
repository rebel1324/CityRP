nut.craft.list = {}
function nut.craft.add(id, table) 
    nut.craft.list[id] = table
end
function nut.craft.get(id)
    return nut.craft.list[id]
end

CRAFT = {}
    CRAFT.name = "Gold Camo"                -- Name of the craftable thing
    CRAFT.desc = "skin gold shit mate"      -- Description of the craftable thing
    CRAFT.requiredAttribute = {}
    CRAFT.requiredItem = {
        mineral_silver = 10,
    }
    CRAFT.resultItem = {
        ammo_ar2 = 10,
    }
    CRAFT.craftingTable = {},
    nut.craft.add("a", CRAFT) 
CRAFT = nil

hook.Run("OnCraftingLoaded")