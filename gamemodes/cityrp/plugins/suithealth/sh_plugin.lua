local PLUGIN = PLUGIN
PLUGIN.name = "Suit and Health Charger"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "I was bored."

if (SERVER) then
	function PLUGIN:SaveData()
		local entTable = {}
		local class
		for k, v in ipairs(ents.GetAll()) do
			class = v:GetClass():lower()
			if (class == "nut_charger") then
				table.insert(entTable, {
					class = class,
					pos = v:GetPos(),
					ang = v:GetAngles()
				})
			end
		end

		self:setData(entTable)
	end

	function PLUGIN:LoadData()
		local entTable = self:getData(entTable) or {}
		
		for k, v in ipairs(entTable) do
			local ent = ents.Create(v.class or "nut_charger")
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
			ent:Activate()
		end
	end
end