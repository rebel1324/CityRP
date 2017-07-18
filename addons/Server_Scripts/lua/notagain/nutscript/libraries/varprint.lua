function varprint(...)
	local args = {...}

	if #args == 0 then return end

	Msg((debug.getinfo(2, "n").name or "unknown") .. ":\n")

	-- it will only align correctly for variable names below 16 characters.
	-- I don't think there is need to make it support for anything higher since 99%
	-- of all var names are below 16 characters so the amount code for supporting > 16 chars
	-- will not be worth making

	for index, arg in pairs(args) do
		local name = debug.getlocal(2, index)
		Msg("\t" .. (name or "unknown") .. ":" .. ("\t"):rep(name and (#name < 8 and 2) or 1) .. tostring(arg) .. "\n")
	end
end