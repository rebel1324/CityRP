ATTACHMENT_SIGHT = 1
ATTACHMENT_BARREL = 2
ATTACHMENT_LASER = 3
ATTACHMENT_MAGAZINE = 4
ATTACHMENT_GRIP = 5

local attItems = {}
attItems.att_rdot = {
    name = "Red Dot Sight",
    desc = "attRDotDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_aimpoint",
        "md_microt1",
        "md_rmr",
    }
}
attItems.att_holo = {
    name = "Holographic Sight",
    desc = "attHoloDesc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_kobra",
        "md_cobram2",
        "md_eotech",
    }
}
attItems.att_scope4 = {
    name = "4x Scope",
    desc = "attScope4Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_schmidt_shortdot",
        "md_acog",
    }
}
attItems.att_scope8 = {
    name = "8x Scope",
    desc = "attScope8Desc",
    slot = ATTACHMENT_SIGHT,
    attSearch = {
        "md_pso1",
        "bg_sg1scope",
        "md_nightforce_nxs",
    }
}
attItems.att_muzsup = {
    name = "Suppressor",
    desc = "attSupDesc",
    slot = ATTACHMENT_BARREL,
    attSearch = {
        "md_saker",
        "md_tundra9mm",
        "md_pbs1",
    },
}
attItems.att_exmag = {
    name = "Extended Mag",
    desc = "attEMagDesc",
    slot = ATTACHMENT_MAGAZINE,
    attSearch = {
    }
}
attItems.att_foregrip = {
    name = "Foregrip",
    desc = "attForeDesc",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "md_foregrip",
    }
}
attItems.att_laser = {
    name = "Laser Sight",
    desc = "attLaserDesc",
    slot = ATTACHMENT_LASER,
    attSearch = {
        "md_anpeq15",
        "md_insight_x2",
    }
}
attItems.att_bipod = {
    name = "Bipod",
    desc = "attBipodDesc",
    slot = ATTACHMENT_GRIP,
    attSearch = {
        "bg_bipod",
        "md_bipod",
    }
}
        for className, v in pairs(attItems) do
			local ITEM = nut.item.register(className, nil, nil, nil, true)
			ITEM.name = className
			ITEM.desc = v.desc
			ITEM.price = 300
			ITEM.model = "models/Items/BoxSRounds.mdl"
			ITEM.width = 1
			ITEM.height = 1
			ITEM.isAttachment = true
			ITEM.category = "Attachments"
            ITEM.attSearch = v.attSearch

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
                            if (v.isWeapon and v.isCW) then
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
						local client = item.player
						local char = client:getChar()
						local inv = char:getInv()
						local items = inv:getItems()
                        
                        local target = data
                        
                        -- This is the only way, ffagot
						for k, v in pairs(items) do
                            if (data) then
                                if (v:getID() == data) then
                                    target = v
                                    break
                                end
                            else
                                if (v.isWeapon and v.isCW) then
                                    target = v
                                    break
                                end
                            end
						end

                        if (!target) then
                            client:notifyLocalized("noWeapon")
                            return false
                        else
							local class = target.class
							local SWEP = weapons.Get(class)

							if (target.isCW) then
                                -- Insert Weapon Filter here if you just want to create weapon specific shit. 

								local atts = SWEP.Attachments
								local mods = target:getData("mod", {})
								
								if (atts) then		                                
                                    -- Is the Weapon Slot Filled?
                                    if (mods[v.slot]) then
										client:notifyLocalized("alreadyAttached")

										return false
                                    end

									local pokemon
									for atcat, data in pairs(atts) do
                                        if (pokemon) then
                                            break
                                        end

										for k, name in pairs(data.atts) do
                                            if (pokemon) then
                                                break
                                            end

                                            for _, doAtt in pairs(v.attSearch) do
                                                if (name == doAtt) then
                                                    pokemon = doAtt

                                                    break
                                                end
                                            end
										end
									end

									if (!pokemon) then
										client:notifyLocalized("cantAttached")

										return false
									end

                                    mods[v.slot] = {className, pokemon}
									target:setData("mod", mods)

									local wepon = client:GetActiveWeapon()
									if (IsValid(wepon) and wepon:GetClass() == target.class) then
										wepon:attachSpecificAttachment(pokemon)
									end

									return true
								else
									client:notifyLocalized("notCW")
								end
							end
                        end

						client:notifyLocalized("noWeapon")
						return false
					end,
			}
end

local conversionKits = {}
