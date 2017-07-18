-- Extremely invasive, but no can do :s
-- At least we could REVERT...
if	SERVER then
	AddCSLuaFile"convar_force.lua"
	return
end

hook.Add('InitPostEntity','convar_force',function()
	hook.Remove('InitPostEntity','convar_force')

	RunConsoleCommand("cl_timeout","3000")
	if GetConVarString"mat_motion_blur_enabled"=="0" then
		RunConsoleCommand("mat_motion_blur_enabled","1")
	end
	
	if GetConVarString"r_decals"=="2048" then
		RunConsoleCommand("r_decals","256") -- banni lag
	end
	
	RunConsoleCommand("ragdoll_sleepaftertime","40.0f")
	RunConsoleCommand("cl_jiggle_bone_framerate_cutoff","4")
	
	RunConsoleCommand("cl_resend","11")
end)