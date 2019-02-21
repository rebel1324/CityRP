
local ORGANIZATION = nut.org.meta or {}
ORGANIZATION.__index = ORGANIZATION
ORGANIZATION.id = ORGANIZATION.id or 0
ORGANIZATION.data = ORGANIZATION.data or {}

debug.getregistry().Organization = ORGANIZATION -- hi mark

ORGANIZATION_OWNER = 5
ORGANIZATION_SUPERADMIN = 4
ORGANIZATION_ADMIN = 3
ORGANIZATION_MODERATOR = 2
ORGANIZATION_TRUSTED = 1
ORGANIZATION_MEMBER = 0
ORGANIZATION_RANK_NAME = {
    [ORGANIZATION_OWNER] = "orgRankOwner",
    [ORGANIZATION_SUPERADMIN] = "orgRankSuperadmin",
    [ORGANIZATION_ADMIN] = "orgRankAdmin",
    [ORGANIZATION_MODERATOR] = "orgRankModerator",
    [ORGANIZATION_TRUSTED] = "orgRankTrusted",
    [ORGANIZATION_MEMBER] = "orgRankMember",
}

function nut.org.new()
    return setmetatable({
        name = "Unnamed Organization",
        id = 0,
        members = {},
        level = 1, 
        money = ORGANIZATION_INITIAL_MONEY, 
        experience = 0,
        data = {}
    }, ORGANIZATION)
end

if (SERVER) then
    function ORGANIZATION:__tostring()
        return "organization [" .. (self.id or 0) .. "]"
    end

    function ORGANIZATION:__eq(other)
        return (self:getID() == other:getID())
    end

    function ORGANIZATION:addCharacter(char, rank, callback)
        local charID = (type(char) == "table" and char:getID() or char)
        
        if (charID) then
            rank = rank or ORGANIZATION_MEMBER
            self.members[rank] = self.members[rank] or {}
            
            local targetChar = nut.char.loaded[charID]
            self.members[rank][charID] = targetChar and targetChar:getName()  -- member level.

            if (SERVER and targetChar) then
                targetChar:setData("organization", self.id, nil, player.GetAll())
                targetChar:setData("organizationRank", rank, nil, player.GetAll())

                local target = targetChar:getPlayer()
                if (IsValid(target)) then
                    target:setNetVar("charOrg", self.id)
                end
            end

            nut.org.join(self.id, charID)

            netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID)
        else
            return false, "noChar"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setName(text)
        self.name = text

        nut.org.setName(self.id, text):next(function()
            netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "name", text)
        end, function(error)
            ErrorNoHalt(error)
        end)
    end

    function ORGANIZATION:adjustMemberRank(charID, rank)
        local charID = (type(char) == "table" and char:getID() or charID)

        if (charID) then
            local prevName
            for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                if (self.members[i] and self.members[i][charID]) then
                    prevName = self.members[i][charID]
                    self.members[i][charID] = nil
                    break
                end
            end
            local targetChar = nut.char.loaded[charID]
            self.members[rank] = self.members[rank] or {}
            self.members[rank][charID] = targetChar and targetChar:getName() or prevName 

            nut.org.charRank(charID, self.id, rank):next(function()
                netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID, prevName)

                if (targetChar and SERVER) then
                    targetChar:setData("organizationRank", rank, nil, player.GetAll())
                end
            end, function(error)
                ErrorNoHalt(error)
            end)

            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:removeCharacter(char, leaving)
        local charID = (type(char) == "table" and char:getID() or char)
        
        local removed = false
        for i = ORGANIZATION_MEMBER, (ORGANIZATION_OWNER - (leaving and 0 or 1)) do
            if (self.members[i] and self.members[i][charID]) then
                self.members[i][charID] = nil

                removed = true
                break
            end
        end
        
        if (removed) then
            local targetChar = nut.char.loaded[charID]
            if (targetChar and SERVER) then
                targetChar:setData("organization", nil, nil, player.GetAll())
                targetChar:setData("organizationRank", nil, nil, player.GetAll())

                local target = targetChar:getPlayer()
                if (IsValid(target)) then
                    target:setNetVar("charOrg", nil)
                end
            end

            nut.db.query("DELETE FROM nut_orgmembers WHERE _charID = " .. charID)
            self:sync()
            
            if (ORGANIZATION_REMOVE_EMPTY_GROUP == true and self:getMemberCount() == 0) then
                nut.org.delete(self.id)
            end

            return true
        else
            return false, "noMember"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setData(key, value)
        self.data[key] = value

        local serialized = pon.encode(self.data)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.updateTable({
            _data = serialized,
            _lastModify = timeStamp,
        }, nil, "organization", "_id = ".. self.id)
        
        netstream.Start(player.GetAll(), "nutOrgSyncData", self.id, key, value)
    end

    function ORGANIZATION:setExperience(amt)
        self.experience = amt

        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.updateTable({
            _experience = amt,
            _lastModify = timeStamp,
        }, nil, "organization", "_id = ".. self.id)
        
        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "experience", amt)
    end

    function ORGANIZATION:setLevel(amt)
        self.level = amt
        
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.updateTable({
            _level = amt,
            _lastModify = timeStamp,
        }, nil, "organization", "_id = ".. self.id)

        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "level", amt)
    end

    function ORGANIZATION:setMoney(amt)
        self.level = amt
        
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.updateTable({
            _money = amt,
            _lastModify = timeStamp,
        }, nil, "organization", "_id = ".. self.id)

        netstream.Start(player.GetAll(), "nutOrgSyncValue", self.id, "level", amt)
    end

    function ORGANIZATION:setOwner(char)
        if (char) then
            self:addCharacter(char, ORGANIZATION_OWNER)
        end
    end

    function ORGANIZATION:addExperience(amt)
        self:setExperience(self:getExperience() + amt)
    end

    function ORGANIZATION:addLevel(amt)
        self:setLevel(self:getLevel() + amt)
    end

    function ORGANIZATION:addMoney(amt)
        self:setLevel(self:getLevel() + amt)
    end
end

function ORGANIZATION:getMemberCount()
    local count = 0
    
    for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
        if (self.members[i]) then
            count = count + table.Count(self.members[i])
        end
    end
    
    return count
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

function ORGANIZATION:getMembersByRank(rank)
    return self.members[rank] or {}
end

function ORGANIZATION:getMember(charID)
    local member, rank
    
    for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
        if (self.members[i] and self.members[i][charID]) then
            member = self.members[i][charID]
            rank = i

            break;
        end
    end

    return member, rank
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

function ORGANIZATION:getLevel()
    return self.money
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

nut.org.meta = ORGANIZATION