IS_INTERNATIONAL = true

WEAPON_REQSKILLS = {}

-- 아이템 스킬 필요도 초기화 함수
local function addRequire(itemID, reqAttribs)
	WEAPON_REQSKILLS[itemID] =  reqAttribs
end

nut.currency.symbol = "$"
nut.currency.singular = ""
nut.currency.plural = ""
nut.config.language = IS_INTERNATIONAL and "english" or "korean"

-- ITEM SKILL REQUIREMENTS
--[[
	addRequire("ak47", {gunskill = 3})
	addRequire("aug", {gunskill = 5})
	addRequire("deagle", {gunskill = 5})
	addRequire("famas", {gunskill = 3})
	addRequire("fiveseven", {gunskill = 2})
	addRequire("galil", {gunskill = 3})
	addRequire("m4a1", {gunskill = 5})
	addRequire("mac10", {gunskill = 3})
	addRequire("mp5", {gunskill = 4})
	addRequire("p228", {gunskill = 1})
	addRequire("p90", {gunskill = 4})
	addRequire("sg552", {gunskill = 5})
	addRequire("tmp", {gunskill = 3})
	addRequire("ump", {gunskill = 3})
	addRequire("usp", {gunskill = 2})
	addRequire("healthkit", {medical = 7})
	addRequire("healvial", {medical = 3})
]]


-- ALLOWED_ENTS
-- Entities Listed below can be touch and tooled.
ALLOWED_ENTS = {
    ["prop_physics"] = true,
    ["nut_item"] = true,
    ["nut_d_lamp"] = true,
    ["nut_punchbag"] = true,
    ["nut_d_pot"] = true,
    ["nut_shootbag"] = true,
    ["nut_craftingtable"] = true,
    ["nut_microwave"] = true,
    ["nut_foodvendor"] = true,
    ["nut_drinkvendor"] = true,
    ["nut_helloboard"] = true,
    ["rprotect_terminal"] = true,
    ["rprotect_scanner"] = true,
    ["rprotect_camera"] = true,
    ["nut_checker"] = true,
    ["sent_bingle_simplenoti"] = true,
    ["sent_bingle_simplenoti_mdbig"] = true,
    ["sent_bingle_simplenoti_orlong"] = true,
    ["keypad"] = true,
    ["nut_lawboard"] = true,
    ["gmod_lamp"] = true,
    ["gmod_light"] = true,
    ["sammyservers_textscreen"] = true,
    ["nut_stove"] = true,
    ["nut_storage"] = true,
    ["jukebox"] = true,
    ["instrument_drumpad"] = true,
    ["synthesizer"] = true,
    ["synthesizer_guitar"] = true,
    ["synthesizer_piano"] = true,
    ["synthesizer_violin"] = true,
    ["nut_emergency"] = true,

	["nut_vnd_soda"] = true,
	["nut_vnd_snack"] = true,
	["nut_vnd_popcorn"] = true,
	["nut_vnd_food"] = true,
	["nut_vnd_covfefe"] = true,
	["nut_vnd_covfefe_refill"] = true,
	["nut_seller"] = true,
	
	--------BITMINER 2
	["bm2_bitminer_1"] = true,
	["bm2_bitminer_2"] = true,
	["bm2_bitminer_rack"] = true,
	["bm2_bitminer_server"] = true,
	["bm2_extention_lead"] = true,
	["bm2_fuel"] = true,
	["bm2_generator"] = true,
	["bm2_power_lead"] = true,
}

-- DEFAULT_PURCHASE
-- Default Purchasable list.
DEFAULT_PURCHASE = {
	-- Ammo
	["ammo_pistol"] = 1,
	["ammo_buckshot"] = 1,
	["ammo_357"] = 1,
	["keypad"] = 1,
}

-- DROPITEM
-- Drops specified items when player dies. 
-- 1 means 100% chance to drop.
-- 0 means never drops the item
DROPITEM = {
	["raweed"] = 1,
}

-- ILLEGAL_ENTITY
ILLEGAL_ENTITY = {
	["moneyprinter_samsung"] = 0.8,
	["moneyprinter_agple"] = 0.8,
	["moneyprinter_lg"] = 0.8,
	["nut_d_lamp"] = 0.8,
	["nut_d_pot"] = 0.8,
}

USABLE_FUNCS = {
	"use",
	"throw",
	"View",
	"Equip",
	"EquipUn",
}

WEEDTABLE = {
	price = 500,
	min = 0.7,
	max = 1.3,
}


WEAPON_STOCKS = {
	[1] = {
		desc = "sellRifles",
		stocks = {
			["ma85_wf_ar04"] = {amount = 3, price = 5000},
			["ma85_wf_ar06"] = {amount = 3, price = 4000},
			["ma85_wf_ar26"] = {amount = 3, price = 4000},
			["ma85_wf_ar11"] = {amount = 3, price = 6000},
			["ma85_wf_ar24"] = {amount = 3, price = 6000},
			["ma85_wf_shg05"] = {amount = 3, price = 12000},
		},
	},
	[2] = {
		desc = "sellHeavyWeapons",
		stocks = {
			["ma85_wf_mg07"] = {amount = 2, price = 15000},
		},
	},
	[3] = {
		desc = "sellSniperRifles",
		stocks = {
			["ma85_wf_sr34"] = {amount = 1, price = 12000},
			["ma85_wf_sr39"] = {amount = 1, price = 17000},
			["ma85_wf_sr04"] = {amount = 1, price = 25000},
			["ma85_wf_sr34_gold"] = {amount = 1, price = 30000},
		},
	},
}

-- Adding Schema Specific Configs.
nut.config.setDefault("font", "Bitstream Vera Sans")

nut.config.add("garbageInterval", 20, "How long trash regen takes.", 
	function(oldValue, newValue)
		if (timer.Exists("nutGrabage")) then
			timer.Adjust("nutGrabage", newValue, 0, SCHEMA.CrapPayload)
		end
	end, {
	data = {min = 10, max = 3600},
	category = "schema"
})

nut.config.add("hitCost", 500, "Amount of money for requesting hit.", nil, {
	data = {min = 250, max = 5000},
	category = "schema"
})

nut.config.add("garbageMax", 25, "How many trash can be in single world.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("garbageCount", 7, "How many trash spawned in one tick.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("voteJob", 25, "Percentage of vote to get a job", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("voteDemote", 25, "Percentage of vote to demote people", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("vendorWeedInterval", 3600, "Amount of seconds to update Narcotic NPC Shops.", 
	function(oldValue, newValue)
		if (timer.Exists("nutVendorWeedSell")) then
			timer.Adjust("nutVendorWeedSell", newValue, 0, SCHEMA.UpdateWeedVendors)
		end
	end, {
	data = {min = 600, max = 7200},
	category = "schema"
})

nut.config.add("vendorInterval", 3600, "Amount of seconds to update Black Market Dealer NPC Shops.", 
	function(oldValue, newValue)
		if (timer.Exists("nutVendorSell")) then
			timer.Adjust("nutVendorSell", newValue, 0, SCHEMA.UpdateVendors)
		end
	end, {
	data = {min = 600, max = 7200},
	category = "schema"
})

nut.config.add("wageInterval", 180, "Amount of seconds to distribute paycheck on players.", 
	function(oldValue, newValue)
		if (timer.Exists("nutSalary")) then
			timer.Adjust("nutSalary", newValue, 0, SCHEMA.SalaryPayload)
		end
	end, {
	data = {min = 10, max = 3600},
	category = "schema"
})

nut.config.add("incomeInterval", 1000, "Amount of seconds to distribute bank income.", 
	function(oldValue, newValue)
		if (timer.Exists("nutBankIncome")) then
			timer.Adjust("nutBankIncome", newValue, 0, SCHEMA.BankIncomePayload)
		end
	end, {
	data = {min = 10, max = 3600},
	category = "schema"
})

nut.config.add("doorTaxInterval", 300, "Amount of seconds to get door tax.", 
	function(oldValue, newValue)
		if (timer.Exists("nutDoorTax")) then
			timer.Adjust("nutDoorTax", newValue, 0, SCHEMA.BuildingTaxPayload)
		end
	end, {
	data = {min = 1, max = 3600},
	category = "schema"
})

nut.config.add("jailTime", 200, "Amount of seconds.", nil, {
	data = {min = 0, max = 600},
	category = "schema"
})

nut.config.add("hungerTime", 1, "The time of which is deducted from hunger when not eating.", nil, {
	data = {min = 0, max = 600},
	category = "schema"
})

nut.config.add("tazeTime", 5, "The ammount of time someone is tazed for.", nil, {
	data = {min = 0, max = 600},
	category = "schema"
})

nut.config.add("incomeRate", .1, "Percentage of income.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("dpBank", 10, "Percentage of Money to lose in Death Penalty.", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("potPerLaw", 4, "Week Pot limit.", nil, {
	data = {min = 0, max = 10},
	category = "schema"
})

nut.config.add("bankFee", 5, "The Bank Transfer Fee (x% of Transfer Money).", nil, {
	data = {min = 0, max = 100},
	category = "schema"
})

nut.config.add("startMoney", 5000, "Start money for new character.", nil, {
	data = {min = 0, max = 50000},
	category = "schema"
})

nut.config.add("deathMoney", true, "Lose money on death.", nil, {
	category = "penalty"
})

nut.config.add("deathWeapon", true, "Lose weapon on death.", nil, {
	category = "penalty"
})

nut.config.add("afkDemote", 240, "afk Demote.", nil, {
	data = {min = 0, max = 1000},
	category = "schema"
})

nut.config.add("doorTax", 100, "door tax.", nil, {
	data = {min = 0, max = 1000},
	category = "schema"
})

local function pianoOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		
		if (class != CLASS_PIANIST) then return end

		return true
	end

	return
end

local function djOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		
		if (class != CLASS_DJ) then return end

		return true
	end

	return
end

local function cookOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()

		if (class != CLASS_COOK) then return end

		return true
	end

	return
end

local function dealerOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()

		if !(class == CLASS_BLACKDEALER or
			class == CLASS_DEALER) then return end

		return true
	end

	return
end

local function mobOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (!classData) then return end
		if (classData.team == 2 or classData.team == 3) then 
			return true
		end

		return false
	end

	return
end

local function notLaw(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (!classData) then return end
		if (classData.law == true) then return end

		return true
	end

	return
end

local function docOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		
		return class == CLASS_DOCTOR
	end

	return
end

local function busiOnly(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		
		return class == CLASS_BUSINESS
	end

	return
end

local function onlyLaw(client)
	local char = client:getChar()

	if (char) then
		local class = char:getClass()
		local classData = nut.class.list[class]

		if (!classData) then return end
		if (classData.law != true) then return end

		return true
	end

	return
end

local function all(client) return true end

function nut.bent.add(entClass, entModel, entName, entMax, entPrice, buyCondition)
	local condt = buyCondition or defaultCond

	nut.bent.list[entClass] = {
		class = entClass,
		name = entName,
		model = entModel,
		max = entMax,
		price = entPrice,
		condition = condt
	}

	return nut.bent.list[entClass] 
end

--[[
nut.tips = {
	--'대부분의 아이템은 Ctrl을 누르고 클릭하면 바로 사용할 수 있습니다.',
	'월급은 바로 은행으로 들어오기 때문에 현금화가 필요합니다.',
	'인벤토리는 F3으로도 바로 열 수 있습니다.',
	'스탯은 특정행동을 반복하는 것으로도 올릴 수 있습니다. ',
	'가끔은 주변사람들에게 베풀어주는 것 만으로도 긍정적인 효과를 얻을 수 있습니다. ',
	'펀치 인형은 "주먹으로 때릴 경우에만" 숙련 경험치를 줍니다.',
	'책을 읽으면 한번에 많은 양의 숙련 경험치를 얻지만, 가격이 매우 높습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
}
]]

--Translated By AngryBaldMan
nut.tips = {
	--'Most items can be used immediately by pressing Ctrl and clicking.',
	'The salary comes directly into the bank, so cash is required.',
	'Inventory can also be opened directly with F3.',
	'Stats can be raised by repeating certain actions',
	'Sometimes it can be a positive effect just to give it to people around you. ',
	'Punch dolls give "only when you hit with a punch" experience',
	'When you read a book, you get a lot of experience at a time, but the price is very high.',
	'You can turn off this tip through the C menu. The option is located in the upper right corner of the screen.',
}



nut.bent.add("nut_checker", "models/props_wasteland/interior_fence002e.mdl", "weaponChecker", 2, 1000, onlyLaw)

nut.bent.add("moneyprinter_samsung", "models/props_c17/consolebox01a.mdl", "printerNameSamsung", 2, 1000, notLaw)
nut.bent.add("moneyprinter_agple", "models/props_c17/consolebox01a.mdl", "printerNameLG", 2, 1000, notLaw)
nut.bent.add("moneyprinter_lg", "models/props_c17/consolebox01a.mdl", "printerNameApple", 2, 1000, notLaw)

nut.bent.add("nut_vnd_food", "models/props_wasteland/kitchen_stove002a.mdl", "foodVendor", 1, 800, cookOnly)
nut.bent.add("nut_vnd_soda", "models/rebel1324/sodavendor.mdl", "sodaVendor", 1, 1000, cookOnly)
nut.bent.add("nut_vnd_covfefe", "models/props/commercial/coffeemachine01.mdl", "coffeeVendor", 1, 4500, cookOnly)

nut.bent.add("nut_microwave", "models/props/cs_office/microwave.mdl", "microwave", 2, 400, cookOnly)
nut.bent.add("nut_stove", "models/props_c17/furnitureStove001a.mdl", "stove", 1, 1500, cookOnly)

nut.bent.add("nut_d_lamp", "models/gonzo/weedb/lamp2.mdl", "weedLampName", 4, 800, mobOnly)
nut.bent.add("nut_d_pot", "models/gonzo/weedb/pot2.mdl", "weedPotName", 20, 1000, mobOnly)
nut.bent.add("nut_attrib_gun", "models/props_c17/doll01.mdl", "gunBoosterName", 2, 3000, dealerOnly)

nut.bent.add("instrument_drumpad", "models/metasync/gpad.mdl", "launchPad", 1, 1000, djOnly) -- Gonna be removed soon
nut.bent.add("nut_vnd_medical", "models/rebel1324/medicvendor.mdl", "medicalVendorName", 1, 1000, docOnly)

nut.bent.add("synthesizer", "models/tnf/synths.mdl", "synthesizer", 1, 3000, pianoOnly)
nut.bent.add("synthesizer_guitar", "models/tnf/synth.mdl", "synthesizerGuitar", 1, 3000, pianoOnly)
nut.bent.add("synthesizer_piano", "models/tnf/synth.mdl", "synthesizerPiano", 1, 3000, pianoOnly)
nut.bent.add("synthesizer_violin", "models/tnf/synth.mdl", "synthesizerViolin", 1, 3000, pianoOnly)

nut.bent.add("jukebox", "models/fallout3/jukebox.mdl", "jukebox", 1, 1000, djOnly)

nut.bent.add("nut_seller", "models/rebel1324/nmrih_cash_register.mdl", "checkoutName", 1, 2500, all)

nut.bent.add("nut_craftingtable", "models/props_wasteland/controlroom_desk001b.mdl", "craftingTable", 1, 500, all)
nut.bent.add("nut_loadingtable", "models/props_wasteland/controlroom_desk001b.mdl", "loadingTable", 1, 500, all)

nut.bent.add("sent_bingle_simplenoti", "models/props/cs_assault/chaintrainstationsign.mdl", "signSmall", 2, 400, all)
nut.bent.add("sent_bingle_simplenoti_orlong", "models/squad/sf_plates/sf_plate2x5.mdl", "signMedium", 2, 400, all)
nut.bent.add("sent_bingle_simplenoti_mdbig", "models/hunter/plates/plate1x3.mdl", "singBig", 2, 400, all)
nut.bent.add("nut_attrib_punch", "models/props_lab/huladoll.mdl", "strBoosterName", 2, 1000, all)

nut.bent.add("rprotect_terminal", "models/props_phx/rt_screen.mdl", "survTerminal", 1, 2000, all)
nut.bent.add("rprotect_scanner", "models/Items/battery.mdl", "survScanner", 4, 1500, all)
nut.bent.add("rprotect_camera", "models/tools/camera/camera.mdl", "survCamera", 1, 2000, all)
--nut.bent.add("nut_vnd_covfefe_refill", "models/props/interior/coffee_maker.mdl", "coffeeVendorRefill", 1, 6000, all)

nut.bent.add("bm2_bitminer_1", "models/bitminers2/bitminer_1.mdl", "bitminer", 1, 5000, busiOnly)
nut.bent.add("bm2_bitminer_2", "models/bitminers2/bitminer_2.mdl", "bitminer2", 1, 8000, busiOnly)
nut.bent.add("bm2_bitminer_rack", "models/bitminers2/bitminer_rack.mdl", "bitminerRack", 1, 5000, busiOnly)
nut.bent.add("bm2_bitminer_server", "models/bitminers2/bitminer_2.mdl", "bitminerServer", 8, 25000, busiOnly)
nut.bent.add("bm2_extention_lead", "models/bitminers2/bitminer_plug_3.mdl", "bitminerExtend", 1, 3000, busiOnly)
nut.bent.add("bm2_fuel", "models/props_junk/gascan001a.mdl", "bitminerFuel", 1, 2500, busiOnly)
nut.bent.add("bm2_generator", "models/bitminers2/generator.mdl", "bitminerGenerator", 1, 4000, busiOnly)
nut.bent.add("bm2_power_lead", "models/bitminers2/bitminer_plug_2.mdl", "bitminerPlug", 3, 3500, busiOnly)
/*
-- need to get better shit.
local bentstr = nut.bent.add("nut_storage", "models/rebel1324/footlocker.mdl", "5x3 아이템 상자", 2, 1000, all)
hook.Add("InitializedPlugins", "registerFootlockers", function()
	STORAGE_DEFINITIONS["models/rebel1324/footlocker.mdl"] = {
		name = "Crate",
		desc = "5x3의 공간을 가지고 있는 상자입니다.",
		width = 5,
		height = 3,
		onOpen = function(entity, activator)
			timer.Simple(1, function()
				local seq = entity:LookupSequence("open")
				entity:ResetSequence(seq)
			end)

			timer.Simple(3, function()
				if (entity and IsValid(entity)) then
					local seq = entity:LookupSequence("closed")
					entity:ResetSequence(seq)
				end
			end)
		end,
	}
end)

bentstr.onSpawn = function(entity, client, char, info)
	local data = STORAGE_DEFINITIONS[info.model:lower()]

	if (data) then
		entity:SetModel(info.model)
		entity:SetSolid(SOLID_VPHYSICS)
		entity:PhysicsInit(SOLID_VPHYSICS)

		local ca, cb = entity:GetCollisionBounds()
		entity:SetPos(entity:GetPos() + cb)

		nut.item.newInv(0, "st"..data.name, function(inventory)
			inventory.vars.isStorage = true

			if (IsValid(entity)) then
				entity:setInventory(inventory)
			end
		end)

		local phys = entity:GetPhysicsObject()

		if (phys) then
			phys:Wake()
		end
	else
		print("server got request that contains wrong storage model STORAGE_DEFINITIONS.")
		entity:Remove()
	end
end
*/
--[[
nut.tips = {
	--'대부분의 아이템은 Ctrl을 누르고 클릭하면 바로 사용할 수 있습니다.',
	'월급은 바로 은행으로 들어오기 때문에 현금화가 필요합니다.',
	'인벤토리는 F3으로도 바로 열 수 있습니다.',
	'스탯은 특정행동을 반복하는 것으로도 올릴 수 있습니다. ',
	'가끔은 주변사람들에게 베풀어주는 것 만으로도 긍정적인 효과를 얻을 수 있습니다. ',
	'펀치 인형은 "주먹으로 때릴 경우에만" 숙련 경험치를 줍니다.',
	'책을 읽으면 한번에 많은 양의 숙련 경험치를 얻지만, 가격이 매우 높습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'C메뉴를 통해서 이 팁을 끌 수 있습니다. 옵션은 화면의 오른쪽 위 구석에 위치하고 있습니다.',
	'사격 인형은 "총으로 사격할 경우에만" 숙련 경험치를 줍니다.',
	'몇몇 상인은 특정 직업에게만 물건을 판매합니다.',
	'쓰레기는 거지만 보고 주울 수 있습니다.',
	'마피아와 갱스터 그리고 경찰끼리만 /팀 을 사용해서 채팅을 주고받을 수 있습니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'버그와 불편 신고는 이미지나 비디오를 첨부하면 매우 빠르게 해결됩니다.',
	'돈 복사기를 숨겨놓아서 돈을 벌 수 있습니다.',
	'경찰들은 돈 복사기를 처리함으로써 돈을 벌 수 있습니다.',
	'IC와 OOC를 구분해 주세요!',
	'IC와 OOC를 구분해 주세요!',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'신고하기전에 MOTD와 IC/OOC 여부를 체크해주세요.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
	'!신고 명령어로 어드민에게 신고를 할 수 있습니다.',
}
]]

// Translation by AngryBaldMan
nut.tips = {
	--'대부분의 아이템은 Ctrl을 누르고 클릭하면 바로 사용할 수 있습니다.',
	'The salary comes directly into the bank, so cash is required.',
	'Inventory can also be opened directly with F3.',
	'Stats can be raised by repeating certain actions. ',
	'Sometimes it can be a positive effect just to give it to people around you.. ',
	'Punch dolls gives you "experience only when you hit with a punch".',
	'When you read a book, you get a lot of experience at a time, but the price is very high.',
	'You can turn off this tip through the C menu. The option is located in the upper right corner of the screen.',
	'You can turn off this tip through the C menu. The option is located in the upper right corner of the screen.',
	'You can turn off this tip through the C menu. The option is located in the upper right corner of the screen.',
	'Shooting Dolls will give you "Experienced".',
	'Some traders sell things only to certain jobs.',
	'Its garbage but you can see it.',
	'Mobs, gangsters, and policemen can only chat with each other / team.',
	'Bug and bug reports can be resolved very quickly if you attach an image or video.',
	'Bug and bug reports can be resolved very quickly if you attach an image or video.',
	'Bug and bug reports can be resolved very quickly if you attach an image or video.',
	'Money You can earn money by hiding copiers.',
	'Police can make money by processing money copiers.',
	'Please separate IC and OOC!',
	'Please separate IC and OOC!',
	'Please check MOTD and IC / OOC before declaring.',
	'Please check MOTD and IC / OOC before declaring.',
	'Please check MOTD and IC / OOC before declaring.',
	'We can report to administrator with report command.',
	'We can report to administrator with report command.',
	'We can report to administrator with report command.',
	'We can report to administrator with report command.',
}
