SCHEMA.name = "CityRP" -- Change this name if you're going to create new schema.
SCHEMA.author = "Black Tea / RealKallos"
SCHEMA.desc = "Welcome to the new world."

-- Schema Help Menu. You can add more stuffs in cl_hooks.lua.
SCHEMA.helps = {
	["Alpha"] = 
	[[yay]],
}

SCHEMA.prisonPositions = SCHEMA.prisonPositions or {}
SCHEMA.crapPositions = SCHEMA.crapPositions or {}
SCHEMA.laws = {
	"Murder is illegal.",
	"Sharing is caring",
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

if (CLIENT) then
	nut.playerInteract.addFunc("quickGiveMoney", {
		nameLocalized = "quickGiveMoney",
		callback = function(target)
			Derma_StringRequest(L"setAmount", L"setAmountDesc", "", function(text)
				local client = LocalPlayer()
				text = text or ""
				text = tonumber(text) or 0

				client:ConCommand("say /give ".. text)
			end, function() end)
		end,
		canSee = function(target)
			local client = LocalPlayer()
			if (!IsValid(target)) then return end
			if (!target or !target:IsPlayer()) then return end
			local char = target:getChar()
			if (!char) then return end

			return true
		end
	})

	nut.playerInteract.addFunc("quickUseTie", {
		nameLocalized = "quickUseTie",
		callback = function(target)
			local client = LocalPlayer()
			local char = client:getChar()
			local inv = char:getInv()
			local item = inv:hasItem("tie")

			netstream.Start("invAct", "Use", item.id, item.invID)
		end,
		canSee = function(target)
			local client = LocalPlayer()
			if (!IsValid(target)) then return end
			if (!target:IsPlayer()) then return end
			local char = client:getChar()
			if (!char) then return end
			local inv = char:getInv()
			if (!inv) then return end
			local hasItem = inv:hasItem("tie")
			if (!hasItem) then return end
			
			return true
		end
	})

	nut.playerInteract.addFunc("quickSearchPlayer", {
		nameLocalized = "quickSearchPlayer",
		callback = function(target)
			client:ConCommand("say /search")
		end,
		canSee = function(target)
			local client = LocalPlayer()
			if (!IsValid(target)) then return end
			local char = client:getChar()
			if (!char) then return end
			local class = char:getClass()
			if (!class) then return end
			local classData = nut.class.list[class]
			if (!classData or !classData.law) then return end
			if (!target:IsPlayer()) then return end

			return true
		end
	})

	nut.playerInteract.addFunc("quickGiveLicense", {
		nameLocalized = "quickGiveLicense",
		callback = function(target)
			client:ConCommand("say /gunlicense")
		end,
		canSee = function(target)
			local client = LocalPlayer()
			if (!IsValid(target)) then return end
			local char = client:getChar()
			if (!char) then return end
			local class = char:getClass()
			if (!class) then return end
			local classData = nut.class.list[class]
			if (!classData or !classData.law) then return end
			if (!target:IsPlayer()) then return end
			if (target:getNetVar("license")) then return end
			return true
		end
	})

	nut.playerInteract.addFunc("quickRevokeLicense", {
		nameLocalized = "quickRevokeLicense",
		callback = function(target)
			client:ConCommand("say /revokegunlicense")
		end,
		canSee = function(target)
			local client = LocalPlayer()
			if (!IsValid(target)) then return end
			local char = client:getChar()
			if (!char) then return end
			local class = char:getClass()
			if (!class) then return end
			local classData = nut.class.list[class]
			if (!classData or !classData.law) then return end
			if (!target:IsPlayer()) then return end
			if (!target:getNetVar("license")) then return end
			return true
		end
	})

	nut.playerInteract.addFunc("placeHit", {
		nameLocalized = "placeHit",
		callback = function(target)
			local char = target:getChar()
			print("hi")
		end,
		canSee = function(target)
			local char = target:getChar()

			return char and char:getClass() == CLASS_HITMAN
		end
	})
end

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

-- Mafia Model Animation Registeration
nut.anim.setModelClass("models/fearless/mafia02.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia04.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia06.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia07.mdl", "player")
nut.anim.setModelClass("models/fearless/mafia09.mdl", "player")
nut.anim.setModelClass("models/fearless/don1.mdl", "player")

-- Police Model Animation Registeration
nut.anim.setModelClass("models/humans/nypd1940/male_01.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_02.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_03.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_04.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_05.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_06.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_07.mdl", "player")
nut.anim.setModelClass("models/humans/nypd1940/male_09.mdl", "player")

-- Black Tea Citizen Model Registeration
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

-- This hook prevents default Nutscript plugins to load.
local noLoad = {
	chatbox  = false, -- CityRP is using XPChat as default chat.
	wepselect = false, -- CityRP does not use Nutscript's Weapon Selection.
	thirdperson = false, -- CityRP does not use Thridperson.
	spawnsaver = false, -- CityRP does not use spawnsaver (returning back to defualt location)
	saveitems = false, -- CityRP does not save any items on the map.
	recognition = false, -- CityRP does not need recognition.
}
function SCHEMA:PluginShouldLoad(uniqueID)
	return noLoad[uniqueID] -- true = don't load the specified plugin.
end

if (SERVER) then
	if timer.Exists("CheckHookTimes") then
		timer.Remove("CheckHookTimes")
	end
end

hook.Add("Initialize", "CITYRP_LAG_FIXER", function()
	hook.Remove("PlayerTick", "TickWidgets")
	hook.Remove( "PostGameSaved", "OnCreationsSaved" )
	hook.Remove( "PopulateVehicles", "AddEntityContent" )
	hook.Remove( "PopulatePostProcess", "AddPostProcess" )
	hook.Remove( "PopulateNPCs", "AddNPCContent" )
	hook.Remove( "DupeSaveAvailable", "UpdateDupeSpawnmenuAvailable")
	hook.Remove( "DupeSaveUnavailable", "UpdateDupeSpawnmenuUnavailable")
	hook.Remove( "DupeSaved", "DuplicationSavedSpawnMenu")
	hook.Remove( "LoadGModSave", "LoadGModSave")
	hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
	hook.Remove("RenderScreenspaceEffects", "RenderBloom")
	hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
	hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
	hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
	hook.Remove("RenderScreenspaceEffects", "RenderSobel")
	hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
	hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
	hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
	hook.Remove("RenderScene", "RenderStereoscopy")
	hook.Remove("RenderScene", "RenderSuperDoF")
	hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
	hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
	hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
	hook.Remove("PostRender", "RenderFrameBlend")
	hook.Remove("PreRender", "PreRenderFrameBlend")
	hook.Remove("Think", "DOFThink")
	hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
	hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
	hook.Remove("PostDrawEffects", "RenderWidgets")
	hook.Remove("PostDrawEffects", "RenderHalos")
end)