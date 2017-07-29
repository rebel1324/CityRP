local function GetSource()
    return debug.getinfo(1).short_src:gsub("\\", "/")
end

--function Path()
--    return ({GetSource()})[1] -- select(i, ...) doesn't work here for some reason ???
--end
--This breaks the god damn Nextbot stuff

function Folder()
    return GetSource():GetPathFromFilename()
end

function FileName() -- or Filename?
    return GetSource():GetFileFromFilename():Left(-1)
end

function AddToResource()
	AddCSLuaFile(Path())
end



function Permutate(x)
	if type(x) == "string" then
		local input = {x:byte(1, -1)}
		local output = {}
		while #input > 0 do table.insert(output, table.remove(input, math.random(#input))) end
		return string.char(unpack(output))
	elseif type(x) == "table" then
		local input, output = {}, {}
		for k, v in ipairs(x) do input[k] = v end
		while #input > 0 do table.insert(output, table.remove(input, math.random(#input))) end
		return output
	end
end

EMPTY_FUNC = function() end
SHARED = true -- hmmmm

QUOTE = [["]]
SINGLE_QUOTE = [[']]

CVAR_PREFIX = CLIENT and "cl_" or SERVER and "sv_" or ""

local _E=_E
if not _E then
 _E=_G
end

_E.BONE_PELVIS = "ValveBiped.Bip01_Pelvis"
_E.BONE_SPINE0 = "ValveBiped.Bip01_Spine"
_E.BONE_SPINE1 = "ValveBiped.Bip01_Spine1"
_E.BONE_SPINE2 = "ValveBiped.Bip01_Spine2"
_E.BONE_SPINE3 = "ValveBiped.Bip01_Spine3"
_E.BONE_SPINE4 = "ValveBiped.Bip01_Spine4"
_E.BONE_NECK = "ValveBiped.Bip01_Neck1"
_E.BONE_HEAD = "ValveBiped.Bip01_Head1"
_E.BONE_RIGHT_CLAVICLE = "ValveBiped.Bip01_R_Clavicle"
_E.BONE_RIGHT_UPPERARM = "ValveBiped.Bip01_R_UpperArm"
_E.BONE_RIGHT_FOREARM = "ValveBiped.Bip01_R_Forearm"
_E.BONE_RIGHT_HAND = "ValveBiped.Bip01_R_Hand"
_E.BONE_LEFT_CLAVICLE = "ValveBiped.Bip01_L_Clavicle"
_E.BONE_LEFT_UPPERARM = "ValveBiped.Bip01_L_UpperArm"
_E.BONE_LEFT_FOREARM = "ValveBiped.Bip01_L_Forearm"
_E.BONE_LEFT_HAND = "ValveBiped.Bip01_L_Hand"
_E.BONE_RIGHT_THIGH = "ValveBiped.Bip01_R_Thigh"
_E.BONE_RIGHT_CALF = "ValveBiped.Bip01_R_Calf"
_E.BONE_RIGHT_FOOT = "ValveBiped.Bip01_R_Foot"
_E.BONE_RIGHT_TOE = "ValveBiped.Bip01_R_Toe0"
_E.BONE_LEFT_THIGH = "ValveBiped.Bip01_L_Thigh"
_E.BONE_LEFT_CALF = "ValveBiped.Bip01_L_Calf"
_E.BONE_LEFT_FOOT = "ValveBiped.Bip01_L_Foot"
_E.BONE_LEFT_TOE = "ValveBiped.Bip01_L_Toe0"



function Say(...)
    local first=true
    local msg=""
    for _,val in pairs{...} do
      if first then
           first = false
       else
           msg=msg..' '
       end
       msg=msg..tostring(val)
    end
    msg = msg:gsub("\n",""):gsub(";",":"):gsub("\"","'")
    if SERVER then
        game.ConsoleCommand("say "..msg.."\n")
    elseif chatbox and chatbox.SendChatMessage then
        chatbox.SendChatMessage(msg)
    else
        RunConsoleCommand("say",msg)
    end
end



local XID=0
local Now=SysTime
function CalculateFPS(callback,sampletime,nonimmediate)
	local hadfocus=system.HasFocus()
	sampletime=sampletime or 4
	callback=callback or function(fps)
		LocalPlayer():ConCommand("say FPS: "..math.Round(fps).." "..((not hadfocus or not system.HasFocus()) and "(No focus)" or ""),not nonimmediate)
	end
	local frames=0
	local a=Now()
	hook.Add('RenderScene',callback,function()
		frames=frames+1
		local b=Now()
		if b-a>sampletime then
			hook.Remove('RenderScene',callback)
			local fps=frames/sampletime
			callback(fps)
		end
	end)

end


local meta = FindMetaTable("Player")

function meta:IP()
	local ip=self:IPAddress()
	ip=ip:sub(1,ip:find(':',1,true)-1)
	return ip
end
