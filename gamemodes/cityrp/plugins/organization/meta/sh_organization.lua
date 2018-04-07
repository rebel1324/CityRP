
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

    function ORGANIZATION:addPlayer(char, rank, callback)
        if (char) then
            rank = rank or ORGANIZATION_MEMBER
            self.members[rank] = self.members[rank] or {}
            self.members[rank][char:getID()] = true -- member level.

            if (SERVER) then
                char:setData("organization", self.id)
                char:setData("organizationRank", rank)

                nut.db.insertTable({
                    _orgID = self.id,
                    _charID = char:getID(), 
                    _rank = rank,
                    _name = char:getName()
                }, function(succ) 
                end, "orgmembers")
            end
        else
            return false, "noChar"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setName(text)
        self.name = text
    end

    function ORGANIZATION:adjustMemberRank(charID, rank)
        local targetChar

        if (type(charID) == "table" and charID.getID) then
            targetChar = charID
            charID = targetChar:getID()
        end

        if (charID) then
            for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                if (self.members[i] and self.members[i][charID]) then
                    self.members[i][charID] = nil

                    break
                end
            end

            self.members[rank] = self.members[rank] or {}
            self.members[rank][charID] = true 

            if (targetChar and SERVER) then
                targetChar:setData("organizationRank", rank)
            end

            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:removePlayer()
        local charID = char:getID()
        local targetChar = nut.char.loaded[charID]

        if (self.members[char:getID()]) then
            for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                if (self.members[i][charID]) then
                    self.members[i][charID] = nil
                end
            end
            
            if (targetChar and SERVER) then
                targetChar:setData("organization", nil)
                targetChar:setData("organizationRank", nil)
            end

            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setData(key, value)
        self.data[key] = value

        -- send netstream to sync the value
        --netstream.Start("nutOrgSync", id, key, value)
    end

    function ORGANIZATION:setExperience()
        self.experience = amt
    end

    function ORGANIZATION:addExperience(amt)
        self:setExperience(self:getExperience() + amt)
    end

    function ORGANIZATION:setLevel(amt)
        self.level = amt
    end

    function ORGANIZATION:setOwner(char)
        if (char) then
            self:addPlayer(char, ORGANIZATION_OWNER)
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
    function ORGANIZATION:sync(recipient)

    end

    --client does not need every data.
    function ORGANIZATION:getSyncInfo()
        return {
            name = self:getName()
        }
    end
end