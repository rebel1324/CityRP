materials = materials or {}

materials.Replaced = {}

function materials.ReplaceTexture(path, to)
	if check then check(path, "string") end
	if check then check(to, "string", "ITexture", "Material") end

	path = path:lower()

	local mat = Material(path)

	if not mat:IsError() then

		local typ = type(to)
		local tex

		if typ == "string" then
			tex = Material(to):GetTexture("$basetexture")
		elseif typ == "ITexture" then
			tex = to
		elseif typ == "Material" then
			tex = to:GetTexture("$basetexture")
		else return false end

		materials.Replaced[path] = materials.Replaced[path] or {}

		materials.Replaced[path].OldTexture = materials.Replaced[path].OldTexture or mat:GetTexture("$basetexture")
		materials.Replaced[path].NewTexture = tex

		mat:SetTexture("$basetexture",tex)

		return true
	end

	return false
end


function materials.SetColor(path, color)
	if check then check(path, "string") end
	if check then check(color, "Vector") end

	path = path:lower()

	local mat = Material(path)

	if not mat:IsError() then
		materials.Replaced[path] = materials.Replaced[path] or {}
		materials.Replaced[path].OldColor = materials.Replaced[path].OldColor or mat:GetVector("$color")
		materials.Replaced[path].NewColor = color

		mat:SetVector("$color", color)

		return true
	end

	return false
end

function materials.SetInvisible(path)
	if check then check(path, "string") end

	path = path:lower()

	local mat = Material(path)

	if not mat:IsError() then
		mat:SetInt("$translucent", 1)

		return true
	end

	return false
end

function materials.RestoreAll()
	for name, tbl in pairs(materials.Replaced) do
		if
			not pcall(function()
				if tbl.OldTexture then
					materials.ReplaceTexture(name, tbl.OldTexture)
				end

				if tbl.OldColor then
					materials.SetColor(name, tbl.OldColor)
				end
			end)
		then
			print("Failed to restore: " .. tostring(name))
		end
	end
end
hook.Add("ShutDown", "material_restore", materials.RestoreAll)

module 	( "ms" , package.seeall )
/*
local replace = {
	"PLAY_ASSIST/PA_AMMO_SHELF",
	"PLAY_ASSIST/PA_HEALTH02",
	"PLAY_ASSIST/PA_WARP_IN",
}

for k,v in pairs(replace) do
	local mat = Material(v)

	if not mat:IsError() then
	else
		CreateMaterial(v, "UnlitGeneric", {
			["$basetexture"]	= "sprites/white",
			["$additive"]		= "1",
			["$vertexcolor"]	= "1",
			["$vertexalpha"]	= "1",
		})
	end
end

*/