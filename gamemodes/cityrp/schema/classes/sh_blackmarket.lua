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
	["flare_g_shipment"] = 1,	
	["flare_b_shipment"] = 1,	
	["flare_shipment"] = 1,	

	-- Misc
	["vision_a"] = 1,
	["vision_b"] = 1,

	-- Outfits
	["balivest"] = 1,
	["advest"] = 1,

	-- Ammo
	["ammo_ar2"] = 1,
	["ammo_sniperround"] = 1,

	-- Firearms
	["cw_ak74_shipment"] = 1,
	["cw_ar15_shipment"] = 1,
	["cw_fiveseven_shipment"] = 1,
	["cw_scarh_shipment"] = 1,
	["cw_g36c_shipment"] = 1,
	["cw_ump45_shipment"] = 1,
	["cw_deagle_shipment"] = 1,
	["cw_l115_shipment"] = 1,
	["cw_m14_shipment"] = 1,
	["cw_m3super90_shipment"] = 1,
	["cw_mac11_shipment"] = 1,
	["cw_mr96_shipment"] = 1,
	["cw_makarov_shipment"] = 1,
	["tfa_bt_b93r_shipment"] = 1,
	["tfa_bt_famas_shipment"] = 1,

	["tfa_bt_b93r"] = 1,
	["tfa_bt_famas"] = 1,

	["att_rdot"] = 1,
	["att_holo"] = 1,
	["att_scope4"] = 1,
	["att_scope8"] = 1,
	["att_muzsup"] = 1,
	["att_exmag"] = 1,
	["att_foregrip"] = 1,
	["att_laser"] = 1,
	["att_bipod"] = 1,
}



function CLASS:OnSet(client)
end

CLASS_BLACKDEALER = CLASS.index