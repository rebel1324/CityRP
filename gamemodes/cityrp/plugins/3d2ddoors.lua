PLUGIN.name = "3D2D Door Information"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "Now door information is displayed as 3d2d."

if (SERVER) then	
	netstream.Hook("doorCallMenu", function(client)
		hook.Run("ShowTeam", client)
	end)
	
	local fuckoff = function(client, door, state)
		if (IsValid(client) and client:GetPos():Distance(door:GetPos()) > 96) then
			return
		end

		if (door:isDoor()) then
			local partner = door:getDoorPartner()

			if (state) then
				if (IsValid(partner)) then
					partner:Fire("lock")
				end

				door:Fire("lock")
				client:EmitSound("doors/door_latch3.wav")
			else
				if (IsValid(partner)) then
					partner:Fire("unlock")
				end

				door:Fire("unlock")
				client:EmitSound("doors/door_latch1.wav")
			end
		elseif (door:IsVehicle()) then
			if (state) then
				door:Fire("lock")
				client:EmitSound("doors/door_latch3.wav")
			else
				door:Fire("unlock")
				client:EmitSound("doors/door_latch1.wav")
			end
		end
	end

	netstream.Hook("doorLocker", function(client, door)
		if (IsValid(door) and
			(
				(door:isDoor() and door:checkDoorAccess(client)) or
				(door:IsVehicle() and door:GetDTEntity(0) == client:getChar():getID())
			)
		) then
			local time = nut.config.get("doorLockTime", 1)
			client:setAction("@locking", time, function()
				fuckoff(client, door, true)
			end)
		end
	end)
	netstream.Hook("doorUnLocker", function(client, door)
		if (IsValid(door) and
			(
				(door:isDoor() and door:checkDoorAccess(client)) or
				(door:IsVehicle() and door:GetDTEntity(0) == client:getChar():getID())
			)
		) then
			local time = nut.config.get("doorLockTime", 1)
			client:setAction("@unlocking", time, function()
				fuckoff(client, door, false)
			end)
		end
	end)
end

if (CLIENT) then
	local nutDoor = nut.plugin.list["doors"]
	local LUASCREEN = LuaScreen()
	LUASCREEN.noClipping = true
	LUASCREEN.scale = .1

	local toScreen = FindMetaTable("Vector").ToScreen
	local colorAlpha = ColorAlpha
	local drawText = nut.util.drawText
	local configGet = nut.config.get
	local teamGetColor = team.GetColor

	local gradient = nut.util.getMaterial("vgui/gradient-l")
	local gradient2 = nut.util.getMaterial("vgui/gradient-r")
	local commands = {}
	commands.buy = {
		icon = "S",
		canDraw = function(entity)
			local owner = entity.GetDTEntity(entity, 0)
			
			if (IsValid(owner) and owner == LocalPlayer()) then return false end
		end,
		command = function()
			LocalPlayer():ConCommand("say /doorbuy")
		end
	}
	commands.sell = {
		icon = "G",
		canDraw = function(entity)
			local owner = entity.GetDTEntity(entity, 0)
			
			if (IsValid(owner) and owner == LocalPlayer()) then return true end
			return false
		end,
		command = function()
			LocalPlayer():ConCommand("say /doorsell")
		end
	}
	commands.reg = {
		icon = "W",
		canDraw = function(entity)
			local owner = entity.GetDTEntity(entity, 0)
			
			if (IsValid(owner) and owner == LocalPlayer()) then return true end
			return false
		end,
		command = function()
			netstream.Start("doorCallMenu")
		end
	}
	commands.lock = {
		icon = "P",
		canDraw = function(entity)
			local owner = entity.GetDTEntity(entity, 0)
			
			if (IsValid(owner) and owner == LocalPlayer()) then return true end
			return false
		end,
		command = function(entity)
			netstream.Start("doorLocker", entity)
		end
	}
	commands.unlock = {
		icon = "Q",
		canDraw = function(entity)
			local owner = entity.GetDTEntity(entity, 0)
			
			if (IsValid(owner) and owner == LocalPlayer()) then return true end
			return false
		end,
		command = function(entity)
			netstream.Start("doorUnLocker", entity)
		end
	}

	local defw = 35
	local defh = 20
	LUASCREEN.renderCode = function(scr, ent, wide, tall)
		local entity = scr.entity
		if (!IsValid(entity)) then return end
		local alpha = scr.alpha
		local scale = 1 / scr.scale
		
		local x, y = wide/2, tall/2
		local gw, gh = wide/2, tall/3
		
		do 
			surface.SetMaterial(gradient2)
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawTexturedRect(x - gw + 1, y - gh/2, gw, gh)

			surface.SetMaterial(gradient)
			surface.SetDrawColor(0, 0, 0, alpha)
			surface.DrawTexturedRect(x, y - gh/2, gw, gh)
			
			local owner = entity.GetDTEntity(entity, 0)
			local name = entity.getNetVar(entity, "title", entity.getNetVar(entity, "name", IsValid(owner) and L"dTitleOwned" or L"dTitle"))
			local faction = entity.getNetVar(entity, "faction")
			local class = entity.getNetVar(entity, "class")
			local color

			if (faction) then
				color = teamGetColor(faction)
			else
				color = configGet("color")
			end

			local classData
			if (class) then
				classData = nut.class.list[class]
				
				if (classData) then
					color = classData.color
				else
					color = configGet("color")
				end
			else
				color = configGet("color")
			end

			drawText(name, x, y - 8, colorAlpha(color, alpha), 1, 1)

			if (IsValid(owner)) then
				drawText(L("dOwnedBy", owner.Name(owner)), x, y + 8, colorAlpha(color_white, alpha), 1, 1)
			elseif (faction) then
				local info = nut.faction.indices[faction]

				if (info) then
					drawText(L("dOwnedBy", L2(info.name) or info.name), x, y + 8, colorAlpha(color_white, alpha), 1, 1)
				end
			elseif (class) then
				if (classData) then
					drawText(L("dOwnedBy", L2(classData.name) or classData.name), x, y + 8, colorAlpha(color_white, alpha), 1, 1)
				end
			else
				drawText(entity.getNetVar(entity, "noSell") and L"dIsNotOwnable" or L"dIsOwnable", x, y + 8, colorAlpha(color_white, alpha), 1, 1)
			end
		end
		
		local commandDisplay = (!entity.getNetVar(entity, "noSell") and !entity.getNetVar(entity, "class") and !entity.getNetVar(entity, "faction"))
	
		if (commandDisplay) then
			local ax, ay, aa = x, y + gh, 0
			local margin = 5
			local sqsize = 32

			-- fuck off it's not good
			local cnt = 0
			for k, v in pairs(commands) do 
				if (v.canDraw and v.canDraw(entity) == false) then continue end
				cnt = cnt + 1
			end

			local totalsizew = cnt * sqsize + cnt * margin

			DOORSOMETHING = false
			for k, v in pairs(commands) do
				local dx, dy = ax + aa - totalsizew/2, ay - sqsize/2
				v.active = scr:cursorInBox(dx, dy, sqsize, sqsize)
				
				if (v.canDraw and v.canDraw(entity) == false) then continue end

				if (v.active) then
					DOORSOMETHING = true
				end

				surface.SetDrawColor(0, 0, 0, alpha * (v.active and 1 or 0.7))
				surface.DrawRect(dx, dy, sqsize, sqsize)
				drawText(v.icon, dx + sqsize/2, dy + sqsize/2 - 1, colorAlpha(color_white, alpha), 1, 1, "nutIconsSmall")

				aa = aa + margin + sqsize
			end
		end
	end

	LUASCREEN.onMouseClick = function(scr, key)
		if (NEXTCOMMAND and NEXTCOMMAND > CurTime()) then return end

		NEXTCOMMAND = CurTime() + 0.5
		for k, v in pairs(commands) do
			if (v.canDraw and v.canDraw(LUASCREEN.entity) == false) then continue end
			
			if (v.active) then
				if (v.command) then v.command(LUASCREEN.entity) return end
			end
		end
	end

	local meta = getmetatable("Entity")


	function PLUGIN:PlayerBindPress(client, bind, pressed)
		if (DOORSOMETHING) then
			if (bind:find("use") or bind:find("attack")) then
				if (LUASCREEN.onMouseClick) then
					LUASCREEN.onMouseClick(IN_USE)
				end
				return true
			end
		end
	end

	function PLUGIN:DrawEntityInfo(entity, alpha)
		if (entity:isDoor()) then
			local a, b = entity:GetCollisionBounds()
			doorSize = b - a

			local direction = 0
			local width, height, thin
			local lel = {
				{1, doorSize[1]},
				{2, doorSize[2]},
				{3, doorSize[3]},
			}
			table.SortByMember(lel, 2)

			local a, b = lel[1][1], lel[2][1]
			
			if ((a == 2 or a == 3) and (b == 2 or b == 3)) then
				direction = 1
				width = doorSize[2]
				height = doorSize[3]
				thin = doorSize[1]
			elseif ((a == 1 or a == 3) and (b == 1 or b == 3)) then
				direction = 2
				width = doorSize[1]
				height = doorSize[3]
				thin = doorSize[2]
			elseif ((a == 1 or a == 2) and (b == 1 or b == 2)) then
				direction = 3
				width = doorSize[1]
				height = doorSize[2]
				thin = doorSize[3]
			end

			if (!entity:GetClass():find("func")) then
				width = doorSize[2]
				height = doorSize[3]
				thin = doorSize[1]
				direction = 4
			end

			local pos = entity:GetPos()
			pos = LocalToWorld(entity:OBBCenter(), entity:GetAngles(), entity:GetPos(), entity:GetAngles())

			if (direction == 1) then
				local ang = entity:GetAngles()
				local dot = LocalPlayer():GetAimVector():DotProduct(entity:GetForward())
				dot = dot >= 0 and -1 or 1
				pos = pos + entity:GetForward() * dot * (thin/2)

				if (dot < 0) then
					ang:RotateAroundAxis(entity:GetUp(), 180)
				end	
				local mul = math.abs(width / 50)
				LUASCREEN.w = defw * mul
				LUASCREEN.h = defh * mul
				LUASCREEN.scale = mul / 10
				LUASCREEN.ang = ang
			elseif (direction == 2) then
				local ang = entity:GetAngles()
				ang:RotateAroundAxis(entity:GetUp(), -90)
				local dot = LocalPlayer():GetAimVector():DotProduct(entity:GetRight())
				dot = dot >= 0 and -1 or 1
				pos = pos + entity:GetRight() * dot * (thin/2)

				if (dot < 0) then
					ang:RotateAroundAxis(entity:GetUp(), 180)
				end	
				local mul = math.abs(width / 50)/10
				LUASCREEN.w = defw
				LUASCREEN.h = defh
				LUASCREEN.scale = mul
				LUASCREEN.ang = ang
			elseif (direction == 3) then
				local ang = entity:GetAngles()
				ang:RotateAroundAxis(entity:GetRight(), -90)
				local dot = LocalPlayer():GetAimVector():DotProduct(entity:GetUp())
				dot = dot >= 0 and -1 or 1
				pos = pos + entity:GetUp() * dot * (thin/2)

				if (dot > 0) then
					ang:RotateAroundAxis(entity:GetRight(), 180)
				end	
				local mul = math.abs(width / 50)/10
				LUASCREEN.w = defw
				LUASCREEN.h = defh
				LUASCREEN.scale = mul
				LUASCREEN.ang = ang
			elseif (direction == 4) then
				local ang = entity:GetAngles()
				local dot = LocalPlayer():GetAimVector():DotProduct(entity:GetForward())
				dot = dot >= 0 and -1 or 1
				pos = pos + entity:GetForward() * dot * (thin/2)

				if (dot < 0) then
					ang:RotateAroundAxis(entity:GetUp(), 180)
				end	
				local mul = math.abs(width / 50)/10
				LUASCREEN.w = defw
				LUASCREEN.h = defh
				LUASCREEN.scale = mul
				LUASCREEN.ang = ang
			end

			LUASCREEN.alpha = alpha
			LUASCREEN.entity = entity
			LUASCREEN.pos = pos
		end
	end

	function PLUGIN:CanDrawDoorInfo()
		return false
	end
	
	function PLUGIN:PostDrawTranslucentRenderables()
		for k, v in pairs(paintedEntitiesCache) do
			if (IsValid(k)) then
				if (k:isDoor()) then
					LUASCREEN:render()
					LUASCREEN:think()
					
					return
				end
			end
		end
		
		LUASCREEN.alpha = 0
	end
end
