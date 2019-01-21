PLUGIN.name = "Quick Inventory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds Quick Inventory Key in F3."

if (CLIENT) then
	local quickInventoryPanel = nil

	netstream.Hook("quickMenu", function()
		if (quickInventoryPanel) then
			quickInventoryPanel:Remove()
		end

		local inventory = LocalPlayer():getChar():getInv()

		if (inventory) then
			quickInventoryPanel = inventory:show()
			
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
