PLUGIN.name = "Macro Weapon Register - TFA"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gun Jesus have arrived."

nut.util.include("sh_configs.lua")
nut.util.include("sh_languages.lua")
nut.util.include("sh_attachments.lua")

TFA_GENERATE_ITEM = true 
TFA_ATTACHMENT_QUEUE = TFA_ATTACHMENT_QUEUE or {}

function PLUGIN:InitializedPlugins()
	table.Merge(nut.lang.stored["korean"], self.koreanTranslation)
	table.Merge(nut.lang.stored["english"], self.englishTranslation)

	do
		local PANEL = {}
		function PANEL:Init()
			self:Remove()
		end

		if (CLIENT) then
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
	-- Create Items with Lua
	do
		-- ammunition
		for name, data in pairs(self.ammoInfo) do
			local uniqueID = "ammo_"..name:lower()
			local ammoInfo = data

			local ITEM = nut.item.register(uniqueID, "base_ammo", nil, nil, true)
			ITEM.name = ammoInfo.name
			ITEM.ammo = name
			ITEM.price = ammoInfo.price or 200
			ITEM.model = ammoInfo.model or AMMO_BOX
			ITEM.isStackable = true
			ITEM.maxQuantity = ammoInfo.maxQuantity
			ITEM.exRender = true

			function ITEM:getDesc()
				return L("ammoDesc", self.getQuantity and self:getQuantity() or "", L(self.ammo))
			end
		end
	end

	-- Create Items with Lua
	do
		for k, v in ipairs(weapons.GetList()) do

			local class = v.ClassName

			if (weapons.IsBasedOn(v.ClassName, "tfa_gun_base")) then
				if (class:find("base")) then continue end


				-- Configure Weapon's Variables
				v.isGoodWeapon = true
				v.Primary.DefaultClip = 0

				if (self.changeAmmo[v.Primary.Ammo]) then
					v.Primary.Ammo = self.changeAmmo[v.Primary.Ammo]
				end

				-- Generate Items
				local dat = self.gunData[class] or {}
				v.Slot = dat.slot or 2

				if (TFA_GENERATE_ITEM) then
					local ITEM = nut.item.register(class:lower(), "base_weapons", nil, nil, true)
					ITEM.name = class
					ITEM.price = dat.price or 4000
					ITEM.exRender = dat.exRender or false
					ITEM.iconCam = self.modelCam[v.WorldModel:lower()]
					ITEM.class = class
					ITEM.holsterDrawInfo = dat.holster
					ITEM.isTFA = true
					ITEM.model = v.WorldModel
					if (dat.holster) then
						ITEM.holsterDrawInfo.model = v.WorldModel
					end

					local slot = self.slotCategory[v.Slot]
					ITEM.width = dat.width or 1
					ITEM.height = dat.height or 1
					ITEM.weaponCategory = slot or "primary"

					function ITEM:onGetDropModel()
						if (dat.width >= 3 and dat.height >= 2) then
							return "models/props_junk/cardboard_box003a.mdl"
						end

						return "models/props_junk/cardboard_box004a.mdl"
					end

					function ITEM:drawEntity(entity)
						local name = self.uniqueID
						local exIcon = ikon:getIcon(name)
						local type
						if (self.width >= 3 and self.height >= 2) then
							type = 0
						else
							type = 1
						end

						if (exIcon) then  
							if (!entity.initText and !entity.customText) then
								entity.initText = true

								itemRTTextrue.loadItemTex(entity, self, exIcon, type)
							end

							if (entity.customText) then
								render.MaterialOverrideByIndex(0, entity.customText)
							end

							entity:DrawModel()
							
							render.MaterialOverrideByIndex(1)
						else
							ikon:renderIcon(
								self.uniqueID,
								self.width,
								self.height,
								self.model,
								self.iconCam
							)
						end
					end

					function ITEM:paintOver(item, w, h)
						local x, y = w - 14, h - 14

						if (item:getData("equip")) then
							surface.SetDrawColor(110, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)

							x = x - 8*1.6
						end

						if (table.Count(item:getData("atmod", {})) > 0) then
							surface.SetDrawColor(255, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)
						end
					end

					function ITEM:getDesc()
						if (!self.entity or !IsValid(self.entity)) then
							local text = L("gunInfoDesc", L(v.Primary.Ammo)) .. "\n"

							text = text .. L("gunInfoStat", v.Damage, L(self.weaponCategory), v.Primary.ClipSize) .. "\n"

							local attText = ""
							local mods = self:getData("atmod", {})
							for _, att1 in pairs(mods) do
								attText = attText .. "\n<color=39, 174, 96>" .. L(att1[1] or "ERROR") .. "</color>"
							end

							text = text .. L("gunInfoAttachments", attText)

							return text
						else
							local text = L("gunInfoDesc", L(v.Primary.Ammo))
							return text
						end
					end
					
					-- TODO: Remove THOTS
					-- jesus fuck this is one messy shit
					-- On player eqipped the item, Gives a weapon to player and load the ammo data from the item.
					ITEM.functions.Equip = {
						name = "Equip",
						tip = "equipTip",
						icon = "icon16/tick.png",
						onRun = function(item)
							local client = item.player
							local items = client:getChar():getInv():getItems()

							client.carryWeapons = client.carryWeapons or {}

							for k, v in pairs(items) do
								if (v.id != item.id) then
									local itemTable = nut.item.instances[v.id]
									
									if (!itemTable) then
										client:notifyLocalized("tellAdmin", "wid!xt")

										return false
									else
										if (itemTable.isWeapon and client.carryWeapons[item.weaponCategory] and itemTable:getData("equip")) then
											client:notifyLocalized("weaponSlotFilled")

											return false
										end
									end
								end
							end
							
							if (client:HasWeapon(item.class)) then
								client:StripWeapon(item.class)
							end

							local weapon = client:Give(item.class)

							if (IsValid(weapon)) then
								-- to prevent weird shits.
								TFA_ATTACHMENT_QUEUE[weapon:EntIndex()] = item:getData("atmod")
								timer.Simple(0, function()
									if (IsValid(client) and IsValid(weapon)) then
										client:SelectWeapon(weapon:GetClass())
									end
								end)
								
								client.carryWeapons[item.weaponCategory] = weapon
								client:EmitSound("items/ammo_pickup.wav", 80)

								-- Remove default given ammo.
								if (client:GetAmmoCount(weapon:GetPrimaryAmmoType()) == weapon:Clip1() and item:getData("ammo", 0) == 0) then
									client:RemoveAmmo(weapon:Clip1(), weapon:GetPrimaryAmmoType())
								end
								item:setData("equip", true)

								weapon:SetClip1(item:getData("ammo", 0))
							else
								print(Format("[Nutscript] Weapon %s does not exist!", item.class))
							end

							return false
						end,
						onCanRun = function(item)
							return (!IsValid(item.entity) and item:getData("equip") != true)
						end
					}

					ITEM.functions.zDetach = {
					name = "Detach",
					tip = "useTip",
					icon = "icon16/wrench.png",
					isMulti = true,
					multiOptions = function(item, client)
						local targets = {}

						for k, v in pairs(item:getData("atmod", {})) do
							table.insert(targets, {
								name = L(v[1] or "ERROR"),
								data = k,
							})
						end

						return targets
					end,
					onCanRun = function(item)
						if (table.Count(item:getData("atmod", {})) <= 0) then
							return false
						end
						
						return (!IsValid(item.entity))
					end,
					onRun = function(item, data)
								local client = item.player
								if (data) then
									local char = client:getChar()

									if (char) then
										local inv = char:getInv()

										if (inv) then
											local mods = item:getData("atmod", {})
											local attData = mods[data]

											if (attData) then
												local add = inv:add(attData[1])

												if (add) then
													local wepon = client:GetActiveWeapon()
													if (IsValid(wepon) and wepon:GetClass() == item.class) then
														hook.Run("OnPlayerAttachment", item, wepon, attData[2], attData[3], false)	
													else
														hook.Run("OnPlayerAttachment", item, nil, attData[2], attData[3], false)	
													end

													mods[data] = nil

													if (table.Count(mods) == 0) then
														item:setData("atmod", nil)
													else
														item:setData("atmod", mods)
													end

													-- Yeah let them know you did something with your dildo
													client:EmitSound("cw/holster4.wav")
												else
													client:notifyLocalized("noSpace")
												end
											else
												client:notifyLocalized("notAttachment")
											end
										end
									end
								else
									client:notifyLocalized("detTarget")
								end

								return false
							end,
					}
				end

				HOLSTER_DRAWINFO[ITEM.class] = ITEM.holsterDrawInfo

				-- Register Language name for the gun.
				if (CLIENT) then
					if (nut.lang.stored["english"] and nut.lang.stored["korean"]) then
						ITEM.name = v.PrintName 

						nut.lang.stored["english"][class] = v.PrintName 
						nut.lang.stored["korean"][class] = v.PrintName 
					end
				end
			end
		end
	end

	-- Reconfigure Customizable Weaponry in here	
	do	
		do
			--[[
			CustomizableWeaponry.callbacks:addNew("finishReload", "nutExperience", function(weapon)
				if (CLIENT) then return end

				local owner = weapon:GetOwner()

				if (IsValid(owner) and owner:IsPlayer()) then
					local char = owner:getChar()

					if (char) then
						if (char:getAttrib("gunskill", 0) < 5) then
							char:updateAttrib("gunskill", 0.003)
						end
					end
				end
			end)

			CustomizableWeaponry.callbacks:addNew("deployWeapon", "uploadAttachments", function(weapon)
				if (CLIENT) then return end

				timer.Simple(.1, function()
					if (IsValid(weapon)) then
						if (weapon.recalculateStats) then
							weapon:recalculateStats()
							
							netstream.Start(weapon:GetOwner(), "nutUpdateWeapon", weapon)
						end
					end
				end)

				local class = weapon:GetClass():lower()
				local client = weapon:GetOwner()

				if (!client) then return end
				if (weapon.attLoaded) then return end

				local char = client:getChar()

				if (char) then
					local inv = char:getInv()
					local attList = {}

					for k, v in pairs(inv:getItems()) do
						if (v.isWeapon and v.class == class) then
							local attachments = v:getData("atmod")

							if (attachments) then
								for k, v in pairs(attachments) do
									table.insert(attList, v[2])
								end
							end

							break
						end
					end

					timer.Simple(0.2, function()
						if (IsValid(weapon) and weapon:GetClass() == class and weapon.attachSpecificAttachment) then
							for _, b in ipairs(attList) do
								weapon:attachSpecificAttachment(b)
							end
						end
					end)

					weapon.attLoaded = true
				end
			end)
			]]
		end
	end
end

if (SERVER) then
	function PLUGIN:TFA_FinalInitAttachments(weapon)
		timer.Simple(.05, function()
			if (IsValid(weapon)) then
				local attachments = TFA_ATTACHMENT_QUEUE[weapon:EntIndex()]
				
				if (attachments) then
					for slot, attData in pairs(attachments) do
						print(attData[2], attData[3])
						weapon:SetTFAAttachment(attData[2], attData[3], true, true)
					end

					TFA_ATTACHMENT_QUEUE[weapon:EntIndex()] = nil
				end
			end
        end)
	end
	
    function PLUGIN:OnPlayerAttachment(itemObject, weaponEntity, attachmentCategory, attachmentIndex, isAttach)
		if (IsValid(weaponEntity)) then
			if (isAttach) then
				weaponEntity:SetTFAAttachment(attachmentCategory, attachmentIndex, true, true)
			else
				weaponEntity:SetTFAAttachment(attachmentCategory, 0, true, true)
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