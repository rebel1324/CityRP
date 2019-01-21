PLUGIN.name = "AAAAAAAA"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "AAAAAAAAAAAAAAAAAA."

function PLUGIN:SaveData()
	local entTable = {}
	local class
	for k, v in ipairs(ents.GetAll()) do
		class = v:GetClass():lower()
        if (class == "sent_kiosk") then
			table.insert(entTable, {
				class = class,
				pos = v:GetPos(),
                ang = v:GetAngles(),
                class = v:GetNW2Int("class")
			})
		end
	end
	self:setData(entTable)
end

function PLUGIN:LoadData()
	local entTable = self:getData(entTable) or {}
	
	for k, v in pairs(entTable) do
		local ent = ents.Create("sent_kiosk")
		ent:SetPos(v.pos)
		ent:SetAngles(v.ang)
		ent:Spawn()
		ent:Activate()
        ent:SetNW2Int("class", v.class)
	end
end

nut.command.add("setkiosk", {
	syntax = "<amount>",
	onRun = function(client, arguments)
			-- Get the Vehicle Spawn position.
		traceData = {}
		traceData.start = client:GetShootPos()
		traceData.endpos = traceData.start + client:GetAimVector() * 256
		traceData.filter = client
		trace = util.TraceLine(traceData)

		local target = trace.Entity

		if (target and target:IsValid() and client:IsSuperAdmin()) then
			target:SetNW2Int("class", table.concat(arguments, ""))
		end
	end,
})