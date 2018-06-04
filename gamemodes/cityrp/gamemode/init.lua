AddCSLuaFile("cl_init.lua")
DeriveGamemode("nutscript")

concommand.Remove("gm_save")
concommand.Remove("dupe_arm")

concommand.Add("gm_save", function(client, command, arguments)
end)

concommand.Add("dupe_arm", function(client, command, arguments)
end)