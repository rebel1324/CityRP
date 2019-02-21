local PLUGIN = {}
PLUGIN.name = "3D2D Nametag"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin displays 3D2D Player information on the top of the head of the player."

if (SERVER) then return end

local lerp = Lerp
local surface = surface
local frameTime = FrameTime
local colorAlpha = ColorAlpha
local cam = cam
local util = util
local draw = draw

local ntMax = 512
local ntPos, ntView, ntAng, ntEye, ntScale = Vector(), Vector(), Angle(), Angle(), 0.05
local ntCol, ntX, ntY, ntDwt
local ntShadow = Color(0, 0, 0)
local ntWhite = Color(255, 255, 255)
local ntAFK = Color(102, 102, 204)
local ntWanted = Color(222, 22, 22)
local ntGood = Color(166, 222, 166)
local ntRed = Color(255 ,0, 0)
local ntGreen = Color(100, 255, 100)
local ntOrg = Color(52, 152, 219)
local ntLocalPlayer = LocalPlayer()
local txt = {
{75, "injured1"},
{50, "injured2"},
{25, "injured3"}}

btNameTag = {}
btNameTag.info = {
	{
		canDraw = function(client, char) return (ORGANIZATION_ENABLED and char:getOrganizationInfo()) and true or false end,
		doDraw = function(client, ntX, ntY, ntCol)
			local char = client:getChar()
			local info = char:getOrganizationInfo()
			local colData = info:getData("nameCol", ntOrg)

			return btNameTag:drawText(info:getName(), ntX, ntY, colorAlpha(colData, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char) return client:isLegBroken() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"legBroken", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char, ntRagdoll) return client:Alive() and client:Health() < 75 end,
		doDraw = function(client, ntX, ntY, ntCol)
			local text
			for _, b in pairs(txt) do
				if (b[1] > client:Health()) then
					text = L(b[2])
				end
			end
			return btNameTag:drawText(text, ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char, ntRagdoll) return client:Alive() and IsValid(ntRagdoll) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"stunned", ntX, ntY, colorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char) return !client:Alive() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"dead", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:IsAFK() end,
		doDraw = function(client, ntX, ntY, ntCol)
			local s = btNameTag.afkPhrases[math.floor((CurTime()/4 + client:EntIndex())%#btNameTag.afkPhrases) + 1]
			return btNameTag:drawText(s, ntX, ntY, colorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("onHit") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onHit", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return false end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"afk", ntX, ntY, colorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("restricted") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"tied", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("hitman") == ntLocalPlayer end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"hitTarget", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("license", false) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"hasLicense", ntX, ntY, colorAlpha(ntGood, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client.isBanned and client:isBanned() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"hasBanni", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("searchWarrant", false) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onWarrant", ntX, ntY, colorAlpha(ntGood, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char) return char:getData("wanted") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onWanted", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:isArrested() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"arrested", ntX, ntY, colorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
}

btNameTag.font = {"btNameTag_font", "btNameTag_blur", "btNameTag_small", "btNameTag_ssmall"}
btNameTag.afkPhrases = {
	"AFK",
}

hook.Add("LoadFonts", "nutFontNametag", function(font, genericFont)
	for i = 0, 1 do
		surface.CreateFont(
			btNameTag.font[1 + 2 * i],
			{
				font 		= font,
				size 		= 100 - 40*i,
				weight 		= 800,
				antialias 	= true,
				additive 	= false,
				extended = true,
			}
		)
		surface.CreateFont(
			btNameTag.font[2 + 2 * i],
			{
				font 		= font,
				size 		= 100 - 40*i,
				weight 		= 800,
				antialias 	= true,
				additive 	= false,
				blursize 	= 2,
				extended = true,
			}
		)
	end
end)

local offset = Vector(0, 0, 16)
function btNameTag:getHead(entity)
	local pos
	local bone = entity:GetAttachment(entity:LookupAttachment("eyes"))
	pos = bone and bone.Pos
	
	if not pos then
		local bone = entity:LookupBone("ValveBiped.Bip01_Head1")
		
		pos = bone and entity:GetBonePosition(bone) + offset or entity:EyePos() + offset
	end
	
	return pos + offset
end


local ntChar, ntClass, ntClassInfo, ntRagdoll

local lastCall = FrameNumber()
local lastCallPlayer
local originMatrix = Matrix()
local hullSize = 3
local maxVector = Vector(1, 1, 1) * hullSize
local minVector = maxVector * -hullSize
local detectRange = 512
local targetEntity
timer.Create('btNameTagFinder', .3, 0, function()
    local localPlayer = LocalPlayer()
	if (IsValid(localPlayer)) then
		local data = {}
			data.start = localPlayer:GetShootPos()
			data.endpos = data.start + localPlayer:GetAimVector()*detectRange
			data.filter = localPlayer
			data.mins = minVector
			data.maxs = maxVector
			data.mask = MASK_SHOT
		local trace = util.TraceHull(data)

		targetEntity = trace.Entity

		if (IsValid(targetEntity) and not targetEntity:IsPlayer()) then
			local data = {}
				data.start = localPlayer:GetShootPos()
				data.endpos = data.start + localPlayer:GetAimVector()*detectRange
				data.filter = localPlayer
				data.mask = MASK_SHOT
			local trace = util.TraceLine(data)
			
			if (trace.Entity:IsPlayer()) then
				targetEntity = trace.Entity
			end
		end
    end
end)

local popFraction = 0
local popSpeed = .3
local lastEntity

function btNameTag:drawText(text, x, y, tCol, a)
	draw.SimpleText(text, btNameTag.font[2 + 2*(a or 0)], x, y, colorAlpha(ntShadow, math.min(tCol.a * 2, 255)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, btNameTag.font[1 + 2*(a or 0)], x - 1, y - 1, tCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function lookAtMeAngle(entityA, entityB)
    local ang = entityB:GetPos() - entityA:GetPos()
    ang:Normalize()
    ang = ang:Angle()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    return ang
end

hook.Add("PostDrawTranslucentRenderables", "btNameTag", function(client)
    local localPlayer = LocalPlayer()
	local client = targetEntity

	if (IsValid(client) and client:GetNoDraw() != true and client:IsPlayer()) then
        if (lastEntity != client) then
            popFraction = 0
            lastEntity = client
        end

        popFraction = lerp(frameTime() * popSpeed, popFraction, 1)
        local viewScale = nut.ease.easeOutElastic(popFraction, 1, 0, 1) * .1

		ntPos = btNameTag:getHead(client)
		ntChar = client:getChar()
		if (ntChar or client:IsBot()) then
			cam.Start3D2D(ntPos, lookAtMeAngle(localPlayer, client), viewScale)
				xpcall(function()
				    local ntX, ntY = 0, 0
					ntCol = color_white
					ntClass = ntChar:getClass()

					local description = ntChar:getDesc()
					if (description and description != "") then
						if (!client.oldDesc or client.oldDesc != description) then
							local preCalcFont = btNameTag.font[2 + 2*(1 or 0)]
							client.oldDescObject = nut.util.wrapText(description, 900, preCalcFont)
							client.oldDesc = description
						end
						
						for i = 1, #client.oldDescObject do
							btNameTag:drawText(client.oldDescObject[#client.oldDescObject - i + 1], ntX, ntY, colorAlpha(ntGreen, 255), 1)
							ntY = ntY - 60
						end
					end
					
					local name = hook.Run("ShouldAllowScoreboardOverride", client, "name") and hook.Run("GetDisplayedName", client) or client:Nick()
					if (ntClass or client:IsBot()) then
						if (client:IsBot()) then
							btNameTag:drawText(name, ntX, ntY, colorAlpha(nut.config.get("color"), 255))
							ntY = ntY - 80
						else
							ntClassInfo = nut.class.list[ntClass]
							if (ntClassInfo) then
								btNameTag:drawText(L(ntClassInfo.name), ntX, ntY, colorAlpha(ntCol, 255), 1)
								ntY = ntY - 75
							end
			
							btNameTag:drawText(name, ntX, ntY, colorAlpha(ntClassInfo.color or nut.config.get("color"), 255))
							ntY = ntY - 80
						end
					else
						ntY = ntY - 25
						btNameTag:drawText(name, ntX, ntY, colorAlpha(nut.config.get("color"), 255))
					end
					
					for _, info in ipairs(btNameTag.info) do
						if (info.canDraw(client, ntChar, ntRagdoll)) then
							info.doDraw(client, ntX, ntY, colorAlpha(ntCol, 255))
							ntY = ntY -  60
						end
					end
				end, function(...) print(...) end)
			cam.End3D2D()
		end
		
		ntChar = nil
		ntClass = nil
		ntClassInfo = nil
		ntRagdoll = nil		
        lastEntity = client
    else
        popFraction = 0
	end
end)