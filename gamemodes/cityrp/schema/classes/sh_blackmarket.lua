CLASS.name = "Gun Dealer"
CLASS.faction = FACTION_CITIZEN
CLASS.salary = 210
CLASS.limit = 3
CLASS.color = Color(200, 90, 0)
CLASS.business = {
	-- Illegal
	["mlgbot"] = 1,	
	["weed"] = 1,	
	["steroid"] = 1,	

	-- Communication
	["radio"] = 1,	
	["pager"] = 1,	
	["sradio"] = 1,	

	-- Grenades
	["teargas"] = 1,	
	["flare_g"] = 1,	
	["flare_b"] = 1,	
	["flare"] = 1,	
	["beacon_1"] = 1,	
	["beacon_2"] = 1,	
	["beacon_3"] = 1,	
	["beacon_4"] = 1,	

	-- Misc
	["spraycan"] = 1,
	["tie"] = 1,

	["cw_ber_deagletoast"] = 1,
	["cw_fiveseven"] = 1,
	["cw_ws_mosin"] = 1,

	-- Outfits
	["balivest"] = 1,
	["advest"] = 1,

	-- Ammo
	["ammo_ar2"] = 1,
	["ammo_sniperround"] = 1,

	-- Firearms

	["cw_mr96"] = 1,
	["cw_ak74"] = 1,
	["cw_ar15"] = 1,
	["cw_fiveseven"] = 1,
	["cw_scarh"] = 1,
	["cw_frag_grenade"] = 1,
	["cw_g3a3"] = 1,
	["cw_g36c"] = 1,
	["cw_ump45"] = 1,
	["cw_deagle"] = 1,
	["cw_l115"] = 1,
	["cw_l85a2"] = 1,
	["cw_m14"] = 1,
	["cw_m249_official"] = 1,
	["cw_m3super90"] = 1,
	["cw_mac11"] = 1,
	["cw_p99"] = 1,
	["cw_makarov"] = 1,
	["cw_shorty"] = 1,
	["cw_vss"] = 1,
	["cw_smoke_grenade"] = 1,
	
	["att_rdot"] = 1,
	["att_holo"] = 1,
	["att_scope4"] = 1,
	["att_scope8"] = 1,
	["att_muzsup"] = 1,
	["att_exmag"] = 1,
	["att_foregrip"] = 1,
	["att_laser"] = 1,
	["att_bipod"] = 1,
	
	--[[
	["ma85_wf_smg26"] = 1,
	["ma85_wf_smg17"] = 1,
	["ma85_wf_smg37"] = 1,
	["ma85_wf_smg31"] = 1,
	["ma85_wf_smg18"] = 1,

	["ma85_wf_smg35"] = 1,
	["ma85_wf_shg38"] = 1,
	["ma85_wf_shg13"] = 1,

	["ma85_wf_pt10"] = 1,
	["ma85_wf_pt27"] = 1,
	["ma85_wf_pt21"] = 1,
	["ma85_wf_pt22"] = 1,
	["ma85_wf_pt04"] = 1,

	["ma85_wf_sr41"] = 1,

	["ma85_wf_smg_silencer"] = 1,
	["ma85_wf_smg_suppressor"] = 1,
	["ma85_wf_smg_bayonet"] = 1,
	["ma85_wf_smg_grip"] = 1,
	["ma85_wf_smg_grip_pod"] = 1,
	["ma85_wf_smg_basic_scope"] = 1,
	["ma85_wf_smg_adv_scope"] = 1,
	["ma85_wf_smg_ultra_scope"] = 1,

	["ma85_wf_medic_silencer"] = 1,
	["ma85_wf_medic_suppressor"] = 1,
	["ma85_wf_medic_bayonet"] = 1,
	["ma85_wf_medic_bayonet_old"] = 1,
	["ma85_wf_medic_aimpoint"] = 1,
	["ma85_wf_medic_adv_reflex"] = 1,

	["ma85_wf_pistol_silencer"] = 1,
	["ma85_wf_pistol_suppressor"] = 1,
	["ma85_wf_pistol_bayonet"] = 1,
	["ma85_wf_pistol_scope"] = 1,

	["ma85_wf_rifle_silencer"] = 1,
	["ma85_wf_rifle_suppressor"] = 1,
	["ma85_wf_rifle_bayonet"] = 1,
	["ma85_wf_rifle_grip"] = 1,
	["ma85_wf_rifle_grip_pod"] = 1,
	["ma85_wf_rifle_gl"] = 1,
	["ma85_wf_rifle_bipod"] = 1,
	["ma85_wf_rifle_basic_scope"] = 1,
	["ma85_wf_rifle_adv_scope"] = 1,
	["ma85_wf_rifle_ultra_scope"] = 1,

	["ma85_wf_shared_silencer"] = 1,
	["ma85_wf_shared_grip"] = 1,
	["ma85_wf_shared_holo"] = 1,
	["ma85_wf_shared_reflex"] = 1,
	["ma85_wf_shared_red_dot"] = 1,
	["ma85_wf_shared_reflex_old"] = 1,
	
	["ma85_wf_sniper_silencer"] = 1,
	["ma85_wf_sniper_suppressor"] = 1,
	["ma85_wf_sniper_bipod"] = 1,
	["ma85_wf_sniper_bipod_special"] = 1,
	["ma85_wf_sniper_scope_def"] = 1,
	["ma85_wf_sniper_scope_mid"] = 1,
	["ma85_wf_sniper_scope_close"] = 1,
	["ma85_wf_sniper_scope_fast"] = 1,

	["bg_wf_zf4_scope"] = 1,
	["bg_wf_p226_silencer"] = 1,
	["bg_wf_p226_rds"] = 1,
	["bg_wf_xlr5_rds"] = 1,
	["bg_wf_scarl_grip"] = 1,
	["bg_wf_cs5_silencer"] = 1,
	["bg_wf_scout_silencer"] = 1,
	
	--]]
}



function CLASS:OnSet(client)
end

CLASS_BLACKDEALER = CLASS.index