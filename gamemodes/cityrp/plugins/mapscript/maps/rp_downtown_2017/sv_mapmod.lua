if (true) then return end
local irisPairs = {
    1020,
    1021,
}
local vaultDoor = 1029

hook.Add("InitPostEntity", "mapmodded", function()
    for k, v in ipairs(ents.GetAll()) do
        local hammerID = v:GetMapID()

        if (table.hasValue(irisPairs, hammerID)) then
            -- for shortage of the time
            v:SetKeyValue("waitingtime", 0.5);
        end

    end    
end)