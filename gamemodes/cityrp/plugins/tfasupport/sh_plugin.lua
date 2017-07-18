PLUGIN.name = "Macro Weapon Register - TFA"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Gun Jesus have arrived."

nut.util.include("sh_configs.lua")
nut.util.include("cl_effects.lua")

if (true) then return end -- NO TFA

function PLUGIN:InitializedPlugins()
	-- Create Items with Lua
	do
	
		-- WEAPON REGISTERATION
		for k, v in ipairs(weapons.GetList()) do
			local class = v.ClassName
			local prefix

			if (class:find("tfa_")) then
				prefix = "tfa_"
			end
			
			if (prefix and !class:find("base")) then
				local infoDat = self.TFAInfo[class]

				v.Primary.DefaultClip = 0

				if (self.changeAmmo[v.Primary.Ammo]) then
					v.Primary.Ammo = self.changeAmmo[v.Primary.Ammo]
				end


				v.RenderGroup = RENDERGROUP_BOTH
				function v:PostDrawViewModel()
					local weapon = LocalPlayer():GetViewModel()

					local at
					if (self.Akimbo) then
						at = weapon:GetAttachment(2 - (game.SinglePlayer() and self:GetNW2Int("AnimCycle", 1) or self.AnimCycle))
					else
						at = weapon:GetAttachment(1)
					end
					
					if (!at) then return end

					weapon.emitter = weapon.emitter or ParticleEmitter(Vector())
					weapon.emitter:SetNoDraw(true)
					weapon.emitter:DrawAt(at.Pos, EyeAngles())
				end
				function v:DrawWorldModelTranslucent()
					local weapon = self
				
					local at
					if (weapon.Akimbo) then
						at = weapon:GetAttachment(2 - (game.SinglePlayer() and self:GetNW2Int("AnimCycle", 1) or self.AnimCycle))
					else
						at = weapon:GetAttachment(1)
					end

					if (!at) then return end

					weapon.emitter = weapon.emitter or ParticleEmitter(Vector())
					weapon.emitter:SetNoDraw(true)
					
					if (infoDat) then
						local bork = infoDat.muzDir

						if (bork) then
							weapon.emitter:DrawAt(at.Pos, self.muzDir[bork](at.Ang))
						else
							weapon.emitter:DrawAt(at.Pos, at.Ang:Up():Angle())
						end
					else
						weapon.emitter:DrawAt(at.Pos, at.Ang:Forward():Angle())
					end
				end

				if (infoDat) then
					v.Slot = infoDat.slot
					v.shell = infoDat.shell
					v.viewScale = infoDat.viewMuzzle
					v.worldScale = infoDat.worldMuzzle

					local ITEM = nut.item.register(class, "base_weapons", nil, nil, true)
					ITEM.name = class
					ITEM.desc = v.Primary.Ammo .. "를 사용하는 총기"
					ITEM.price = infoDat.price or 4000
					ITEM.iconCam = self.modelCam[v.WorldModel:lower()]
					ITEM.class = prefix .. uniqueID
					ITEM.holsterDrawInfo = infoDat.holster

					if (infoDat.holster) then
						ITEM.holsterDrawInfo.model = v.WorldModel
					end

					ITEM.model = v.WorldModel

					local slot = self.slotCategory[v.Slot]
					ITEM.width = 1
					ITEM.height = 1
					ITEM.weaponCategory = slot or "primary"

					function ITEM:onEquipWeapon(client, weapon)
					end

					function ITEM:paintOver(item, w, h)
						local x, y = w - 14, h - 14

						if (item:getData("equip")) then
							surface.SetDrawColor(110, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)

							x = x - 8*1.6
						end

						if (item:getData("mod")) then
							surface.SetDrawColor(255, 255, 110, 100)
							surface.DrawRect(x, y, 8, 8)
						end
					end

					HOLSTER_DRAWINFO[ITEM.class] = ITEM.holsterDrawInfo

					if (CLIENT) then
						if (nut.lang.stored["english"] and nut.lang.stored["korean"]) then
							ITEM.name = v.PrintName 

							nut.lang.stored["english"][prefix .. uniqueID] = v.PrintName 
							nut.lang.stored["korean"][prefix .. uniqueID] = v.PrintName 
						end
					end
				end
			end
		end
	end
end