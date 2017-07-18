AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

do
	REWARDMULTIPLY = {
		0,
		2,
		3,
		4,
		8,
		10,
		15,
		20,
		40,
	}
	TRYMONEY = 100

	if (SERVER) then
		GAMEDIFFICULTY = 25
		CHEERUPRANK = 2
		CHEERUPCHANCE = 0.10
		
		--[[local aaoa = {}
		local tries = 1000000
		for i = 1, tries do
			local random = math.Rand(0, 1)
			local rewardIndex = math.floor((random^GAMEDIFFICULTY * #REWARDMULTIPLY)) + 1
			
		if (rewardIndex <= CHEERUPRANK and (math.Rand(0, 1) <= CHEERUPCHANCE)) then
			rewardIndex = rewardIndex + 1
		end
		
			aaoa[rewardIndex] = aaoa[rewardIndex] or 0
			aaoa[rewardIndex] = aaoa[rewardIndex] + 1
		end
		
		local profit = 0
		local cost = TRYMONEY * tries
		
		for k, v in pairs(aaoa) do
			profit = profit + TRYMONEY * REWARDMULTIPLY[k] * v
		end
		print(cost, profit)
		
		PrintTable(aaoa)]]
		
	end
	
end

ENT.PrintName = "Casino Slot Machine"
ENT.Author = "Black Tea"
ENT.Information = "An edible slotmachine"
ENT.Category = "Nutscript - CityRP"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()

end
 
function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local ent = ents.Create( ClassName )
	ent:Spawn()
	ent:Activate()

	local ca, cb = ent:GetCollisionBounds()
	ent:SetPos( tr.HitPos + cb )

	return ent
end

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props/slotmachine/slotmachinefinal.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetGame(false)
		self:SetResult(0)

		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end
	end
end

function ENT:CanBeActivated()
	return (!self.activate)
end

function ENT:Use(client, call)
	if (client:IsPlayer() and self:CanBeActivated()) then
		local char = client:getChar()
		local cash = char:getMoney()
		local amount = TRYMONEY - cash 

		if (amount > 0) then
			client:notifyLocalized("cantAfford")

			return false
		end

		self:EmitSound("ambient/levels/labs/coinslot1.wav")
		char:takeMoney(TRYMONEY)
		if (SERVER) then
			self:PlayGame(client)
		end
	end
end
	
if (SERVER) then
	function ENT:PlayGame(client)
		local random = math.Rand(0, 1)
		local rewardIndex = math.floor((random^GAMEDIFFICULTY * #REWARDMULTIPLY)) + 1

		if (rewardIndex <= CHEERUPRANK and (math.Rand(0, 1) <= CHEERUPCHANCE)) then
			rewardIndex = rewardIndex + 1
		end

		local broadBool = true
		if (rewardIndex != 1) then
			broadBool = false
		end

		self.activate = client
		self:SetGame(true)
		self:SetResult(rewardIndex)

		-- this will do the stuff.
		timer.Create("slotGiveReward_fuckoff_" .. client:SteamID() .. self:EntIndex(), 2, 1, function()
			if (self and self:IsValid()) then
				self:SetGame(false)

				self:GiveReward(client, rewardIndex)
			end
		end)
	end

	function ENT:GiveReward(client, rewardIndex)
		local money = TRYMONEY * REWARDMULTIPLY[rewardIndex]
		local char = client:getChar()

		if (char and money > 0) then
			client:notifyLocalized("moneyTaken", nut.currency.get(money))
			char:giveMoney(money)
		end

		self.activate = nil
	end
else
	ENT.modelData = {}

	local MODEL = {}
	MODEL.model = "models/props/slotmachine/spin_wheel.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(-12, 1.5, -5)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["roll1"] = MODEL

	local MODEL = {}
	MODEL.model = "models/props/slotmachine/spin_wheel.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(-2.5, 1.5, -5)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["roll2"] = MODEL

	local MODEL = {}
	MODEL.model = "models/props/slotmachine/spin_wheel.mdl"
	MODEL.angle = Angle(0, 0, 0)
	MODEL.position = Vector(6.5, 1.5, -5)
	MODEL.scale = Vector(1, 1, 1)
	ENT.modelData["roll3"] = MODEL

	function ENT:Initialize()
		self.models = {}
		
		for k, v in pairs(self.modelData) do
			self.models[k] = ClientsideModel(v.model, RENDERGROUP_BOTH )
			self.models[k]:SetColor( v.color or color_white )
			self.models[k]:SetNoDraw(true)
			self.models[k]:SetSkin(1)

			if (v.material) then
				self.models[k]:SetMaterial( v.material )
			end
		end
	end

	function ENT:OnRemove()
		for k, v in pairs(self.models) do
			if (v and v:IsValid()) then
				v:Remove()
			end
		end
	end

	function ENT:Draw()
		local prevEntity
		for uid, dat in pairs(self.modelData) do
			local drawEntity = self.models[uid]

			if (drawEntity and drawEntity:IsValid()) then
				local pos, ang = self:GetPos(), self:GetAngles()
				local ang2 = ang

				pos = pos + self:GetForward() * dat.position[1]
				pos = pos + self:GetRight() * dat.position[2]
				pos = pos + self:GetUp() * dat.position[3]

				ang:RotateAroundAxis(self:GetForward(), dat.angle[1])
				ang:RotateAroundAxis(self:GetRight(), dat.angle[2])
				ang:RotateAroundAxis(self:GetUp(), dat.angle[3])

				if (dat.scale) then
					local matrix = Matrix()
					matrix:Scale((dat.scale or Vector( 1, 1, 1 )))
					drawEntity:EnableMatrix("RenderMultiply", matrix)
				end

				drawEntity:SetRenderOrigin( pos )
				drawEntity:SetRenderAngles( ang2 )
				drawEntity:DrawModel()

				if (self:GetGame()) then
					self.non = true
					drawEntity:SetSkin(0)
					drawEntity.number = math.random(1, 11)

					while (prevEntity and prevEntity.number == drawEntity.number) do
						drawEntity.number = math.random(1, 11)
					end
				else					
					local result = self:GetResult()

					if (self.non) then
						self:EmitSound("HL1/fvox/blip.wav")

						self.non = false
					end

					if (result <= 1) then
						drawEntity:SetSkin(drawEntity.number or 1)
					else
						drawEntity:SetSkin(result)
					end
				end

				prevEntity = drawEntity
			else
				self.models[uid] = ClientsideModel(dat.model, RENDERGROUP_BOTH )
				self.models[uid]:SetColor( dat.color or color_white )
				self.models[uid]:SetNoDraw(true)
				self.models[uid]:SetSkin(1)

				if (dat.material) then
					self.models[uid]:SetMaterial( dat.material )
				end
			end
		end

		self:DrawModel()
	end

	function ENT:Think()
	end
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 1, "Game")
	self:NetworkVar("Int", 2, "Result")
end