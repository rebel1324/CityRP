local PLUGIN = PLUGIN
PLUGIN.name = "Police Armory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Armory for police classes"


function SCHEMA:ResetVariables(client, signal)
	if (IsValid(client) and client:Alive()) then
        for k, v in pairs(client:GetWeapons()) do
            if (v.policeProperty) then
                v:Remove() 
            end
        end
	end
end