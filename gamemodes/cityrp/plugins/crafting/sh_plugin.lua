local PLUGIN = PLUGIN
PLUGIN.name = "Crafting"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "How about getting new foods in NutScript?"
PLUGIN.craftingData = {}

local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")

function playerMeta:canCraft(craftID)
	-- is player occuping the crafting table?
	-- is player is capable of crafting? (ex. not dead, not tied, etc...)
	-- does player has enough ingredients?
	-- has flags or perks that preventing player from crafting item?
	if (!self:Alive()) then
		return false
	end

	return true -- add some conditions
end

function playerMeta:doCraft(craftID)
	-- check the condition
	-- strip the ingredients
	-- add the result into player's inventory

	return true
end

function entityMeta:isCraftingTable()
	local class = self:GetClass()

	return (class == "nut_craftingtable")
end
-- Register HUD Bars.
if (CLIENT) then

	netstream.Hook("craftingTableOpen", function(entity, index)
		local inventory = nut.item.inventories[index]

		if (IsValid(entity) and inventory and inventory.slots) then
			nut.gui.inv1 = vgui.Create("nutInventory")
			nut.gui.inv1:ShowCloseButton(true)

			local inventory2 = LocalPlayer():getChar():getInv()

			if (inventory2) then
				nut.gui.inv1:setInventory(inventory2)
			end

			local panel = vgui.Create("nutInventory")
			panel:ShowCloseButton(true)
			panel:SetTitle("Crafting Table")
			panel:setInventory(inventory)
			panel:MoveLeftOf(nut.gui.inv1, 4)
			panel.OnClose = function(this)
				if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
					nut.gui.inv1:Remove()
				end

				netstream.Start("invExit")
			end

			function nut.gui.inv1:OnClose()
				if (IsValid(panel) and !IsValid(nut.gui.menu)) then
					panel:Remove()
				end

				netstream.Start("invExit")
			end

			local actPanel = vgui.Create("DPanel")
			actPanel:SetDrawOnTop(true)
			actPanel:SetSize(100, panel:GetTall())
			actPanel.Think = function(this)
				if (!panel or !panel:IsValid() or !panel:IsVisible()) then
					this:Remove()

					return
				end

				local x, y = panel:GetPos()
				this:SetPos(x - this:GetWide() - 5, y)
			end

			local btn = actPanel:Add("DButton")
			btn:Dock(TOP)
			btn:SetText(L"craft")
			btn:SetColor(color_white)
			btn:DockMargin(5, 5, 5, 0)

			function btn.DoClick()
				netstream.Start("doCraft", entity, v)
			end

			nut.gui["inv"..index] = panel
		end
	end)
else
	local PLUGIN = PLUGIN

	function PLUGIN:LoadData()
		/*
		local savedTable = self:getData() or {}

		for k, v in ipairs(savedTable) do
			local stove = ents.Create(v.class)
			stove:SetPos(v.pos)
			stove:SetAngles(v.ang)
			stove:Spawn()
			stove:Activate()
		end
		*/
	end
	
	function PLUGIN:SaveData()
		/*
		local savedTable = {}

		for k, v in ipairs(ents.GetAll()) do
			if (v:isStove()) then
				table.insert(savedTable, {class = v:GetClass(), pos = v:GetPos(), ang = v:GetAngles()})
			end
		end

		self:setData(savedTable)
		*/
	end

	function PLUGIN:PlayerDeath(client)
	end

	function PLUGIN:PlayerSpawn(client)
	end
end