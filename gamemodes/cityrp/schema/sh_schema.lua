SCHEMA.name = "Doshi" -- Change this name if you're going to create new schema.
SCHEMA.author = "Black Tea / RealKallos"
SCHEMA.desc = "새로운 세계에 오신것을 환영합니다."

-- Schema Help Menu. You can add more stuffs in cl_hooks.lua.
SCHEMA.helps = {
	["라크알피의 역사에 대해"] = 
	[[라크알피의 탄생은 Lac 와 RealKallos 의 협력으로 이루어졌습니다.
	<br>라크알피 시즌1 초기, Black Tea za rebel1324 이 개발팀에 합류하였습니다.
	<br>라크알피 시즌2 이후 Lac가 서버 운영과 개발을 그만두고 모든 개발과 운영은 RealKallos 이 이어 진행하였습니다.
	<br>이후 Black Tea za rebel1324 또한 군입대로 인해 개발을 그만두었으나 시즌5, 다시금 라크알피에 합류하였습니다.
	<br>RealKallos 의 시즌3,4 가 지나고 새로운 시즌인 시즌5가 현재 진행중입니다.]],
	["이모드는 무엇인가요?"] = 
	[[현재 플레이중 이신 모드는 뉴 라크알피입니다.
	<br>NutScript 의 ModernRP base 를 기본으로 원작자인 Black Tea za rebel1324 의 주도하에 제작되었습니다.
	<br>기존 넛스크립트의 SeriousRP가 아닌 DarkRP와 같은 가벼운 RP모드를 지향하며 제작되었습니다.]],
	["제작자에 대해"] = 
	[[이 Schema의 메인 제작자는 Black Tea za rebel1324(https://github.com/rebel1324) 입니다.
	<br>2015. Feb. 9, 군에 입대하여 제대한후 제작한 Schema 입니다.
	<br>이 Schema는 RealKallos 와 Weed 의 도움으로 만들어졌습니다.
	<br>현재 서버는 RealGaming.kr 의 메인 서버로 가동중입니다.]]
}

SCHEMA.prisonPositions = SCHEMA.prisonPositions or {}
SCHEMA.crapPositions = SCHEMA.crapPositions or {}
SCHEMA.laws = {
	"살인을 한 자는 반드시 처벌받는다",
	"남을 돕고 살자",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
	"",
}

nut.vote = nut.vote or {}
nut.vote.list = nut.vote.list or {}

nut.bent = nut.bent or {}
nut.bent.list = {}

nut.util.include("sv_database.lua")
nut.util.include("sh_configs.lua")
nut.util.include("cl_effects.lua")
nut.util.include("sv_hooks.lua")
nut.util.include("cl_hooks.lua")
nut.util.include("sh_hooks.lua")
nut.util.include("sh_commands.lua")
nut.util.include("meta/sh_player.lua")
nut.util.include("meta/sh_entity.lua")
nut.util.include("meta/sh_character.lua")
nut.util.include("sh_dev.lua") -- Developer Functions
nut.util.include("sh_character.lua")
nut.util.include("sv_schema.lua")

nut.anim.setModelClass("models/fearless/mafia02.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia04.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia06.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia07.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia09.mdl", "player")

nut.anim.setModelClass("models/humans/nypd1940/male_01.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_02.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_03.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_04.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_05.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_06.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_07.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_09.mdl", "player")

nut.anim.setModelClass("models/btcitizen/male_01.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_02.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_03.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_04.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_05.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_06.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_07.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_08.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_09.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_10.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_11.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_12.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_13.mdl", "player")
nut.anim.setModelClass("models/btcitizen/male_14.mdl", "player")

nut.anim.setModelClass("models/btcitizen/female_01.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_02.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_03.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_04.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_05.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_06.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_07.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_08.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_09.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_10.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_11.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_12.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_13.mdl", "player")
nut.anim.setModelClass("models/btcitizen/female_14.mdl", "player")

local fuckoff = {
	chatbox  = false,
	wepselect = false,
	thirdperson = false,
	spawnsaver = false,
	saveitems = false,
	recognition = false,
}
function SCHEMA:PluginShouldLoad(uniqueID)
	return fuckoff[uniqueID]
end