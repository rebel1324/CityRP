local CHAR = FindMetaTable("Character")

function CHAR:getOrganization()
    return self:getData("organization", -1)
end

function CHAR:getOrganizationInfo()
    return nut.org.loaded[self:getOrganization()]
end

function CHAR:setOrganization(orgID)
    return self:setData("organization", orgID)
end

function CHAR:canJoinOrganization(orgID)
    local org = nut.org.get(orgID)

    if (org) then
        local client = self:getPlayer()

        if (client) then
            if (self:getOrganizationInfo()) then return false, "orgJoined" end

            return hook.Run("PlayerCanJoinOrganization", client, org)
        end
    end
end

function CHAR:isLeader()
    local org = nut.org.get(self:getOrganization())
    if (org) then return (org.ownerID == self:getID()) end
end