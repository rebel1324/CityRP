PLUGIN.name = "Organization"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Organization plugin."

nut.org = nut.org or {}
nut.org.loaded = nut.org.loaded or {}

ORGANIZATION_ENABLED = true

if (ORGANIZATION_ENABLED != true) then return end

ORGANIZATION_DEFUALT_NAME = "Unnamed Organization"

nut.util.include("meta/sh_character.lua")
nut.util.include("meta/sh_organization.lua")
nut.util.include("sv_database.lua")

if (SERVER) then
    function nut.org.create(callback)
        local ponNull = pon.encode({})

        nut.db.insertTable({
            _name = ORGANIZATION_DEFUALT_NAME,
            _level = 1, 
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
        nut.org.loaded[id]:unsync()
        nut.org.loaded[id] = nil
		nut.db.query("DELETE FROM nut_organization WHERE _id IN ("..id..")")
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

                    nut.db.query("SELECT _orgID, _charID, _rank FROM nut_orgmembers WHERE _orgID IN ("..id..")", function(data)
                        if (data) then
                            for k, v in ipairs(data) do
                                local rank = tonumber(v._rank)
                                org.members[rank] = org.members[rank] or {}
                                org.members[rank][tonumber(v._charID)] = true
                            end
                        end

                        if (callback) then
                            callback(org)
                        end
                    end)
                end
            end
        end)
        -- db callback.
    end
end

-- load org information when character's organization is not loaded in the server's memory.
function PLUGIN:CharacterLoaded(id)
    local char = nut.char.loaded[id]
    
    if (char) then
        local orgID = char:getOrganization()

        if (orgID and orgID > 0) then
            if (!nut.org.loaded[orgID]) then
                nut.org.load(orgID, function(org)
                    org:sync()
                end)
            end
        end
    end
end

function PLUGIN:PlayerInitialSpawn(client)
    for k, v in pairs(nut.org.loaded) do
        v:sync(client)
    end
end

if (CLIENT) then
    --sync specific server organization data
    netstream.Hook("nutOrgSync", function(id, data)
        if (data) then
            local org = nut.org.new()

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
        print(id, key, value)
        if (nut.org.loaded[id]) then
            nut.org.loaded[id][key] = value
        end
    end)

    netstream.Hook("nutOrgSyncData", function(id, key, value)
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

            org.members[rank] = org.members[rank] or {}
            org.members[rank][charID] = true
        end
    end)

    netstream.Hook("nutOrgSyncOfflineMembers", function(id, data)
        
    end)
else

end

--TODO: on player change the name, update the organization db!
--TODO: on player deletes the character, wipe out organization data!