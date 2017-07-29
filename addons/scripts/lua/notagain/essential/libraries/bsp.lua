-- this was taken from
-- http://steamcommunity.com/sharedfiles/filedetails/?id=160087429
-- which was made by Silverlan
-- http://steamcommunity.com/profiles/76561197967919092

local SIZEOF_INT = 4
local SIZEOF_SHORT = 2
local function toUShort(b)
	local i = {string.byte(b,1,SIZEOF_SHORT)}
	return i[1] +i[2] *256
end
local function toInt(b)
	local i = {string.byte(b,1,SIZEOF_INT)}
	i = i[1] +i[2] *256 +i[3] *65536 +i[4] *16777216
	if(i > 2147483647) then return i -4294967296 end
	return i
end
local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end
local function ReadShort(f)
	local b1 = f:ReadByte()
	local b2 = f:ReadByte()
	return bit.lshift(b2,8) +b1
end

local function ReadNullTerminatedString(f,max)
	local t = ""
	local l
	for i = 1,max do
		local c = f:Read(1)
		t = t .. c
		if(c == "\0") then
			l = i
			break
		end
	end
	return t,l
end

local HEADER_LUMPS = 64
local SIZE_LUMP_PLANE = 20
local SIZE_LUMP_BRUSH = 12
local SIZE_LUMP_BRUSHSIDE = 8
local SIZE_LUMP_TEXINFO = 72
local SIZE_LUMP_TEXDATA = 32
local SIZE_LUMP_TEXDATA_STRING_TABLE = 4
local SIZE_LUMP_DISPINFO = 176
local MAX_SIZE_TEXTURE_NAME = 128

BSP_LUMP_PLANES = 1
BSP_LUMP_TEXDATA = 2
BSP_LUMP_TEXINFO = 6
BSP_LUMP_BRUSHES = 18
BSP_LUMP_BRUSHSIDES = 19
BSP_LUMP_DISPINFO = 26
BSP_LUMP_TEXDATA_STRING_DATA = 43
BSP_LUMP_TEXDATA_STRING_TABLE = 44

local _R = debug.getregistry()
local meta = {}
_R.Bsp = meta
local methods = {}
meta.__index = methods
function meta:__tostring()
	local str = "Bsp [" .. tostring(self.m_map) .. "] [" .. tostring(self.m_version) .. "] [" .. tostring(self.m_ident) .. "]"
	return str
end
methods.MetaName = "Bsp"

local function OpenBSP(fName)
	fName = fName || ("maps/" .. game.GetMap() .. ".bsp")
	local f = file.Open(fName,"rb","GAME")
	if(!f) then return false end
	local t = {}
	setmetatable(t,meta)
	local ident = ReadInt(f)
	local version = ReadInt(f)
	local lumps = {}
	for i = 1,HEADER_LUMPS do
		local lump = {
			fileofs = ReadInt(f),
			filelen = ReadInt(f),
			version = ReadInt(f),
			fourCC = {
				f:ReadByte(),
				f:ReadByte(),
				f:ReadByte(),
				f:ReadByte()
			}
		}
		table.insert(lumps,lump)
	end
	fName = string.sub(fName,1,-5)
	t.m_map = string.GetFileFromFilename(fName)
	t.m_ident = ident
	t.m_version = version
	t.m_lumps = lumps
	t.m_file = f
	return t
end

function methods:GetLumpInfo(i) return self.m_lumps[i +1] end

function methods:Close()
	local f = self.m_file
	if(!f) then return end
	f:Close()
	self.m_file = nil
end

function methods:ReadLump(lumpID)
	if(lumpID == BSP_LUMP_PLANES) then return self:ReadLumpPlanes()
	elseif(lumpID == BSP_LUMP_TEXDATA) then return self:ReadLumpTexData()
	elseif(lumpID == BSP_LUMP_TEXINFO) then return self:ReadLumpTexInfo()
	elseif(lumpID == BSP_LUMP_BRUSHES) then return self:ReadLumpBrushes()
	elseif(lumpID == BSP_LUMP_BRUSHSIDES) then return self:ReadLumpBrushSides()
	elseif(lumpID == BSP_LUMP_TEXDATA_STRING_DATA) then return self:ReadLumpTextDataStringData()
	elseif(lumpID == BSP_LUMP_TEXDATA_STRING_TABLE) then return self:ReadLumpTextDataStringTable()
	elseif(lumpID == BSP_LUMP_DISPINFO) then return self:ReadLumpDispInfo() end
end
/*
function methods:ReadLumpDispInfo()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_DISPINFO)
	local dispinfo = {}
	f:Seek(info.fileofs)
	local numDisp = info.filelen /SIZE_LUMP_DISPINFO
	for i = 1,numDisp do
		local startPosition = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
		local DispVertStart = ReadInt(f)
		local DispTriStart = ReadInt(f)
		local power = ReadInt(f)
		local minTess = ReadInt(f)
		local smoothingAngle = f:ReadFloat()
		local contents = ReadInt(f)
		local MapFace = ReadUShort(f)
		local LightmapAlphaStart = ReadInt(f)
		local LightmapSamplePositionStart = ReadInt(f)
		local EdgeNeighbors = // TODO: Read these in properly. (See bspfile.h)
		local CornerNeighbors = //
		table.insert(dispinfo,{
			startPosition = startPosition,
			DispVertStart = DispVertStart,
			DispTriStart = DispTriStart,
			power = power,
			minTess = minTess,
			smoothingAngle = smoothingAngle,
			contents = contents,
			MapFace = MapFace,
			LightmapAlphaStart = LightmapAlphaStart,
			LightmapSamplePositionStart = LightmapSamplePositionStart
		})
	end
	return dispinfo
end
*/
function methods:ReadLumpPlanes()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_PLANES)
	local planes = {}
	f:Seek(info.fileofs)
	local numPlanes = info.filelen /SIZE_LUMP_PLANE
	for i = 1,numPlanes do
		local normal = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
		local dist = f:ReadFloat()
		local type = ReadInt(f)
		table.insert(planes,{
			normal = normal,
			dist = dist,
			type = type
		})
	end
	return planes
end

function methods:ReadLumpBrushSides()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_BRUSHSIDES)
	local brushSides = {}
	f:Seek(info.fileofs)
	local numBrushSides = info.filelen /SIZE_LUMP_BRUSHSIDE
	for i = 1,numBrushSides do
		local planenum = ReadUShort(f)
		local texinfo = ReadShort(f)
		local dispinfo = ReadShort(f)
		local bevel = ReadShort(f)
		table.insert(brushSides,{
			planenum = planenum,
			texinfo = texinfo,
			dispinfo = dispinfo,
			bevel = bevel
		})
	end
	return brushSides
end

function methods:ReadLumpBrushes()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_BRUSHES)
	local brushs = {}
	f:Seek(info.fileofs)
	local numBrushs = info.filelen /SIZE_LUMP_BRUSH
	for i = 1,numBrushs do
		local firstside = ReadInt(f)
		local numsides = ReadInt(f)
		local contents = ReadInt(f)
		local brush = {
			firstside = firstside,
			numsides = numsides,
			contents = contents
		}
		table.insert(brushs,brush)
	end
	return brushs
end

function methods:ReadLumpTexInfo()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_TEXINFO)
	local texinfo = {}
	f:Seek(info.fileofs)
	local numTexInfo = info.filelen /SIZE_LUMP_TEXINFO
	for i = 1,numTexInfo do
		local textureVecs = {}
		for i = 1,2 do
			textureVecs[i] = {}
			for j = 1,4 do
				textureVecs[i][j] = f:ReadFloat()
			end
		end
		local lightmapVecs = {}
		for i = 1,2 do
			lightmapVecs[i] = {}
			for j = 1,4 do
				lightmapVecs[i][j] = f:ReadFloat()
			end
		end
		local flags = ReadInt(f)
		local texdata = ReadInt(f)
		table.insert(texinfo,{
			textureVecs = textureVecs,
			lightmapVecs = lightmapVecs,
			flags = flags,
			texdata = texdata
		})
	end
	return texinfo
end

function methods:ReadLumpTexData()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_TEXDATA)
	local texdata = {}
	f:Seek(info.fileofs)
	local numTexData = info.filelen /SIZE_LUMP_TEXDATA
	for i = 1,numTexData do
		local reflectivity = Vector(f:ReadFloat(),f:ReadFloat(),f:ReadFloat())
		local nameStringTableID = ReadInt(f)
		local width = ReadInt(f)
		local height = ReadInt(f)
		local view_width = ReadInt(f)
		local view_height = ReadInt(f)
		table.insert(texdata,{
			reflectivity = reflectivity,
			nameStringTableID = nameStringTableID,
			width = wdith,
			height = height,
			view_width = view_width,
			view_height = view_height
		})
	end
	return texdata
end

function methods:ReadLumpTextDataStringData()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_TEXDATA_STRING_DATA)
	local texdatastring = {}
	f:Seek(info.fileofs)
	local sz = info.filelen
	while(sz > 0) do
		local t,l = ReadNullTerminatedString(f,MAX_SIZE_TEXTURE_NAME)
		table.insert(texdatastring,t)
		sz = sz -l
	end
	return texdatastring
end

function methods:ReadLumpTextDataStringTable()
	local f = self.m_file
	if(!f) then return end
	local info = self:GetLumpInfo(BSP_LUMP_TEXDATA_STRING_TABLE)
	local texdatastring = {}
	f:Seek(info.fileofs)
	local num = info.filelen /SIZE_LUMP_TEXDATA_STRING_TABLE
	for i = 1,num do
		table.insert(texdatastring,ReadInt(f))
	end
	return texdatastring
end

function methods:GetTranslatedTextDataStringTable()
	local f = self.m_file
	if(!f) then return end
	local data = {}
	local info = self:GetLumpInfo(BSP_LUMP_TEXDATA_STRING_DATA)
	local stringtable = self:ReadLumpTextDataStringTable()
	for i = 1,#stringtable do
		local tdata = stringtable[i]
		local tdataNext = stringtable[i +1]
		f:Seek(info.fileofs +tdata)
		data[i] = f:Read((tdataNext || info.filelen) -tdata)
	end
	return data
end

return {Open = OpenBSP}