-- Welcome to the Oblivion source code! This file is primarily for loading separate files,
-- which are split to improve code readibility and navigability.

-- Points of interest:
	-- /cross-mod   - Code for features that only activate when the corresponding mod is enabled.
	-- /data        - Data used across the entire mod, and meant to be as easily expandible as possible.
	-- /items       - The code for the mod's content itself, including cards, card modifiers, blinds, and stakes.
	-- /load-assets - Rapid and centralized definition of assets.
	-- /modules     - Largely technical code that is used across the entire mod.

-- Create this mod's global table
if not Oblivion then Oblivion = {} end
Oblivion.obj = SMODS.current_mod
Oblivion.mod_path = tostring(Oblivion.obj.path)
Oblivion.config = Oblivion.obj.config
-- Function object
Ovn_f = {}

Oblivion.obj.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
	cardareas = {
		unscored = true,
		deck = true,
		discard = true,
	},
	object_weights = true,
}

-- Used in localization
Oblivion.sp = "{s:0.3} "

-- Used by lovely/increase_deck_preview_size.toml
Oblivion.suit_display_count = 5

-- Talisman incompat
-- You should really be using Amulet
if (
	(SMODS.Mods["Talisman"] or {}).can_load
	and not (SMODS.Mods["Amulet"] or {}).can_load
) then
	error([[TALISMAN detected!




====== HOW TO FIX THIS CRASH ======
1. Uninstall Talisman
2. Install Amulet
https://github.com/frostice482/amulet



]])
end

-- PlayLog compatibility
PlayLog = PlayLog or {
	log = function() end,
	LogType = function() end,
}

-- Try to load a file.
---@param file_name string
---@return nil
function Ovn_f.try_load_file(file_name)
	print("[OBLIVION] Loading file " .. file_name)
	local file_func, err = SMODS.load_file(file_name)
	if err then error(err) end
	if file_func then file_func() end
end

-- Loads all Lua files in a directory.
---@param folder_name string
---@param condition_function? fun(file_name: string): boolean
---@return nil
function Ovn_f.load_directory(folder_name, condition_function)
	local mod_path = Oblivion.mod_path
	local files = SMODS.NFS.getDirectoryItems(mod_path .. folder_name)
	local condition = function (file_name)
		local condition_function_check = true
		if condition_function then
			condition_function_check = condition_function(file_name)
		end
		return (
			file_name:match("%.lua$")
			and not file_name:match("%.d.lua$")
			and condition_function_check
		)
	end

	for _,file_name in ipairs(files) do
		if condition(file_name) then
			Ovn_f.try_load_file(folder_name .. "/" .. file_name)
		end
	end
end

Ovn_f.try_load_file("modules/funcs.lua")
Ovn_f.try_load_file("modules/hooks.lua")
Ovn_f.try_load_file("modules/jtml.lua")
Ovn_f.try_load_file("modules/objects.lua")
Ovn_f.try_load_file("modules/ui_funcs.lua")
Ovn_f.try_load_file("modules/ui_hook.lua")

Ovn_f.load_directory("modules/item-specific")
Ovn_f.load_directory("load-assets")
Ovn_f.load_directory("items")
Ovn_f.load_directory("data")
Ovn_f.load_directory("cross-mod", function (file_name)
	-- Cross-mod files (named with mod ID) only loaded if mod is loaded
	-- Cryptid is loaded by a patch into Cryptid, so skip it here
	return (SMODS.Mods[file_name:gsub('%.lua$', '')] or {}).can_load
end)

Ovn_f.try_load_file("modules/post-load.lua")
