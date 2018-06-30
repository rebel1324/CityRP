ITEM.name = "Diamond"
ITEM.desc = "diamondDesc"
ITEM.mineralLevel = 80
ITEM.isStackable = true
ITEM.maxQuantity = 100
ITEM.price = 15000 * ITEM.maxQuantity
ITEM.model = "models/props_debris/concrete_chunk03a.mdl"
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(174.06451416016, 147.3090057373, 106.74727630615),
	ang = Angle(25, -139.73446655273, -4.0246305465698),
	entAng = Angle(24.31579208374, 25.148393630981, 18.206037521362),
	fov = 4.674599566873,
	outline = true,
	outlineColor = Color(255, 95, 95)
}


if (CLIENT) then
	function ITEM:paintOver(item, w, h)
		local quantity = item:getQuantity()

		nut.util.drawText(quantity, 8, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, "nutChatFont")
	end
end
