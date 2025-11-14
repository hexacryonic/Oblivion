SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
	cardareas = {
		unscored = true,
		deck = true,
		discard = true,
	}
}

-- talisman compat
to_big = to_big or function(x)
	return x
end

if not Oblivion then Oblivion = {} end
Oblivion.mod_path = tostring(SMODS.current_mod.path)
-- Function object
Ovn_f = {}

-- A shorthand of adding an event to G.E_MANAGER that only defines the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value\
-- or if other parameters such as blocking require specification.
---@param trigger string | nil
---@param delay number | nil
---@param func function
---@return nil
Ovn_f.add_simple_event = function(trigger, delay, func)
	-- This is here in Oblivion.lua so it's loaded before everything, which uses this function
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

-- Sets description box styling
SMODS.current_mod.description_loc_vars = function()
	return {
		background_colour = G.C.CLEAR,
		text_colour = G.C.WHITE,
		scale = 1.2
	}
end

-- Loads all Lua files in a directory.
---@param folder_name string
---@param condition_function? fun(file_name: string): boolean
---@return nil
function Ovn_f.load_directory(folder_name, condition_function)
	local mod_path = Oblivion.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)

	for _,file_name in ipairs(files) do if file_name:match("%.lua$") then
		local condition_is_met = true
		if condition_function then condition_is_met = condition_function(file_name) end

		if condition_is_met then
			print("[OBLIVION] Loading file " .. file_name)
			local file_format = "%s/%s"
			local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))
			if err then error(err) end --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
			if file_func then file_func() end
		end
	end end
end

Ovn_f.load_directory("modules")
Ovn_f.load_directory("load-assets")
Ovn_f.load_directory("items")
Ovn_f.load_directory("cross-mod", function (file_name)
	-- Cross-mod files (named with mod ID) only loaded if mod is loaded
	-- Cryptid is loaded by a patch into Cryptid, so skip it here
	return file_name ~= "Cryptid.lua" and (SMODS.Mod[file_name:gsub('%.lua$', '')] or {}).can_load
end)

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
cmap["j_baseball"]            = "j_ovn_cigarette_card"
cmap["j_splash"]              = "j_ovn_sludge"
cmap["j_arrowhead"]           = "j_ovn_apache_tears"
cmap["j_bloodstone"]          = "j_ovn_apache_tears"
cmap["j_onyx_agate"]          = "j_ovn_apache_tears"
cmap["j_rough_gem"]           = "j_ovn_apache_tears"

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
cenh["m_lucky"] = "m_ovn_ion"

if not Oblivion.seal_corrupt then Oblivion.seal_corrupt = {} end
local cseal         = Oblivion.seal_corrupt
cseal["Red"]        = "ovn_ruby_mark"
cseal["Blue"]       = "ovn_sapphire_mark"
cseal["Purple"]     = "ovn_amethyst_mark"
cseal["Gold"]       = "ovn_citrine_mark"
cseal["ovn_indigo"] = "ovn_iolite_mark"

SMODS.current_mod.extra_tabs = function ()
	return {
		{
			label = "Credits (WIP)",
			tab_definition_function = Ovn_f.credits_ui
		}
	}
end

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
				print("[OBLIVION] Purity mapping: Enhancement " .. corrupt_key .. " does not exist!")
			end
			penh[corrupt_key] = pure_key
		end

		-- Corrupt to Pure Seals
		Oblivion.seal_purify = {}
		local pseal = Oblivion.seal_purify
		for pure_key,corrupt_key in pairs(Oblivion.seal_corrupt) do
			if not SMODS.Seals[corrupt_key] then
				print("[OBLIVION] Purity mapping: Seal " .. corrupt_key .. " does not exist!")
			end
			pseal[corrupt_key] = pure_key
		end

		-- Purity map entries map to either a string (only pure form) or a list of strings (list of pure forms)
		return true
	end
})

-- Card credits that only appears in the Collection
Oblivion.DescriptionDummy {
	key = "credits",
	generate_ui = function (self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		-- specific_vars is sent by generate_card_ui (patched by corruption.toml)
		-- and is a string-keyed table based on a card's `credits` value
		if not card then card = self:create_fake_card() end

		local credits_ui_style = {
			[".credits_text_container"] = {padding = 0.075},
			[".credits_text"] = {
				scale = 0.32,
				colour = G.C.UI.TEXT_DARK,
				padding = 0.025,
			},
			[".credits_body"] = {align = "center-middle"},
			[".credits_label"] = {colour = G.C.BLUE},
			[".left"] = {align = "center-right"},
			[".right"] = {align = "center-left"},
		}

		local label_order = {"art", "code"}

		local function credits_labels()
			local entries = {}
			local label_loc = G.localization.descriptions.DescriptionDummy.dd_ovn_credits.labels
			for _,label_key in ipairs(label_order) do
				if specific_vars[label_key] then
					table.insert(entries,
						{"row", class="left", style={padding=0}, {
							{"text", class="credits_text credits_label", text=label_loc[label_key]}
						}}
					)
				end
			end
			return {"column", class="credits_text_container left", entries}
		end

		local function credits_names()
			local entries = {}
			for _,label_key in ipairs(label_order) do
				if specific_vars[label_key] then
					table.insert(entries,
						{"row", class="right", style={padding=0}, {
							{"text", class="credits_text credits_name", text=specific_vars[label_key]}
						}}
					)
				end
			end
			return {"column", class="credits_text_container right", entries}
		end

		local credits_ui =
		{"row", class="credits_body", {
			credits_labels(),
			credits_names()
		}}

		desc_nodes.name = localize{type = 'name_text', key = 'dd_ovn_credits', set = "DescriptionDummy"}
		table.insert(desc_nodes, {Ovn_f.jtml_to_uiboxdef(credits_ui, credits_ui_style)})
	end
}