local STRING = getmetatable("")


local string = string
local table = table

-- repeat ("lol" * 10)
STRING.__mul = function(self, var)
	checkstring(self)
	check(var, "number")

	return self:rep(var)
end

-- repeat ("lol" * 10)
STRING.__div = function(self, var)
	checkstring(self)
	check(var, "string")

	return var:Explode(self)
end

-- repeat ("lol" + "hmm")
STRING.__add = function(self, var)
	return self .. var
end

-- removes the port from an ip (10.0.0.1:3600 becomes 10.0.0.1)
function string.RemovePortFromIP(self)
	return string.gsub(self,":%d-$","")
end

-- find with no patterns
function string.FindSimple(self, find)
	checkstring(self)
	check(find, "string", "number")

	return self:find(find, 0, true) ~= nil
end

string.split = function(a,b) return string.Explode(b,a) end

function string.ulen(ustring)
	local len=0
	for uchar in string.gmatch(ustring, "([%z\1-\127\194-\244][\128-\191]*)") do
		  len=len+1
    end
	return len
end

function string.usplit(ustring)
	local tbl={}
	local len=0
	for uchar in string.gmatch(ustring, "([%z\1-\127\194-\244][\128-\191]*)") do
          tbl[#tbl+1]=uchar
		  len=len+#uchar
    end
	return tbl
end

-- ("qwe"):splitlen(1)=={"q","w","e"}

string.splitlen=function(str,len)
	local ret = {}
	local offset=1
	
	local maxl=#str+1
	local i=0
	while offset<maxl do
		local left = offset
		offset = offset + len
		i=i+1
		
		local res = str:sub(left,offset-1)
		if res:len()>0 then
			ret[i]=res
		else
			break
		end
	end
	return ret
end

--URL encode a string.
local function encode(str)

  --Ensure all newlines are in CRLF form
  str = string.gsub (str, "\r?\n", "\r\n")

  --Percent-encode all non-unreserved characters
  --as per RFC 3986, Section 2.3
  --(except for space, which gets plus-encoded)
  str = string.gsub (str, "([^%w%-%.%_%~ ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)

  --Convert spaces to plus signs
  str = string.gsub (str, " ", "+")

  return str
end

--Make this function available as part of the module
string.urlencode = encode

--URL encode a table as a series of parameters.
function table.urlencode(t)

  --table of argument strings
  local argts = {}

  --insertion iterator
  local i = 1

  --URL-encode every pair
  for k, v in pairs(t) do
    argts[i]=encode(k).."="..encode(v)
    i=i+1
  end

  return table.concat(argts,'&')
end


string.newlines = function(str) return string.gmatch(str,"[^\r\n]+") end

function string.occurances(INP,NEEDLE)
    local count = 0
    local sp,ep = 0,0
    if string.find(INP,NEEDLE)!=nil    then
        sp,ep = string.find(INP,NEEDLE)
        local str = string.sub(INP,ep + 1,#INP)
        count = count + 1
        count = count + occurancesOf(str,NEEDLE)
    end
    return count
    
end



-------------------

-- wtf need new file

----------------------
local entities = {
    amp = "&",
    lt = "<",
    gt = ">",
    quot = "\"",
    apos = "'",
    nbsp = " ",
    iexcl = "¡",
    cent = "¢",
    pound = "£",
    curren = "¤",
    yen = "¥",
    brvbar = "¦",
    sect = "§",
    uml = "¨",
    copy = "©",
    ordf = "ª",
    laquo = "«",
    reg = "®",
    macr = "¯",
    deg = "°",
    plusmn = "±",
    sup2 = "²",
    sup3 = "³",
    acute = "´",
    micro = "µ",
    para = "¶",
    middot = "·",
    cedil = "¸",
    sup1 = "¹",
    ordm = "º",
    raquo = "»",
    frac14 = "¼",
    frac12 = "½",
    frac34 = "¾",
    iquest = "¿",
    times = "×",
    divide = "÷",
  }

function string.decodeHTMLEntities(s)


  local ret = string.gsub(s, "&(%w+);?", entities)
    return ret
end
