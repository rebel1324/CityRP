AddCSLuaFile()

ENT.Base = "nut_storage"
ENT.PrintName = "Itembox"
ENT.Author = "Black Tea"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup 		= RENDERGROUP_BOTH
ENT.Category = "NutScript"
ENT.isCooker = true
ENT.StorageInfo = {
	name = "itembox",
	desc = "itemboxDesc",
	invType = "grid",
	invData = {
		w = 8,
		h = 4
	}
}
ENT.cookerModel = "models/props_wasteland/prison_shelf002a.mdl"

function ENT:getStorageInfo()
	return self.StorageInfo
end

if (SERVER) then
	function ENT:PostInitialize()
		self:SetModel(self.cookerModel)

		local data = self:getStorageInfo()
		nut.inventory.instance(data.invType, data.invData)
			:next(function(inventory)
				if (IsValid(self)) then
					inventory.isStorage = true
					self:setInventory(inventory)
					if (isfunction(data.onSpawn)) then
						data.onSpawn(storage)
					end
				end
			end, function(err)
				ErrorNoHalt(
					"Unable to create storage entity for "..client:Name().."\n"..
					err.."\n"
				)
				if (IsValid(storage)) then
					self:Remove()
				end
			end)
	end
end