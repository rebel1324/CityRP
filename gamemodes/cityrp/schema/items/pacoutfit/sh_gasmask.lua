ITEM.name = "Respirator"
ITEM.desc = "gasmaskDesc"
ITEM.model = "models/barneyhelmet_faceplate.mdl"
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 2500
ITEM.iconCam = {
	pos = Vector(133.12742614746, 109.28756713867, 78.981819152832),
	ang = Angle(25, 220, 0),
	fov = 4.5012266396634,
	outline = true,
	outlineColor = Color(255, 255, 255)
}
ITEM.team = {1}
ITEM.exRender = true
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(8.4950472228229e-005, -66.922698974609, -89.999969482422),
					["UniqueID"] = "3085914138",
					["ClassName"] = "model",
					["Size"] = 0.95,
					["EditorExpand"] = true,
					["Model"] = "models/barneyhelmet_faceplate.mdl",
					["Position"] = Vector(3.3733520507813, -1.6019897460938, -0.00595703125),
				},
			},
		},
		["self"] = {
			["EditorExpand"] = true,
			["UniqueID"] = "GASMASK_MODEL",
			["ClassName"] = "group",
			["Name"] = "my outfit",
			["Description"] = "add parts to me!",
		},
	},
}
ITEM.removeOnDeath = true

if (SERVER) then
	local function toggleGas(client, item, bool)
		local gasBool = client:getNetVar("gasMaskOn", false)

		if (gasBool != bool) then
			client:EmitSound(bool and "gasmaskon.wav" or "gasmaskoff.wav", 80)
			client:ScreenFade(1, Color(0, 0, 0, 255), 1, 0)
		end

		client:setNetVar("gasMaskOn", bool)

        if (bool) then
            local a, b = "ResetVariables", "removeGasVar"

            hook.Add(a, b, function(client, signal)
                if (not (signal == SIGNAL_JOB)) then
                    client:setNetVar("gasMaskOn", false)

                    hook.Remove(a, b)
                end
            end)
        end
    end

	ITEM.postHooks.drop = function(item, result, data)
		toggleGas(item.player, item, false)
	end

	ITEM.postHooks.Equip = function(item, result, data)
		toggleGas(item.player, item, true)
	end

	ITEM.postHooks.EquipUn = function(item, result, data)
		toggleGas(item.player, item, false)
	end
end