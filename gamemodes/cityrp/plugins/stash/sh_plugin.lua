local PLUGIN = PLUGIN
PLUGIN.name = "Perma Stash"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "You save your stuffs in the stash."
PLUGIN.stashData = PLUGIN.stashData or {}

nut.config.add("maxStash", 20, "Maximum storage of Permanant Stash.", nil, {
	data = {min = 1, max = 40},
	category = "stash"
})

nut.util.include("sv_plugin.lua")

local meta = nut.meta.character

function meta:getStash()
	return self:getVar("stash", {})
end

function meta:getStashCount()
	return table.Count(self:getStash())
end

function meta:getStashMax()
	return nut.config.get("maxStash", 10)
end

-- TODO: Stash vgui needs more better sync.
if (CLIENT) then
	netstream.Hook("stashIn", function(id)
		if (nut.gui.stash and nut.gui.stash:IsVisible()) then
			nut.gui.stash:setStash()
			surface.PlaySound("items/ammocrate_open.wav")
		end
	end)

	netstream.Hook("stashOut", function(id)
		if (nut.gui.stash and nut.gui.stash:IsVisible()) then
			nut.gui.stash:setStash()
			surface.PlaySound("items/ammocrate_open.wav")
		end
	end)

	netstream.Hook("stashMenu", function(items)
		local stash = vgui.Create("nutStash")
		stash:setStash(items)
	end)
end