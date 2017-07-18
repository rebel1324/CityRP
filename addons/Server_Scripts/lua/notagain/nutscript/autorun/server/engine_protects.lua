if CLIENT then return end

if not StringTable and not stringtable then
	pcall(require, 'stringtables')
	if not StringTable and not stringtable then
		pcall(require, 'stringtable')
		if not StringTable and not stringtable then
			MsgC(Color(255, 127, 127), debug.getinfo(1).source .. " could not find stringtable binary module!\n")
		end
	end
end

local Entity = FindMetaTable("Entity")
local Player = FindMetaTable("Player")
local PhysObj = FindMetaTable("PhysObj")

do -- Find allowed models with hack module
	
	local function GetOwner(prop)
		local p = prop and ( prop.CPPIGetOwner and prop:CPPIGetOwner() or prop.Owner )
		if p then
			return tostring(p),p
		end
	end

	local mdl_whitelist={}
	
	for mdl,_ in pairs( {} ) do
		if string.find(mdl,"*",1,true) then
			mdl_whitelist[mdl] = true
		end
	end

	Entity_SetModel = Entity_SetModel or Entity.SetModel
	function Entity.SetModel(self,mdl)
		if mdl and string.find(mdl,"*",1,true) and !mdl_whitelist[mdl] then
			if !self or !Model(self:GetModel()) then
				Entity_SetModel(self,"models/props_junk/popcan01a.mdl")
			end
			local p = GetOwner( e )
			MsgN("WARNING: "..tostring(p or "Someone").." tried to set model to '*' !")
		elseif IsValid(self) then
			Entity_SetModel( self, mdl )
		else
			debug.Trace()
			print("SetModel called without self??")
		end
	end
end

local Entity_SetParent = Entity.SetParent
function Entity.SetParent(self,pt)
	if !IsValid(self) or !IsValid(pt) then Entity_SetParent(self,pt) return end
	local pr = pt
	repeat
		if pr then
			if pr == NULL then Entity_SetParent(self,pt) end
			pr = pr:GetParent()
			if pr == self then
				debug.Trace()
				print("WARNING: Prevented parent loop")
				return
			end
		end
	until !IsValid(pr)

	Entity_SetParent(self,pt)

end


local Entity_SetMoveParent = Entity.SetMoveParent
function Entity.SetMoveParent(self,pt)
	if !IsValid(self) or !IsValid(pt) then Entity_SetMoveParent(self,pt) return end
	local pr = pt
	repeat
		if pr then
			if pr == NULL then Entity_SetMoveParent(self,pt) end
			pr = pr:GetParent()
			if pr == self then
				debug.Trace()
				print("WARNING: Prevented SetMoveParent loop")
				return
			end
		end
	until !IsValid(pr)

	Entity_SetMoveParent(self,pt)

end


do -- TRAILS EXPLOIT IS NOT GONE...
    --------------------------------------
    -- Trails tend to crash people/server
    --------------------------------------
	--[[
    local util_SpriteTrail = util.SpriteTrail
    function util.SpriteTrail(e, aid,col, add, sw, ew, lt, tr, tx, ...)

		if tx and type(tx) == "string" then
			local mat = tx:lower()
			if mat:find("*",1,true) or mat:find(".vmt.vmt",1,true) or !mat:find"%.vmt$" then

				ErrorNoHalt("WARNING: Prevented trails crash")
				tx="trails/lol.vmt"
			end
			if not file.Exists("materials/"..tx,"GAME") and not  file.Exists("materials/"..mat,"GAME") then
				ErrorNoHalt("[TRAILS] Material "..tx.." missing!")
				tx="trails/lol.vmt"
			end
		else
			tx="trails/lol.vmt"
		end
		if #ents.FindByClass"env_spritetrail">25 then return NULL end
		
		return util_SpriteTrail(e, aid,col, add, sw, ew, lt, tr, tx, ...)
    end
	]]--
end


--------------------------------------
-- Vehicles are broken.
--------------------------------------
local allowed = CreateConVar("sv_vehicles_fix","1")

local disallowed = {
	"models/airboat.mdl",
	"models/buggy.mdl",
	"models/vehicle.mdl",
}

hook.Add( "PlayerSpawnVehicle", "Fuu", function(ply, model)
	if LINUX and table.HasValue(disallowed, model:lower()) and !allowed:GetBool() then
		ply:ChatPrint("Vehicles (except seats) are DISABLE DUE TO CRASHES!")
		return false
	end
end)


do  -- prevent bad modifications / Prevent removing important stuff
	local SetSolid = Entity.SetSolid
	local SetNotSolid = Entity.SetNotSolid
	local SetCollisionGroup = Entity.SetCollisionGroup
	local Remove = Entity.Remove
	local Remove_Ply = Player.Remove
	local Fire = Entity.Fire
	local Input = Entity.Input
	local world=nil
	local critical={	["player_manager"] = true,
						["sky_camera"] = true,
						["worldspawn"] = true
	}

	local function dotrace(foo,self,...)
		debug.Trace()
		local str = tostring(self)
		for i,v in ipairs({...}) do
			str = str .. ", " .. tostring(v)
		end
		ErrorNoHalt("[Engine] Prevented calling "..foo.." with parameter(s) ",str,"\n")
		return true -- ugly but cba to change
	end

	function Entity.SetSolid( e, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and dotrace("SetSolid", e, ...)) then return end
		return SetSolid( e, ... )
	end
	function Entity.SetNotSolid( e, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and dotrace("SetNotSolid", e, ...)) then return end
		return SetNotSolid( e, ... )
	end
	function Entity.SetCollisionGroup( e, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and dotrace("SetCollisionGroup", e, ...)) then return end
		return SetCollisionGroup( e, ... )
	end
	local critical={	["player_manager"] = true,
						["sky_camera"] = true,
						["worldspawn"] = true,
						["player"] = true
	}

	function Entity.Remove( e, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and dotrace("Entity.Remove", e, ...)) then return end
		return Remove( e, ... )
	end
	function Player.Remove( e, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and dotrace("Player.Remove", e, ...)) then return end
		return Remove_Ply( e, ... )
	end
	function Entity.Fire( e, input, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and isstring(input) and string.find(input:lower(),"kill") and dotrace("Entity.Fire", e, input, ...)) then return end
		return Fire( e, input, ... )
	end
	function Entity.Input( e, input, ... )
		if (e and e.IsValid and (e:IsValid() or e:IsWorld()) and critical[e:GetClass()] and isstring(input) and string.find(input:lower(),"kill") and dotrace("Entity.Input", e, input, ...)) then return end
		return Input( e, input, ... )
	end

end



do -- Prevent old jeeps and trace with missing entities...
 -- prevent too many ents

	local howmany=0

	local function recalc()
		howmany = 0
		for k,v in pairs(ents.GetAll()) do
			if v:EntIndex()>0 then
				howmany = howmany + 1
			end
		end
	end

	local IsValid = IsValid

	timer.Simple(2.1,function()
		hook.Add("OnEntityCreated","toomany",function(e)
			if IsValid(e) and e:EntIndex()>0 then
				howmany = howmany + 1
			end
		end)
		
		hook.Add("EntityRemoved","toomany",function(e)
			if IsValid(e) and e:EntIndex()>0 then
				howmany = howmany - 1
			end
		end)
		recalc()
	end)

	ents.CountEdicts=function() return howmany end

	local toomany = 8192-128

	local ents_Create=ents.Create
	function ents.Create(e,...)
		if howmany>toomany then
			recalc()
			ErrorNoHalt("MAXIMUM SAFE ENT COUNT REACHED: "..howmany..'/'..toomany.."\n")
			return NULL
		end
	
		if e=="prop_vehicle_jeep_old" then
			e="prop_vehicle_jeep"
		end
		
		local ret=ents_Create(e,...)
		if ret==NULL then
			ErrorNoHalt("Unknown entity: '"..tostring(e).."' ")
			debug.Trace()
		end
		return ret
	end
end

do -- PhysObj shit. Any other functions break?
	local valid=PhysObj.IsValid
	
	
	local _Sleep=PhysObj.Sleep
	PhysObj.Sleep=function(x)
		if valid(x) then return _Sleep(x) else error("FixME: PhysObj invalid!!!!",2) end
	end

	local _EnableMotion=PhysObj.EnableMotion
	PhysObj.EnableMotion=function(x,e)
		if valid(x) then return _EnableMotion(x,e) else error("FixME: PhysObj invalid!!!!",2) end
	end

	local PhysObj_IsMoveable=PhysObj.IsMoveable
	PhysObj.IsMoveable=function(x)
		if valid(x) then return PhysObj_IsMoveable(x) else error("FixME: PhysObj invalid!!!!",2) end
	end
	
end

-- no you don't bug yourself if you remove the jeep while exiting it
hook.Add("EntityRemoved","jeepfix",function(ent)
	if ent.IsValid and ent:IsValid() and ent:IsVehicle() then
		if IsValid(ent.GetPassenger and ent:GetPassenger(0)) then
			ent:GetPassenger(0):ExitVehicle()
		end
	end
end)

-- constraints love to crash the server with propbreak
hook.Add("PropBreak", "dontcrash", function(attacker, ent)
	if ent and ent.IsValid and ent:IsValid() then
		pcall(constraint.RemoveAll,ent)
	end
end)

do -- Weird positions if you swap vehicles on the same tick :(
	local vec=Vector(0,0,0)
	hook.Add("PlayerEnteredVehicle","vehposfix",function(pl)
		timer.Create("vehposfix"..pl:EntIndex(),0,5,function() -- 5 ticks fix...
			if pl:InVehicle() then
				local pos=pl:GetLocalPos()
				if pos.x~=0 or pos.y~=0 or pos.z~=0 then
					pl:SetLocalPos(vec)
				end
			end
		end)
	end)
end

/*
do -- CLAMPING THIS STUFF
	local nan,inf,ninf=math.huge/math.huge,math.huge,-math.huge
	local Player_GetInfoNum=Player.GetInfoNum
	Player.GetInfoNum=function(pl,what,def,...)
		local num=Player_GetInfoNum(pl,what,def,...)
		if num and not (num<inf and num>ninf) then num = def or 0 end
		return num
	end
	local Player_GetInfo=Player.GetInfo
	Player.GetInfo=function(pl,what,def,...)
		local var=Player_GetInfo(pl,what,def,...)
		num=tonumber(var)
		if num and not (num<inf and num>ninf) then return def or 0 end
		return var
	end
end
*/

do -- don't crash on too many precached models, just restart
	local timeout = 35
	local msg = "EMERGENCY RESTART: TOO MANY SPAWNED MODELS!!!\nSAVE YOUR STUFF AND HOLD ON TIGHT!"
	local safe = 8
	local maxPrecachedModels = 2048
	local safePrecachedModels = maxPrecachedModels - safe

	local function restart()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end
	
	local strtbl
	local last=0
	local coroutine=coroutine
	--[[
	local function count()
		if coroutine.running() then return last end -- crash proofing
		
		if strtbl==nil then
			strtbl=false
			if StringTable then
				strtbl = StringTable"modelprecache"
			end
		end
		
		if strtbl then last = strtbl:GetNumStrings() end
		return last
	end
	]]--
	local function panic(count)
		if count == maxPrecachedModels or coroutine.running() then -- force restart, next model would crash
			restart()
		end
		if not timer.Exists("__countdown__") and aowl and aowl.CountDown then -- restart countdown
			aowl.CountDown(timeout, msg, restart)
		end
	end

	hook.Add("OnEntityCreated", "dontCrashTooManyPrecachedModels", function()
		local count = 0--count()
		if count > safePrecachedModels then -- we are about to crash soon
			xpcall(panic,ErrorNoHalt,count)
		end
	end)
end

