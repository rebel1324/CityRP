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

			},
			model = {
				["models/props_junk/bicycle01a.mdl"] = true
			},
			class = {
				prop_physics_multiplayer = true,
				func_physbox_multiplayer = true,
			}
		}
		function PLUGIN:InitPostEntity()
			HOOKER = ents.Create("hooker")

			for k, v in ipairs(ents.GetAll()) do
				local idList = mapInfo.id
				local mdlList = mapInfo.model
				local classList = mapInfo.class
				local mdl = v:GetModel() or ""
				local isBanned = idList[v:MapCreationID()] or mdlList[mdl:lower()] or classList[v:GetClass()]

				if (isBanned) then
					v:Remove()
				end
			end
		end
	end
end