--[[
Tomas
--]]
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Money Printer"
ENT.Author = "Black Tea"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.SeizeReward = 450
ENT.lockable = true
ENT.printerUpgrades = {
	power = "PowerLevel",
	stability = "StabilityLevel",
	cooler = "CoolerLevel",
	speed = "SpeedLevel",
}
-- TODO: Language
ENT.upgradeText = {
	power = function(self)
		return nut.currency.get(self:CalcMoney()) .. "인쇄"
	end,
	stability = function(self)
		return self:CalcStability() .. "% 오류확률"
	end,
	cooler = function(self)
		return self:CalcCooling(true) .. "도 쿨링 (꺼질시)"
	end,
	speed = function(self)
		return "생성시간 " .. self:CalcSpeed() .. "초"
	end,
}
ENT.setting = {
	upgrade = {
		price = {
			power = {4000, 1},
			stability = {4000, 1},
			cooler = {4000, 1},
			speed = {4000, 1},
		},
		val = {
			power = {500, 1}, -- add, mul
			stability = {3, 2, 1, .5, .1, 0}, -- hey
			cooler = {10, 20, 30, 33, 36, 40}, -- cooler
			speed = (.1), -- upg
		},
		max = 5, -- Maximum Upgrade
	},
	spec = {
		price = 20000,
		maxHoldStacks = 15,
		time = 60,
		coolTime = 20,
		print = 2000,
		maxTemp = 120,
		printTemp = 5,
		enableCoolEfficieny = .15,
	}
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "Temperature")
	self:NetworkVar("Int", 1, "PrintRate")
	self:NetworkVar("Int", 2, "PowerLevel")
	self:NetworkVar("Int", 3, "StabilityLevel")
	self:NetworkVar("Int", 4, "CoolerLevel")
	self:NetworkVar("Int", 5, "SpeedLevel")
	self:NetworkVar("Bool", 0, "Enabled")
	self:NetworkVar("Entity", 0, "owning_ent")
	self:NetworkVar("Float", 2, "Money")

	
	if (SERVER) then
		self:NetworkVarNotify("SpeedLevel", function(entity, name, old, new)
			if (old == new) then
				return
			end

			entity:UpdatePrintTimer(true)
		end)

		self:NetworkVarNotify("Enabled", function(entity, name, old, new)
			if (old == new) then
				return
			end

			if (!new) then
				entity:UpdatePrintTimer(true)
			else
				entity:UpdatePrintTimer(false)
			end
		end)
	end
end


function ENT:CalcStability()
	local level = (self:GetStabilityLevel() + 1)
	local probTable = self.setting.upgrade.val.stability

	return (probTable[level] or 0)
end

function ENT:CalcCooling(display)
	local level = self:GetCoolerLevel()
	local coolerTable = self.setting.upgrade.val.cooler
	local fraction = self.setting.spec.enableCoolEfficieny
	if (display or self:GetEnabled() != true) then
		fraction = 1
	end

	return ((coolerTable[level] or 10) * fraction)
end

function ENT:CalcSpeed()
	local level = self:GetSpeedLevel()
	local orginalTime = self.setting.spec.time

	return orginalTime * (1 - (level * self.setting.upgrade.val.speed or .2))
end

function ENT:CalcMoney()
	local powerInfo = self.setting.upgrade.val.power

	return math.Round(self.setting.spec.print + (self:GetPowerLevel() * powerInfo[1] * powerInfo[2]))
end


local upgradeOptionsMoney = {
	power = function(ent) local hey = ent.setting.upgrade.price.power return math.Round((ent:GetPowerLevel() + 1) * hey[1] * hey[2]) end,
	stability = function(ent) local hey = ent.setting.upgrade.price.stability return math.Round((ent:GetStabilityLevel() + 1) * hey[1] * hey[2]) end,
	cooler = function(ent) local hey = ent.setting.upgrade.price.cooler return math.Round((ent:GetCoolerLevel() + 1) * hey[1] * hey[2]) end,
	speed = function(ent) local hey = ent.setting.upgrade.price.speed return math.Round((ent:GetSpeedLevel() + 1) * hey[1] * hey[2]) end,
}
function ENT:GetUpgradeMoney(key)
	local maxLevel = self.setting.upgrade.max
	local keys = self.printerUpgrades
	if (keys[key]) then
		local info = self.setting.upgrade.price[key]
		if (info) then
			local getFunc = self[("Get" .. keys[key])]

			if (getFunc) then
				local level = getFunc(self)
				if (level >= maxLevel) then
					return -1
				end

				return info[1] * info[2] * (level + 1)
			end
		end
	end
end