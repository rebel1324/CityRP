PLUGIN.name = "Macro Weapon Register - TFA"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gun Jesus have arrived."

-- get plugin's config and laguages.
nut.util.include("sh_configs.lua")
-- get item generators
nut.util.include("sh_generate_ammo.lua")
nut.util.include("sh_generate_attachment.lua")
nut.util.include("sh_generate_weapon.lua")

--[[
	
	TFA-Nutscript Integration code goes below.
	
]]
function PLUGIN:InitializedPlugins()
	do
		if (CLIENT) then
			local PANEL = {}
			function PANEL:Init()
				self:Remove()
			end

			vgui.Register("TFAAttachmentTip", PANEL, "Panel")
			vgui.Register("TFAAttachmentPanel", PANEL, "Panel")
			vgui.Register("TFAAttachmentIcon", PANEL, "Panel")
		end

		hook.Remove("EntityTakeDamage","TFA_TurretPhysics")
		hook.Remove("HUDPaint", "TFAPatchTTT")
		hook.Remove("InitPostEntity", "TFAPatchTTT")
		hook.Remove("EntityEmitSound", "zzz_TFA_EntityEmitSound")
		hook.Remove("PreDrawEffects", "TFAMuzzleUpdate")
		hook.Remove("PopulateMenuBar", "NPCOptions_MenuBar_TFA")
		hook.Remove("PostDrawTranslucentRenderables", "PreDrawViewModel_TFA_INSPECT")
		hook.Remove("InitPostEntity","InitTFABlur")
		hook.Remove("PlayerFootstep", "TFAWalkcycle")
		hook.Remove("Tick", "TFAInspectionScreenClicker")
		hook.Remove("AllowPlayerPickup", "TFAPickupDisable")
		hook.Remove("ContextMenuOpen", "TFAContextBlock")
		hook.Remove("Think", "TFAInspectionMenu")
		hook.Remove("PlayerSay", "TFAJoinGroupChat")
		hook.Remove("HUDPaint", "tfa_debugcrosshair")
		hook.Remove("canPocket", "TFA_PockBlock")
		hook.Remove("HUDPaint", "TFA_DISPLAY_CHANGELOG")
		hook.Remove("PostDrawOpaqueRenderables", "TFABallisticsRender")
		hook.Remove("PreRender", "TFABallisticsTick")
		hook.Remove("HUDPaint", "TFA_TRIGGERCLIENTLOAD")
		hook.Remove("Tick", "TFABallisticsTick")
	end
end

function PLUGIN:InitializedItems()
	if (TFA_GENERATE_ITEM) then
		print("[+] Generating TFA Weapons and Attachments")
		hook.Run("OnGenerateTFAItems", self)
	end
end

if (SERVER) then
	TFA_ATTACHMENT_QUEUE = TFA_ATTACHMENT_QUEUE or {}
	
	function PLUGIN:TFA_FinalInitAttachments(weapon)
		timer.Simple(.07, function()
			if (IsValid(weapon)) then
				local attachments = TFA_ATTACHMENT_QUEUE[weapon:EntIndex()]
				
				if (attachments) then
					for slot, attData in pairs(attachments) do
						weapon:Attach(attData[2], true, true)
					end

					TFA_ATTACHMENT_QUEUE[weapon:EntIndex()] = nil
				end
			end
        end)
	end
	
	function PLUGIN:OnPlayerAttachment(itemObject, weaponEntity, attachment, isAttach)
		if (IsValid(weaponEntity)) then
			if (isAttach) then
				if (weaponEntity.Attach) then
					weaponEntity:Attach(attachment)
				end
			else
				if (weaponEntity.Detach) then
					weaponEntity:Detach(attachment)
				end
			end
		end
	end

	function PLUGIN:OnCharAttribUpdated(client, character, key, value)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			-- update gun's stats.
		end
	end

	function PLUGIN:OnCharAttribBoosted(client, character, attribID, boostID, boostAmount)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			-- update gun's stats.
		end
	end
else
	local sizeGenerate = 512
	
	local function drawMaterial(exIcon, w, h, name, type)
		surface.SetDrawColor(Color(187, 187, 187))
		surface.DrawRect(0, 0, sizeGenerate, sizeGenerate)
		
		--[[
			surface.SetMaterial(temporalMaterial)
			surface.SetDrawColor(color_white)
			surface.DrawTexturedRect(0, 0, sizeGenerate, sizeGenerate)
		]]--
		if (type == 1) then
			nut.util.drawText(name, sizeGenerate*.24, sizeGenerate*.03, color_white, 1, 1, "nutItemDisplayRT2", 255)
			
			if (exIcon) then
				local iw, ih = sizeGenerate/8*w/2, sizeGenerate/8*h/2
				surface.SetMaterial(exIcon)
				surface.SetDrawColor(color_black)
				surface.DrawTexturedRect(sizeGenerate*.24 - iw/2, sizeGenerate*.085 - ih/2, iw, ih)
			end
		else
			nut.util.drawText(name, sizeGenerate*.2, sizeGenerate*.23, color_white, 1, 1, "nutItemDisplayRT", 255)
			
			if (exIcon) then
				local iw, ih = sizeGenerate/8*w/1.5, sizeGenerate/8*h/1.5
				surface.SetMaterial(exIcon)
				surface.SetDrawColor(color_black)
				surface.DrawTexturedRect(sizeGenerate*.2 - iw/2, sizeGenerate*.35 - ih/2, iw, ih)
			end
		end
	end

	itemRTTextrue = itemRTTextrue or {}
	function itemRTTextrue.loadItemTex(entity, itemTable, exIcon, type)
		if (exIcon) then
			local oldRT = render.GetRenderTarget()
			local newText
				
			local tamp = entity:EntIndex() .. "_custoDiam"
			itemRTTextrue.RT = GetRenderTarget(tamp, sizeGenerate, sizeGenerate, false)
			render.PushRenderTarget(itemRTTextrue.RT)
				cam.Start2D()
					render.Clear(0,0,0,255)
					render.ClearDepth()
					
					surface.SetMaterial(Material("anslogo.png"))
					surface.SetDrawColor(color_white)
					surface.DrawTexturedRect(0, 0, 512, 512)
					drawMaterial(exIcon, itemTable.width, itemTable.height, itemTable.name, type)
				cam.End2D()
			render.PopRenderTarget()
					
			local wtf = CreateMaterial(RealTime() .. "_custodium", "VertexLitGeneric")
			wtf:SetTexture("$basetexture", itemRTTextrue.RT)
			entity.customText = wtf
		end
	end
end