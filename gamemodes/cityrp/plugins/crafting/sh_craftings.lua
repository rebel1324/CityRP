nut.craft.list = {}
function nut.craft.add(id, table) 
    if (id and not istable(id)) then
        table.id = id
        nut.craft.list[id] = table
    else
        nut.craft.list[table.id] = table
    end
end
function nut.craft.get(id)
    return nut.craft.list[id]
end

CRAFT = {}
    CRAFT.name = "refillExpert"                -- Name of the craftable thing
    CRAFT.desc = "refillDesc"      -- Description of the craftable thing
    CRAFT.requiredAttribute = {}
    CRAFT.requiredItem = {
        refill_advanced = 2,
        chem_basic_adhesive = 30,
        mineral_gold = 30,
    }
    CRAFT.resultItem = {
        refill_expert = 10,
    }
    CRAFT.craftingTable = {},
    nut.craft.add("a", CRAFT) 
CRAFT = nil


hook.Run("OnCraftingLoaded")