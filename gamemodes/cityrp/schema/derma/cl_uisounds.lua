
SOUND_BUSINESS_BUY = "nui/click4.ogg"
SOUND_BUSINESS_PREVENT_BUY = "buttons/button11.wav"
SOUND_BUSINESS_PREVENT_RESPONSE = "buttons/button3.wav"
SOUND_BUSINESS_PREVENT_TIMEOUT = "buttons/button11.wav"
SOUND_CUSTOM_CHAT_SOUND = "nui/rollover.ogg"
SOUND_F1_MENU_UNANCHOR = "buttons/lightswitch2.wav"
SOUND_MENU_BUTTON_ROLLOVER = "ui/buttonrollover.wav"
SOUND_MENU_BUTTON_PRESSED = "ui/buttonclickrelease.wav"
SOUND_NOTIFY = {"nui/beepclear.wav", 40, 150}
SOUND_CHAR_HOVER = {"nui/rollover1.ogg", 35, 144}
SOUND_CHAR_CLICK = {"nui/switch29.ogg", 35, 80}
SOUND_CHAR_WARNING = {"ui/boop.wav", 33, 170}
SOUND_BAG_RESPONSE = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
SOUND_ATTRIBUTE_BUTTON = {"buttons/button16.wav", 30, 255}

SOUND_INVENTORY_CLICK = {"nui/switch8.ogg", 40, 180}
SOUND_INVENTORY_MENU = {"nui/switch2.ogg", 40, 100}
SOUND_INVENTORY_TRANSFER = {"nui/switch4.ogg", 40, 100}
SOUND_INVENTORY_INTERACT = {"nui/switch5.ogg", 40, 100}
SOUND_INVENTORY_OPEN = {"nui/invopen.wav", 50, 120}

hook.Add("InterceptClickItemIcon", "__ASD", function(inventoryPanel, itemIconPanel, pressedKeyCode)
	if (pressedKeyCode == MOUSE_RIGHT) then
        LocalPlayer():EmitSound(unpack(SOUND_INVENTORY_MENU))
    elseif (pressedKeyCode == MOUSE_LEFT) then
        LocalPlayer():EmitSound(unpack(SOUND_INVENTORY_CLICK))
    end
end)

hook.Add("OnRequestItemTransfer", "__AD", function(inventoryPanel, fromInventoryID, toInventoryID, x, y)
    LocalPlayer():EmitSound(unpack(SOUND_INVENTORY_TRANSFER))
end)