-- Defines Joker corruptions, and any conditions to allow such

--[[

Oblivion.corruption_map takes key-value pairs,
where the key is the key of the Joker being transformed
and the value is the key of the Joker to transform into

Oblivion.corruption_condition also takes key-value pairs
where the key is the key of the Joker being transformed,
and the value is a function that returns a boolean;
    if true, corruption is allowed

]]

Oblivion.corruption_map = Oblivion.corruption_map or {}

local map = Oblivion.corruption_map
map["j_joker"]               = "j_ovn_darkjoker"
map["j_fibonacci"]           = "j_ovn_lucasseries"
map["j_reserved_parking"]    = "j_ovn_perpendicular"
map["j_acrobat"]             = "j_ovn_yolo"
map["j_gift"]                = "j_ovn_supplydrop"
map["j_pareidolia"]          = "j_ovn_pmo"
map["j_ring_master"]         = "j_ovn_showneverends"
map["j_walkie_talkie"]       = "j_ovn_airstrike"
map["j_droll"]               = "j_ovn_bombastic"
map["j_crafty"]              = "j_ovn_insightful"
map["j_tribe"]               = "j_ovn_breach"
map["j_lusty_joker"]         = "j_ovn_prideful"
map["j_wrathful_joker"]      = "j_ovn_prideful"
map["j_gluttenous_joker"]    = "j_ovn_prideful"
map["j_greedy_joker"]        = "j_ovn_prideful"
map["j_cavendish"]           = "j_ovn_cultivar"
map["j_gros_michel"]         = "j_ovn_aeon"
map["j_hologram"]            = "j_ovn_apartfalling"
map["j_drunkard"]            = "j_ovn_spiral_of_addiction"
map["j_mystic_summit"]       = "j_ovn_collapsing_world"
map["j_erosion"]             = "j_ovn_collapsing_world"
map["j_hit_the_road"]        = "j_ovn_master_of_puppets"
map["j_wee"]                 = "j_ovn_infinitesimal"
map["j_hallucination"]       = "j_ovn_migraine"
map["j_abstract"]            = "j_ovn_database"
map["j_ovn_pure_visage"]     = "j_ovn_corrupt_visage"
map["j_todo_list"]           = "j_ovn_library_of_babel"
map["j_card_sharp"]          = "j_ovn_library_of_babel"
map["j_obelisk"]             = "j_ovn_library_of_babel"
map["j_ovn_trolley_problem"] = "j_ovn_bottled_ship_of_theseus"
map["j_ovn_purifier"]        = "j_ovn_nexus_point"
map["j_ovn_nexus_point"]     = "j_ovn_nexus_point"
map["j_supernova"]           = "j_ovn_event_horizon"
map["j_constellation"]       = "j_ovn_event_horizon"
map["j_midas_mask"]          = "j_ovn_philosophers_stone"
map["j_baseball"]            = "j_ovn_cigarette_card"
map["j_splash"]              = "j_ovn_sludge"
map["j_arrowhead"]           = "j_ovn_apache_tears"
map["j_bloodstone"]          = "j_ovn_apache_tears"
map["j_onyx_agate"]          = "j_ovn_apache_tears"
map["j_rough_gem"]           = "j_ovn_apache_tears"
map["j_caino"] --[[sic]]     = "j_ovn_nyarlathotep"
map["j_triboulet"]           = "j_ovn_nyarlathotep"
map["j_yorick"]              = "j_ovn_nyarlathotep"
map["j_chicot"]              = "j_ovn_nyarlathotep"
map["j_perkeo"]              = "j_ovn_nyarlathotep"

Oblivion.corruption_condition = Oblivion.corruption_condition or {}
Oblivion.corruption_condition["j_gros_michel"] = function()
	return G.GAME and G.GAME.corruptiblemichel
end