local tag= "enhanceddmg"
module(tag,package.seeall)

RUNSPEED = nil
WALKSPEED = nil

function Damage(ply, hitgroup, dmginfo) 
	if (GetConVar("enhanceddamage_enabled"):GetBool()) then
		if (ply.isProtected) then
			local prec, tad = ply:isProtected()
			
			dmginfo:ScaleDamage(1 - prec)
			
			if (prec and tad) then
				if (tad == "class") then return end
				if (dmginfo:IsDamageType(DMG_BULLET)) then
					local char = ply:getChar()
					local inv = char:getInv()
					local items = inv:getItemsByUniqueID(tad) or {}

					for k, v in pairs(items) do
						local equipped = v:getData("equip")

						if (v:getData("equip")) then
							local health = v:getData("health", v.defaultHealth)

							v:setData("health", health - math.random(6, 9))

							if (health <= 0) then
								if (ply.removePart) then
									ply:removePart(v.uniqueID)
								end
								
								v:remove()
								hook.Run("OnPlayerItemBreak", ply, v)

								break
							end
						end
					end
				end
			end
			
		end

		if (ConVarExists("sandboxteams_npcdamage") and ply:Team() != 1 ) then return end --Pseudo support for my sandbox teams addon
		local dmgpos = dmginfo:GetDamagePosition()
		
		local PelvisIndx = ply:LookupBone("ValveBiped.Bip01_Pelvis")
		if (PelvisIndx == nil) then return dmginfo end --Maybe Hitgroup still works, need testing
		local PelvisPos = ply:GetBonePosition( PelvisIndx )
		local NutsDistance = dmgpos:Distance(PelvisPos)

		local LHandIndex = ply:LookupBone("ValveBiped.Bip01_L_Hand")
		local LHandPos = ply:GetBonePosition( LHandIndex )
		local LHandDistance = dmgpos:Distance(LHandPos)

		local RHandIndex = ply:LookupBone("ValveBiped.Bip01_R_Hand")
		local RHandPos = ply:GetBonePosition(RHandIndex)
		local RHandDistance = dmgpos:Distance(RHandPos)
		
		if (NutsDistance <= 7 && NutsDistance >= 5) then
			hitgroup = "HITGROUP_NUTS"
		elseif (LHandDistance < 7 || RHandDistance < 7 ) then
			hitgroup = "HITGROUP_HAND"
		end

		if (hitgroup == HITGROUP_HEAD) then
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_headdamagescale"):GetFloat())
			HeadshotHurtSound(ply)

		elseif (hitgroup == HITGROUP_LEFTARM || hitgroup == HITGROUP_RIGHTARM) then
			ArmHurtSound(ply)
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_armdamagescale"):GetFloat())
		elseif (hitgroup == HITGROUP_LEFTLEG || hitgroup == HITGROUP_RIGHTLEG) then
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_legdamagescale"):GetFloat())

			if ply:IsPlayer() then
				hook.Run("OnPlayerLegDamaged", ply, dmginfo)
				BreakLeg(ply)
			else
				LegHurtSound(ply)
			end

		elseif (hitgroup == HITGROUP_CHEST) then
			GenericHurtSound(ply)
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_chestdamagescale"):GetFloat())

		elseif (hitgroup == HITGROUP_STOMACH) then
			StomachHurtSound(ply)
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_stomachdamagescale"):GetFloat())

		elseif (hitgroup == "HITGROUP_NUTS") then
			local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  
			if (!isFemale(ply) and SoundsEnabled) then
				dmginfo:ScaleDamage(GetConVar("enhanceddamage_nutsdamagescale"):GetFloat())
				local sound = Sound("vo/npc/male01/ow01.wav")
				ply:EmitSound(sound,500,125)
			end

		elseif(hitgroup == "HITGROUP_HAND") then
			ArmHurtSound(ply)
			dmginfo:ScaleDamage(GetConVar("enhanceddamage_handdamagescale"):GetFloat())
		else
			GenericHurtSound(ply)
		end
		ply.hurttimer = true
		timer.Simple(1, function() ply.hurttimer = false end)
	end
end

function FallDamage(ply,speed)
if  GetConVar("enhanceddamage_falldamage"):GetBool() then
	local damage = speed / 10
	if (damage > ply:Health() / 2 and damage < ply:Health()) then
		BreakLeg(ply,10)
	end
	return damage
else --Default valve falldamage calculations
	if GetConVarNumber("mp_falldamage") == 1 then
		speed = speed - 580
		return speed * (100/(1024-580))
	end
	return 10
end
end

--This is terrible but whatevs
function BreakLeg(ply,duration)
	if !ply.legshot then
		local char = ply:getChar()
		char:setData("b_leg", true)

		ply:breakLegs()

		LegHurtSound(ply)
	end
end

function GenericHurtSound(ply)
	local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  

	if !ply.hurttimer and SoundsEnabled then
		if isFemale(ply) then
			local sound = table.Random(femalepainsounds)
			ply:EmitSound(sound)
		else
			local sound = table.Random(malepainsounds)
			ply:EmitSound(sound)
		end
	end
end

function HeadshotHurtSound(ply)
	local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  

	if  !ply.hurttimer and SoundsEnabled  then
			local sound = table.Random(headshotsounds)
			ply:EmitSound(sound)	
	end
end

function ArmHurtSound(ply)
	local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  
	if  !ply.hurttimer and SoundsEnabled then
		if isFemale(ply) then
			local sound = table.Random(femalearmsounds)
			ply:EmitSound(sound)
		else
			local sound = table.Random(malearmsounds)
			ply:EmitSound(sound)
		end
	end
end

function LegHurtSound(ply)
	local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  

	if  !ply.hurttimer and SoundsEnabled then
		if isFemale(ply) then
			local sound = table.Random(femalelegsounds)
			ply:EmitSound(sound)
		else
			local sound = table.Random(malelegsounds)
			ply:EmitSound(sound)
		end
	end
end

function StomachHurtSound(ply)
	local SoundsEnabled = GetConVar("enhanceddamage_enablesounds"):GetBool()  

	if  !ply.hurttimer and SoundsEnabled then
		if isFemale(ply) then
			local sound = table.Random(femalegutsounds)
			ply:EmitSound(sound)
		else
			local sound = table.Random(malegutsounds)
			ply:EmitSound(sound)
		end
	end
end

function isFemale(ply) 
	if table.HasValue(femalemodels,ply:GetModel()) then
		return true
	else
		if string.match(ply:GetModel(),"female") || string.match(ply:GetModel(),"alyx") || string.match(ply:GetModel(),"mossman") then 
			return true
		else
			return false
		end
	end
end

malearmsounds = {Sound("vo/npc/male01/myarm01.wav"),Sound("vo/npc/male01/myarm02.wav")}
femalearmsounds = {Sound("vo/npc/female01/myarm01.wav"),Sound("vo/npc/female01/myarm02.wav")}

malelegsounds = {Sound("vo/npc/male01/myleg01.wav"),Sound("vo/npc/male01/myleg02.wav")}
femalelegsounds = {Sound("vo/npc/female01/myleg01.wav"),Sound("vo/npc/female01/myleg02.wav")}

malegutsounds = {Sound("vo/npc/male01/mygut02.wav"),Sound("vo/npc/male01/hitingut01.wav"),Sound("vo/npc/male01/hitingut02.wav")}
femalegutsounds = {Sound("vo/npc/female01/mygut02.wav"),Sound("vo/npc/female01/hitingut01.wav"),Sound("vo/npc/female01/hitingut02.wav")}

headshotsounds  = {Sound("flesh_squishy_impact_hard1.wav"),Sound("flesh_squishy_impact_hard2.wav"),Sound("flesh_squishy_impact_hard3.wav"),Sound("flesh_squishy_impact_hard4.wav")}

falldamage = {"npc_fastzombie","npc_headcrab","npc_headcrab_poison","npc_headcrab_black","npc_headcrab_fast","npc_antlion"}

malepainsounds = {Sound("vo/npc/male01/pain01.wav"),
Sound("vo/npc/male01/pain02.wav"),
Sound("vo/npc/male01/pain03.wav"),
Sound("vo/npc/male01/pain04.wav"),
Sound("vo/npc/male01/pain05.wav"),
Sound("vo/npc/male01/pain06.wav"),
Sound("vo/npc/male01/pain07.wav"),
Sound("vo/npc/male01/pain08.wav"),
Sound("vo/npc/male01/pain09.wav"),
Sound("vo/ravenholm/monk_pain01"),
Sound("vo/ravenholm/monk_pain02"),
Sound("vo/ravenholm/monk_pain03"),
Sound("vo/ravenholm/monk_pain04"),
Sound("vo/ravenholm/monk_pain05"),
Sound("vo/ravenholm/monk_pain06"),
Sound("vo/ravenholm/monk_pain07"),
Sound("vo/ravenholm/monk_pain08"),
Sound("vo/ravenholm/monk_pain09"),
Sound("vo/ravenholm/monk_pain10"),
Sound("vo/ravenholm/monk_pain12"),
Sound("vo/npc/male01/moan01.wav"),
Sound("vo/npc/male01/moan02.wav"),
Sound("vo/npc/male01/moan03.wav"),
Sound("vo/npc/male01/moan04.wav"),
Sound("vo/npc/male01/moan05.wav"),

}

maleburnsounds =
{
	Sound("player/pl_burnpain1.wav"),
	Sound("player/pl_burnpain2.wav"),
	Sound("player/pl_burnpain3.wav")
}

femalepainsounds = {Sound("vo/npc/female01/pain01.wav"),
Sound("vo/npc/female01/pain02.wav"),
Sound("vo/npc/female01/pain03.wav"),
Sound("vo/npc/female01/pain04.wav"),
Sound("vo/npc/female01/pain05.wav"),
Sound("vo/npc/female01/pain06.wav"),
Sound("vo/npc/female01/pain07.wav"),
Sound("vo/npc/female01/pain08.wav"),
Sound("vo/npc/female01/pain09.wav"),
Sound("vo/npc/female01/moan01.wav"),
Sound("vo/npc/female01/moan02.wav"),
Sound("vo/npc/female01/moan03.wav"),
Sound("vo/npc/female01/moan04.wav"),
Sound("vo/npc/female01/moan05.wav"),}

femalemodels = {
"models/player/group01/female_01.mdl",
"models/player/group01/female_02.mdl",
"models/player/group01/female_03.mdl",
"models/player/group01/female_04.mdl",
"models/player/group01/female_05.mdl",
"models/player/group01/female_06.mdl",
"models/player/group01/female_07.mdl",
"models/player/group03/female_01.mdl",
"models/player/group03/female_02.mdl",
"models/player/group03/female_03.mdl",
"models/player/group03/female_04.mdl",
"models/player/group03/female_05.mdl",
"models/player/group03/female_06.mdl",
"models/player/group03/female_07.mdl",
"models/player/alyx.mdl",

"models/player/mossman.mdl",
"models/Humans/alyx.mdl",
"models/Humans/mossman.mdl",
 }



CreateConVar("enhanceddamage_enabled", 1, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Enable enhanced damage")

CreateConVar("enhanceddamage_headdamagescale", 4, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_armdamagescale", 0.50, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_legdamagescale",0.50, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_chestdamagescale", 1.25, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_stomachdamagescale",0.75, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_nutsdamagescale", 2, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")
CreateConVar("enhanceddamage_handdamagescale", 0.25, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")

CreateConVar("enhanceddamage_armdropchance",25, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"The weapon drop chance for ")
CreateConVar("enhanceddamage_handdropchance", 50, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Change the scale for this bodypart")

CreateConVar("enhanceddamage_enablesounds", 1, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Enable the sounds when hurt ")

CreateConVar("enhanceddamage_legbreak", 1, {FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Enable enhanced damage")
CreateConVar("enhanceddamage_falldamage",1,{FCVAR_SERVER_CAN_EXECUTE,FCVAR_NOTIFY,FCVAR_ARCHIVE},"Enable enhanced falldamage (Much more 'realistic' and breaks your bones)")

hook.Add("ScalePlayerDamage",tag,Damage)
hook.Add("GetFallDamage",tag,FallDamage)
