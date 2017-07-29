concommand.Add("vgui_cleanup", function()
	for k, v in pairs( vgui.GetWorldPanel():GetChildren() ) do
		if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then
			v:Remove()
		end
	end
end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")