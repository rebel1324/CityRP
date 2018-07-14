
if (CLIENT) then
    -- organization networkings
    
    do
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