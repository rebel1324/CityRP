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

		if (SERVER) then
			local shit = {
				[2654] = 1,
				[2655] = 1,
			}
			
			hook.Add("AcceptInput", "shitfucker", function(a, b , c)
				local id = a:MapCreationID()
				
				if (b == "Use") then
					if (shit[id] == 1) then
						if (IsValid(c) and c:IsPlayer()) then
							if (c.nextBitanNotify and c.nextBitanNotify > CurTime()) then return end

							c:notify("다른 스위치를 동시에 누르면 금고의 잠금을 해제합니다.")
							c.nextBitanNotify = CurTime() + 1
						end
					end
				end
			end)
		end
	end
end