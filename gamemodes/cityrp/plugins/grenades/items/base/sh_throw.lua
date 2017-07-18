ITEM.name = "Throwable Object"
ITEM.model = "models/Items/grenadeAmmo.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.throwent = "nut_flare"
ITEM.throwforce = 2500
ITEM.desc = "Throwable Object Example"

-- You can use hunger table? i guess? 
ITEM.functions = ITEM.functions or {}
ITEM.functions.throw = {
	name = "Throw",
	tip = "useTip",
	icon = "icon16/arrow_up.png",
	onRun = function(item)
		local client = item.player
		local grd = ents.Create( item.throwent )
		grd:SetPos( client:EyePos() + client:GetAimVector() * 50 )
		grd:Spawn()
		grd:CPPISetOwner(client)

		local phys = grd:GetPhysicsObject()
		phys:SetVelocity( client:GetAimVector() * item.throwforce * math.Rand( .8, 1 ) )
		phys:AddAngleVelocity( client:GetAimVector() * item.throwforce  )

		if (item.entConfigure) then
			item:entConfigure(grd)
		end
		
		return true
	end,
}