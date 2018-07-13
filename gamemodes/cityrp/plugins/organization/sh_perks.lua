nut.org.perks = {}
function nut.org.registerPerk(id, tbl)
    nut.org.perks[id] = tbl
end


hook.Run("OnRegisterOrganizationPerks")