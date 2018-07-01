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
				["models/props_junk/bicycle01a.mdl"] = true,
				["models/props_junk/rock001a.mdl"] = true,
				["models/props_wasteland/laundry_cart002.mdl"] = true,
			},
			class = {
				prop_physics_multiplayer = true,
				func_physbox_multiplayer = true,
				keyframe_rope = true,
				move_rope = true,
			},
			name = {
				obiwan = true,
				banderia = true,
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

        local policeSpawnPoint = {
            Vector(-9422.2529296875, 4030.0688476563, 56.03125),
            Vector(-9329.8896484375, 4041.6806640625, 56.03125),
            Vector(-9204.2685546875, 4057.4738769531, 56.03125),
            Vector(-9193.873046875, 3920.5083007813, 56.03125),
            Vector(-9329.251953125, 3871.7331542969, 56.03125),
            Vector(-9449.3974609375, 3880.4799804688, 56.03125),
        }
        function PLUGIN:PlayerLoadout(client)
            local char = client:getChar()

            if (char) then
                local class = char:getClass()
                if (class) then
                    local classData = nut.class.list[class]

                    if (classData) then
                        if (classData.law) then
                            client:SetPos(table.Random(policeSpawnPoint))
                        end
                    end 
                end
            end
		end
		local min, max = Vector(-9411.001953, 9309.968750, -14.968750), Vector(-11479.968750, 8460.031250, 268.625000)
		-- gets two vector and gives min and max vector for Vector:WithinAA(min, max)
		local function sortVector(vector1, vector2)
			local minVector = Vector(0, 0, 0)
			local maxVector = Vector(0, 0, 0)

			for i = 1, 3 do
				if (vector1[i] >= vector2[i]) then
					maxVector[i] = vector1[i]
					minVector[i] = vector2[i]
				else
					maxVector[i] = vector2[i]
					minVector[i] = vector1[i]
				end
			end

			return minVector, maxVector
		end
		min, max = sortVector(min, max)
		function PLUGIN:PlayerShouldTakeDamage(client, hit, dmgInfo)
			local pos = client:GetPos()

			if (pos:WithinAABox(min, max)) then
				return false
			end
		end
	end
end