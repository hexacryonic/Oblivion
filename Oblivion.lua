SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
	cardareas = {
		unscored = true,
		deck = true,
		discard = true,
	}
}

if not Oblivion then Oblivion = {} end
Oblivion.mod_path = tostring(SMODS.current_mod.path)
-- Function object
Ovn_f = {}

SMODS.current_mod.description_loc_vars = function()
	return {
		background_colour = G.C.CLEAR,
		text_colour = G.C.WHITE,
		scale = 1.2
	}
end

function Ovn_f.load_directory(folder_name)
	local mod_path = Oblivion.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)
	for _,file_name in ipairs(files) do
		print("[OBLIVION] Loading file " .. file_name)
		local file_format = ("%s/%s")
		local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))
		if err then error(err) end --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
		if file_func then file_func() end
	end
end

Ovn_f.load_directory("lib")
Ovn_f.load_directory("load-assets")
Ovn_f.load_directory("items")

-- Mapping this way so other mods can add define_corruption if it's nonexistent
-- and thus define their own corruptions
if not Oblivion.corruption_map then Oblivion.corruption_map = {} end
local cmap = Oblivion.corruption_map
cmap["j_joker"]               = "j_ovn_darkjoker"
cmap["j_fibonacci"]           = "j_ovn_lucasseries"
cmap["j_reserved_parking"]    = "j_ovn_perpendicular"
cmap["j_acrobat"]             = "j_ovn_yolo"
cmap["j_gift"]                = "j_ovn_supplydrop"
cmap["j_pareidolia"]          = "j_ovn_pmo"
cmap["j_ring_master"]         = "j_ovn_showneverends"
cmap["j_walkie_talkie"]       = "j_ovn_airstrike"
cmap["j_droll"]               = "j_ovn_bombastic"
cmap["j_crafty"]              = "j_ovn_insightful"
cmap["j_tribe"]               = "j_ovn_breach"
cmap["j_lusty_joker"]         = "j_ovn_prideful"
cmap["j_wrathful_joker"]      = "j_ovn_prideful"
cmap["j_gluttenous_joker"]    = "j_ovn_prideful"
cmap["j_greedy_joker"]        = "j_ovn_prideful"
cmap["j_cavendish"]           = "j_ovn_cultivar"
cmap["j_gros_michel"]         = "j_ovn_aeon"
cmap["j_hologram"]            = "j_ovn_apartfalling"
cmap["j_drunkard"]            = "j_ovn_spiral_of_addiction"
cmap["j_mystic_summit"]       = "j_ovn_collapsing_world"
cmap["j_erosion"]             = "j_ovn_collapsing_world"
cmap["j_hit_the_road"]        = "j_ovn_master_of_puppets"
cmap["j_wee"]                 = "j_ovn_infinitesimal"
cmap["j_hallucination"]       = "j_ovn_migraine"
cmap["j_abstract"]            = "j_ovn_database"
cmap["j_ovn_pure_visage"]     = "j_ovn_corrupt_visage"
cmap["j_todo_list"]           = "j_ovn_library_of_babel"
cmap["j_card_sharp"]          = "j_ovn_library_of_babel"
cmap["j_obelisk"]             = "j_ovn_library_of_babel"
cmap["j_ovn_trolley_problem"] = "j_ovn_bottled_ship_of_theseus"
cmap["j_ovn_purifier"]        = "j_ovn_nexus_point"
cmap["j_ovn_nexus_point"]     = "j_ovn_nexus_point"
cmap["j_supernova"]           = "j_ovn_event_horizon"
cmap["j_constellation"]       = "j_ovn_event_horizon"
cmap["j_midas_mask"]          = "j_ovn_philosophers_stone"

if not Oblivion.corruption_condition then Oblivion.corruption_condition = {} end
Oblivion.corruption_condition["j_gros_michel"] = function()
	return G.GAME and G.GAME.corruptiblemichel
end

-- Similar to corruption_map
if not Oblivion.enhancement_corrupt then Oblivion.enhancement_corrupt = {} end
local cenh = Oblivion.enhancement_corrupt
cenh["m_glass"] = "m_ovn_ice"
cenh["m_gold"]  = "m_ovn_dense"
cenh["m_steel"] = "m_ovn_unob"
cenh["m_wild"]  = "m_ovn_coord"
cenh["m_stone"] = "m_ovn_crystal"
cenh["m_bonus"] = "m_ovn_radiant"
cenh["m_mult"]  = "m_ovn_dynamo"

-- Generates immediately after the game finishes loading
G.E_MANAGER:add_event(Event {
	blocking = false,
	func = function()
		-- Corrupt to Pure Jokers
		Oblivion.purity_map = {}
		local pmap = Oblivion.purity_map
		for pure_key,corrupt_key in pairs(Oblivion.corruption_map) do
			if not G.P_CENTERS[corrupt_key] then
				print("[OBLIVION] Purity mapping: Joker " .. corrupt_key .. " does not exist!")
			end
			if not pmap[corrupt_key] then
				pmap[corrupt_key] = pure_key
			elseif type(pmap[corrupt_key]) == "string" then
				pmap[corrupt_key] = {pmap[corrupt_key]}
				table.insert(pmap[corrupt_key], pure_key)
			else
				table.insert(pmap[corrupt_key], pure_key)
			end
		end

		-- Corrupt to Pure Enhancements
		Oblivion.enhancement_purify = {}
		local penh = Oblivion.enhancement_purify
		for pure_key,corrupt_key in pairs(Oblivion.enhancement_corrupt) do
			if not G.P_CENTERS[corrupt_key] then
				print("[OBLIVION] Purity mapping: Joker " .. corrupt_key .. " does not exist!")
			end
			penh[corrupt_key] = pure_key
		end

		-- Purity map entries map to either a string (only pure form) or a list of strings (list of pure forms)
		return true
	end
})