if SERVER then AddCSLuaFile() return end

local vgui_Create = vgui.Create
vgui.panels = setmetatable({}, {__mode='v'})

vgui.Create = function(name, ...)
	
	if type(name) ~= "string" then
		print("#1 is ", tostring(name))
		debug.Trace()
	end
	
	local ret = vgui_Create(name, ...)
	
	if not ret or not ret:IsValid() then
		debug.Trace()
	end
	
	table.insert(vgui.panels, {pnl = pnl, name = name})
	
	return ret
end

local PANEL = FindMetaTable"Panel"

local open_url = PANEL.OpenURL

function PANEL:OpenURL(url, ...)
	self.__openurl = url
	
	return open_url(self, url, ...)
end

concommand.Add("awesomium_list", function()
	for k, v in pairs(vgui.panels) do
		if v.name == "Awesomium" then
			Msg(k,":\t ")
			if ValidPanel(v) then
				print(v, v.__openurl)
				Msg("\tParent: ", v:GetParent())
			else
				print"Not GC'd"
			end
		end
	end
end)

concommand.Add("awesomium_kill",function(_,_,_, c)
	for k,v in pairs(vgui.panels) do
		if v.name == "Awesomium" then
			if k == tonumber(c) then
				v:Remove()
			end
		end
	end
end)

concommand.Add("panel_kill",function(_,_,_, c)
	for k,v in pairs(vgui.panels) do
		if v.name:lower():find(c:lower(),nil,true) then
			v:Remove()
		end
	end
end)