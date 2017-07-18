local melody = {
	100, 125, 112, 75, 0,
	100, 112, 125, 100, 0,0
}

local melody2 = {
	100, 125, 112, 75, 0,
	100, 112, 125, 100,	0,
	
	125, 100, 112, 75, 0,
	100, 112, 125, 100, 0,0
}

local cvar = CreateClientConVar("cl_hourly_jingle", 1, true, false)

local function play_jingle(data)
	local snd
	local nextplay = RealTime()
	local prev
	hook.Add("Think","hourly_jingle",function()
		local now = RealTime()
		
		if nextplay > now then return end
		
		local k,pitch = next(data,prev)
		prev = k
		
		nextplay = now + 1/1.4
		
		if not pitch then
			snd:Stop()
			hook.Remove("Think","hourly_jingle")
			return
		elseif pitch>0 then
			if snd then snd:Stop() end
			snd = CreateSound(LocalPlayer(), "ambient/levels/canals/windchime2.wav")
			snd:PlayEx(0.5, pitch/1.2)
		end
		
	end)
	

end

--play_jingle(melody)


--- clock

local DrawText = surface.DrawText
local SetTextPos = surface.SetTextPos
local PopModelMatrix = cam.PopModelMatrix
local PushModelMatrix = cam.PushModelMatrix
local surface=surface
local LocalPlayer=LocalPlayer


local matrix = Matrix()
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)

local function TextRotated(text, x, y, xScale, yScale, angle)
	matrixAngle.y = angle
	matrix:SetAngles(matrixAngle)
	
	matrixTranslation.x = x
	matrixTranslation.y = y
	matrix:SetTranslation(matrixTranslation)
	
	matrixScale.x = xScale
	matrixScale.y = yScale
	matrix:Scale(matrixScale)
	
	SetTextPos(0, 0)
	
	PushModelMatrix(matrix)
		DrawText(text)
	PopModelMatrix()
end

local lastw=0

local font="BigHUDFont"

local exists
local function setfont()
	if not exists then
		local ok = pcall(surface.SetFont,font)
		if not ok then
			surface.CreateFont(font,{
				 font = "Tahoma",
				 size = 84,
				 weight = 500,
				 blursize = 0,
				 scanlines = 0,
				 antialias = true,
				 underline = false,
				 italic = false,
				 strikeout = false,
				 symbol = false,
				 rotary = false,
				 shadow = false,
				 additive = true,
				 outline = false
			})
		end
		exists = true
	end
	surface.SetFont(font)
end


local now=0
local ssin=function(m,s,p)
	return m*math.sin(now*s+p*math.pi)
end

local a,b,c,d={u=0,v=0},{u=0,v=0},{u=0,v=0},{u=0,v=0}
local tbl={a,b,c,d}

local hide=false

local function HUDPaint()
	local sw,sh=ScrW(),ScrH()
	
	setfont()
	local time=os.date"%H:%M:%S"
	local txt=time
	local tw,th=surface.GetTextSize(txt)
	
	local p=6
	local w,h=tw+p+p,th+p+p
	--if hide then w=-5 end
	local q=hide and 0.97 or 0.8
	lastw=lastw*q+(hide and 0 or w)*(1-q)
		
	if lastw<=1 then
		
		hook.Remove("HUDPaint","hourly_jingle")
		return
	
	end
	w=lastw
	local x,y=sw-w,0
	
	
	surface.SetTextColor(255,249,240,50)
	surface.SetDrawColor(30,30,30,200)
	surface.SetTexture(0)
	
	now=CurTime()
	
	a.x=	x-ssin(2,11,0)
	a.y=	y+p+ssin(2,10,.5)
	
	b.x=	x+w
	b.y=	y
	
	c.x=	x+w
	c.y=	y+h-p+ssin(2,-13,1)
	
	d.x=	x+p-ssin(2,-10,1)
	d.y=	y+h+ssin(2,-10,-1)
	
	surface.DrawPoly(tbl)
		
	SetTextPos(x+p,y+p)
	local sy=-ssin(2,12,0)
	TextRotated(txt,x+p,-sy+y+p,1,1,1+ssin(1,-10.5,1.1))
	TextRotated(txt,x+p+1,-sy+y+p,1,1,1+ssin(1,-10.5,1.3))
	TextRotated(txt,x+p,-sy+y+p+1,1,1,1+ssin(1,-10.5,1.2))
end


local function display_clock()
	hide=false
	timer.Simple(16,function()
		hide=true
	end)
	hook.Add("HUDPaint","hourly_jingle",HUDPaint)
end


local last_h = os.date("%H")

timer.Create("hourly_jingle", 1, 0, function()
	if not cvar:GetBool() then
		return
	end
	local h = os.date("%H")
	
	if last_h ~= h then
		last_h = h
		play_jingle(h ~= "00" and melody or melody2)
		display_clock()
	end
end)
