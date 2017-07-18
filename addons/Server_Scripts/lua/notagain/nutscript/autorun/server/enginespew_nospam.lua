require'enginespew'

local err="DataTable warning: "
local len=err:len()

local err2="Bad pstudiohdr"
local len2=err2:len()

--local err3="do_constraint_system:"
--local len3=err3:len()

local err4 = "Error Vertex File"
local len4=err4:len()

local err5="CSceneEntity"
local len5=err5:len()

local sub=string.sub
local find=string.find
local inspew=false
hook.Add("EngineSpew", "PreventSpam", function(_, msg)
	if inspew then return end inspew=true
	
	if
	   sub(msg,1,len) == err
	or sub(msg,1,len2) == err2
	--or sub(msg,1,len3) == err3 -- USES printf, can't be removed.
	or sub(msg,1,len4) == err4
	--or sub(msg,1,len5) == err5
	or find(msg,[[ENTITY_CHANGE_NONE]],10,true)
	or find(msg,[[Couldn't find scene]],1,true)
		then
			inspew=false
			return false
		end
		
	inspew=false
end)