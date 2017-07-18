
if not system.IsLinux() then return end

require("title")

local old_title = ""

timer.Create("console_title", 1, 0, function()
	local new_title = GetConVarString("hostname")

	if #new_title > 61 then
		new_title = new_title:sub(1, 61) .. "..."
	end

	if new_title ~= old_title then
		SetConsoleTitle(new_title)
	end

	old_title = new_title
end)
