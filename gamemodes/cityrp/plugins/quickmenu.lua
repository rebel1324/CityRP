PLUGIN.name = "Quick Inventory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds Quick Inventory Key in F3."

if (CLIENT) then
	local fastUseFuncs = {
		"use",
		"throw",
		"View",
		"Equip",
		"EquipUn",
	}

	function PLUGIN:PostDrawInventory(pnl)
		if (pnl and pnl:IsVisible()) then
			local x, y = pnl:GetPos()
			local w, h = pnl:GetSize()
			local color = nut.config.get("color")
			local tx, ty = nut.util.drawText(L("ctrlInv"), x + 5, y + h, ColorAlpha(color, 255))
			tx, ty = nut.util.drawText(L("ctrlInv2"), x + 5, y + h + ty, ColorAlpha(color, 255))
		end
	end

	function PLUGIN:InterceptClickItemIcon(inventoryPanel, itemIconPanel, pressedKeyCode)
		local combinationA = input.IsKeyDown(KEY_LCONTROL) -- Fast Use / Undefined
		local combinationB = input.IsKeyDown(KEY_LALT) -- Undefined / Fast Drop
		local combinationC = input.IsKeyDown(KEY_LSHIFT) -- Undefined / Fast Split

		if (pressedKeyCode == MOUSE_RIGHT) then
		elseif (pressedKeyCode == MOUSE_LEFT) then
			if (combinationA) then
				local itemTable = itemIconPanel.itemTable

				if (itemTable) then
					for _, action in ipairs(fastUseFuncs) do
						local actionInfo = itemTable.functions and itemTable.functions[action]

						if (actionInfo) then
							if (isfunction(actionInfo.onCanRun) and not actionInfo.onCanRun(itemTable)) then
								continue
							end

							itemTable.player = LocalPlayer()
								local send = true

								if (actionInfo.onClick) then
									send = actionInfo.onClick(itemTable)
								end

								if (actionInfo.sound) then
									surface.PlaySound(actionInfo.sound)
								end

								if (send != false) then
									netstream.Start("invAct", action, itemTable.id, inventoryPanel.invID)
								end
							itemTable.player = nil

							return true
						end
					end
				end
			end
		end
	end

	local quickInventoryPanel = nil

	netstream.Hook("quickMenu", function()
		if (quickInventoryPanel) then
			quickInventoryPanel:Remove()
		end

		local inventory = LocalPlayer():getChar():getInv()

		if (inventory) then
			if (SOUND_INVENTORY_OPEN) then
				LocalPlayer():EmitSound(unpack(SOUND_INVENTORY_OPEN))
			end

			quickInventoryPanel = inventory:show()
			quickInventoryPanel:ShowCloseButton(true)
			hook.Add("PostRenderVGUI", quickInventoryPanel, function()
				hook.Run("PostDrawInventory", quickInventoryPanel)
			end)
			
			function quickInventoryPanel:OnKeyCodePressed(key)
				if (key == 94) then
					quickInventoryPanel:Remove()
				end
			end
		end
	end)
else
	function PLUGIN:ShowSpare1(client)
		if (client:getChar()) then
			netstream.Start(client, "quickMenu")
		end
	end
end
