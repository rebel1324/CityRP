PLUGIN.name = "Macro Weapon Register"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gun Jesus have arrived."

nut.util.include("sh_configs.lua")
nut.util.include("sh_languages.lua")

if (true) then
	return false
end

if (!CustomizableWeaponry) then

function PLUGIN:InitializedPlugins()
	table.Merge(nut.lang.stored["korean"], self.koreanTranslation)
	table.Merge(nut.lang.stored["english"], self.englishTranslation)

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
				return L("ammoDesc", self:getQuantity(), L(self.ammo))
			end
		end
	end
end
	
return end
--[[
	MODIFICATION TUTORIAL
		- sh_config
		 This file contains ammo structure.
		- sh_languages
		 This file contains language sets for the weapons.
		- cl_cw3d2d
		 This file contains modification for CW 2.0 HUDs
		- sh_attachments
		 This file contains information and of attachment items.
--]]

nut.util.include("cl_cw3d2d.lua")
nut.util.include("sh_attachments.lua")

CW_GENERATE_ITEM = true 

function PLUGIN:InitializedPlugins()
	table.Merge(nut.lang.stored["korean"], self.koreanTranslation)
	table.Merge(nut.lang.stored["english"], self.englishTranslation)

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
		-- they were ass.
		local assWeapons = {
			["cw_ber_cz75"] = "muzzleflash_6",
			["cw_ber_deagletoast"] = "muzzleflash_6",
			["cw_ber_fnp45"] = "muzzleflash_6",
			["cw_ber_m9"] = "muzzleflash_6",
			["cw_ber_p220"] = "muzzleflash_6",
			["cw_ber_model620"] = "muzzleflash_6",
			["cw_ber_usp"] = "muzzleflash_6",
		}

		for k, v in ipairs(weapons.GetList()) do
			local class = v.ClassName

			if (weapons.IsBasedOn(v.ClassName, "cw_base")) then
				-- Configure Weapon's Variables
				v.CanRicochet = false
				v.isGoodWeapon = true
				v.canPenetrate = function() return false end
				v.canRicochet = function() return false end
				--v.MuzzleEffect = "muzzleflash_ak74" -- lol jk
				v.Primary.DefaultClip = 0

				if (self.changeAmmo[v.Primary.Ammo]) then
					v.Primary.Ammo = self.changeAmmo[v.Primary.Ammo]
				end

				v.VelocitySensitivity = 2

				if (v.MaxSpreadInc) then
					if (!v.neat_MaxSpreadInc) then
						v.neat_MaxSpreadInc = v.MaxSpreadInc
					end
					v.MaxSpreadInc = ((v.neat_MaxSpreadInc or v.MaxSpreadInc) or 0.1) * 3 
				end
				
				if (v.SpreadPerShot) then
					if (!v.neat_SpreadPerShot) then
						v.neat_SpreadPerShot  = v.SpreadPerShot or 0.1
					end

					v.SpreadPerShot = (v.neat_SpreadPerShot or v.SpreadPerShot) * 10

					if (v.FireDelay) then
						v.SpreadCooldown = (v.FireDelay or 0)*0.3
					end
					v.AddSpreadSpeed = v.SpreadPerShot*5
				end

				if (!v.oldcrosshairVisible) then
					v.oldcrosshairVisible = v.crosshairVisible
				end

				function v:crosshairVisible()
					-- not visible if we're aiming
					if self.dt.State == CW_AIMING and self.FadeCrosshairOnAim then
						return false
					end
					
					-- or are in an inactive state (action in progress/running)
					if self.InactiveWeaponStates[self.dt.State] then
						return false
					end

					-- or have safety turned on
					if self.dt.Safe then
						return false
					end
					
					-- or are in a vehicle
					if self.Owner:InVehicle() then
						return false 
					end
					
					-- or are near a wall
					if self.NearWall then
						return false
					end
					
					-- or are reloading the weapon
					if (self.IsReloading or self.IsFiddlingWithSuppressor) and self.Cycle <= 0.9 then
						return false
					end
					
					-- or are reloading the M203
					if self.reloadingM203 then
						return false
					end

					local owner = self:GetOwner()
					if (IsValid(owner) and owner:IsPlayer() and !owner:isWepRaised()) then
						return false
					end

					return true
				end

				-- lol fuck you 
				function v:detachSpecificAttachment(attachmentName)
					-- since we don't know the category, we'll just have to iterate over all attachments, find the one we want, and attach it there
					for category, data in pairs(self.Attachments) do
						for key, attachment in ipairs(data.atts) do
							if attachment == attachmentName then
								self:detach(category, key - 1, false)
							end
						end
					end
				end

				-- A code to get rid of fucking movement/sway disability.
				function v:getFinalSpread(vel, maxMultiplier)
					maxMultiplier = maxMultiplier or 1
					
					local final = self.BaseCone
					local aiming = self.dt.State == CW_AIMING
					-- take the continuous fire spread into account
					final = final + self.AddSpread
					
					-- and the player's velocity * mobility factor
					
					if aiming then
						-- irl the accuracy of your weapon goes to shit when you start moving even if you aim down the sights, so when aiming, player movement will impact the spread even more than it does during hip fire
						-- but we're gonna clamp it to a maximum of the weapon's hip fire spread, so that even if you aim down the sights and move, your accuracy won't be worse than your hip fire spread
						final = math.min(final + (vel / 10000 * self.VelocitySensitivity) * self.AimMobilitySpreadMod, self.HipSpread)
					else
						final = final + (vel / 10000 * self.VelocitySensitivity)
					end
					
					if self.ShootWhileProne and self:isPlayerProne() then
						final = final + vel / 1000
					end
					
					-- lastly, return the final clamped value
					return math.Clamp(final, 0, 0.09 + self:getMaxSpreadIncrease(maxMultiplier))
				end

				function v:recalculateDamage()
					local mult = hook.Run("GetSchemaCWDamage", self, self.Owner) or 1

					self.Damage = self.Damage_Orig * self.DamageMult * mult
				end

				function v:recalculateRecoil()
					local mult = hook.Run("GetSchemaCWRecoil", self, self.Owner) or 1

					self.Recoil = self.Recoil_Orig * self.RecoilMult * mult
				end

				function v:recalculateFirerate()
					local mult = hook.Run("GetSchemaCWFirerate", self, self.Owner) or 1

					self.FireDelay = self.FireDelay_Orig * self.FireDelayMult * mult
				end

				function v:recalculateVelocitySensitivity()
					local mult = hook.Run("GetSchemaCWVel", self, self.Owner) or 1

					self.VelocitySensitivity = self.VelocitySensitivity_Orig * self.VelocitySensitivityMult * mult
				end

				function v:recalculateAimSpread()
					local mult = hook.Run("GetSchemaCWAimSpread", self, self.Owner) or 1

					self.AimSpread = self.AimSpread_Orig * self.AimSpreadMult * mult
				end

				function v:recalculateHipSpread()
					local mult = hook.Run("GetSchemaCWHipSpread", self, self.Owner) or 1

					self.HipSpread = self.HipSpread_Orig * self.HipSpreadMult * mult
				end

				function v:recalculateDeployTime()
					local mult = hook.Run("GetSchemaCWDeployTime", self, self.Owner) or 1

					self.DrawSpeed = self.DrawSpeed_Orig * self.DrawSpeedMult * mult
				end

				function v:recalculateReloadSpeed()
					local mult = hook.Run("GetSchemaCWReloadSpeed", self, self.Owner) or 1

					self.ReloadSpeed = self.ReloadSpeed_Orig * self.ReloadSpeedMult * mult
				end

				function v:recalculateMaxSpreadInc()
					local mult = hook.Run("GetSchemaCWMaxSpread", self, self.Owner) or 1

					self.MaxSpreadInc = self.MaxSpreadInc_Orig * self.MaxSpreadIncMult * mult
				end

				-- Generate Items
				local dat = self.gunData[class] or {}
				v.Slot = dat.slot or 2

				if (CW_GENERATE_ITEM) then
					local ITEM = nut.item.register(class:lower(), "base_weapons", nil, nil, true)
					ITEM.name = class
					ITEM.price = dat.price or 4000
					ITEM.exRender = dat.exRender or false
					ITEM.iconCam = self.modelCam[v.WorldModel:lower()]
					ITEM.class = class
					ITEM.holsterDrawInfo = dat.holster
					ITEM.isCW = true

					if (dat.holster) then
						ITEM.holsterDrawInfo.model = v.WorldModel
					end

					ITEM.model = v.WorldModel

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

					function ITEM:onEquipWeapon(client, weapon)
					end

					function ITEM:paintOver(item, w, h)
						local x, y = w - 14, h - 14

						if (item:getData("equip")) then
							surface.SetDrawColor(110, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)

							x = x - 8*1.6
						end

						if (table.Count(item:getData("mod", {})) > 0) then
							surface.SetDrawColor(255, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)
						end
					end

					function ITEM:getDesc()
						if (!self.entity or !IsValid(self.entity)) then
							local text = L("gunInfoDesc", L(v.Primary.Ammo)) .. "\n"

							text = text .. L("gunInfoStat", v.Damage, L(self.weaponCategory), v.Primary.ClipSize) .. "\n"

							local attText = ""
							local mods = self:getData("mod", {})
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
								timer.Simple(0, function()
									if (isvector(client) and IsValid(weapon)) then
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

								if (item.onEquipWeapon) then
									item:onEquipWeapon(client, weapon)
								end
							else
								print(Format("[Nutscript] Weapon %s does not exist!", item.class))
							end

							return false
						end,
						onCanRun = function(item)
							return (!IsValid(item.entity) and item:getData("equip") != true)
						end
					}
















					ITEM.functions.use = {
					name = "Detach",
					tip = "useTip",
					icon = "icon16/wrench.png",
					isMulti = true,
					multiOptions = function(item, client)
						local targets = {}

						for k, v in pairs(item:getData("mod", {})) do
							table.insert(targets, {
								name = L(v[1] or "ERROR"),
								data = k,
							})
						end

						return targets
					end,
					onCanRun = function(item)
						if (table.Count(item:getData("mod", {})) <= 0) then
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
											local mods = item:getData("mod", {})
											local attData = mods[data]

											if (attData) then
												inv:add(attData[1])

												
												local wepon = client:GetActiveWeapon()
												if (IsValid(wepon) and wepon:GetClass() == item.class) then
													wepon:detachSpecificAttachment(attData[2])
												end

												mods[data] = nil

												if (table.Count(mods) == 0) then
													item:setData("mod", nil)
												else
													item:setData("mod", mods)
												end
												
												-- Yeah let them know you did something with your dildo
												client:EmitSound("cw/holster4.wav")
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
		-- There is no Customization Keys.
		CustomizableWeaponry.customizationMenuKey = "" -- the key we need to press to toggle the customization menu
		CustomizableWeaponry.canDropWeapon = false
		CustomizableWeaponry.enableWeaponDrops = false
		CustomizableWeaponry.quickGrenade.enabled = false
		CustomizableWeaponry.quickGrenade.canDropLiveGrenadeIfKilled = false
		CustomizableWeaponry.quickGrenade.unthrownGrenadesGiveWeapon = false
		CustomizableWeaponry.physicalBulletsEnabled = false
		CustomizableWeaponry.customizationEnabled = false

		hook.Remove("PlayerInitialSpawn", "CustomizableWeaponry.PlayerInitialSpawn")
		hook.Remove("PlayerSpawn", "CustomizableWeaponry.PlayerSpawn")
		hook.Remove("AllowPlayerPickup", "CustomizableWeaponry.AllowPlayerPickup")

		if (CLIENT) then
			local up = Vector(0, 0, -100)
			local shellMins, shellMaxs = Vector(-0.5, -0.15, -0.5), Vector(0.5, 0.15, 0.5)
			local angleVel = Vector(0, 0, 0)

			function CustomizableWeaponry.shells:finishMaking(pos, ang, velocity, soundTime, removeTime)
				velocity = velocity or up
				velocity.x = velocity.x + math.Rand(-5, 5)
				velocity.y = velocity.y + math.Rand(-5, 5)
				velocity.z = velocity.z + math.Rand(-5, 5)
				
				time = time or 0.5
				removetime = 2
				
				local t = self._shellTable or CustomizableWeaponry.shells:getShell("mainshell") -- default to the 'mainshell' shell type if there is none defined

				local ent = ClientsideModel(t.m, RENDERGROUP_BOTH) 
				ent:SetPos(pos)
				ent:PhysicsInitBox(shellMins, shellMaxs)
				ent:SetAngles(AngleRand())
				ent:SetModelScale((self.ShellScale*.9 or .7), 0)
				ent:SetMoveType(MOVETYPE_VPHYSICS) 
				ent:SetSolid(SOLID_VPHYSICS) 
                ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				
				local phys = ent:GetPhysicsObject()
				phys:SetMaterial("gmod_silent")
				phys:SetMass(100)
				phys:SetVelocity(velocity*.75)
                
                phys:AddAngleVelocity(VectorRand()*5000)

				timer.Simple(time, function()
					if t.s and IsValid(ent) then
						sound.Play(t.s, ent:GetPos())
					end
				end)
				
				SafeRemoveEntityDelayed(ent, removetime)
			end

			CustomizableWeaponry.callbacks:addNew("adjustViewmodelPosition", "nutHolster", function(weapon, pos, ang)
				local owner = weapon:GetOwner()

				if (IsValid(owner) and owner:IsPlayer() and !owner:isWepRaised()) then
					if (weapon.dt.State == CW_IDLE) then
						if (weapon.ViewModelFlip) then
							return pos, (ang + Vector(-12, -20, 20))
						else
							return pos, (ang + Vector(-12, 20, -20))
						end
					end
				end
			end)
		end

		do
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

			if (CLIENT) then
				netstream.Hook("nutUpdateWeapon", function(weapon) if (weapon and weapon:IsValid() and weapon.recalculateStats) then weapon:recalculateStats() end end)
			end

			function CustomizableWeaponry:hasAttachment(ply, att, lookIn)		
				return true
			end

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
							local attachments = v:getData("mod")

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
		end
	end
end

function PLUGIN:GetSchemaCWVel(weapon, client)
	return 10
end

if (SERVER) then
	function PLUGIN:OnCharAttribUpdated(client, character, key, value)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			if (value == "gunskill") then
				if (weapon and weapon:IsValid() and weapon.recalculateStats) then
					weapon:recalculateStats()
					
					netstream.Start(client, "nutUpdateWeapon", weapon)
				end
			end
		end
	end

	function PLUGIN:OnCharAttribBoosted(client, character, attribID, boostID, boostAmount)
		if (!client) then
			client = (character and character:getPlayer())
		end

		if (client and client:IsValid()) then
			local weapon = client:GetActiveWeapon()

			if (value == "gunskill") then
				if (weapon and weapon:IsValid() and weapon.recalculateStats) then
					weapon:recalculateStats()
					
					netstream.Start(client, "nutUpdateWeapon", weapon)
				end
			end
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