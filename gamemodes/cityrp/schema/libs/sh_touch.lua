-- Metasctruct Lua Screen. Metatable Conversion by Black Tea za rebel1324.

nut.screen = nut.screen or {}

-- This function is default unassinged renderscreen for Touch Screen.
local function defaultRender(scr, ent, wide, tall)
	draw.RoundedBox(0, 0, 0, wide, tall, Color(255, 0, 0, 255))
	draw.SimpleText("MISSING RENDERCODE", "ChatFont", wide/2, tall/2, color_white, 1, 1)
end

-- This function creates new Touchable Screen Object.
function nut.screen.new(w, h, scale)
	local screen = setmetatable(
		{
			pos = Vector(),
			ang = Angle(),
			w = w or 100,
			h = h or 100,
			scale = scale or 1,
		}, 
		{__index = FindMetaTable("TouchScreen")})
	screen.renderCode = defaultRender

	return screen
end
-- With this, you can create new lua touchscrren with LuaScreen(w, h, scale)
LuaScreen = nut.screen.new

-- The code below is Touchable Screen Metatable function.
local _R = debug.getregistry()

local SCREEN = _R.TouchScreen or {}
SCREEN.__index = SCREEN
SCREEN.w = 100
SCREEN.h = 100
SCREEN.pos = Vector(0, 0, 0)
SCREEN.ang = Angle(0, 0, 0)
SCREEN.scale = 1
SCREEN.filter = true
SCREEN.screenName = "Default"

-- This function allows you to print this Object with proper name.
function SCREEN:__tostring()
	return "[SCREEN OBJECT]"
end

-- This RayQuadIntersect gets the Point Position (x and y, range: 0 - 1) of the Plane that you're looking. 
local vec = Vector(0,0,0)
local function rayQuadIntersect(vOrigin, vDirection, vPlane, vX, vY)
        local vp = vDirection:Cross(vY)

        local d = vX:DotProduct(vp)

        if (d <= 0.0) then return end

        local vt = vOrigin - vPlane
        local u = vt:DotProduct(vp)
        if (u < 0.0 or u > d) then return end

        local v = vDirection:DotProduct(vt:Cross(vX))
        if (v < 0.0 or v > d) then return end

        return u / d,v / d
end
SCREEN.rayQuadIntersect = rayQuadIntersect

-- This function checks If the player can't see the 3D2D Screen.
function SCREEN:isBehind(client)
	if ((client:EyePos() - self.pos):DotProduct(self.ang:Forward()) < 0) then
		return true
	end
end

-- This function checks If the player can access to Touch Panel.
function SCREEN:isAccessible(client)
	local w, h, pos, ang = self.w, self.h, self.pos, self.ang
	client = client or LocalPlayer()
	
	-- Check if the player is too faraway from the screen.
	if (pos:Distance(client:EyePos()) > (w/2 + 64)) then
		return
	end

	-- Check the player can see the front of the panel.
	if ((client:EyePos() - pos):DotProduct(ang:Forward()) < 0) then
		return
	end

	-- Declare the plane.
	local plane = pos
	+ ang:Up() * h/2
	+ ang:Right() * (-w/2)

	local x = ang:Right() * w
	local y = ang:Up() * -h

	local aimVector = (vgui.CursorVisible() and gui.ScreenToVector(gui.MousePos())) or client:GetAimVector()

	return rayQuadIntersect(VIEWOVRD or client:GetShootPos(), aimVector, plane, x, y)
end

if (CLIENT) then
	SCREEN.mx = -1
	SCREEN.my = -1

	local glowMaterial = Material("sprites/glow04_noz")
	-- This function renders the 3D2D Panel. Requires proper Position and Angle, Scale and Good 3D2D Rendering Code.
	function SCREEN:render()
		local pos = self.pos
		local ang = Angle(self.ang[1], self.ang[2], self.ang[3])
		local scrDir = EyePos() - pos
		scrDir:Normalize()

		-- If the screen is reversed from your view, do not draw the screen.
		if (scrDir:DotProduct(ang:Forward()) < 0) then
			return
		end

		-- Shift the position little bit.
		pos = pos + ang:Right() * (self.w / 2)
		pos = pos + ang:Up() * (self.h / 2)

		-- Rotate the angle little bit.
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		-- Make the size reasonable.
		local wide = self.w * (1 / self.scale)
		local tall = self.h * (1 / self.scale)

		local up = self.ang:Up()
		local right = self.ang:Right()
		local ch = up * self.h * .5
		local cw = right * self.w * .5

		-- Draw the 3D2D Panel.
		if (!self.noClipping) then
			render.PushCustomClipPlane(up, up:Dot(pos - ch*2))
			render.PushCustomClipPlane(-up, (-up):Dot(pos))
			render.PushCustomClipPlane(right, right:Dot(pos - cw*2))
			render.PushCustomClipPlane(-right, (-right):Dot(pos))
			render.EnableClipping( true )
		end

		cam.Start3D2D(pos, ang, self.scale)		
			local succ, err = pcall(self.renderCode, self, ent, wide, tall)	
		cam.End3D2D()

		if (!self.noClipping) then
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.PopCustomClipPlane()
			render.EnableClipping( false )
		end
		
		-- Print the error.
		if !succ then
			print(err)
			return err
		end
	end

	-- Returns the horizontal size of the screen.
	function SCREEN:getWide()
		return self.w * (1 / self.scale)
	end

	-- Returns the vertical size of the screen.
	function SCREEN:getTall()
		return self.h * (1 / self.scale)
	end

	-- Get the Cursor's Position in the Touch Screen.
	function SCREEN:mousePos()
		if (!self.mx) then 
			return false 
		end

		return (1 - self.mx) * self:getWide(), self.my * self:getTall() 
	end

	-- Returns whether the cursor in the specific sized box or not.
	function SCREEN:cursorInBox(x, y, w, h)
		local mx, my = self:mousePos()

		if	(mx >= x and mx <= x + w
			and my >= y and my <= y + h) then

			return true
		end
	end

	-- No one should replace this until you know what the hell you're doing. 
	function SCREEN:think()
		local client = LocalPlayer()
		local mx, my = self:isAccessible()
		-- If the screen can calculate the Position of the cursor.
		if mx then
			-- If the screen can calculate, The screen has the focus.
			self.mx, self.my = mx, my
			self.hasFocus = true
			
			if (!vgui.CursorVisible()) then
				-- If the following key is pressed (USE, PRIMARY/SECONDARY ATTACK).
				local key = client:KeyDown(bit.bor(IN_USE, IN_ATTACK, IN_ATTACK2))

				if (key and !self.IN_USE) then
					self.IN_USE = true

					if (self.onMouseClick) then
						self:onMouseClick(self, IN_USE)
					end
				elseif (!key and self.IN_USE) then
					self.IN_USE = false

					if (self.onMouseRelease) then
						self:onMouseRelease(self, IN_USE)
					end
				end
			else
				-- If the following key is pressed (USE, PRIMARY/SECONDARY ATTACK).
				local key = input.IsMouseDown(MOUSE_LEFT)

				if (key and !self.IN_USE) then
					self.IN_USE = true

					if (self.onMouseClick) then
						self:onMouseClick(self, MOUSE_LEFT)
					end
				elseif (!key and self.IN_USE) then
					self.IN_USE = false

					if (self.onMouseRelease) then
						self:onMouseRelease(self, MOUSE_LEFT)
					end
				end
			end
		else
			-- If the screen can't calculate, The screen does not have focus.
			self.hasFocus = nil

			if (self.IN_USE) then
				self.IN_USE = false

				if (self.onMouseRelease) then
					self:onMouseRelease(IN_USE)
				end
			end
		end
	end
end

_R.TouchScreen = SCREEN