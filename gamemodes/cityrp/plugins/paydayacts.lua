PLUGIN.name = "Payday Action Bars"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Payday like action bars (requires contents)."

local function DrawPercRect(x, y, w, h, perc, sten)
	local d
	local rx, ry
	local px, py
	
	if (sten) then
		w, h = w*2, h*2
		d = w/2
	else
		d = math.sqrt(w^2 + h^2)/2
	end

	px, py = math.sin(perc*math.pi*2), -math.cos(perc*math.pi*2)
	rx, ry = math.Clamp(x + px*d, x - w/2, x + w/2), math.Clamp(y + py*d, y - h/2, y + h/2)

	if (perc < .25) then
		triangle = {
			{ x = rx , y = ry },
			{ x = x + w/2, y = y - h/2 },
			{ x = x + w/2, y = y + 0 },
			{ x = x , y = y + 0 },
		}
		surface.DrawPoly( triangle )
	end
	
	if (perc < .5) then
		triangle = {
			{ x = x , y = y - 0 },
			{ x = x + w/2, y = y - 0 },
			{ x = x + w/2, y = y + h/2 },
			{ x = x , y = y + h/2 },
		}
		if (perc > .25) then
			triangle[2] = { x = rx , y = ry }
			if (perc > (.25 + .25/2)) then
				triangle[3] = { x = rx , y = ry }
			end
		end
		surface.DrawPoly( triangle)
	end

	if (perc < .75) then
		triangle = {
			{ x = x - w/2, y = y - 0 },
			{ x = x + 0, y = y - 0 },
			{ x = x + 0, y = y + h/2 },
			{ x = x - w/2, y = y + h/2 },
		}
		if (perc > .5) then
			triangle[3] = { x = rx , y = ry }
		end
		surface.DrawPoly( triangle )
	end

	triangle = {
		{ x = x - w/2, y = y - h/2 },
		{ x = x + 0, y = y - h/2 },
		{ x = x + 0, y = y + 0 },
		{ x = x - w/2, y = y + 0 },
	}
	if (perc > .75) then
		triangle[4] = { x = rx , y = ry }
		if (perc > (.75 + .25/2)) then
			triangle[1] = { x = rx , y = ry }
		end
	end
	surface.DrawPoly( triangle )
end

local mat = Material("ring_paydaya.png")
local function drawRingCunt(x, y, w, h, perc, color, cirMat)
	render.ClearStencil()
	render.SetStencilEnable(true)
		render.SetStencilWriteMask(255)
		render.SetStencilTestMask(255)
		render.SetStencilReferenceValue(1)
		render.SetStencilFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
		render.SetBlend(0) --don't visually draw, just stencil
		
		surface.SetDrawColor( 0, 0, 0, 1 )
		draw.NoTexture()
		DrawPercRect(x, y, w, h, perc, true)

		render.SetBlend(1)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	
	surface.SetDrawColor(color.r, color.g, color.b, color.a)
	cirMat = cirMat or mat
	surface.SetMaterial(cirMat)
	surface.DrawTexturedRect(x - w/2, y - h/2, w, h)
	render.SetStencilEnable(false)
end

function PLUGIN:LoadFonts(font, genericFont)
	surface.CreateFont(
		"puff",
		{
			font 		= "HalfLife2",
			size 		= ScreenScale(17),
			weight 		= 500,
		}
	)

	surface.CreateFont(
		"puff2",
		{
			font 		= font,
			size 		= ScreenScale(8),
			extended    = true,
			weight 		= 500,
		}
	)
end

local alpha = 0
local totalTime = 0
local actionTime = RealTime()
local donePerc = 1
local yesusText = ""
local DONTACDUM = false

netstream.Hook("actBar", function(start, finish, text)
	if (!text) then
		DONTACDUM = false
		donePerc = 1
		alpha = 0
		totalTime = 0
		actionTime = RealTime()
		yesusText = ""
	else
		DONTACDUM = true
		alpha = 255
		totalTime = finish - start
		actionTime = RealTime() + totalTime
		donePerc = 0
		
		if (text:sub(1, 1) == "@") then
			text = L2(text:sub(2)) or text
		end

		yesusText = text:upper()
	end
end)

function PLUGIN:ShouldDrawCrosshair()
	if (DONTACDUM) then
        return false
    end
end

function PLUGIN:HUDPaint()
	local x, y, w, h = ScrW()/2, ScrH()/2, 170, 170

	if (DONTACDUM) then
		local perc = math.min(1, 1 - ((actionTime - RealTime()) / totalTime))
		if (perc == 1) then
			donePerc = Lerp(FrameTime()*10, donePerc, 1)

			if (donePerc>=0.99) then
				DONTACDUM = false
			end
		end
		local colo = ColorAlpha(color_white, 255 - 280*donePerc)

		drawRingCunt(x, y, w + w*.15*donePerc, h + h*.15*donePerc, 1 -perc, colo)

		nut.util.drawText(Format("%.1f", (1 - perc)*totalTime), x, y, colo, 1, 1, "puff")
		nut.util.drawText(yesusText, x, y + h*.75, colo, 1, 1, "puff2")
	end
end