local Tag="afkui"

local outafk,inafk
local fadeoutlen=3
local Now=RealTime --  function() return RealTime()*3600 end




local DrawText = surface.DrawText
local SetTextPos = surface.SetTextPos
local PopModelMatrix = cam.PopModelMatrix
local PushModelMatrix = cam.PushModelMatrix
local surface=surface
local LocalPlayer=LocalPlayer
local cl_afkui = CreateClientConVar("cl_afkui","1",true,false)
local matrix = Matrix()
local matrixAngle = Angle(0, 0, 0)
local matrixScale = Vector(0, 0, 0)
local matrixTranslation = Vector(0, 0, 0)
local last
local function HUDPaint()
	local sw,sh = ScrW(),ScrH()
	local bw,bh=500,200
	
	local now = Now()
	local len = LocalPlayer():AFKTime()

	local frac = len/0.5
	frac=frac>1 and 1 or frac<0 and 0 or frac
	
	if outafk then
		frac=frac+5-(now-outafk)*2
		frac=frac>1 and 1 or frac<0 and 0 or frac
	end
	
	local h = math.floor(len/60/60)
	local m = math.floor(len/60-h*60)
	local s = math.floor(len-m*60-h*60*60)
	
	surface.SetFont"closecaption_bold"
	surface.SetTextColor(255,255,255,frac*255)
	surface.SetDrawColor(255,255,255,frac*255)
	
	local txt = outafk and last or string.format("AFK %.2d:%.2d:%.2d",h,m,s)
	last=txt
	
	local tw,th = surface.GetTextSize(txt)
	surface.SetTextPos(0,0)
	local scl = ScreenScale(0.9)
	
	local matrix = Matrix()
	
	matrixTranslation.x = sw*0.5-tw*scl*0.5
	matrixTranslation.y = sh*0.1--th*scl*0.5
	matrix:SetTranslation(matrixTranslation)
	
	matrixScale.x = scl
	matrixScale.y = scl
	matrix:Scale(matrixScale)
	
	
	PushModelMatrix(matrix)
	surface.SetTextPos(1,1)
	surface.SetTextColor(30,30,30,frac*100)
		DrawText(txt)
	if outafk then
		surface.SetTextColor(236,253,154,frac*200)
	else
		surface.SetTextColor(244,254,255,frac*200)
	end
	
	surface.SetTextPos(0,0)
		DrawText(txt)
	PopModelMatrix()
	
	if outafk and now-outafk>fadeoutlen then
		hook.Remove("HUDPaint",Tag)
	end
end

local function afkage(afk)
	if afk then
		if not cl_afkui:GetBool() then return end
		inafk=Now()
		outafk = false
		hook.Add("HUDPaint",Tag,HUDPaint)
		
	else
		outafk=Now()
	end
end

hook.Add('AFK',Tag,function(pl,afk,id,len)
	
	if pl~=LocalPlayer() then return end
	
	afkage(afk)

end)
