PLUGIN.name = "Arrest System"
PLUGIN.author = "AngryBaldMan and Chessnut"
PLUGIN.desc = "Adds the ability to arrest players."

nut.util.include("sh_searching.lua")

if (SERVER) then
	function PLUGIN:PlayerLoadout(client)
		client:setNetVar("cuffed")
		--client:SetNetVar( "Float", 0, "Cuffed" )
	end

	function PLUGIN:PlayerUse(client, entity)
		if (!client:getNetVar("cuffed") and entity:IsPlayer() and entity:getNetVar("cuffed") and !entity.nutBeingUnCuffed) then
			entity.nutBeingUnCuffed = true
			entity:setAction("@beingUnCuffed", 5)
			entity:setNetVar("notcuffed")
			client:setAction("@unCuffing", 5)
			client:doStaredAction(entity, function()
				entity:setCuffed(false)
				entity.nutBeingUnCuffed = false

				client:EmitSound("npc/roller/blade_in.wav")
			end, 5, function()
				if (IsValid(entity)) then
					entity.nutBeingUnCuffed = false
					entity:setAction()
				end

				if (IsValid(client)) then
					client:setAction()
				end
			end)
		end
	end
else
	local COLOR_TIED = Color(245, 215, 110)

	function PLUGIN:DrawCharInfo(client, character, info)
		if (client:getNetVar("cuffed")) then
			info[#info + 1] = {L"isCuffed", COLOR_TIED}
		end
	end
end