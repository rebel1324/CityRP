AddCSLuaFile("cl_init.lua")
DeriveGamemode("nutscript")

--[[
    Why are you running
]]
concommand.Remove("gm_save")
concommand.Remove("dupe_arm")
concommand.Add("gm_save", function(client, command, arguments)
end)
concommand.Add("dupe_arm", function(client, command, arguments)
end)
hook.Add( "ShutDown", "SavePersistenceOnShutdown", function() hook.Run( "PersistenceSave" ) end )
hook.Add( "PersistenceSave", "PersistenceSave", function( name )
end )
hook.Add( "PersistenceLoad", "PersistenceLoad", function( name )
end )
cvars.AddChangeCallback( "sbox_persist", function( name, old, new )
end, "sbox_persist_load" )
hook.Add( "InitPostEntity", "PersistenceInit", function()
end )
