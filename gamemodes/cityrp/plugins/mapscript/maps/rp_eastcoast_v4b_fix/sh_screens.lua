do
	if (SERVER) then
		--[[
			CREATE MAP EVENT HOOKER
			THIS WILL HELP DEVELOPER TO RELAY THE INPUT/OUTPUT
			OF THE MAP EVENTS
		]]
		do
			local ENT = {}
			ENT.Type = "point"
			function ENT:AcceptInput( inputName, activator, called, data )
				hook.Run("CustomTrigger", inputName, activator, data, called)
			end
			scripted_ents.Register(ENT, "hooker")
		end

		--[[
			REMOVE SHITS
		]]
		local mapInfo = {
			id = {
				[2048] = true
			},
			model = {
				["models/props_junk/bicycle01a.mdl"] = true
			},
			class = {
				prop_physics_multiplayer = true,
				func_physbox_multiplayer = true,
				func_physbox_multiplayer = true,
				keyframe_rope = true,
				move_rope = true,
			},
			name = {
				--club_spotlight_branch = true
			}
		}
		function PLUGIN:InitPostEntity()
			HOOKER = ents.Create("hooker")

			for k, v in ipairs(ents.GetAll()) do
				local idList = mapInfo.id
				local mdlList = mapInfo.model
				local classList = mapInfo.class
				local nameList = mapInfo.name
				local mdl = v:GetModel() or ""
				local isBanned = idList[v:MapCreationID()] or mdlList[mdl:lower()] or classList[v:GetClass()] or nameList[v:GetName()]

				if (isBanned) then
					v:Remove()
				end
			end
		end

		local min = Vector(-4032.490234, 2360.863037, -62.760902)
		local max = Vector(-3194.483887, 3242.707275, 243.360474)
		function PLUGIN:PlayerShouldTakeDamage(client, damage)
			local pos = client:GetPos()

			if (pos:WithinAABox(min, max)) then
				return false
			end
		end
	end
end