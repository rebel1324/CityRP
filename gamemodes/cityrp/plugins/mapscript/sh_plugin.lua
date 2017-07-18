local PLUGIN = PLUGIN
PLUGIN.name = "Map Script"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "A Script that run on map"

local path = PLUGIN.folder
nut.util.includeDir(path .. "/maps/" .. string.lower(game.GetMap()), true)