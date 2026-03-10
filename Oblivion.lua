-- Welcome to the Oblivion source code! This file is primarily for loading separate files,
-- which are split to improve code readibility and navigability.

-- Points of interest:
	-- /cross-mod   - Code for features that only activate when the corresponding mod is enabled.
	-- /data        - Data used across the entire mod, and meant to be as easily expandible as possible.
	-- /items       - The code for the mod's content itself, including cards, card modifiers, blinds, and stakes.
	-- /load-assets - Allows assets to be defined quickly and easily.
	-- /modules     - Largely technical code that is used across the entire mod.

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
-- but you should really be using amulet
-- (might depreciate talisman sometime down the line)
to_big = to_big or function(x)
	return x
end

-- Create this mod's global table
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
	local files = SMODS.NFS.getDirectoryItems(mod_path .. folder_name)

	print("[OBLIVION] == Loading directory " .. folder_name .. " ==")
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
Ovn_f.load_directory("data")
Ovn_f.load_directory("cross-mod", function (file_name)
	-- Cross-mod files (named with mod ID) only loaded if mod is loaded
	-- Cryptid is loaded by a patch into Cryptid, so skip it here
	return file_name ~= "Cryptid.lua" and (SMODS.Mods[file_name:gsub('%.lua$', '')] or {}).can_load
end)

SMODS.current_mod.extra_tabs = function ()
	return {
		{
			label = "Credits",
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

		-- For rarity-modifier mapping, convert "*" to an actual list of all defined modifiers
		local all_modis = {}
		for modifier in pairs(Oblivion.modifier_def) do
			table.insert(all_modis, modifier)
		end

		for _,rarity_modi_def in pairs(Oblivion.rarity_modifier_map) do
			rarity_modi_def.modifiers = all_modis
		end

		return true
	end
})

-- Card credits that only appears in the Collection
Oblivion.DescriptionDummy {
	key = "credits",
	generate_ui = function (self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		-- specific_vars is sent by generate_card_ui (patched by corruption.toml)
		-- It is a string-keyed table based on a card's `credits` value
		if not card then card = self:create_fake_card() end

		local label_loc = G.localization.descriptions.DescriptionDummy.dd_ovn_credits.labels
		local label_order = {"concept", "art", "shader", "music", "sound", "code"}

		local table_rows = {}
		for _,label_key in ipairs(label_order) do
			local left = {
				text = label_loc[label_key],
				colour = G.C.BLUE,
				align = "right"
			}
			local right = specific_vars[label_key]
			if right then
				table.insert(table_rows, {left, right})
			end
		end

		local credits_ui = Ovn_f.generate_table_ui(table_rows, {no_header = true})
		desc_nodes.name = localize{type = 'name_text', key = 'dd_ovn_credits', set = "DescriptionDummy"}
		table.insert(desc_nodes, {credits_ui})
	end
}