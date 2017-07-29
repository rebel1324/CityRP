local class = {}

class.registeredClasses = {}
local registered = class.registeredClasses

local function recursive_init(tbl, meta, ...)
	if meta.__baseclass then recursive_init(tbl, meta.__baseclass, ...) end
	meta.__ctor(tbl, ...)
end

function class:register(name, meta, base, noGlobal, tbl)
	registered[name] = meta
	if registered[base] then
		meta.__baseclass = registered[base]
	end
	meta.MetaName = name
	function meta:__index(k)
		if k == "__ctor" then
			self.__hash = string.format("%p", self)
			return function(...) recursive_init(self, meta, ...) end
		end
		return meta[k] or (meta.__baseclass and meta.__baseclass[k])
	end
	function meta:__gc()
		self:__dtor()
	end
	function meta:__tostring()
		return string.format("%s: %p", name, self.__hash)
	end
	meta.__ctor = meta.__ctor or function() end
	meta.__dtor = meta.__dtor or function() end
	if not noGlobal then
		local env = tbl or _G or getfenv(0)

		env[name] = function(...)
			return class:new(name, ...)
		end
	end
end

local setmetatable = debug.setmetatable
function class:new(name, ...)
	local meta = registered[name]
	assert(meta, ("unknown class %q"):format(name))
	local obj = {}
	setmetatable(obj, meta)
	obj.__ctor(...)
	return obj
end

function class.type(obj)
	return obj.MetaName or type(class)
end

function class:makeFunction(n)
	_G[n] = function(...)
		return class:new(n, ...)
	end
end

return class
