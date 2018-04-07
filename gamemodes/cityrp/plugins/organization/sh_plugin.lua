PLUGIN.name = "Organization"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Organization plugin."

nut.org = nut.org or {}
nut.org.loaded = nut.org.loaded or {}

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
                    callback(org)
                end
            end
        end, "organization")
    end

    function nut.org.delete(id)
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

                            if (callback) then
                                callback(org)
                            end
                        end
                    end)
                end
            end
        end)
        -- db callback.
    end

    function nut.org.save(id)
        local org = nut.org.loaded[id]

        if (org) then
            nut.db.updateTable({
                _id = timeStamp,
                _name = timeStamp,
                _level = timeStamp,
                _experience = timeStamp,
                _data = timeStamp,
            }, nil, "organization", "_id = "..id)
        end
    end
end

function PLUGIN:CharacterLoaded(id)
    local char = nut.char.loaded[id]
    
    if (char) then
        local orgID = char:getOrganization()

        if (orgID and orgID > 0) then
            nut.org.load(orgID)
        end
    end
end

--TODO: on player change the name, update the organization db!