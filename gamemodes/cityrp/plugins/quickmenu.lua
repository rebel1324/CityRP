PLUGIN.name = "Quick Inventory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds Quick Inventory Key in F3."

if (CLIENT) then
	netstream.Hook("quickMenu", function()
		if (nut.gui.inv1) then
			nut.gui.inv1:Remove()
		end

		nut.gui.inv1 = vgui.Create("nutInventory")
		nut.gui.inv1.childPanels = {}

		local inventory = LocalPlayer():getChar():getInv()

		if (inventory) then
			nut.gui.inv1:setInventory(inventory)
			nut.gui.inv1:ShowCloseButton(true)

			function nut.gui.inv1:OnKeyCodePressed(key)
				if (key == 94) then
					nut.gui.inv1:Remove()
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
