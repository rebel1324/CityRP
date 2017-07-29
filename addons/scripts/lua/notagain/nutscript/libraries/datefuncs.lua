if SERVER then  AddCSLuaFile"datefuncs.lua" end
local dd=60*60*24
local hh=60*60
local mm=60

local function datetable(a)
	local negative=false
    if a<0 then negative=true a=a*-1 end
	local f,s,m,h,d
    f=a - math.floor(a)
	f=math.Round(f*10)*0.1
    a=math.floor(a)
    d=math.floor(a/dd)
    a=a-d*dd
    h=math.floor(a/hh)
    a=a-h*hh
    m=math.floor(a/mm)
    a=a-m*mm
    s=a
    return {
		f=f,
		s=s,
		m=m,
		h=h,
		d=d,
		n=negative
	}
end
local prettydate do
	local conjunction=  " and"
	local conjunction2= ","
	prettydate = function(t)
		if type(t)=="number" then
			t=datetable(t)
		end

		local tbl={}
		if t.d~=0 then
			table.insert(tbl,t.d .." 일")
		end

		local lastand
		if t.h~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.h .." 시간")
		end
		if t.m~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.m .." 분")
		end
		if t.s~=0 or #tbl==0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.s .."."..math.Round(t.f*10).." 초")
		end
		if t.n then
			table.insert(tbl," 과거")
		end
		for k,v in pairs(tbl) do
			if v==conjunction and k~=lastand then
				tbl[k]=conjunction2
			end
		end

		return table. concat ( tbl , "" )

	end
end
_G.os.datetable=datetable
_G.os.prettydate=prettydate
