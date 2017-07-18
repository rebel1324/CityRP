ITEM.name = "Police Ballistic Vest"
ITEM.desc = "poliVestDesc"
ITEM.model = "models/rebel1324/b_balivest.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.outfitCategory = "vest"
ITEM.price = 750
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(734.41784667969, 618.29461669922, 484.25646972656),
	ang = Angle(24.324199676514, 220, 0),
	fov = 1.4901393229734,
}
ITEM.team = {1}

function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end
ITEM.pacData = {
    [1] = {
        ["children"] = {
            [1] = {
                ["children"] = {
                },
                ["self"] = {
                    ["BoneMerge"] = true,
                    ["Material"] = "sal/acc/armor01_2",
                    ["UniqueID"] = "3416688674",
                    ["Model"] = "models/rebel1324/b_balivest.mdl",
                    ["ClassName"] = "model",
                },
            },
        },
        ["self"] = {
            ["EditorExpand"] = true,
            ["UniqueID"] = "1729817554",
            ["ClassName"] = "group",
            ["Name"] = "my outfit",
            ["Description"] = "add parts to me!",
        },
    },
}


function ITEM:getDesc()	
	if (self.entity and IsValid(self.entity)) then
		return L("poliVestDescEntity")
	end

	return L("poliVestDesc")
end

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:hook("Equip", function(item)
	item.player:EmitSound("items/ammo_pickup.wav", 80)

    -- Register Item in the Unequip Pool
    item.player.uneqTeam = item.player.uneqTeam or {}
    item.player.uneqTeam[item:getID()] = item
end)
ITEM:hook("Unequip", function(item)
	item.player:EmitSound("items/ammo_pickup.wav", 80)

    -- Unregister Item in the Unequip Pool
    item.player.uneqTeam = item.player.uneqTeam or {}
    item.player.uneqTeam[item:getID()] = nil
end)

ITEM.isEquipment = true
ITEM.defaultHealth = 200
-- ITEM CODE
function ITEM:onInstanced(index, x, y, item)
	item:setData("health", item.defaultHealth)
end

-- Inventory drawing
if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		if (item:getData("equip")) then
			surface.SetDrawColor(110, 255, 110, 100)
			surface.DrawRect(w - 14, h - 14, 8, 8)
		end

			local def = item.defaultHealth
			local health = item:getData("health", def)/def*100
			local color = Color(255, health*255, health*255)
			nut.util.drawText(Format("%d", health) .. "%", 4, h - 3, color, 0, 4, "nutSmallFont")
	end
end
