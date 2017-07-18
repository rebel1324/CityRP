local Entity = FindMetaTable("Entity")
local PhysObj = FindMetaTable("PhysObj")


local function vector_safety(vec)
	vec.x=1
	vec.y=2
	vec.z=3
end

local function vector_clamp(vec,len)
	local x = vec.x
	local y = vec.y
	local z = vec.z
	
	local nlen=-len
	
	vec.x=x>len and len or x<nlen and nlen or x~=x and 0 or z
	vec.y=y>len and len or y<nlen and nlen or y~=y and 0 or y
	vec.z=z>len and len or z<nlen and nlen or z~=z and 0 or z
end


local MAP_DIMENSION = 65536
local MAX_SAFE_LEN = math.ceil( math.sqrt( (MAP_DIMENSION^2)*3 ) )
local PhysObj_SetPos=PhysObj.SetPos
function PhysObj:SetPos(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_safety(vec)
	end
	return PhysObj_SetPos(self, vec)
end

local Entity_SetPos=Entity.SetPos
function Entity:SetPos(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		ErrorNoHalt("Invalid SetPos on "..tostring(self)..": "..tostring(vec)..'\n')
		vector_safety(vec)
	end
	return Entity_SetPos(self, vec)
end

-- 2^27 loses precision
local MAX_SAFE_LEN = 9007199254740992
--2^46+2^44+2^43+2^41

local PhysObj_ApplyForceCenter=PhysObj.ApplyForceCenter
function PhysObj:ApplyForceCenter(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	return PhysObj_ApplyForceCenter(self, vec)
end

local PhysObj_ApplyForceOffset=PhysObj.ApplyForceOffset
function PhysObj:ApplyForceOffset(vec,vec2)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	
	len = vec2:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec2,MAX_SAFE_LEN)
	end
	return PhysObj_ApplyForceOffset(self, vec, vec2)
end



local PhysObj_AddVelocity=PhysObj.AddVelocity
function PhysObj:AddVelocity(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	return PhysObj_AddVelocity(self, vec)
end



local PhysObj_AddAngleVelocity=PhysObj.AddAngleVelocity
function PhysObj:AddAngleVelocity(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	return PhysObj_AddAngleVelocity(self, vec)
end

	
local PhysObj_SetVelocity=PhysObj.SetVelocity
function PhysObj:SetVelocity(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	return PhysObj_SetVelocity(self, vec)
end

local PhysObj_SetVelocityInstantaneous=PhysObj.SetVelocityInstantaneous
function PhysObj:SetVelocityInstantaneous(vec)
	local len = vec:Length() 
	if len>MAX_SAFE_LEN or len~=len then
		vector_clamp(vec,MAX_SAFE_LEN)
	end
	return PhysObj_SetVelocityInstantaneous(self, vec)
end
	
local MAX_MASS = 99999
local MIN_MASS = 0.001
local PhysObj_SetMass=PhysObj.SetMass
function PhysObj:SetMass(mass)
	
	if not self:IsValid() then error"invalid entity" end
	
	if !tobool(self:GetEntity():GetClass():find("acf")) and (mass>MAX_MASS or mass~=mass) then
		print("Clamping big mass:",mass,"on",self:GetEntity())
		mass = MAX_MASS
	elseif mass<=1000 then
		local ent = self:GetEntity()
		if ent:IsVehicle() then
			local class = ent:GetClass()
			if class:find("jeep",1,true) then
				mass = mass<1000 and 1000 or mass>5000 and 5000 or mass
			elseif class:find("airboat",1,true) then
				mass = mass<400 and 400 or mass>5000 and 5000 or mass
			elseif mass<MIN_MASS then
				mass = MIN_MASS
			end
		elseif mass<MIN_MASS then
			mass = MIN_MASS
		end
	end
	return PhysObj_SetMass(self, mass)
end
	

local PhysObj_SetAngles=PhysObj.SetAngles
function PhysObj:SetAngles(ang)
	ang:Normalize() -- makes any infinite/nan angle a nan
	local p,y,r = ang.p,ang.y,ang.r
	if p~=p then error"BAD ANGLE P" end
	if y~=y then error"BAD ANGLE Y" end
	if r~=r then error"BAD ANGLE R" end
	
	return PhysObj_SetAngles(self, ang)
end

local Entity_SetAngles=Entity.SetAngles
function Entity:SetAngles(ang)
	ang:Normalize() -- makes any infinite/nan angle a nan
	local p,y,r = ang.p,ang.y,ang.r
	if p~=p then error"BAD ANGLE P" end
	if y~=y then error"BAD ANGLE Y" end
	if r~=r then error"BAD ANGLE R" end
	
	return Entity_SetAngles(self, ang)
end



local PhysObj_AlignAngles=PhysObj.AlignAngles
function PhysObj:AlignAngles(ang,ang2)
	ang:Normalize() -- makes any infinite/nan angle a nan
	local p,y,r = ang.p,ang.y,ang.r
	if p~=p then error"BAD ANGLE P" end
	if y~=y then error"BAD ANGLE Y" end
	if r~=r then error"BAD ANGLE R" end
	
	ang2:Normalize() -- makes any infinite/nan angle a nan
	p,y,r = ang2.p,ang2.y,ang2.r
	if p~=p then error"BAD ANGLE P" end
	if y~=y then error"BAD ANGLE Y" end
	if r~=r then error"BAD ANGLE R" end
	
	
	return PhysObj_AlignAngles(self, ang, ang2)
end

local PhysObj_RotateAroundAxis=PhysObj.RotateAroundAxis
function PhysObj:RotateAroundAxis(vec,ang)
	ang=math.fmod(ang,360)
	if ang~=ang then error"BAD ROT ANGLE" end
	vec = not isvector(vec) and Vector(0,0,0) or vec
	local len = vec:Length() 
	if len>99999999999 or len~=len then
		error"invalid normal vector"
	end
	return PhysObj_RotateAroundAxis(self, vec, ang)
end

