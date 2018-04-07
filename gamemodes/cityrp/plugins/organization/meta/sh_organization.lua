
local ORGANIZATION = {}
debug.getregistry().Organization = ORGANIZATION -- hi mark

ORGANIZATION_OWNER = 5
ORGANIZATION_SUPERADMIN = 4
ORGANIZATION_ADMIN = 3
ORGANIZATION_MODERATOR = 2
ORGANIZATION_TRUSTED = 1
ORGANIZATION_MEMBER = 0

function nut.org.new()
    return setmetatable({
        name = "Unnamed Organization",
        id = 0,
        members = {},
        level = 1, 
        experience = 0,
        data = {}
    }, {__index = ORGANIZATION})
end

if (SERVER) then
    function ORGANIZATION:__tostring()
        return "organization [" .. self.id .. "]"
    end

    function ORGANIZATION:__eq(other)
        return (self.id == other.id)
    end

    function ORGANIZATION:addCharacter(char, rank, callback)
        local charID = (type(char) == "table" and char:getID() or char)
        
        if (charID) then
            rank = rank or ORGANIZATION_MEMBER
            self.members[rank] = self.members[rank] or {}
            self.members[rank][charID] = true -- member level.

            local targetChar = nut.char.loaded[charID]
            if (SERVER and targetChar) then
                char:setData("organization", self.id)
                char:setData("organizationRank", rank)
            end

            nut.db.insertTable({
                _orgID = self.id,
                _charID = charID, 
                _rank = rank,
                _name = char:getName()
            }, function(succ) 
                netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID)
            end, "orgmembers")
        else
            return false, "noChar"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setName(text)
        self.name = text

        nut.db.updateTable({
            _name = text,
        }, nil, "organization", "_id = ".. self.id)

        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "name", text)
    end

    function ORGANIZATION:adjustMemberRank(charID, rank)
        local charID = (type(char) == "table" and char:getID() or char)

        if (charID) then
            for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                if (self.members[i] and self.members[i][charID]) then
                    self.members[i][charID] = nil
                    break
                end
            end

            self.members[rank] = self.members[rank] or {}
            self.members[rank][charID] = true 

            nut.db.updateTable({
                _rank = rank,
            }, nil, "orgmembers", "_charID = ".. charID .. " AND _orgID = " .. self.id)
            
            netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID, true)

            local targetChar = nut.char.loaded[charID]
            if (targetChar and SERVER) then
                targetChar:setData("organizationRank", rank)
            end

            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:removeCharacter(char)
        local charID = (type(char) == "table" and char:getID() or char)
        
        local removed = false
        for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
            if (self.members[i] and self.members[i][charID]) then
                self.members[i][charID] = nil

                removed = true
            end
        end
        
        if (removed) then
            local targetChar = nut.char.loaded[charID]
            if (targetChar and SERVER) then
                targetChar:setData("organization", nil)
                targetChar:setData("organizationRank", nil)
            end

            nut.db.query("DELETE FROM nut_orgmembers WHERE _charID = " .. charID .. " AND _orgID = " .. self.id)
            
            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setData(key, value)
        self.data[key] = value
    end

    function ORGANIZATION:setExperience(amt)
        self.experience = amt

        nut.db.updateTable({
            _experience = amt,
        }, nil, "organization", "_id = ".. self.id)
        
        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "experience", amt)
    end

    function ORGANIZATION:addExperience(amt)
        self:setExperience(self:getExperience() + amt)
    end

    function ORGANIZATION:setLevel(amt)
        self.level = amt
        
        nut.db.updateTable({
            _level = amt,
        }, nil, "organization", "_id = ".. self.id)

        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "level", amt)
    end

    function ORGANIZATION:setOwner(char)
        if (char) then
            self:addCharacter(char, ORGANIZATION_OWNER)
        end
    end

    function ORGANIZATION:addLevel(amt)
        self:setLevel(self:getLevel() + amt)
    end
end

function ORGANIZATION:getID()
    return self.id
end

function ORGANIZATION:getName()
    return self.name
end

function ORGANIZATION:getMemberRank(char)
    return char:getData("organizationRank", ORGANIZATION_MEMBER)
end

function ORGANIZATION:getRankMember(id)
    return self.members[id]
end

function ORGANIZATION:getData(key, default)
    return self.data[key] or default
end

function ORGANIZATION:getExperience()
    return self.experience
end

function ORGANIZATION:getLevel()
    return self.level
end

-- returns 
function ORGANIZATION:getOwner(char)
    local that

    if (self.members[ORGANIZATION_OWNER]) then
        for k, v in pairs(self.members[ORGANIZATION_OWNER]) do
            that = k
            break;
        end
    end

    local char = nut.char.loaded[that]

    if (char) then
        local client = char:getPlayer()

        if (IsValid(client)) then
            return client
        end 

        return char
    end

    return that
end

do
    function ORGANIZATION:unsync(recipient)
        recipient = recipient or player.GetAll()

        netstream.Start(recipient, "nutOrgRemove", self.id)
    end

    function ORGANIZATION:sync(recipient)
        recipient = recipient or player.GetAll()

        netstream.Start(recipient, "nutOrgSync", self.id, self:getSyncInfo())
    end

    --client does not need every data.
    function ORGANIZATION:getSyncInfo()
        return {
            name = self.name,
            level = self.level,
            experience = self.experience,
            id = self.id,
            data = self.data,
            members = self.members
        }
    end
end