DeriveGamemode("nutscript")

local whiteList = {
	constraintinfo = true,
	material = true,
	weld = true,
	nocollide = true,
	colour = true,
	measuringstick = true,
	fading_door = true,
	shareprops = true,
	nocollide_world = true,
	balloon = true,
	camera = true,
	button = true,
	remover = true,
	keypad_willox = true,
	material = true,
	camera = true,
}


hook.Add("CanTool", "asfasfsaf", function(client, trace, mode, ENT)
    if (whiteList[mode]) then
        return true 
    end

    return client:IsSuperAdmin()
end)

if (CLIENT) then
    local function eliminateCunts()
        local SWEP = weapons.GetStored("gmod_tool")
        if (SWEP) then
            local TOOLS_LIST = SWEP.Tool
    
            for k, v in pairs(TOOLS_LIST) do
                if (!whiteList[k]) then 
                    v.AddToMenu = false
                    continue
                end
            end
        end
	end

	--[[---------------------------------------------------------
		Called to create the spawn menu..
	-----------------------------------------------------------]]
    local function CreateSpawnMenu()
            eliminateCunts()

            -- If we have an old spawn menu remove it.
            if ( IsValid( g_SpawnMenu ) ) then

                g_SpawnMenu:Remove()
                g_SpawnMenu = nil

            end

            -- Start Fresh
            spawnmenu.ClearToolMenus()

            -- Add defaults for the gamemode. In sandbox these defaults
            -- are the Main/Postprocessing/Options tabs.
            -- They're added first in sandbox so they're always first
            hook.Run( "AddGamemodeToolMenuTabs" )

            -- Use this hook to add your custom tools
            -- This ensures that the default tabs are always
            -- first.
            hook.Run( "AddToolMenuTabs" )

            -- Use this hook to add your custom tools
            -- We add the gamemode tool menu categories first
            -- to ensure they're always at the top.
            hook.Run( "AddGamemodeToolMenuCategories" )
            hook.Run( "AddToolMenuCategories" )

            -- Add the tabs to the tool menu before trying
            -- to populate them with tools.
            hook.Run( "PopulateToolMenu" )

            g_SpawnMenu = vgui.Create( "SpawnMenu" )
            g_SpawnMenu:SetVisible( false )

            CreateContextMenu()

            hook.Run( "PostReloadToolsMenu" )
    end
    
	-- Hook to create the spawnmenu at the appropriate time (when all sents and sweps are loaded)
	hook.Add( "OnGamemodeLoaded", "CreateSpawnMenu", CreateSpawnMenu )
	concommand.Add( "spawnmenu_reload", CreateSpawnMenu )
end
