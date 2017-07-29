GM = GM or GAMEMODE
local PLUGIN = {}

timer.Simple(1, function()
OUTFIT_REGISTERED = {
	-- EXTENDED ENHANCED CITIZEN SUPPORT
	efemale = {
		{
			name = "model",				
		},
		{
			name = "face",	
			outfits = function(entity)
				local faces = {}
				local mdl = entity:GetModel()
				local woo = OUTFIT_DATA[mdl:lower()]
				if (!woo) then return faces end
				local facemaps = woo.skins

				for i = 1, facemaps do
					table.insert(faces, {data = (i - 1), name = "facemap", price = 9500})
				end

				return faces
			end,
			func = function(entity, outfit, orig)
				if (outfit) then
					local facemap = tonumber(outfit.data)

					if (facemap) then
						entity:SetSkin(facemap)
					end
				end
			end,			
		},
		{
			bodygroup = 4,
			name = "head",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup
				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,		
		},
		{
			name = "torso",		
			bodygroup = 1,
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 5, name = "bodygroup", price = 4500},
				{data = 6, name = "bodygroup", price = 4500},
				{data = 7, name = "bodygroup", price = 4500},
				{data = 8, name = "bodygroup", price = 4500},
				{data = 9, name = "bodygroup", price = 4500},
				{data = 15, name = "bodygroup", price = 4500},
				{data = 16, name = "bodygroup", price = 4500},
				{data = 17, name = "bodygroup", price = 4500},
				{data = "citizensheetf/scrubs1_shtfe",name = "sheet", price = 4500},
				{data = "citizensheetf/scrubs2_shtfe", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_01", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_02", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_03", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_04", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_05", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_06", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_07", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_08", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_09", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_10", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_11", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_12", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_13", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_14", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_15", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_suit", name = "sheet", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)

				local find = "models/bloo_ltcom_zel/citizens/female/citizen_sheet"
				local part = orig.bodygroup
				local matIndex
				for k, v in ipairs(entity:GetMaterials()) do
					if (v == find) then
						matIndex = k - 1

						break
					end
				end

				if (!bodygroup) then
					if (part) then
						entity:SetBodygroup(part, 0)
					end

					if (matIndex) then
						entity:SetSubMaterial(matIndex, outfit.data)
					end
				else
					if (matIndex) then
						entity:SetSubMaterial(matIndex)
					end

					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,	
		},
		{
			bodygroup = 3,
			name = "gloves",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,				
		},
		{
			bodygroup = 2,
			name = "pants",	
			outfits = {
				{data = 1, name = "bodygroup", price = 4500},
				{data = "citizensheetf/scrubs1_shtfe",name = "sheet", price = 4500},
				{data = "citizensheetf/scrubs2_shtfe", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_01", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_02", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_03", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_04", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_05", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_06", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_07", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_08", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_09", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_10", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_11", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_12", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_13", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_14", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_15", name = "sheet", price = 4500},
				{data = "citizensheetf/sheet_suit", name = "sheet", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)

				local find = "models/bloo_ltcom_zel/citizens/female/citizen_sheet2"
				local part = orig.bodygroup
				local matIndex
				for k, v in ipairs(entity:GetMaterials()) do
					if (v == find) then
						matIndex = k - 1

						break
					end
				end

				if (!bodygroup) then
					if (part) then
						entity:SetBodygroup(part, 1)
					end

					if (matIndex) then
						entity:SetSubMaterial(matIndex, outfit.data)
					end
				else
					if (matIndex) then
						entity:SetSubMaterial(matIndex)
					end

					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,			
		},
	},
	emale = {
		{
			name = "model",				
		},
		{
			name = "face",	
			outfits = function(entity)
				local faces = {}
				local mdl = entity:GetModel()
				local woo = OUTFIT_DATA[mdl:lower()]
				if (!woo) then return faces end
				local facemaps = woo.skins

				for i = 1, facemaps do
					table.insert(faces, {data = (i - 1), name = "facemap", price = 9500})
				end

				return faces
			end,
			func = function(entity, outfit, orig)
				if (outfit) then
					local facemap = tonumber(outfit.data)

					if (facemap) then
						entity:SetSkin(facemap)
					end
				end
			end,		
		},
		{
			bodygroup = 4,
			name = "head",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup
				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,		
		},
		{
			name = "torso",		
			bodygroup = 1,
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 5, name = "bodygroup", price = 4500},
				{data = 6, name = "bodygroup", price = 4500},
				{data = 7, name = "bodygroup", price = 4500},
				{data = 8, name = "bodygroup", price = 4500},
				{data = 9, name = "bodygroup", price = 4500},
				{data = 15, name = "bodygroup", price = 4500},
				{data = 16, name = "bodygroup", price = 4500},
				{data = 17, name = "bodygroup", price = 4500},
				{data = 18, name = "bodygroup", price = 4500},
				{data = 19, name = "bodygroup", price = 4500},
				{data = 20, name = "bodygroup", price = 4500},
				{data = "citizensheet/sheet_02", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_03", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_reich", name = "sheet", price = 4500},
				{data = "citizensheet/scrubs1_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/scrubs2_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_suit", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_04", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_08", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_10", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_14", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_18", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_17", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_19", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_20", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_21", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_22", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_23", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_24", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_25", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_26", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_27", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_28", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_29", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_30", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_31", name = "sheet", price = 4500},
				{data = "citizensheet/costage_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/hostage_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/security_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/military_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/monk_sheet", name = "sheet", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)

				local find = "models/bloo_ltcom_zel/citizens/citizen_sheet"
				local part = orig.bodygroup
				local matIndex
				for k, v in ipairs(entity:GetMaterials()) do
					if (v == find) then
						matIndex = k - 1

						break
					end
				end

				if (!bodygroup) then
					if (part) then
						entity:SetBodygroup(part, 0)
					end

					if (matIndex) then
						entity:SetSubMaterial(matIndex, outfit.data)
					end
				else
					if (matIndex) then
						entity:SetSubMaterial(matIndex)
					end

					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,	
		},
		{
			bodygroup = 3,
			name = "gloves",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,				
		},
		{
			bodygroup = 2,
			name = "pants",	
			outfits = {
				{data = 1, name = "bodygroup", price = 4500},
				{data = "citizensheet/sheet_02", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_03", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_reich", name = "sheet", price = 4500},
				{data = "citizensheet/scrubs1_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/scrubs2_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_suit", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_04", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_08", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_10", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_14", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_18", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_17", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_19", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_20", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_21", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_22", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_23", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_24", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_25", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_26", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_27", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_28", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_29", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_30", name = "sheet", price = 4500},
				{data = "citizensheet/sheet_31", name = "sheet", price = 4500},
				{data = "citizensheet/costage_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/hostage_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/security_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/military_sheet", name = "sheet", price = 4500},
				{data = "citizensheet/monk_sheet", name = "sheet", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)

				local find = "models/bloo_ltcom_zel/citizens/citizen_sheet2"
				local part = orig.bodygroup
				local matIndex
				for k, v in ipairs(entity:GetMaterials()) do
					if (v == find) then
						matIndex = k - 1

						break
					end
				end

				if (!bodygroup) then
					if (part) then
						entity:SetBodygroup(part, 1)
					end

					if (matIndex) then
						entity:SetSubMaterial(matIndex, outfit.data)
					end
				else
					if (matIndex) then
						entity:SetSubMaterial(matIndex)
					end

					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,			
		},
	},

	-- BLACK TEA CITIZEN COMPILATION SUPPORT
	bmale = {
		{
			name = "face",	
			canDisplay = function()
			end,
			outfits = function(entity)
				local mdl = entity:GetModel()
				local faces = {}
				local woo = OUTFIT_DATA[mdl:lower()]
				if (!woo) then return faces end
				
				if (woo.facemap) then
					local mdl = entity:GetModel()
					local facemaps = woo.skins

					table.insert(faces, {mat = woo.facemap, price = 9500})
					
					if (facemaps) then
						for i = 1, #facemaps do
							table.insert(faces, {mat = facemaps[i], price = 9500})
						end
					end
				end

				return faces
			end,
			func = function(entity, outfit, orig)
				local mdl = entity:GetModel()
				local woo = OUTFIT_DATA[mdl:lower()]

				if (outfit and woo and woo.facemap) then
					local find = woo.facemap
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end
				end
			end,		
		},
		{
			name = "torso",		
			bodygroup = 1,
			outfits = {
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "models/btcitizen/citizen_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_02"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_03"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_reich"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_suit"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_04"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_08"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_10"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_14"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_18"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_17"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_19"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_20"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_21"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_22"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_23"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_24"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_25"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_26"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_27"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_28"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_29"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_30"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/sheet_31"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/costage_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/hostage_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/security_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/military_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 0, mat = "citizensheet/monk_sheet"},

				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_27"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_30"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_29"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_28"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_26"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_25"},
				{price = 5000, find = "models/btcitizen/citizen_sheet", group = 1, mat = "citizensheet/sheet_reich"},
				
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_a"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_b"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_c"},
				
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_a"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_b"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_c"},
				
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 4, mat = "models/btcitizen/prague_civ_rioter_body_col_a"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 4, mat = "models/btcitizen/prague_civ_rioter_body_col_b"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 4, mat = "models/btcitizen/prague_civ_rioter_body_col_c"},

				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/citizen_summer"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer2"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer3"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer4"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer5"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer6"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer7"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer8"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer9"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer10"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer11"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 5, mat = "models/btcitizen/summersheet/citizen_summer_camo"},

				{price = 5000, group = 6},
			},
			func = function(entity, outfit, orig)
				if (orig.bodygroup) then
					local find = outfit.find
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,	
		},
		{
			bodygroup = 3,
			name = "shoes",	
			outfits = {
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "models/btcitizen/citizen_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/sheet_02"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/sheet_03"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/sheet_17"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/sheet_24"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/sheet_26"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/hostage_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/security_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/military_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_shoes", group = 0, mat = "citizensheet/monk_sheet"},
				{price = 5000, group = 1},
				{price = 5000, group = 2},
				{price = 5000, group = 3},
			},
			func = function(entity, outfit, orig)
				/*
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end*/
				if (orig.bodygroup) then
					local find = outfit.find
					
					if (find) then
						local matIndex
						for k, v in ipairs(entity:GetMaterials()) do
							if (v == find) then
								matIndex = k - 1

								break
							end
						end
						
						if (matIndex and outfit.mat) then
							entity:SetSubMaterial(matIndex, outfit.mat)
						end
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,				
		},
		{
			bodygroup = 4,
			name = "gloves",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,				
		},
		{
			bodygroup = 2,
			name = "pants",	
			outfits = {
				{price = 5000, group = 0, find = "models/btcitizen/citizen_sheet_legs", mat = "models/btcitizen/citizen_sheet_legs",},
				
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_02"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_03"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_reich"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_suit"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_04"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_08"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_14"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_18"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_17"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_19"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_20"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_23"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_24"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_25"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_26"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_27"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_28"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_29"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_30"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/sheet_31"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/costage_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/hostage_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/security_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/military_sheet"},
				{price = 5000, find = "models/btcitizen/citizen_sheet_legs", group = 0, mat = "citizensheet/monk_sheet"},
				
				{price = 5000, group = 2},
			},
			func = function(entity, outfit, orig)
				if (orig.bodygroup) then
					local find = outfit.find
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,			
		},
	},

	bfemale = {
		{
			name = "face",	
			canDisplay = function()
			end,
			outfits = function(entity)
				local mdl = entity:GetModel()
				local faces = {}
				local woo = OUTFIT_DATA[mdl:lower()]
				if (!woo) then return faces end
				
				if (woo.facemap) then
					local mdl = entity:GetModel()
					local facemaps = woo.skins

					table.insert(faces, {mat = woo.facemap, price = 9500})
					
					if (facemaps) then
						for i = 1, #facemaps do
							table.insert(faces, {mat = facemaps[i], price = 9500})
						end
					end
				end

				return faces
			end,
			func = function(entity, outfit, orig)
				local mdl = entity:GetModel()
				local woo = OUTFIT_DATA[mdl:lower()]

				if (outfit and woo.facemap) then
					local find = woo.facemap
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end
				end
			end,		
		},
		{
			name = "torso",		
			bodygroup = 1,
			outfits = {
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "models/btcitizen/female/citizen_sheet"},

				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_01"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_02"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_03"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_04"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_05"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_06"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_07"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_08"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_09"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_10"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_11"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_12"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_13"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_14"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_15"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 0, mat = "citizensheetf/sheet_suit"},

				/*
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_01"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_02"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_03"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_04"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_05"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_06"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_07"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_08"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_09"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_10"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_11"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_12"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_13"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_14"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_15"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet", group = 1, mat = "citizensheetf/sheet_suit"},
				*/

				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_a"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_b"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 2, mat = "models/btcitizen/prague_civ_rioter_body_col_c"},
				
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_a"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_b"},
				{price = 5000, find = "models/btcitizen/prague_civ_rioter_body_col_a", group = 3, mat = "models/btcitizen/prague_civ_rioter_body_col_c"},
				
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/citizen_summer"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer2"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer3"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer4"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer5"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer6"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer7"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer8"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer9"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer10"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer11"},
				{price = 5000, find = "models/btcitizen/citizen_summer", group = 4, mat = "models/btcitizen/summersheet/citizen_summer_camo"},
			},
			func = function(entity, outfit, orig)
				if (orig.bodygroup) then
					local find = outfit.find
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,	
		},
		{
			bodygroup = 3,
			name = "shoes",	
			outfits = {
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "models/btcitizen/female/citizen_sheet"},

				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_01"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_02"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_03"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_04"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_05"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_06"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_07"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_08"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_09"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_10"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_11"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_12"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_13"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_14"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_15"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_shoes", group = 0, mat = "citizensheetf/sheet_suit"},

				{price = 5000, group = 1},
			},
			func = function(entity, outfit, orig)
				/*
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end*/
				if (orig.bodygroup) then
					local find = outfit.find
					
					if (find) then
						local matIndex
						for k, v in ipairs(entity:GetMaterials()) do
							if (v == find) then
								matIndex = k - 1

								break
							end
						end
						
						if (matIndex and outfit.mat) then
							entity:SetSubMaterial(matIndex, outfit.mat)
						end
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,				
		},
		{
			bodygroup = 4,
			name = "gloves",	
			outfits = {
				{data = 0, name = "bodygroup", price = 4500},
				{data = 1, name = "bodygroup", price = 4500},
				{data = 2, name = "bodygroup", price = 4500},
			},
			func = function(entity, outfit, orig)
				local bodygroup = tonumber(outfit.data)
				local part = orig.bodygroup

				if (bodygroup) then
					if (part) then
						entity:SetBodygroup(part, bodygroup)
					end
				end
			end,				
		},
		{
			bodygroup = 2,
			name = "pants",	
			outfits = {
				{price = 5000, group = 0, find = "models/btcitizen/female/citizen_sheet_legs", mat = "models/btcitizen/female/citizen_sheet_legs",},

				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_01"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_02"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_03"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_04"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_05"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_06"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_07"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_08"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_09"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_10"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_11"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_12"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_13"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_14"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_15"},
				{price = 5000, find = "models/btcitizen/female/citizen_sheet_legs", group = 0, mat = "citizensheetf/sheet_suit"},
				
				{price = 5000, group = 2},
			},
			func = function(entity, outfit, orig)
				if (orig.bodygroup) then
					local find = outfit.find
					
					local matIndex
					for k, v in ipairs(entity:GetMaterials()) do
						if (v == find) then
							matIndex = k - 1

							break
						end
					end
					
					if (matIndex and outfit.mat) then
						entity:SetSubMaterial(matIndex, outfit.mat)
					end

					if (outfit.group) then
						entity:SetBodygroup(orig.bodygroup, outfit.group)
					end
				end
			end,			
		},
	},
}

end)