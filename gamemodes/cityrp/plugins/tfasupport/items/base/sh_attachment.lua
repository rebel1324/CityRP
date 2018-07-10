ITEM.name = "Attachment Object"             -- name of the attachment.
ITEM.model = "models/Items/grenadeAmmo.mdl" -- model of the attachment
ITEM.width = 1 -- width of the attachment
ITEM.height = 1 -- height of the attachment
ITEM.isAttachment = true -- bool to distinguish if the item is attachment or not
ITEM.category = "Attachments" -- Category
ITEM.reusable = false -- is attachment reusable?
ITEM.useQuantity = false -- is attachment use quantity?
ITEM.canRefill = false -- is attachment can be refilled?
ITEM.maxQuantity = 1 -- maximum use of attachment

--[[
    -- REQUIRED DATA
    ITEM.attSearch = v.attSearch -- 
    ITEM.slot = v.slot
    ITEM.icon = v.icon
]]

local function attachment(item, data, combine)
    local client = item.player
    local char = client:getChar()
    local inv = char:getInv()
    local items = inv:getItems()

    local target = data

    -- This is the only way, ffagot
    for k, invItem in pairs(items) do
        if (data) then
            if (invItem:getID() == data) then
                target = invItem

                break
            end
        else
            if (invItem.isWeapon and invItem.isTFA) then
                target = invItem

                break
            end
        end
    end

    if (not target) then
        client:notifyLocalized("noWeapon")

        return false
    else
        local class = target.class
        local SWEP = weapons.Get(class)
        if (target.isTFA) then
            -- Insert Weapon Filter here if you just want to create weapon specific shit. 
            local weaponAttachments = SWEP.Attachments
            local mods = target:getData("atmod", {})
            
            if (weaponAttachments) then		                                
                -- Is the Weapon Slot Filled?
                if (mods[item.slot]) then
                    client:notifyLocalized("alreadyAttached")

                    return false
                end

                local targetAttachment

                for cat, info in pairs(weaponAttachments) do
                    if (targetAttachment) then break end
                    
                    if (info.atts) then
                        for index, att in pairs(info.atts) do
                            if (table.HasValue(item.attSearch, att)) then
                                targetAttachment = att

                                break
                            end
                        end
                    end
                end

                if (not targetAttachment) then
                    client:notifyLocalized("cantAttached")

                    return false
                end

                mods[item.slot] = {item.uniqueID, targetAttachment, item.reusable}
                target:setData("atmod", mods)

                local wepon = client:GetActiveWeapon()
                if not (IsValid(wepon) and wepon:GetClass() == target.class) then
                    for k, v in pairs(client:GetWeapons()) do
                        local wepClass = v:GetClass()
                        
                        if (wepClass == class) then
                            wepon = v
                        end
                    end
                end

                if (IsValid(wepon)) then
                    hook.Run("OnPlayerAttachment", item, wepon, targetAttachment, true)	
                else
                    hook.Run("OnPlayerAttachment", item, nil, targetAttachment, true)	
                end

                client:EmitSound("cw/holster4.wav")
                return true
            else
                client:notifyLocalized("notCW")

                return false
            end
        end
    end

    client:notifyLocalized("noWeapon")
    return false
end

ITEM.functions.use = {
     name = "Attach",
     tip = "useTip",
     icon = "icon16/wrench.png",
     isMulti = true,
     multiOptions = function(item, client)
         local targets = {}
         local char = client:getChar()
         
         if (char) then
             local inv = char:getInv()

             if (inv) then
                 local items = inv:getItems()

                 for k, v in pairs(items) do
                    if (v.isWeapon and v.isTFA) then
                        table.insert(targets, {
                            name = L(v.name),
                            data = v:getID(),
                        })
                    else
                        continue
                    end
                 end
             end
         end
         return targets
    end,
    onCanRun = function(item)				
        return (!IsValid(item.entity))
    end,
    onRun = function(item, data)
         return attachment(item, data, false)
	end,
}

ITEM.functions.combine = {
    onCanRun = function(item, data)
        local targetItem = nut.item.instances[data]
        
        if (data and targetItem) then
            if (!IsValid(item.entity) and targetItem.isWeapon and targetItem.isTFA) then
                return true
            else
                return false
            end
        end
    end,
    onRun = function(item, data)
        return attachment(item, data, true)
    end,
}