AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Map Beacon"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
	function ENT:SpawnFunction(client, trace, class)
		local entity = ents.Create(class)
		entity:SetPos(trace.HitPos)
		entity:SetAngles(trace.HitNormal:Angle())
		entity:Spawn()
		entity:Activate()

		return entity
	end

	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_mine01.mdl")

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:DrawShadow(false)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end

	function ENT:OnRemove()
	end

	function ENT:Use(client)
		if (client:IsSuperAdmin() or self:CPPIGetOwner() == client) then
			netstream.Start(client, "nutBeaconMenu", self)
		end
	end

	netstream.Hook("nutBeaconRequestIcon", function(client, entity, index)
		if (client:IsSuperAdmin() or entity:CPPIGetOwner() == client) then
			entity:SetNW2Int("icon", index)
		end
	end)

	netstream.Hook("nutBeaconRequestTitle", function(client, entity, place)
		if (client:IsSuperAdmin() or entity:CPPIGetOwner() == client) then
			entity:SetNW2String("place", place)
		end
	end)
else
	netstream.Hook("nutBeaconMenu", function(entity)
		vgui.Create("nutBeaconSetting"):setEntity(entity)
	end)
	
	local PANEL = {}

	function PANEL:Init()
		if (IsValid(nut.gui.beacon)) then
			nut.gui.beacon:Remove()
		end

		nut.gui.beacon = self

		self:SetSize(400, 400)
		self:SetPos(ScrW()/2 + 200, ScrH()/2 - 200)
		self:MakePopup()
		self:SetTitle(L"beaconMenu")
		self:DockPadding(10, 30, 10, 10)

		self.label = self:Add("DLabel")
		self.label:Dock(TOP)
		self.label:SetText(L"title")
		self.label:SetFont("nutSmallFont")

		self.goBack = self:Add("DPanel")
		self.goBack:Dock(TOP)
		self.goBack:DockMargin(0, 5, 0, 0)

		self.title = self.goBack:Add("DTextEntry")
		self.title:Dock(FILL)
		self.title:SetText(L"title")
		self.title:SetFont("nutSmallFont")

		self.confirm = self.goBack:Add("DButton")
		self.confirm:Dock(RIGHT)
		self.confirm:SetText(L"confirm")
		self.confirm:SetFont("nutSmallFont")
		self.confirm:SetTextColor(color_white)


		self.iconslabel = self:Add("DLabel")
		self.iconslabel:Dock(TOP)
		self.iconslabel:SetText(L"icons")
		self.iconslabel:DockMargin(0, 15, 0, 0)
		self.iconslabel:SetFont("nutSmallFont")

		self.iconList = self:Add("DIconLayout")
		self.iconList:Dock(FILL)
		self.iconList:DockMargin(0, 5, 0, 0)
		self.iconList:SetSpaceY( 6 )
		self.iconList:SetSpaceX( 6 )
	end

	function PANEL:setEntity(entity)
		local title = self.title
		title:SetText(entity:GetNW2String("place", "장소"))

		function self.confirm:DoClick()
			netstream.Start("nutBeaconRequestTitle", entity, title:GetText())
		end

		function self.title:OnEnter()
			netstream.Start("nutBeaconRequestTitle", entity, title:GetText())
		end

		for index, txt in ipairs(entity.iconList) do
			local hey = self.iconList:Add("DButton")
			hey:SetSize(32, 32)
			hey:SetText(txt)
			hey:SetFont("nutIconsMediumNew")
			hey:SetTextColor(color_white)
			hey.index = index
			
			function hey:DoClick()
				netstream.Start("nutBeaconRequestIcon", entity, index)
			end
		end
	end

	vgui.Register("nutBeaconSetting", PANEL, "DFrame")

	ENT.iconList = {
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
		"",
	}

	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = (self:GetPos() + self:GetUp() * 10):ToScreen()
		local x, y = position.x, position.y

		nut.util.drawText(L"mapBeacon", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)

		nut.util.drawText(L("mapBeaconDesc", self:GetNW2String("place", "장소")), x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		nut.util.drawText(self.iconList[self:GetNW2Int("icon", 1)], x, y + 40, ColorAlpha(color_white, alpha), 1, 1, "nutIconsMediumNew", alpha * 0.65)
	end

	function ENT:Initialize()
		hook.Add("GetMapEntities", self, function(entity, dataList)
			table.insert(dataList, {
				pos = entity:GetPos(),
				id = "mapbeacon",
				entity = entity
			})
		end)
	end
	
	function ENT:Draw()
		self:DrawModel()
	end

	local GLOW_MATERIAL = Material("sprites/glow04_noz.vmt")
	function ENT:DrawTranslucent()
		local firepos = self:GetPos() + ( self:GetUp() * 12 )
		local delay = 256
		local size = math.max(RealTime() * 128 % delay - delay*.90, 0) % 16 * 2
		local col = Color(100, 255, 100)
		render.SetMaterial(GLOW_MATERIAL)
		render.DrawSprite(firepos, size, size, col)
	end
		
	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end
end
