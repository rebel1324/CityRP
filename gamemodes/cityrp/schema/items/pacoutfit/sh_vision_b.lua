ITEM.name = "IR Night Vision"
ITEM.desc = "irnvGogDesc"
ITEM.model = "models/warz/miltnvg.mdl"
ITEM.price = 500
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "hat"
ITEM.price = 200
function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.iconCam = {
	ang	= Angle(0.57857143878937, 107.16369628906, 0),
	fov	= 3.5281736417478,
	pos	= Vector(54.262397766113, -179.24220275879, 70.199066162109)
}

ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(7.5132084020879e-05, -75, -90.000007629395),
					["Position"] = Vector(4.640625, 1.3984375, 0),
					["ClassName"] = "model",
					["Model"] = "models/warz/miltnvg.mdl",
					["UniqueID"] = "IRNV_MODEL",
				},
			},
		},
		["self"] = {
			["EditorExpand"] = true,
			["UniqueID"] = "IRNV",
			["ClassName"] = "group",
			["Name"] = "my outfit",
			["Description"] = "add parts to me!",
		},
	},
}

if (CLIENT) then
    local sndOn = Sound( "items/nvg_on.wav" )
    local sndOff = Sound( "items/nvg_off.wav" )
	
	netstream.Hook("nutFLIRToggle", function(bool)
		if not LocalPlayer():Alive() then
			return
		end
        
        NV_Status = bool
		NV_NIGHTTYPE = 2
        
        if bool then        
            CurScale = 0.2
            surface.PlaySound( sndOn )
            hook.Add("RenderScreenspaceEffects", "NV_FX", NV_FX)
            hook.Add("PostDrawViewModel", "NV_PostDrawViewModel", NV_PostDrawViewModel)
        else
            surface.PlaySound( sndOff )
            hook.Remove("RenderScreenspaceEffects", "NV_FX")
            hook.Remove("PostDrawViewModel", "NV_PostDrawViewModel")
        end
	end)
end

local function onEquip(item, result)
	if (item:getData("equip")) then
		netstream.Start(item.player, "nutFLIRToggle", true)
		item.player:ScreenFade(1, Color(255, 255, 255, 100), .4, 0)
	end
end

local function onEquipUn(item, result)
	if (!item:getData("equip")) then
		netstream.Start(item.player, "nutFLIRToggle", false)
		item.player:ScreenFade(1, Color(255, 255, 255, 100), .4, 0)
	end
end

ITEM:postHook("Equip", onEquip)
ITEM:postHook("EquipUn", onEquipUn)
