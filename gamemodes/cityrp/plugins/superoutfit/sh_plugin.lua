PLUGIN = PLUGIN or {}
PLUGIN.name = "Advanced Citizen Outfit"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin allows the server having good amount of customizable citizens."

nut.outfit = nut.outfit or {}
nut.outfit.indexCache = nut.outfit.indexCache or {}

if (SERVER) then
    resource.AddWorkshop(320536858)
end
nut.util.include("sh_citizenmodels.lua")
nut.util.include("cl_vgui.lua")

function nut.outfit.getType(modelName)
    return OUTFIT_DATA[modelName:lower()]
end

function nut.outfit.getList(modelName)
	local outfitData = nut.outfit.getType(modelName)

    if (outfitData) then
	    return OUTFIT_REGISTERED[outfitData.uid]
    end

    return {}
end

local function getOutfitData(entity, outfitData)
	if (type(outfitData) == 'function') then
		return outfitData.outfits(entity)
	else
		return outfitData.outfits
	end
end

function nut.outfit.apply(client, character, fixIndex)
	print("[+] Applied Outfit" )
	local char = character or client:getChar()

	if (char) then
        local model = char:getModel():lower()
        local modelOutfitData = nut.outfit.getList(model)
		
		for slot, value in pairs(char:getData("outfits", {})) do
		    local data = modelOutfitData[slot]

            if (data) then
                if (fixIndex) then
                    local count = table.Count(data.outfits)
                        value = value % count
                        if (value == 0) then value = count end
                end

                if (data.func) then
                    data.func(client, value, data)
                end
			end
		end
	end
end

local function wait(time)
    local d = deferred.new()

    timer.Simple(time, function()
        d:resolve()
    end)

    return d
end

local function reset(client)
    client:SetSubMaterial()
    
    for _, data in pairs(client:GetBodyGroups()) do
        client:SetBodygroup(data.num, 0)
    end
end

-- requires material preload to acquire submaterial change.
if (CLIENT) then
	function PLUGIN:OnEntityCreated(ragdoll)
		if (ragdoll and ragdoll:IsValid() and ragdoll:GetClass() == "class C_HL2MPRagdoll") then
			local client = ragdoll:GetRagdollOwner()
			if (client and client:IsValid()) then
                hook.Run("CreateEntityRagdoll", client, ragdoll)
			end
		end
	end

	-- currently only applies on local player.
	-- should store cloth data on char or player.
	function PLUGIN:CreateEntityRagdoll(client, ragdoll)
		if (ragdoll and ragdoll:IsValid() and client:getChar()) then
            nut.outfit.apply(ragdoll, client:getChar())
		end
	end

	netstream.Hook("nutCloseOutfit", function(client)
		if (nut.gui.outfit and nut.gui.outfit.remove) then
			nut.gui.outfit:remove()
		end
	end)
else
	netstream.Hook("nutApplyOutfit", function(client, values)
		local outfitEntity
		for k, v in ipairs(ents.FindInSphere(client:GetPos(), 128)) do
			if (v:GetClass() == "nut_outfit") then
				outfitEntity = v
				break
			end
		end

		if (!outfitEntity) then return end

		local char = client:getChar()

		if (char) then
			local mdl = char:getModel()
			local outfitList = OUTFIT_REGISTERED[OUTFIT_DATA[mdl:lower()].uid]

			if (!outfitList) then
				return
			end

			local price = 0 

			local charOutfits = char:getData("outfits", {})

			for k, v in pairs(outfitList) do
				local index = values[k]
				local data = outfitList[k].outfits
	
				if (type(data) == "function") then
					data = data(client)
				end
				
				if (data) then
					local info = data[index]

					if (info) then
						if ((charOutfits[k] or 1) != index) then
							price = price + info.price or 0
						end
					end
				end
			end

			if (char:hasMoney(price)) then
				char:giveMoney(-price)
			else
				client:notifyLocalized("cantAfford")

				return 
			end

			char:setData("outfits", values)
			nut.outfit.apply(client)

			netstream.Start(client, "nutCloseOutfit")
		end
	end)
end

function PLUGIN:OnCharFallover(client, ragdoll, isFallen)
	if (client and ragdoll and client:IsValid() and ragdoll:IsValid() and client:getChar() and isFallen) then
        nut.outfit.apply(ragdoll, client:getChar())
	end
end

function PLUGIN:PrePlayerLoadedChar(client)
    reset(client)
end

function PLUGIN:PlayerLoadedChar(client, netChar, prevChar)
	wait(.02):next(function()
		if (IsValid(client)) then
			nut.outfit.apply(client)
		end
	end)
end