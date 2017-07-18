AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Checkout Machine"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript - CityRP"

if (CLIENT) then
	local EFFECT = {}
	function EFFECT:Init( data ) 
		self.pos = data:GetStart()	
		self.adj = data:GetOrigin()
		self.nextEmit = CurTime()
		self.scale = 1
		self.emitter = WORLDEMITTER or ParticleEmitter(Vector(0, 0, 0))
		self.lifetime = CurTime() + 0.25

		local pos = data:GetStart()	
		local scale = self.scale

		local smoke = WORLDEMITTER:Add(nut.util.getMaterial("effects/yellowflare"), pos)
		smoke:SetVelocity(Vector())
		smoke:SetDieTime(math.Rand(.05,.1))
		smoke:SetStartAlpha(255)
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(35)
		smoke:SetEndSize(111)
		smoke:SetColor(255, 255, 222)

		for i = 0, 15 do
			local smoke = WORLDEMITTER:Add(nut.util.getMaterial("effects/money.png"), pos)
			smoke:SetVelocity(VectorRand()*100)
			smoke:SetDieTime(math.Rand(.4,.5))
			smoke:SetStartAlpha(math.Rand(188,211))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(3,4)*scale)
			smoke:SetEndSize(math.random(2,3)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetGravity(Vector( 0, 0, -222))
			smoke:SetAirResistance(50)
			
			local smoke = WORLDEMITTER:Add(nut.util.getMaterial("particle/rebel1324/sparks/spark4"), pos)
			smoke:SetVelocity(VectorRand()*222)
			smoke:SetDieTime(math.Rand(.1,.2))
			smoke:SetStartAlpha(math.Rand(188,211))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(7)
			smoke:SetStartLength(22)
			smoke:SetColor(255, 255, 222)
			smoke:SetGravity(Vector( 0, 0, -555))
			smoke:SetAirResistance(50)
		end
		
		for i = 0, 1 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
			smoke:SetVelocity(VectorRand()*150*scale)
			smoke:SetDieTime(math.Rand(.1,.3))
			smoke:SetStartAlpha(math.Rand(222,255))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(0,5)*scale)
			smoke:SetEndSize(math.random(11,22)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(33, 33, 33)
			smoke:SetGravity( Vector( 0, 0, 20 ) )
			smoke:SetAirResistance(250)
		end

		for i = 0, 2 do
			local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
			smoke:SetVelocity(VectorRand()*50*scale)
			smoke:SetDieTime(math.Rand(.1,1))
			smoke:SetStartAlpha(math.Rand(222,255))
			smoke:SetEndAlpha(0)
			smoke:SetStartSize(math.random(11,22)*scale)
			smoke:SetEndSize(math.random(33,44)*scale)
			smoke:SetRoll(math.Rand(180,480))
			smoke:SetRollDelta(math.Rand(-3,3))
			smoke:SetColor(33, 33, 33)
			smoke:SetGravity( Vector( 0, 0, 20 ) )
			smoke:SetAirResistance(250)
		end
	end

	function EFFECT:Render()
	end

	function EFFECT:Think()
		if (self.lifetime > CurTime()) then
			return true
		end
	end

	effects.Register( EFFECT, "cashierBlow" )
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/rebel1324/nmrih_cash_register.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetSolid(SOLID_VPHYSICS)
		self.health = 333

		local physicsObject = self:GetPhysicsObject()
		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self.stocks = {}
		self:Think()
	end

	function ENT:setHealth(amount)
		self.health = amount
	end
	
	function ENT:OnTakeDamage(dmginfo)
		local damage = dmginfo:GetDamage()
		self:setHealth(self.health - damage)

		if (self.health < 0 and !self.onbreak) then
			self.onbreak = true
			self:Remove()
		end
	end
	
	function ENT:getSellingItems()
		for k, v in pairs(self.stocks) do
			if (!IsValid(v)) then
				self.stocks[k] = nil
			end
		end

		return self.stocks or {}
	end

	function ENT:Think()
		for k, v in pairs(self:getSellingItems()) do
			local dist = v:GetPos():Distance(self:GetPos())

			if (dist >= 512) then
				v:CPPISetOwner()
				v:setNetVar("sellOwner", nil)
				v:setNetVar("sellPrice", nil)
				self.stocks[k] = nil
			end
		end
	end

	function ENT:OnRemove()
		if (self.onbreak) then
			local effectData = EffectData()
			effectData:SetStart(self:GetPos())
			effectData:SetOrigin(self:GetPos())
			util.Effect("cashierBlow", effectData, true, true)
		end

		for k, v in pairs(self:getSellingItems()) do
			v:CPPISetOwner()
			v:setNetVar("sellOwner", nil)
			v:setNetVar("sellPrice", nil)
		end
	end

	function ENT:Use(activator)
		if (fuckoff and fuckoff > CurTime()) then return end

		if (activator == self:CPPIGetOwner()) then
			fuckoff = CurTime() + 1
			netstream.Start(activator, "nutCashMachine", self, self:getSellingItems())
		end
	end
else
	local PANEL = {}
		function PANEL:Init()
			self:SetSize(560, 460)
			self:SetTitle(L"cashierList")
			self:Center()
			self:MakePopup()

			local noticeBar = self:Add("nutNoticeBar")
			noticeBar:Dock(TOP)
			noticeBar:setType(4)
			noticeBar:setText(L("cashierTip"))
			noticeBar:DockMargin(3, 0, 3, 5)

			self.scroll = self:Add("DScrollPanel")
			self.scroll:Dock(FILL)

			self.list = self.scroll:Add("DListLayout")
			self.list:Dock(FILL)
		end

		function PANEL:OnClose()
			netstream.Start("lootExit")
		end

		function PANEL:setItems(entity, items)
			self.entity = entity
			self.items = true
			self.itemPanels = {}

			for k, v in SortedPairs(items) do
				local itemTable = v

				if (itemTable) then
					local item = self.list:Add("DPanel")
					item:SetTall(36)
					item:Dock(TOP)
					item:DockMargin(4, 4, 4, 0)

					item.icon = item:Add("SpawnIcon")
					item.icon:SetPos(2, 2)
					item.icon:SetSize(32, 32)
					item.icon:SetModel(itemTable.model)
					item.icon:SetToolTip(itemTable:getDesc())

					item.name = item:Add("DLabel")
					item.name:SetPos(38, 0)
					item.name:SetSize(300, 36)
					item.name:SetFont("nutSmallFont")
					item.name:SetText(L(itemTable.name) .. " ( " .. nut.currency.get(itemTable.entity:getNetVar("sellPrice")) .. ")")
					item.name:SetContentAlignment(4)
					item.name:SetTextColor(color_white)

					item.change = item:Add("DButton")
					item.change:Dock(RIGHT)
					item.change:SetText(L"changePrice")
					item.change:SetWide(96)
					item.change:DockMargin(3, 3, 3, 3)
					item.change.DoClick = function(this)
						Derma_StringRequest(L("enterPrice"), L("enterPrice"), "", function(text)
							netstream.Start("nutCashMachinePrice", text, entity, itemTable.entity)
						end)
					end
					item.itemTable = itemTable

					self.itemPanels[k] = item
				end
			end
		end

		function PANEL:update()
			for k, v in ipairs(self.itemPanels) do
				local itemTable = v.itemTable
				v.name:SetText(L(itemTable.name) .. " ( " .. nut.currency.get(itemTable.entity:getNetVar("sellPrice")) .. ")")
			end
		end

		function PANEL:Think()
			if (self.items and !IsValid(self.entity)) then
				self:Remove()
			end
		end
	vgui.Register("nutCashier", PANEL, "DFrame")

	netstream.Hook("nutCashMachine", function(entity, stocks)		
		local newItems = {}

		for k, v in pairs(stocks) do
			local itemTable = v:getItemTable()
			local item = {
				model = itemTable.model,
				name = itemTable.name,
				getDesc = itemTable.getDesc,
				entity = v,
				price = v:getNetVar("price"),
			}

			if (item) then
				table.insert(newItems, item)
			end
		end

		if (nut.gui.cashmenu) then
			nut.gui.cashmenu:Remove()
			nut.gui.cashmenu = nil
		end

		nut.gui.cashmenu = vgui.Create("nutCashier")
		nut.gui.cashmenu:setItems(entity, newItems)
	end)
	
	netstream.Hook("nutCashUpdate", function()
		if (nut.gui.cashmenu) then
			nut.gui.cashmenu:update()
		end
	end)

	ENT.DrawEntityInfo = true

	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	local configGet = nut.config.get

	function ENT:onDrawEntityInfo(alpha)
		local position = toScreen(self.LocalToWorld(self, self.OBBCenter(self) + Vector(0, 0, 10)))
		local x, y = position.x, position.y

		drawText(L"checkoutName", x, y, colorAlpha(configGet("color"), alpha), 1, 1, nil, alpha * 0.65)
		drawText(L"checkoutDesc", x, y+16, colorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
		drawText(L("checkoutDesc2", self:CPPIGetOwner() and self:CPPIGetOwner():Name() or "World"), x, y+32, colorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end