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
Oblivion.f = {}
Oblivion.mod_path = tostring(SMODS.current_mod.path)

SMODS.current_mod.description_loc_vars = function()
	return {
		background_colour = G.C.CLEAR,
		text_colour = G.C.WHITE,
		scale = 1.2
	}
end

local function load_directory(folder_name)
	local mod_path = Oblivion.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)
	for _,file_name in ipairs(files) do
		print("[OBLIVION] Loading file " .. file_name)
		local file_format = ("%s/%s")
		local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))
		if err then error(err) end --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
		file_func()
	end
end

load_directory("lib")
load_directory("load-assets")
load_directory("items")

-- Mapping this way so other mods can add define_corruption if it's nonexistent
-- and thus define their own corruptions
if not Oblivion.corruption_map then Oblivion.corruption_map = {} end
local cmap = Oblivion.corruption_map
cmap["j_joker"]            = "j_ovn_darkjoker"
cmap["j_fibonacci"]        = "j_ovn_lucasseries"
cmap["j_reserved_parking"] = "j_ovn_perpendicular"
cmap["j_gift"]             = "j_ovn_supplydrop"
cmap["j_acrobat"]          = "j_ovn_yolo"
cmap["j_pareidolia"]       = "j_ovn_pmo"
cmap["j_ring_master"]      = "j_ovn_showneverends"
cmap["j_droll"]            = "j_ovn_bombastic"
cmap["j_crafty"]           = "j_ovn_insightful"
cmap["j_tribe"]            = "j_ovn_breach"
cmap["j_lusty_joker"]      = "j_ovn_prideful"
cmap["j_wrathful_joker"]   = "j_ovn_prideful"
cmap["j_gluttenous_joker"] = "j_ovn_prideful"
cmap["j_greedy_joker"]     = "j_ovn_prideful"
cmap["j_cavendish"]        = "j_ovn_cultivar"
cmap["j_hologram"]         = "j_ovn_apartfalling"
cmap["j_gros_michel"]      = "j_ovn_aeon"

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

-- Generates immediately after the game finishes loading
G.E_MANAGER:add_event(Event {
	blocking = false,
	func = function()
		-- Corrupt to Pure Jokers
		Oblivion.purity_map = {}
		local pmap = Oblivion.purity_map
		for pure_key,corrupt_key in pairs(Oblivion.corruption_map) do
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
			penh[corrupt_key] = pure_key
		end

		-- Purity map entries map to either a string (only pure form) or a list of strings (list of pure forms)
		return true
	end
})