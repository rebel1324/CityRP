ITEM.name = "Coffee"
ITEM.model = "models/shibcuppy.mdl"
ITEM.desc = "coffeeDesc"
ITEM.duration = 100
ITEM.price = 200

ITEM.attribBoosts = {
    ["end"] = 2,
    ["stm"] = -1
}

ITEM.exRender = true

ITEM.iconCam = {
    pos = Vector(58.665554046631, 49.226238250732, 35.71097946167),
    ang = Angle(25, 220, -1.2611966133118),
    entAng = Angle(16.035064697266, -146.10684204102, -2.6315321922302),
    fov = 4.2253316698315
}

ITEM:hook("_use", function(item)
    item.player:EmitSound("items/battery_pickup.wav")
    item.player:ScreenFade(1, Color(255, 255, 255, 255), 3, 0)
end)