
hook.Add("OnGenerateTFAItems", "TFA_GenerateWeapons", function(self)
    local result = 0

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
                if (!ITEM) then
                    print(ITEM)
                    continue
                end

                result = result + 1

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
                
                -- TODO: Make it better
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
                                    local itemUniqueID, attachTarget, isShit = attData[1], attData[2], attData[3]

                                    -- making it sure mate.
                                    if (attData or hook.Run("ShouldCreateAttachmentItem", item, itemUniqueID) == false) then
                                        if (isShit) then
                                            local wepon = client:GetActiveWeapon()

                                            if not (IsValid(wepon) and wepon:GetClass() == item.class) then
                                                for k, v in pairs(client:GetWeapons()) do
                                                    local wepClass = v:GetClass()
                                                    
                                                    if (wepClass == class) then
                                                        wepon = v
                                                    end
                                                end
                                            end

                                            mods[data] = nil
                                            if (table.Count(mods) == 0) then
                                                item:setData("atmod", nil)
                                            else
                                                item:setData("atmod", mods)
                                            end

                                            if (IsValid(wepon)) then
                                                hook.Run("OnPlayerAttachment", item, wepon, attachTarget, false)	
                                            else
                                                hook.Run("OnPlayerAttachment", item, nil, attachTarget, false)	
                                            end

                                            client:EmitSound("cw/holster4.wav")
                                            return false
                                        else
                                            inv:add(itemUniqueID):next(function(newItem)
                                                local wepon = client:GetActiveWeapon()

                                                if not (IsValid(wepon) and wepon:GetClass() == item.class) then
                                                    for k, v in pairs(client:GetWeapons()) do
                                                        local wepClass = v:GetClass()
                                                        
                                                        if (wepClass == class) then
                                                            wepon = v
                                                        end
                                                    end
                                                end

                                                mods[data] = nil
                                                if (table.Count(mods) == 0) then
                                                    item:setData("atmod", nil)
                                                else
                                                    item:setData("atmod", mods)
                                                end

                                                if (IsValid(wepon)) then
                                                    hook.Run("OnPlayerAttachment", item, wepon, attachTarget, false)	
                                                else
                                                    hook.Run("OnPlayerAttachment", item, nil, attachTarget, false)	
                                                end

                                                client:EmitSound("cw/holster4.wav")
                                            end, function(err)
                                                client:notifyLocalized("noSpace")
                                            end)
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
    
    print("[+] TFA Integration: Generated " .. result .. " Weapons")
end)