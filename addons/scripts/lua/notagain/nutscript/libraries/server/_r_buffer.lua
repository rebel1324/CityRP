local _R = debug.getregistry()

_R.Buffer = {}
_R.Buffer.__index = _R.Buffer

function Buffer( str )
	local buffer = str and {string.byte(str,1,#str)} or {}
	return setmetatable( { buffer = buffer, position = 0 }, _R.Buffer )
end

function _R.Buffer:GetBuffer()
	return self.buffer
end

function _R.Buffer:__len()
	return #self.buffer
end

function _R.Buffer:Length()
	return #self
end

function _R.Buffer:Write( str )
	table.Add( self.buffer, {string.byte(str,1,#str)} )
end

function _R.Buffer:WriteByte( byte )
	table.insert( self.buffer, byte )
end

function _R.Buffer:ReadByte()
	self.position = self.position + 1
	return self.buffer[ self.position ]
end

function _R.Buffer:WriteInt( int )
	self:WriteByte( bit.band(bit.rshift(int,24),0xFF) )
	self:WriteByte( bit.band(bit.rshift(int,16),0xFF) )
	self:WriteByte( bit.band(bit.rshift(int,8),0xFF) )
	self:WriteByte( bit.band(int,0xFF) )
end

function _R.Buffer:ReadInt()
	return bit.lshift( self:ReadByte(), 24 ) + bit.lshift( self:ReadByte(), 16 ) + bit.lshift( self:ReadByte(), 8 ) + bit.lshift( self:ReadByte(), 0 )
end

function _R.Buffer:WriteFloat( float )
	if float == 0 then
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
		self:WriteByte( 0x00 )
	elseif number ~= number then
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
		self:WriteByte( 0xFF )
	else
		local sign = 0x00
		if float < 0 then
			sign = 0x80
			float = -float
		end
		local mantissa, exponent = math.frexp(float)
		exponent = exponent + 0x7F
		if exponent <= 0 then
			mantissa = math.ldexp(mantissa, exponent - 1)
			exponent = 0
		elseif exponent > 0 then
			if exponent >= 0xFF then
				self:WriteByte( sign + 0x7F )
				self:WriteByte( 0x80 )
				self:WriteByte( 0x00 )
				self:WriteByte( 0x00 )
				return
			elseif exponent == 1 then
				exponent = 0
			else
				mantissa = mantissa * 2 - 1
				exponent = exponent - 1
			end
		end
		mantissa = math.floor(math.ldexp(mantissa, 23) + 0.5)

		self:WriteByte( sign + math.floor(exponent / 2) )
		self:WriteByte( (exponent % 2) * 0x80 + math.floor(mantissa / 0x10000) )
		self:WriteByte( math.floor(mantissa / 0x100) % 0x100 )
		self:WriteByte( mantissa % 0x100 )
	end
end

function _R.Buffer:ReadFloat()
	local b1, b2, b3, b4 = self:ReadByte(), self:ReadByte(), self:ReadByte(), self:ReadByte()
	local exponent = (b1 % 0x80) * 0x02 + math.floor(b2 / 0x80)
	local mantissa = math.ldexp(((b2 % 0x80) * 0x100 + b3) * 0x100 + b4, -23)
	if exponent == 0xFF then
		if mantissa > 0 then
			return 0 / 0
		else
			mantissa = math.huge
			exponent = 0x7F
		end
	elseif exponent > 0 then
		mantissa = mantissa + 1
	else
		exponent = exponent + 1
	end
	if b1 >= 0x80 then
		mantissa = -mantissa
	end
	return math.ldexp(mantissa, exponent - 0x7F)
end

function _R.Buffer:WriteShort( short )
	self:WriteByte( bit.band(bit.rshift(short,8),0xFF) )
	self:WriteByte( bit.band(short,0xFF) )
end

function _R.Buffer:ReadShort()
	return bit.lshift( self:ReadByte(), 8 ) + bit.lshift( self:ReadByte(), 0 )
end

function _R.Buffer:WriteString( str )
	self:WriteShort( #str )
	self:Write( str )
end

function _R.Buffer:ReadString()
	local str = {}
	local len = self:ReadShort()
	for i = 1, len do
		local byte = self:ReadByte()
		table.insert( str, byte )
	end
	return string.char( unpack( str ) )
end

function _R.Buffer:WriteColor( col )
	self:WriteByte( col.r )
	self:WriteByte( col.g )
	self:WriteByte( col.b )
end

function _R.Buffer:ReadColor()
	return Color( self:ReadByte(), self:ReadByte(), self:ReadByte() )
end

function _R.Buffer:Seek( pos )
	self.position = pos
end

function _R.Buffer:Next()
	return self.buffer[ self.position + 1 ]
end

function _R.Buffer:GetRaw()
	return string.char( unpack( self.buffer ) )
end

function _R.Buffer:SendTo( sock )
	return sock:send( self:GetRaw() )
end

function _R.Buffer:WriteTable( tbl )
	for k, v in pairs( tbl ) do
		self:WriteType( k )
		self:WriteType( v )
	end
	self:WriteByte( 0 )
end

function _R.Buffer:ReadTable()
	local tbl = {}
	
	while true do
		local t = self:ReadByte()
		if ( t == 0 ) then return tbl end
		local k = self:ReadType( t )
	
		local t = self:ReadByte()
		if ( t == 0 ) then return tbl end
		local v = self:ReadType( t )
		
		tbl[ k ] = v
	end
end

function _R.Buffer:WriteVector( vec )
	self:WriteFloat( vec.x )
	self:WriteFloat( vec.y )
	self:WriteFloat( vec.z )
end

function _R.Buffer:ReadVector( vec )
	return Vector( self:ReadFloat(), self:ReadFloat(), self:ReadFloat() )
end

function _R.Buffer:WriteAngle( ang )
	self:WriteFloat( ang.p % 360 )
	self:WriteFloat( ang.y % 360 )
	self:WriteFloat( ang.r % 360 )
end

function _R.Buffer:ReadAngle( vec )
	return Angle( self:ReadFloat(), self:ReadFloat(), self:ReadFloat() )
end

function _R.Buffer:WriteType( obj )
	local tp = TypeID( obj )
	
	if tp == TYPE_NIL then
		self:WriteByte( TYPE_NIL )
	elseif tp == TYPE_STRING then
		self:WriteByte( TYPE_STRING )
		self:WriteString( obj )
	elseif tp == TYPE_NUMBER then
		self:WriteByte( TYPE_NUMBER )
		self:WriteInt( obj )
	elseif tp == TYPE_TABLE then
		self:WriteByte( TYPE_TABLE )
		self:WriteTable( obj )
	elseif tp == TYPE_BOOL then
		self:WriteByte( TYPE_BOOL )
		self:WriteByte( obj and 1 or 0 )
	elseif tp == TYPE_VECTOR then
		self:WriteByte( TYPE_VECTOR )
		self:WriteVector( obj )
	elseif tp == TYPE_ANGLE then
		self:WriteByte( TYPE_ANGLE )
		self:WriteAngle( obj )
	end
	
	Error( "Couldn't write type " .. tp )
end

local ReadVars =  {
	[TYPE_NIL]		= function () return nil end,
	[TYPE_STRING]	= _R.Buffer.ReadString,
	[TYPE_NUMBER]	= _R.Buffer.ReadInt,
	[TYPE_TABLE]	= _R.Buffer.ReadTable,
	[TYPE_BOOL]		= _R.Buffer.ReadByte,
	[TYPE_VECTOR]	= _R.Buffer.ReadVector,
	[TYPE_ANGLE]	= _R.Buffer.ReadAngle,
}

function _R.Buffer:ReadType( typeid )
	local ReadObject = ReadVars[ typeid ]
	if ( ReadObject ) then return self:ReadObject() end
	
	Error( "Couldn't read type " .. typeid )
end