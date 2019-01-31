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
    hook.Add("CreateMenuButtons", "nutOrganization", function(tabs)
        tabs["organization"] = function(panel)
            if (hook.Run("BuildOrganizationMenu", panel) != false) then
                local org = LocalPlayer():getChar():getOrganizationInfo()

                nut.gui.orgMenu = panel
                
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
