local Tag = 'death_effects'

local cl_death_effects = CreateClientConVar("cl_death_effects", "1", true, false)

local matBlurScreen = Material( "pp/blurscreen" )

local starttime = 0
local stoptime = 2

local function HUDPaintBackground(   )

    local frac = (RealTime() - starttime) * (1/0.6) -- start
	frac=frac>1 and 1 or frac<0 and 0 or frac
	frac=math.sin(frac*math.pi*0.5)
	
	
	local f2 = (RealTime() - stoptime) * (1/2) -- end
	
	local sw,sh = ScrW(), ScrH()
	
	f2=f2>1 and 1 or f2<0 and 0 or f2
	frac=frac-f2
	frac=frac>1 and 1 or frac<0 and 0 or frac
	
	if f2==1 then
		hook.Remove("HUDPaintBackground",Tag,HUDPaintBackground)
		--	print"remove"
	end
    surface.SetMaterial( matBlurScreen )
    surface.SetDrawColor( 255, 255, 255, frac*255 )

    for i=0.33, 1, 0.33 do
        matBlurScreen:SetFloat( "$blur", frac * 5 * i )
        matBlurScreen:Recompute()
        if ( render ) then render.UpdateScreenEffectTexture() end
        surface.DrawTexturedRect( 0,0, sw, sh )
    end
    surface.SetDrawColor(150,10,10,frac*55)
    surface.DrawRect(0,0,sw,sh)
end


local lded = false
local snd
local me

hook.Add("Think",Tag,function()
	
	if not cl_death_effects:GetBool() then return end
	
	if not me then
		me=LocalPlayer()
		if not IsValid(me) then
			me=nil
			return
		end
	end
	
	local ded = me:Health() <= 0
	if ded~=lded then
		lded = dedu
		if ded then
			if snd then return end
			
			hook.Add("HUDPaintBackground",Tag,HUDPaintBackground)
			starttime = RealTime()
			stoptime = starttime+2.4
			
			snd = CreateSound(LocalPlayer(),'player/heartbeat1.wav')
			if snd then
				snd:PlayEx(1,100)
				snd:FadeOut(7)
			end
			--LocalPlayer():SetDSP( 33, false )
		elseif snd then
			snd:FadeOut(1)
			snd = nil
		end
	end
end)