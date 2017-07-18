ITEM.name = "Advanced Ballistic Vest"
ITEM.model ="models/rebel1324/cosmetic/armour.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.desc = "ashole"
ITEM.outfitCategory = "vest"
ITEM.price = 3500

function ITEM:getDesc()	
	if (self.entity and IsValid(self.entity)) then
		return L("advBalivestDescEntity")
	end

	return L("advBalivestDesc")
end

function ITEM:onGetDropModel(item) return "models/props_junk/cardboard_box004a.mdl" end

ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(921.61187744141, 775.10821533203, 611.32415771484),
	ang = Angle(24.9094581604, 220, 0),
	fov = 1.292871041622,
}

ITEM.pacData = {
		[1] = {
			["children"] = {
				[1] = {
					["children"] = {
					},
					["self"] = {
						["BoneMerge"] = true,
						["ClassName"] = "model",
						["UniqueID"] = "ADVET",
						["Model"] = "models/rebel1324/cosmetic/armour.mdl",
					},
				},
			},
			["self"] = {
				["EditorExpand"] = true,
				["UniqueID"] = "ADVET_WOW",
				["ClassName"] = "group",
				["Name"] = "my outfit",
				["Description"] = "add parts to me!",
			},
		},
}

-- On item is dropped, Remove a weapon from the player and keep the ammo in the item.
ITEM:hook("Equip", function(item)
	item.player:EmitSound("items/ammo_pickup.wav", 80)
end)
ITEM:hook("Unequip", function(item)
	item.player:EmitSound("items/ammo_pickup.wav", 80)
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
