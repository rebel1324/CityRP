PLUGIN.name = "3D2D Nametag"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin displays 3D2D Player information on the top of the head of the player."

if (SERVER) then return end

local ntMax = 512
local ntPos, ntView, ntAng, ntEye, ntScale = Vector(), Vector(), Angle(), Angle(), 0.05
local ntCol, ntX, ntY, ntDwt, ntAlpha
local ntShadow = Color(0, 0, 0)
local ntWhite = Color(255, 255, 255)
local ntAFK = Color(102, 102, 204)
local ntWanted = Color(222, 22, 22)
local ntGood = Color(166, 222, 166)
local ntRed = Color(255 ,0, 0)
local ntGreen = Color(100, 255, 100)
local ntLocalPlayer = LocalPlayer()
local txt = {
{75, "injured1"},
{50, "injured2"},
{25, "injured3"}}

btNameTag = {}
btNameTag.info = {
	{
		canDraw = function(client, char) return client:isLegBroken() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"legBroken", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
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
			return btNameTag:drawText(text, ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char, ntRagdoll) return client:Alive() and IsValid(ntRagdoll) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"stunned", ntX, ntY, ColorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char) return !client:Alive() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"dead", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:IsAFK() end,
		doDraw = function(client, ntX, ntY, ntCol)
			local s = btNameTag.afkPhrases[math.floor((CurTime()/4 + ply:EntIndex())%#btNameTag.afkPhrases) + 1]
			return btNameTag:drawText(s, ntX, ntY, ColorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("onHit") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onHit", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return false end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"afk", ntX, ntY, ColorAlpha(ntAFK, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("restricted") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"tied", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("hitman") == ntLocalPlayer end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"hitTarget", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("license", false) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"hasLicense", ntX, ntY, ColorAlpha(ntGood, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:getNetVar("searchWarrant", false) end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onWarrant", ntX, ntY, ColorAlpha(ntGood, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client, char) return char:getData("wanted") end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"onWanted", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
		end,
	},
	{
		canDraw = function(client) return client:isArrested() end,
		doDraw = function(client, ntX, ntY, ntCol)
			return btNameTag:drawText(L"arrested", ntX, ntY, ColorAlpha(ntWanted, ntCol.a), 1)
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
				blursize 	= 10,
				extended = true,
			}
		)
	end
end)

function btNameTag:getHead(entity)
	local pos
	local bone = entity:GetAttachment(entity:LookupAttachment("eyes"))
	pos = bone and bone.Pos
	
	if not pos then
		local bone = entity:LookupBone("ValveBiped.Bip01_Head1")
		
		pos = bone and entity:GetBonePosition(bone) or entity:EyePos()
	end
	
	return pos
end

function btNameTag:drawText(text, x, y, tCol, a)
	draw.SimpleText(text, btNameTag.font[2 + 2*(a or 0)], x, y, ColorAlpha(ntShadow, tCol.a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(text, btNameTag.font[1 + 2*(a or 0)], x, y, tCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("PostPlayerDraw", "btNameTag", function(client)
	hook.Run("DrawNameTag", client)
end)

hook.Add("DrawPlayerRagdoll", "btNameTag", function(client)
	hook.Run("DrawNameTag", client)
end)

local ntChar, ntClass, ntClassInfo, ntRagdoll
hook.Add("DrawNameTag", "btNameTag", function(client)
	if (SURPRESS_FROM_STENCIL) then return end
	if (client:GetNoDraw() != true) then
		ntPos = btNameTag:getHead(client)
		ntX, ntY = 0, 0
		
		ntEye = EyeAngles()
		ntAng.p = ntEye.p
		ntAng.y = ntEye.y
		ntAng.r = ntEye.r
		ntAng:RotateAroundAxis(ntAng:Up(), -90)
		ntAng:RotateAroundAxis(ntAng:Forward(), 90)
		ntView = EyePos()
		ntPos = ntPos + Vector(0, 0, 10)
		ntX, ntY = 0, 0
		ntDist = math.Clamp(ntView:Distance(ntPos) / ntMax, 0.25, 1)

		if (ntDist >= 1) then return end

		if (IsValid(client.objCache)) then
			ntRagdoll = client
			client = client.objCache
		else
			if (!client:IsPlayer()) then
				return
			end
		end
		
		ntChar = client:getChar()
		if (ntChar or client:IsBot()) then
			cam.Start3D2D(ntPos, ntAng, ntScale)
				xpcall(function()
				ntCol = Color(255, 255, 255)

				ntAlpha = 255*(1 - ntDist)
				
				ntClass = ntChar:getClass()
				if (ntChar:getDesc() and ntChar:getDesc() != "") then
					btNameTag:drawText(ntChar:getDesc(), ntX, ntY, ColorAlpha(ntGreen, ntAlpha), 1)
					ntY = ntY - 60
				end

				if (ntClass or client:IsBot()) then
					if (client:IsBot()) then
						btNameTag:drawText(client:Name(), ntX, ntY, ColorAlpha(nut.config.get("color"), ntAlpha))
						ntY = ntY - 80
					else
						ntClassInfo = nut.class.list[ntClass]

						if (ntClassInfo) then
							btNameTag:drawText(L(ntClassInfo.name), ntX, ntY, ColorAlpha(ntCol, ntAlpha), 1)
							ntY = ntY - 75
						end

						btNameTag:drawText(client:Name(), ntX, ntY, ColorAlpha(ntClassInfo.color or nut.config.get("color"), ntAlpha))
						ntY = ntY - 80
					end
				end

				for _, info in ipairs(btNameTag.info) do
					if (info.canDraw(client, ntChar, ntRagdoll)) then
						info.doDraw(client, ntX, ntY, ColorAlpha(ntCol, ntAlpha))
						ntY = ntY -  60
					end
				end
				end, function() end)
			cam.End3D2D()
		end
		
		ntChar = nil
		ntClass = nil
		ntClassInfo = nil
		ntRagdoll = nil
	end
end)
