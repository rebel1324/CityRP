PLUGIN.name = "Organization"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Organization plugin."

nut.org = nut.org or {}
nut.org.loaded = nut.org.loaded or {}

ORGANIZATION_ENABLED = true

if (ORGANIZATION_ENABLED != true) then return end

ORGANIZATION_DEFUALT_NAME = "Unnamed Organization"
ORGANIZATION_AUTO_DELETE_TIME = 60*60*24*5 -- 5 days of inactivity will get your organization deleted.
ORGANIZATION_INITIAL_MONEY = 5000
ORGANIZATION_REMOVE_EMPTY_GROUP = true -- remove 0 member organization automatically.
ORGANIZATION_ALLOW_PLAYERORGANIZATION = true -- well is the organization only for the fookign admins?

nut.util.include("meta/sh_character.lua")
nut.util.include("meta/sh_organization.lua")
nut.util.include("vgui/cl_derma.lua")
nut.util.include("sv_database.lua")
nut.util.include("sh_perks.lua")

nut.config.add("orgsFee", 1000000, "Money that costs for the organization", nil, {
	data = {min = 1, max = 10000000},
	category = "orgs"
})


if (CLIENT) then
    local myPanel
    hook.Add("CreateMenuButtons", "nutOrganization", function(tabs)
        tabs["organization"] = function(panel)
            if (hook.Run("BuildEntitiesMenu", panel) != false) then
                local org = LocalPlayer():getChar():getOrganizationInfo()

                myPanel = panel
                
                if (org) then
                    panel:Add("nutOrgManager")
                else
                    panel:Add("nutOrgJoiner")
                end
            end
        end
    end)
    
    netstream.Hook("nutOrgJoined", function()
        if (IsValid(myPanel)) then
            nut.gui.orgloading:Remove()
            myPanel:Add("nutOrgManager")
        end
    end)

    netstream.Hook("nutOrgExited", function()
        if (IsValid(myPanel)) then
            nut.gui.orgloading:Remove()
            myPanel:Add("nutOrgJoiner")
        end
    end)

    netstream.Hook("nutOrgKicked", function()
        if (IsValid(myPanel)) then
            if (IsValid(nut.gui.orgman)) then
                nut.gui.orgman:Remove()
            end
            
            if (IsValid(nut.gui.orgloading)) then
                nut.gui.orgloading:Remove()
            end

            timer.Simple(0, function()
                myPanel:Add("nutOrgJoiner")
            end)
        end
    end)
end

if (SERVER) then
    function nut.org.create(callback)
        local ponNull = pon.encode({})

		local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.insertTable({
            _name = ORGANIZATION_DEFUALT_NAME,
            _lastModify = timeStamp,
            _timeCreated = timeStamp,
            _level = 1, 
            _money = ORGANIZATION_INITIAL_MONEY, 
            _experience = 0,
            _data = ponNull
        }, function(succ, orgID) 
            if (succ != false) then
                local org = nut.org.new()
                org.id = orgID
                nut.org.loaded[orgID] = org

                if (callback) then
                    org:sync()
                    callback(org)
                end
            end
        end, "organization")
    end

    function nut.org.delete(id)
        local org = nut.org.loaded[id]
        
        if (org) then
            local affectedPlayers = {}

            for k, v in ipairs(player.GetAll()) do
                local char = v:getChar()

                if (char) then
                    local charOrg = char:getOrganization()

                    if (charOrg == id) then
                        char:setData("organization", nil, nil, player.GetAll())
                        char:setData("organizationRank", nil, nil, player.GetAll())

                        table.insert(affectedPlayers, v)
                    end
                end
            end

            hook.Run("OnOranizationDeleted", org, affectedPlayers)

            org:unsync()

            nut.org.loaded[id] = nil
            nut.db.query("DELETE FROM nut_organization WHERE _id IN ("..org.id..")")

            return true
        else
            return false, "invalidOrg"
        end
    end

    function nut.org.syncAll(recipient)
        local orgData = {}
        for k, v in pairs(nut.org.loaded) do
            orgData[k] = v:getSyncInfo()
        end
        netstream.Start(recipient, "nutOrgSyncAll", orgData)
    end

    function nut.org.purge(callback)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time() - ORGANIZATION_AUTO_DELETE_TIME)
        
        nut.db.query("DELETE FROM nut_organization WHERE _lastModify <= '".. timeStamp .."'", function(data, data2)
            if (callback) then
                callback()
            end
        end)
    end

    function nut.org.load(id, callback)
        local org = nut.org.new()

        nut.db.query("SELECT _id, _name, _level, _experience, _data FROM nut_organization WHERE _id IN ("..id..")", function(data)
            if (data) then
                for k, v in ipairs(data) do
                    local org = nut.org.new()
                    org.id = tonumber(v._id)
                    org.name = v._name
                    org.level = tonumber(v._level)
                    org.experience = tonumber(v._experience)
                    org.data = pon.decode(v._data)

                    nut.org.loaded[org.id] = org

                    nut.db.query("SELECT _orgID, _charID, _rank, _name FROM nut_orgmembers WHERE _orgID IN ("..org.id..")", function(data)
                        if (data) then
                            for k, v in ipairs(data) do
                                local rank = tonumber(v._rank)
                                org.members[rank] = org.members[rank] or {}
                                org.members[rank][tonumber(v._charID)] = v._name
                            end
                        end

                        if (callback) then
                            callback(org)
                        end
                    end)
                end
            end
        end)
    end
    
    function nut.org.loadAll(callback)
        local org = nut.org.new()

        nut.db.query("SELECT _id, _name, _level, _experience, _data FROM nut_organization", function(data)
            if (data) then
                for k, v in ipairs(data) do
                    local org = nut.org.new()
                    org.id = tonumber(v._id)
                    org.name = v._name
                    org.level = tonumber(v._level)
                    org.experience = tonumber(v._experience)
                    org.data = pon.decode(v._data)

                    nut.org.loaded[org.id] = org

                    nut.db.query("SELECT _orgID, _charID, _rank, _name FROM nut_orgmembers WHERE _orgID IN ("..org.id..")", function(data)
                        if (data) then
                            for k, v in ipairs(data) do
                                local rank = tonumber(v._rank)
                                org.members[rank] = org.members[rank] or {}
                                org.members[rank][tonumber(v._charID)] = v._name
                            end
                        end

                        if (callback) then
                            callback(org)
                        end
                    end)
                end
            end
        end)
    end
end

if (SERVER) then
    function PLUGIN:PlayerInitialSpawn(client)
        nut.org.syncAll(client)

        local fookinData = {}
        for k, v in ipairs(player.GetAll()) do
            if (v == client) then continue end
            
            local char = v:getChar()

            if (char) then
                local id = char:getID()

                if (char:getOrganization() != -1) then
                    fookinData[id] = {
                        char:getData("organization"),
                        char:getData("organizationRank")
                    }
                end
            end
        end
        netstream.Start(client, "nutOrgCharSync", fookinData)
    end

    function PLUGIN:InitializedPlugins()
        nut.org.purge(function()
            nut.org.loadAll(function(org)
                hook.Run("OnOrganizationLoaded", org)
            end)
        end)
    end

    function PLUGIN:CanChangeOrganizationVariable(client, key, value)
        return true
    end

    function PLUGIN:CanCreateOrganization(client)
        local char = client:getChar()

        if (char) then
            if (not char:hasMoney(nut.config.get("orgsFee"))) then
                return false, "cantAfford"
            end

            if (char:getOrganizationInfo()) then
                return false, "orgExists"
            else
                return true
            end
        end

        return false
    end

    function PLUGIN:OnCreateOrganization(client, organization)
        local char = client:getChar()

        if (char) then
            char:takeMoney(nut.config.get("orgsFee"))
        end
    end

    function PLUGIN:PlayerCanJoinOrganization()
        return true
    end
end

if (CLIENT) then
    -- organization networkings
    do
        netstream.Hook("nutOrgCharSync", function(data)
            for id, syncDat in pairs(data) do
                local character = nut.char.loaded[id]
                
                if (character) then
                    character.vars.data = character.vars.data or {}

                    character:getData()["organization"] = syncDat[1]
                    character:getData()["organizationRank"] = syncDat[2]
                end
            end
        end)
        --sync specific server organization data
        netstream.Hook("nutOrgSyncAll", function(orgsData)
            if (orgsData) then
                for id, data in pairs(orgsData) do
                    local org = nut.org.loaded[id] or nut.org.new()

                    for k, v in pairs(data) do
                        org[k] = v
                    end

                    nut.org.loaded[id] = org
                end
            end
        end)

        --sync specific server organization data
        netstream.Hook("nutOrgSync", function(id, data)
            if (data) then
                local org = nut.org.loaded[id] or nut.org.new()

                for k, v in pairs(data) do
                    org[k] = v
                end

                nut.org.loaded[id] = org
            else
                print("got org sync request but no data found")
            end
        end)

        netstream.Hook("nutOrgRemove", function(id)
            nut.org.loaded[id] = nil
        end)
        --sync 
        netstream.Hook("nutOrgSyncValue", function(id, key, value)
            if (nut.org.loaded[id]) then
                nut.org.loaded[id][key] = value
            end
        end)

        netstream.Hook("nutOrgSyncData", function(id, key, value)
            print(id, key, value)
            if (nut.org.loaded[id] and nut.org.loaded[id].data) then
                nut.org.loaded[id].data[key] = value
            end
        end)
        
        netstream.Hook("nutOrgSyncMember", function(id, rank, charID, isChange)
            local org = nut.org.loaded[id]

            if (org) then
                if (isChange) then
                    for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                        if (org.members[i] and org.members[i][charID]) then
                            org.members[i][charID] = nil
                            break
                        end
                    end
                end

                local char = nut.char.loaded[charID]

                org.members[rank] = org.members[rank] or {}
                org.members[rank][charID] = char and char:getName() or (isChange or true)
            end
        end)
    end
else
    -- ui networkings
    do
        netstream.Hook("nutOrgCreate", function(client, data)
            local name, desc = data.name, data.desc
            if (!name) then
                client:notifyLocalized("invalid", L"name")
                return
            elseif (!desc) then
                client:notifyLocalized("invalid", L"desc")
                return
            end
            
            if (name and name:len() < 8) then
                client:notifyLocalized("tooShortInput", L"name")
                return
            elseif (desc and desc:len() < 16) then
                client:notifyLocalized("tooShortInput", L"desc")
                return
            end


            local char = client:getChar()
            
            if (char) then
                local bool, reason = hook.Run("CanCreateOrganization", client)
                if (bool == false) then
                    if (reason) then
                        client:notifyLocalized(reason)
                    end

                    timer.Simple(0, function()
                        netstream.Start(client, "nutOrgKicked")
                    end)
                    return
                end

                nut.org.create(function(orgObject)
                    orgObject:setOwner(char)
                    orgObject:setName(data.name)
                    orgObject:setData("desc", data.desc)
                    netstream.Start(client, "nutOrgJoined")

                    hook.Run("OnCreateOrganization", client, orgObject)
                end)
            end
        end)

        netstream.Hook("nutOrgJoin", function(client, orgID)
            local char = client:getChar()
            
            if (char) then
                local org = nut.org.loaded[orgID]

                if (org) then
                    local bool, reason = char:canJoinOrganization()

                    if (bool != false) then
                        org:addCharacter(char, ORGANIZATION_MEMBER)
                        netstream.Start(client, "nutOrgJoined")
                    else
                        client:notifyLocalized(reason)
                    end
                else
                    client:notifyLocalized("invalidOrg")
                end
            end
        end)

        netstream.Hook("nutOrgExit", function(client)
            local char = client:getChar()
            
            if (char) then
                local org = char:getOrganizationInfo()

                if (org) then
                    local bool, reason = org:removeCharacter(char, true)

                    if (bool == false and reason) then
                        client:notifyLocalized(reason)
                    else
                        netstream.Start(client, "nutOrgExited")
                    end
                else
                    client:notifyLocalized("invalidOrg")
                end
            end
        end)

        netstream.Hook("nutOrgDelete", function(client)
            local char = client:getChar()
            
            if (char) then
                local org = char:getOrganizationInfo()

                if (org) then
                    nut.org.delete(org:getID())
                else
                    client:notifyLocalized("invalidOrg")
                end
            end
        end)

        netstream.Hook("nutOrgBan", function(client, target)
            local char = client:getChar()
            
            if (char) then
                local rank = char:getOrganizationRank()

                if (rank >= ORGANIZATION_ADMIN) then
                    local org = char:getOrganizationInfo()
    
                    if (org) then
                        local banList = org:getData("bans", {})
                        banList[target] = true
                        org:setData("bans", {})

                        client:notifyLocalized("orgBannedPlayer")
                        org:removeCharacter(target)
                        netstream.Start(client, "nutOrgUpdateManager")
                        
                        local targetChar = nut.char.loaded[target]
                        if (targetChar) then
                            local targetClient = targetChar:getPlayer()

                            if (IsValid(targetClient)) then
                                targetClient:notifyLocalized("orgBanned")
                                netstream.Start(targetClient, "nutOrgKicked")
                            end
                        end
                    else
                        client:notifyLocalized("invalidOrg")
                    end
                else
                    client:notifyLocalized("notOrgAdmin")
                end
            end
        end)

        netstream.Hook("nutOrgKick", function(client, target)
            local char = client:getChar()
            
            if (char) then
                local rank = char:getOrganizationRank()

                if (rank >= ORGANIZATION_ADMIN) then
                    local org = char:getOrganizationInfo()
    
                    if (org) then
                        client:notifyLocalized("orgKickedPlayer")
                        org:removeCharacter(target)
                        netstream.Start(client, "nutOrgUpdateManager")
                        
                        local targetChar = nut.char.loaded[target]
                        if (targetChar) then
                            local targetClient = targetChar:getPlayer()

                            if (IsValid(targetClient)) then
                                client:notifyLocalized("orgKicked")
                                netstream.Start(targetClient, "nutOrgKicked")
                            end
                        end
                    else
                        client:notifyLocalized("invalidOrg")
                    end
                else
                    client:notifyLocalized("notOrgAdmin")
                end
            end
        end)

        --[[
            nutOrgAssign
            parameter:
            client [Player]
            target [Character Index]
            rank [Rank ENUM]
        ]]
        netstream.Hook("nutOrgAssign", function(client, target, changeRank)
            local char = client:getChar()
            local charID = char:getID()
            
            if (char and target) then
                local org = char:getOrganizationInfo()

                if (charID == target) then
                    client:notifyLocalized("rankOrgCantSelf")
                    return
                end

                if (org) then
                    local clientIsMember, clientRank = org:getMember(charID)
                    local targetIsMember, targetRank = org:getMember(target)
                    local targetChar = nut.char.loaded[target]

                    if (clientIsMember and targetIsMember and clientRank >= ORGANIZATION_SUPERADMIN) then
                        if (changeRank >= clientRank) then
                            client:notifyLocalized("noOrgPermission")
                        else
                            local bool, reason = org:adjustMemberRank(target, changeRank) 

                            if (bool) then
                                client:notifyLocalized("rankOrgAdjusted")
                                netstream.Start(client, "nutOrgUpdateManager")
                        
                                if (targetChar) then
                                    local targetClient = targetChar:getPlayer()

                                    if (IsValid(targetClient)) then
                                        targetClient:notifyLocalized("rankOrgAdjustedTarget")
                                        netstream.Start(targetClient, "nutOrgUpdateManager")
                                    end
                                end
                            else
                                client:notifyLocalized(reason)
                            end
                        end
                    else
                        client:notifyLocalized("invalidOrg")
                    end
                else
                    client:notifyLocalized("notOrgAdmin")
                end
            end
        end)


        netstream.Hook("nutOrgChangeValue", function(client, key, value)
            local char = client:getChar()
            
            if (char) then
                local org = char:getOrganizationInfo()

                if (org) then
                    local bool, reason = hook.Run("CanChangeOrganizationVariable", client, key, value)

                    if (bool) then
                        if (key == "name") then
                            org:setName(value)
                        else
                            org:setData(key, value)
                        end
                    else
                        client:notifyLocalized(reason)
                    end
                else
                    client:notifyLocalized("invalidOrg")
                end
            end
        end)
    end
end

--TODO: on player change the name, update the organization db!
--TODO: on player deletes the character, wipe out organization data!
