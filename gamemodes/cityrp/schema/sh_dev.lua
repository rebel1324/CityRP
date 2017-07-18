-- This file contains pretty much of development helpers.
-- Set loadFile = false after the development!

local loadFile = true

if (loadFile) then
	if (SERVER) then
		ErrorNoHalt("NUTSCRIPT DEVELOPER HELPER IS STILL ACTIVE!\n")
	end
end

dev = dev or {}

function dev.allitems()
	print("[DEV] Print all item instances.")
	print("[DEV] INV INSTANCE: " .. tostring(nut.item.instances))

	PrintTable(nut.item.instances)
	print("[DEV] END OF RESULT.")
end

function dev.printInv(client)
	if (!client) then return end
	local inv = client:getChar():getInv()
	print("[DEV] CLINT INV ".. tostring(inv))

	inv:print()
end

function dev.invTest(client)
	if (!client) then return end
	local inv = client:getChar():getInv()
	print("[DEV] CLINT INV ".. tostring(inv))

	local randomItem = table.Random(inv:getItems())

	print(randomItem.name)
	local a, b = randomItem:transfer(nil, nil, nil, client, nil, true)

	if (a) then
		print("SUCESS")
	else
		print("FAIL", b)
		return
	end
	
	timer.Simple(10, function()
		a, b = randomItem:transfer(inv:getID(), nil, nil, client)

		if (a) then
			print("SUCESS")
		else
			print("FAIL")
			return
		end
	end)
end

function dev.printInvs()
	for invID, obj in pairs(nut.item.inventories) do
		if (invID == 0) then
			print("------------------------")
			print("LOGIC INVENTORY")
					PrintTable(obj)
			print("------------------------")
		else
			if (SERVER) then
				for k, v in ipairs(player.GetAll()) do
					obj:sync(v, true)
				end
			end

			obj:printAll()
		end
	end
end


function dev.charInvs()
	for k, v in ipairs(player.GetAll()) do
		print(v:Name(), v:getChar():getInv():getID())
	end
end

function dev.printData()
	for k, v in ipairs(player.GetAll()) do
		print("INVENTORY: " .. v:Name() .. " +=============")
		local char = v:getChar()
		local inv = char:getInv()

		for key, item in pairs(inv:getItems()) do
			print("ITEM DATA > ".. item.name)
			PrintTable(item.data)
		end
	end
end

function dev.printmats(client)
	local trace = client:GetEyeTraceNoCursor()
	local ent = trace.Entity

	if (ent and ent:IsValid() and ent:GetClass() == "nut_vendor") then
		local mats = ent:GetMaterials()
		PrintTable(mats)
	end
end

function dev.vmmats()
	local lp = LocalPlayer()
	local vm = lp:GetViewModel()
	if (vm and vm:IsValid()) then
		local mats = vm:GetMaterials()
		PrintTable(mats)
	end
end

local iconsize = 64
function dev.iconFrame(ply, cmd, args)
	local itemID = args[1]
	local frame = vgui.Create("DFrame")
	frame:MakePopup()
	frame:SetSize(iconsize*5 + 4, iconsize*5 + 4)
	frame:Center()
	function frame:addicon(a)
		local panel = self:Add("nutItemIcon")
		panel:SetSize(a.width * iconsize, a.height * iconsize)
		panel:SetZPos(1)
		panel:InvalidateLayout(true)
		panel:SetModel(a.model)
		panel:SetPos(10, 30)

		if (a.iconCam) then
			local iconCam = a.iconCam
			PrintTable(iconCam)
			iconCam = {
				cam_pos = Vector(0, 0, 0),
				cam_fov = iconCam.fov,
				cam_ang = iconCam.ang,
			}
			renderdIcons[string.lower(a.model)] = true
			
			panel.Icon:RebuildSpawnIconEx(
				iconCam
			)
		end
	end

	function frame:reload()
		if frame.icon and frame.item then
			frame.icon:Remove()
			frame:addicon(frame.item)
		end
	end

	local a = nut.item.list[itemID]

	if (a) then
		frame.item = a

		local btn = frame:Add("DButton")
		btn:Dock(BOTTOM)

		frame:addicon(a)
	end
end
concommand.Add("ico", dev.iconFrame)

nut.command.add("giveitemmenu", {
	onRun = function(client, arguments)
		netstream.Start(client, "nutItemMenu")
	end
})

if (CLIENT) then
	local PANEL = {}

	function PANEL:Init()
		self:SetSize(300, 500)
		self:Center()
		self:MakePopup()

		self.menu = self:Add("PanelList")
		self.menu:Dock(FILL)
		self.menu:DockMargin(5, 5, 5, 5)
		self.menu:SetSpacing(2)
		self.menu:SetPadding(2)
		self.menu:EnableVerticalScrollbar()

		self:LoadItems()
	end

	function PANEL:LoadItems()
		local sorted = {}

		for k, v in pairs(nut.item.list) do
			if (v.base) then
				sorted[v.base] = sorted[v.base] or {}
				table.insert(sorted[v.base], v)
			else
				sorted["zzz"] = sorted["zzz"] or {}
				table.insert(sorted["zzz"], v)
			end
		end

		for k, v in SortedPairs(sorted) do
			local label = self.menu:Add("DLabel")
			label:SetText(k)
			self.menu:AddItem(label)

			for _, d in ipairs(v) do
				local button = self.menu:Add("DButton")
				button:SetText(L(d.name))
				self.menu:AddItem(button)

				function button:DoClick()
					LocalPlayer():ConCommand(Format('say /chargiveitem "%s" "%s"', LocalPlayer():Name(), d.uniqueID))
				end
			end
		end
	end

	vgui.Register("nutItemMenu", PANEL, "DFrame")

	netstream.Hook("nutItemMenu", function()
		local a = vgui.Create("nutItemMenu")
	end)
end