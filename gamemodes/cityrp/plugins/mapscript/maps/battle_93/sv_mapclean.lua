local sprFilter = {
	["materials/play_assist/pa_ammo_shelfover.vmt"] = true,
}

local mdlFilter = {
	"oildrum",
	"props_battle"
}

local nameFilter = {
	["point_ammo_smg1"] = true,
	["point_ammo_smg2"] = true,
	["point_ammo_smg3"] = true,
	["point_ammo_ar1"] = true,
	["point_ammo_ar2"] = true,
	["point_ammo_smg1_1"] = true,
	["point_ammo_smg2_1"] = true,
	["point_ammo_smg3_1"] = true,
	["point_ammo_ar1_1"] = true,
	["point_ammo_ar2_1"] = true,
	["point_ammo_smg1_2"] = true,
	["point_ammo_smg2_2"] = true,
	["point_ammo_smg3_2"] = true,
	["point_ammo_ar1_2"] = true,
	["point_ammo_ar2_2"] = true,
	["brush01"] = true,
	["brush02"] = true,
	["brush03"] = true,
	["brush04"] = true,
	["hmbrush01"] = true,
	["hmbrush02"] = true,
	["teleport_assist"] = true,
}

function PLUGIN:InitPostEntity()
	for k, v in ipairs(ents.GetAll()) do
		if (v and v.IsValid and v:IsValid()) then
			local class = v:GetClass():lower()

			if (class == "env_sprite") then
				local spr = v:GetModel():lower()

				if (sprFilter[spr]) then
					v:Remove()
				end
			end	

			if (class:find("item_")) then
				v:Remove()
			end

			local mdl = v:GetModel()

			if (mdl and mdl != "") then
				mdl = mdl:lower()

				for _, key in ipairs(mdlFilter) do
					if (mdl:find(key)) then
						v:Remove()
					end
				end
			end

			local name = v:GetName()
			if (name and name != "") then
				if (nameFilter[name]) then
					v:Remove()
				end
			end
		end
	end
end
	for k, v in ipairs(ents.GetAll()) do
		if (v and v.IsValid and v:IsValid()) then
			local class = v:GetClass():lower()

			if (class == "env_sprite") then
				local spr = v:GetModel():lower()

				if (sprFilter[spr]) then
					v:Remove()
				end
			end	

			if (class:find("item_")) then
				v:Remove()
			end

			local mdl = v:GetModel()

			if (mdl and mdl != "") then
				mdl = mdl:lower()

				for _, key in ipairs(mdlFilter) do
					if (mdl:find(key)) then
						v:Remove()
					end
				end
			end

			local name = v:GetName()
			if (name and name != "") then
				if (nameFilter[name]) then
					v:Remove()
				end
			end
		end
	end