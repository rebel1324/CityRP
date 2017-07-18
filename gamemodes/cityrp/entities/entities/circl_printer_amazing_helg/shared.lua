ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Money Printer"
ENT.Author = "Tomas"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.SeizeReward = 450
ENT.lockable = true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "NextPrint")
	self:NetworkVar("Int", 1, "PrintRate")
	self:NetworkVar("Entity", 2, "owning_ent")

	self.CrclCfg = {}--Keep this

	self.CrclCfg.Name = "printerNameLG" -- The name of the printer...
	self.CrclCfg.FireUpChance = 90 -- Printer break chance
	self.CrclCfg.MaxMoney = 800 -- Max money that it can hold
	self.CrclCfg.PrintInterval = 35 -- Interval in sec that it prints
	self.CrclCfg.PrintRate = 110 -- Prints this amount of the money if it have 100% upgraded speed + exp money added to this 1lvl = 1/4 of this number
	self.CrclCfg.PlusMoney = 35 -- 기초 돈복사량

	self.CrclCfg.SpeedUpgradePrice = 30 -- Price for the speed upgrade
	self.CrclCfg.CoolingUpgradePrice = 1500 -- Price for the cooling upgrade
	self.CrclCfg.PowerUpgradePrice = 1500 -- Price for the cooling upgrade
	self.CrclCfg.StabilityUpgradePrice = 500  -- Price for the cooling upgrade
	self.CrclCfg.PlusSpeed = 10 -- If you push upgrade speed it will upgrade that much


	self.CrclCfg.OnPrintFunc = function(ply) end -- Printer call this function onPrint so its useful for xp, lvl systems or anything You want +
end


function ENT:CalcMoney()
	local laws = 0
	for k, v in ipairs(player.GetAll()) do
		local char = v:getChar()

		if (char) then
			local class = char:getClass()
			local classData = nut.class.list[class]

		if (classData and classData.law) then
			laws = laws
			end
		end
	end

	local lawEfficiency = math.Clamp(0.5, laws/5, 3)

	return math.Round(self.CrclCfg.PlusMoney * ((self.CrclCfg.PrintRate + self:GetDTInt(4))/80) * lawEfficiency * math.max(self:GetDTFloat(1)/180, 1))
end

function ENT:GetMoney()
	return self:GetDTFloat(2)
end