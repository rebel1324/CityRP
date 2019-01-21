PLUGIN.name = "Quick Inventory"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin adds Quick Inventory Key in F3."

if (CLIENT) then
	CURRNET_INVENTORY_MEME = nil

	netstream.Hook("quickMenu", function()
		if (CURRNET_INVENTORY_MEME) then
			CURRNET_INVENTORY_MEME:Remove()
		end

		local inventory = LocalPlayer():getChar():getInv()

		if (inventory) then
			local shitPanel = inventory:show()
			
			function shitPanel:OnKeyCodePressed(key)
				if (key == 94) then
					shitPanel:Remove()
				end
			end

			CURRNET_INVENTORY_MEME = shitPanel 
		end
	end)
else
	function PLUGIN:ShowSpare1(client)
		if (client:getChar()) then
			netstream.Start(client, "quickMenu")
		end
	end
end
