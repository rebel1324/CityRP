DeriveGamemode("nutscript")

local whiteList = {
	constraintinfo = true,
	material = true,
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
	elevator = true,
	elevators = true,
	permaprops = true,
}

hook.Add("CanTool", "asfasfsaf", function(client, trace, mode, ENT)
    if (whiteList[mode]) then
        return true 
    end

    return client:IsSuperAdmin()
end)