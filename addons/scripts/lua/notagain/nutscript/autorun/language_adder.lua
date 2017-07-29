local function updateKeke()

    local lang = nut.lang.stored.english

    local newLang = {
    }

    table.Merge(lang, newLang)
end

local unique = "kek_dsjkfj4j1oi2j"
hook.Add("Think", unique, function()
    if (nut) then
        updateKeke()
        hook.Remove("Think", unique)
    end
end)