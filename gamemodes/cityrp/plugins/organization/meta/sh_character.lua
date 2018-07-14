local CHAR = FindMetaTable("Character")

function CHAR:getOrganization()
    if (SERVER) then
        return self:getData("organization", -1)
    else
        local client = self:getPlayer()

        if (IsValid(client)) then
            return client:getNetVar("charOrg")  
        else
            return self:getData("organization", -1)
        end
    end
end


function CHAR:getOrganizationRank(def)
    return self:getData("organizationRank", def)
end

function CHAR:getOrganizationInfo()
    return nut.org.loaded[self:getOrganization()]
end

function CHAR:setOrganization(orgID)
    return self:setData("organization", orgID)
end

function CHAR:canJoinOrganization(orgID)
    local org = nut.org.loaded[orgID]

    if (org) then
        local client = self:getPlayer()

        if (client) then
            if (self:getOrganizationInfo()) then
                return false, "orgJoined"
            end

            local bans = org:getData("bans", {})
            if (bans[self:getID()]) then
                return false, "charBanned"
            end
            
            return hook.Run("PlayerCanJoinOrganization", client, org)
        end
    end
end

function CHAR:isLeader()
    local org = nut.org.get(self:getOrganization())

    if (org) then
        return (org.ownerID == self:getID())
    end
end