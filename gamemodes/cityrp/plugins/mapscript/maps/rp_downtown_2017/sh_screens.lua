do
end

do
	if (SERVER) then
	else
	
	end
end


do
	if (SERVER) then
	else
		
	end
end

if (CLIENT) then
	hook.Add("Think", "LUASCREEN_GO", function()
	end)
	
	hook.Add("PostDrawTranslucentRenderables", "LUASCREEN_GO", function()
	end)
else
	hook.Add("Think", "aaoa", function()
	end)
	
	hook.Add("PostDrawTranslucentRenderables", "aaoa", function()
	end)
end