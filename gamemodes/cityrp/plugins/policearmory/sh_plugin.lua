local PLUGIN = PLUGIN
PLUGIN.name = "Police Armory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Armory for police classes"


function SCHEMA:ResetVariables(client, signal)
	local char = client:getChar()

	-- When player changed the job or changed the character.
	if (signal == SIGNAL_JOB) then
        for k, v in pairs(client:GetWeapons()) do
            if (v.policeProperty) then
                v:Remove() 
            end
        end
	end
end