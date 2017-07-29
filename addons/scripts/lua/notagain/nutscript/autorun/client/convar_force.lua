hook.Add('InitPostEntity','convar_force',function()
	hook.Remove('InitPostEntity','convar_force')

	RunConsoleCommand("cl_timeout","3000")

	if GetConVarString"mat_motion_blur_enabled"=="0" then
		RunConsoleCommand("mat_motion_blur_enabled","1")
	end

	RunConsoleCommand("ragdoll_sleepaftertime","40.0f")
	RunConsoleCommand("cl_jiggle_bone_framerate_cutoff","4")
	RunConsoleCommand("gmod_mcore_test","1")
	RunConsoleCommand("cl_resend","11")
end)