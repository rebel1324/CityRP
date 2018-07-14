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
nut.util.include("sh_signals.lua")
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

    function PLUGIN:PlayerLoadedChar(client, netChar, prevChar)
        local char = client:getChar()
        if (char) then
            client:setNetVar("charOrg", char:getOrganization())
        end
    end
end


--TODO: on player change the name, update the organization db!
--TODO: on player deletes the character, wipe out organization data!
