
local function unpack_msb_uint32(s)
  local a,b,c,d = s:byte(1,#s)
  local num = (((a*256) + b) * 256 + c) * 256 + d
  return num
end

local function read_msb_uint32(fh)
  return unpack_msb_uint32(fh:Read(4))
end

local function read_byte(fh)
  return fh:Read(1):byte()
end


local function parse_zlib(fh, len)
  local byte1 = read_byte(fh)
  local byte2 = read_byte(fh)

  local compression_method = byte1 % 16
  local compression_info = math.floor(byte1 / 16)

  local fcheck = byte2 % 32
  local fdict = math.floor(byte2 / 32) % 1
  local flevel = math.floor(byte2 / 64)


  fh:Read(len - 6)
  
  local checksum = read_msb_uint32(fh)
  
end

local function parse_IHDR(tbl,fh, len)
  assert(len == 13, 'format error')
  local width = read_msb_uint32(fh)
  local height = read_msb_uint32(fh)
  local bit_depth = read_byte(fh)
  local color_type = read_byte(fh)
  local compression_method = read_byte(fh)
  local filter_method = read_byte(fh)
  local interlace_method = read_byte(fh)

  tbl.width= width
  tbl.height= height
  tbl.bit_depth= bit_depth
  tbl.color_type= color_type
  tbl.compression_method= compression_method
  tbl.filter_method= filter_method
  tbl.interlace_method= interlace_method

  return compression_method
end

local function parse_sRGB(tbl,fh, len)
  assert(len == 1, 'format error')
  local rendering_intent = read_byte(fh)
  tbl.rendering_intent= rendering_intent
end

local function parse_gAMA(tbl,fh, len)
  assert(len == 4, 'format error')
  local rendering_intent = read_msb_uint32(fh)
 tbl.rendering_intent= rendering_intent
end

local function parse_cHRM(tbl,fh, len)
  assert(len == 32, 'format error')

  local white_x = read_msb_uint32(fh)
  local white_y = read_msb_uint32(fh)
  local red_x = read_msb_uint32(fh)
  local red_y = read_msb_uint32(fh)
  local green_x = read_msb_uint32(fh)
  local green_y = read_msb_uint32(fh)
  local blue_x = read_msb_uint32(fh)
  local blue_y = read_msb_uint32(fh)

end

local function parse_IDAT(tbl,fh, len, compression_method)
  if compression_method == 0 then
    -- fh:Read(len)
    parse_zlib(fh, len)
  else
   
  end
end

function file.parse_png(fh)
  if isstring(fh) then
  	fh = file.Open(fh,'rb','GAME')
  	
  end
  if not fh then error"Invalid file" end
  
  local tbl = {}
  
  -- parse PNG header
  local bytes = fh:Read(8)
  local expect = "\137\080\078\071\013\010\026\010"
  if bytes ~= expect then
    error 'not a PNG file'
  end

  -- parse chunks
  local compression_method
  while 1 do
    local len = read_msb_uint32(fh)
    local stype = fh:Read(4)
    
    if stype == 'IHDR' then
      compression_method = parse_IHDR(tbl,fh, len)
      break
    elseif stype == 'sRGB' then
      parse_sRGB(tbl,fh, len)
    elseif stype == 'gAMA' then
      parse_gAMA(tbl,fh, len)
    elseif stype == 'cHRM' then
      parse_cHRM(tbl,fh, len)
    elseif stype == 'IDAT' then
      parse_IDAT(tbl,fh, len, compression_method)
    else
      local data = fh:Read(len)
      --print("data=", len == 0 and "(empty)" or "(not displayed)")
    end
	
	local crc = read_msb_uint32(fh)

    if stype == 'IEND' then
      break
    end
  end
  return tbl
end
