
local ORGANIZATION = nut.org.meta or {}
ORGANIZATION.__index = ORGANIZATION
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
            self.members[rank][charID] = targetChar and targetChar:getName() or true -- member level.

            local targetChar = nut.char.loaded[charID]
            if (SERVER and targetChar) then
                char:setData("organization", self.id, nil, player.GetAll())
                char:setData("organizationRank", rank, nil, player.GetAll())
            end

            local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
                
            nut.db.updateTable({
                _lastModify = timeStamp,
            }, nil, "organization", "_id = ".. self.id)

            nut.db.insertTable({
                _orgID = self.id,
                _charID = charID, 
                _rank = rank,
                _name = char:getName()
            }, function(succ) 
            end, "orgmembers")

            netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID)
        else
            return false, "noChar"
        end

        return false, "invalidRequest"
    end

    function ORGANIZATION:setName(text)
        self.name = text

        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        nut.db.updateTable({
            _name = text,
            _lastModify = timeStamp,
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
            self.members[rank][charID] = targetChar and targetChar:getName() or true 

            local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
            nut.db.updateTable({
                _rank = rank,
                _lastModify = timeStamp,
            }, nil, "orgmembers", "_charID = ".. charID .. " AND _orgID = " .. self.id)
            
            netstream.Start(player.GetAll(), "nutOrgSyncMember", self.id, rank, charID, true)

            local targetChar = nut.char.loaded[charID]
            if (targetChar and SERVER) then
                targetChar:setData("organizationRank", rank, nil, player.GetAll())
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
                targetChar:setData("organization", nil, nil, player.GetAll())
                targetChar:setData("organizationRank", nil, nil, player.GetAll())
            end

            nut.db.query("DELETE FROM nut_orgmembers WHERE _charID = " .. charID)
            
            if (self:getMemberCount() == 0) then
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
    local count = 1

    PrintTable(self.members)
    for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
        if (self.members[i] and self.members[i][charID]) then
            count = count + 1
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