local textures = {}

textures.replaced = {}

function textures.ReplaceTexture(id, path, to)
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
		else
			return false
		end

		textures.replaced[id] = textures.replaced[id] or {}
		textures.replaced[id][path] = textures.replaced[id][path] or {}

		textures.replaced[id][path].old_tex = textures.replaced[id][path].old_tex or mat:GetTexture("$basetexture")
		textures.replaced[id][path].new_tex = tex

		mat:SetTexture("$basetexture", tex)

		return true
	end

	return false
end


function textures.SetColor(id, path, color)
	path = path:lower()

	local mat = Material(path)

	if not mat:IsError() then
		textures.replaced[id] = textures.replaced[id] or {}
		textures.replaced[id][path] = textures.replaced[id][path] or {}

		textures.replaced[id][path].old_color = textures.replaced[id][path].old_color or mat:GetVector("$color")
		textures.replaced[id][path].new_color = color

		mat:SetVector("$color", color)

		return true
	end

	return false
end

function textures.Restore(id)
	for id_, data in pairs(textures.replaced) do
		for path, tbl in pairs(data) do
			local ok, err = pcall(function()
				if tbl.old_tex then
					textures.ReplaceTexture(id_, path, tbl.old_tex)
				end

				if tbl.old_color then
					textures.SetColor(id_, path, tbl.old_color)
				end

				textures.replaced[id_][path] = nil
			end)

			if not ok then
				print("textures.lua: failed to restore:", tostring(path),  err)
			end
		end
		textures.replaced[id_] = nil
		if id == id_ then break end
	end
end

hook.Add("ShutDown", "texture_restore", function() textures.Restore() end)

return textures