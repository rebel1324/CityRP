PLUGIN.name = "Acts"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds acts that can be performed."
PLUGIN.acts = PLUGIN.acts or {}

nut.util.include("sh_setup.lua")

for k, v in pairs(PLUGIN.acts) do
	local data = {}
		local multiple = false

		for k2, v2 in pairs(v) do
			if (type(v2.sequence) == "table" and #v2.sequence > 1) then
				multiple = true

				break
			end
		end

		if (multiple) then
			data.syntax = "[number type]"
		end

		data.onRun = function(client, arguments)
			if (client.nutSeqUntimed) then
				client:setNetVar("actAng")
				client:leaveSequence()
				client.nutSeqUntimed = nil

				return
			end

			if (!client:Alive() or
				client:setLocalVar("ragdoll")) then
				return
			end

			if ((client.nutNextAct or 0) < CurTime()) then
				local class = nut.anim.getModelClass(client:GetModel())
				local info = v[class]

				if (info) then
					if (info.onCheck) then
						local result = info.onCheck(client)

						if (result) then
							return result
						end
					end

					local sequence

					local heckMate = tonumber(arguments[1])

					if (type(info.sequence) == "table") then
						sequence = table.Random(info.sequence)

						if (heckMate) then
							sequence = info.sequence[math.Clamp(heckMate, 1, #info.sequence)]
						end
					else
						sequence = info.sequence
					end

					local duration = client:forceSequence(sequence, nil, info.untimed and 0 or nil)

					if (not duration) then
						client:notifyLocalized("notValid")
					else
						client.nutSeqUntimed = info.untimed
						client.nutNextAct = CurTime() + (info.untimed and 4 or duration) + 1
						client:setNetVar("actAng", client:GetAngles())
					end
				else
					return "@modelNoSeq"
				end
			end
		end
	nut.command.add("act"..k, data)
end

local GMBASE = baseclass.Get("gamemode_base")
local GME = gmod.GetGamemode()
function GME:UpdateAnimation(client, velocity, maxseqgroundspeed)
	local angles = client:getNetVar("actAng")

	if (angles) then
		client:SetRenderAngles(angles)
		client:SetPlaybackRate(1)
	else	
		return GMBASE.UpdateAnimation(self, client, velocity, maxseqgroundspeed)
	end
end

function PLUGIN:OnPlayerLeaveSequence(client)
	client:setNetVar("actAng")
end

function PLUGIN:PlayerDeath(client)
	if (client.nutSeqUntimed) then
		client:setNetVar("actAng")
		client:leaveSequence()
		client.nutSeqUntimed = nil
	end
end

function PLUGIN:OnCharFallover(client)
	if (client.nutSeqUntimed) then
		client:setNetVar("actAng")
		client:leaveSequence()
		client.nutSeqUntimed = nil
	end
end

function PLUGIN:ShouldDrawLocalPlayer(client)
	if (client:getNetVar("actAng")) then
		return true
	end
end

local GROUND_PADDING = Vector(0, 0, 0)
local PLAYER_OFFSET = Vector(0, 0, 32)

function PLUGIN:CalcView(client, origin, angles, fov)
	if (client:getNetVar("actAng")) then
		local bone = client:LookupBone("ValveBiped.Bip01_Spine2")
		local opos = bone and client:GetBonePosition(bone) or client:GetPos() + PLAYER_OFFSET
		local view = {}
			local data = {}
				data.start = opos
				data.endpos = data.start - client:EyeAngles():Forward()*72
				data.filter = client
			view.origin = util.TraceLine(data).HitPos + GROUND_PADDING
			view.angles = client:EyeAngles()
		return view
	end
end

if (SERVER) then
	netstream.Hook("actExit", function(client)
		client:setNetVar("actAng")
		client:leaveSequence()
		client.nutSeqUntimed = nil
		client.nutNextAct = CurTime() + .1
	end)
else
	function PLUGIN:PlayerBindPress(client, bind, pressed)
		if (client:getNetVar("actAng")) then
			bind = bind:lower()

			if (bind:find("+jump") and pressed) then
				netstream.Start("actExit", client)
			
				return true
			end
		end
	end
end