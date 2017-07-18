ITEM.name = "Green Beacon"
ITEM.throwent = "nut_beacon"
ITEM.throwforce = 650
ITEM.desc = "beaconDesc"
ITEM.price = 80

ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(98.124336242676, 82.42163848877, 60.427516937256),
	ang = Angle(25.154916763306, -139.95780944824, -42.897842407227),
	fov = 4.0647949973453,
	outline = true,
	outlineColor = Color(46, 204, 113),
}
function ITEM:entConfigure(grd)
	grd:SetDTInt(0,4)
end