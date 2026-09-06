-- These commonly called functions are used across the mod

-- 1. INTERNAL FUNCTIONS
-- 2. DECK PROPERTIES
-- 3. JOKER TRANSMUTATION
-- 4. JOKER TRANSMUTATION STATES
-- 5. MODIFIER TRANSMUTATION
-- 6. MASTER OF PUPPETS
-- 7. CALCULATION MACROS
-- 8. OTHER GAMEPLAY



----------------------------
---- INTERNAL FUNCTIONS ----
----------------------------

local add_simple_event = Ovn_f.add_simple_event

-- Returns `censored` if family friendly is enabled, else returns `normal`.
---@param normal any
---@param censored any
---@return any
function Ovn_f.f_f(normal, censored)
	return Oblivion.config.family_friendly and censored or normal
end

---@return nil
function Ovn_f.reload_localization()
	SMODS.load_mod_localization(Oblivion.mod_path, Oblivion.obj.id)
	init_localization()
end

-- Determines whether the player is holding the Joker of specified card key.
---@param card_key string
---@return boolean
Ovn_f.has_joker = function(card_key)
	return next(SMODS.find_card(card_key)) and true or false
end

-- Run a sequence of events, with defineable delays.
---@param event_func_list [number, function][]
---@param delay? number
---@param offset? number
---@return nil
Ovn_f.event_sequence = function(event_func_list, delay, offset)
	delay = delay or 0
	offset = offset or 1
	local event_def = event_func_list[offset]
	if not event_def then return end

	local event_delay = event_def[1] or 0
	local event_func  = event_def[2]

	delay = delay + event_delay
	add_simple_event("after", delay, function()
		if event_func then event_func() end
		-- :(
		Ovn_f.event_sequence(event_func_list, delay, offset + 1)
	end)
end

-- Go through nested tables via a list of keys, returning nil if the entire list of keys does not correspond to a chain of tables.
---@param input_table any[] Values correspond to table keys.
---@return any The value of the final key in `input_table`.
Ovn_f.descend_table = function(input_table)
	local current_table = input_table[1]
	if type(current_table) ~= "table" then return nil end
	for i = 2, #input_table do
		local key = input_table[i]
		current_table = current_table[key]
		if ( -- True if not indexable (includes nil)
			type(current_table) ~= "table"
			and i ~= #input_table
		) then return nil end
	end
	return current_table
end

-- Copies a table and any table it contains.
---@param tbl table
---@return table
Ovn_f.bi_shallow_copy = function(tbl)
	local new_table = SMODS.shallow_copy(tbl)
	for i,item in pairs(new_table) do
		new_table[i] = type(item) == "table" and SMODS.shallow_copy(item) or item
	end
	return new_table
end

-- DEBUG: Compile a list of credited users and their contributions.
---@return {string: string[]}
Ovn_f.credited_users = function()
	local users = {}
	for key,center in pairs(G.P_CENTERS) do
		if center.credits then
			for role,usernames in pairs(center.credits) do
				local split_usernames = usernames:gmatch("([^,]+)")
				for username in split_usernames do
					username = username:gsub("^ +", ""):gsub(" +$", "")
					users[username] = users[username] or {}
					table.insert(users[username], role .. " - " .. key)
				end
			end
		end
	end
	return users
end

-- DEBUG: Call this function inside a function to see exactly where this function is being called from.
-- It is recommended to print the return value.
---@return string
Ovn_f.calling_func = function()
	local traceback = debug.traceback()
	local lines = {}
	for str in traceback:gmatch("[^\n]+") do
		table.insert(lines, str)
		if #lines == 4 then break end
	end
	if #lines ~= 4 then return "???" end
	local function_thats_calling_the_function_this_function_is_in_ig = lines[4]:gsub("^ +", "")
	return function_thats_calling_the_function_this_function_is_in_ig
end



-------------------------
---- DECK PROPERTIES ----
-------------------------

-- Checks if the current Deck is corrupt.
---@return boolean
Ovn_f.deck_is_corrupt = function ()
	return (
		G.GAME.selected_back
		and G.GAME.selected_back.effect.center.ovn_corrupt_deck
	) or (
		G.GAME.modifiers
		and G.GAME.modifiers.ovn_corrupt_challenge
	) or false
end

-- Checks if the current Deck is that of a specified key. Do not include prefixes.\
-- If mod_prefix is exactly false, then no mod prefix is inserted.
---@param deck_key string
---@param mod_prefix? string|false
---@return boolean
Ovn_f.on_deck = function (deck_key, mod_prefix)
	local prefix = "b_ovn_"
	if mod_prefix == false then
		prefix = "b_"
	elseif type(mod_prefix) == 'string' then
		prefix = "b_" .. mod_prefix .. "_"
	end
	return G.GAME.selected_back and (G.GAME.selected_back.effect.center.key == (prefix .. deck_key)) or false
end



-----------------------------
---- JOKER TRANSMUTATION ----
-----------------------------

-- Transmutes a Joker into its corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_joker = function(card)
	local card_key = card.config.center.key
	local corrupted_card_key = Oblivion.corruption_map[card_key]
	G.jokers:remove_from_highlighted(card)

	G.GAME.corruptingJoker = true
	local ability = card.ability
	local card_destroyed = false

	if corrupted_card_key == "j_ovn_apache_tears" and Ovn_f.has_joker("j_ovn_apache_tears") then
		SMODS.destroy_cards(card)
		card_destroyed = true
	elseif corrupted_card_key ~= card_key then
		card:set_ability(G.P_CENTERS[corrupted_card_key], false, true)
	-- as Apache Tears "absorbs" the corrupted card instead
	end

	PlayLog.log{ type = "ovn_transmute_joker", transmute_type = "corrupt", from = card_key, to = corrupted_card_key }
    add_simple_event(nil, nil, function()
        play_sound("ovn_corrupting_joker")

		if not card_destroyed then
			card:juice_up(0.3, 0.5)
			card.ability.ovn_former_form = card_key
			card:calculate_joker(Ovn_f.calculate_corrupted_from(card_key, ability))
		end

		SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Joker", card_key, card_destroyed and nil or card))

        G.GAME.corruptingJoker = false
    end)
end

-- Transmutes a Joker into its pure variant.
---@param card Card
---@return nil
Ovn_f.purify_joker = function(card)
	local card_key = card.config.center.key
	local pmap_entry = Oblivion.purity_map[card_key]
	local pure_card_key = (
		card.ability.ovn_former_form
		or (
			type(pmap_entry) == "table"
			and pseudorandom_element(pmap_entry, pseudoseed("purifyJoker"))
			or pmap_entry -- type == "string"
		)
	)
	G.jokers:remove_from_highlighted(card)

	G.GAME.purifyingJoker = true
	local ability = card.ability

	if pure_card_key ~= card_key then
		card:set_ability(G.P_CENTERS[pure_card_key])
	end

	PlayLog.log{ type = "ovn_transmute_joker", transmute_type = "purify", from = card_key, to = pure_card_key }
    add_simple_event(nil, nil, function()
        play_sound("ovn_purifying")
		card:juice_up(0.3, 0.5)
		card:calculate_joker(Ovn_f.calculate_purified_from(card_key, ability))
		SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Joker", card_key, card))
    end)
	add_simple_event('after', 1, function() G.GAME.purifyingJoker = false end)
end



------------------------------------
---- JOKER TRANSMUTATION STATES ----
------------------------------------

-- Determines whether a Joker has a defined corruption.
---@param card_key string
---@return boolean
Ovn_f.joker_has_corruption = function(card_key)
	return Oblivion.corruption_map[card_key] ~= nil
end

-- Determines the key of a Joker's corruption condition.
---@param card_key string
---@return string|nil
Ovn_f.joker_corruption_condition = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return end

	local condition_def = Oblivion.corruption_condition[card_key]
	if condition_def == nil then return end

	local condition_key = condition_def[1]
	return condition_key
end

-- Determines whether a Joker is corruptible based on its defined corruption conditions.
---@param card_key string
---@return boolean
Ovn_f.joker_is_corruptible = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return false end

	local condition_def = Oblivion.corruption_condition[card_key]
	if condition_def == nil then return true end

	local condition_func = condition_def[2]
	return condition_func() and true or false
end

-- Determines whether a Joker is purifiable.
---@param card_key string
---@return boolean
Ovn_f.joker_is_purifiable = function(card_key)
	return Oblivion.purity_map[card_key] and true or false
end

-- Sets a random former form of a (corrupted) card if not set./
---@param card Card
---@return nil|string
Ovn_f.set_random_former_form = function(card)
	if card.ability.ovn_former_form then return end
	local card_key = card.config.center.key

	local pure_form_options = Oblivion.purity_map[card_key]
	if not pure_form_options then return end
	if type(pure_form_options) == "string" then
		card.ability.ovn_former_form = pure_form_options
		return pure_form_options
	end

	local former_form = pseudorandom_element(pure_form_options, "ovn_former_form")
	card.ability.ovn_former_form = former_form
	return former_form
end

-- Determines if a Joker should be out of all pools\
-- due to its corrupted variant being present.
---@param card_key string
---@return boolean
Ovn_f.is_corruptbanished = function(card_key)
	-- Do not continue if purification is occurring
	if G.GAME.purifyingJoker then return false end

	-- In pool if showneverends is held
	local has_tsne = Ovn_f.has_joker('j_ovn_showneverends')
	if has_tsne then return false end

	-- In pool if Joker is not even corruptible
	local corrupt_key = Oblivion.corruption_map[card_key]
	if not corrupt_key then return false end
	-- Do not destroy if self-corruptible
	if corrupt_key == card_key then return false end

	-- In pool if Joker's corrupt variant is not held
	local has_corrupt_joker = Ovn_f.has_joker(corrupt_key)
	if not has_corrupt_joker then return false end

	-- In pool even if Apache Tears is present, but it hasn't absorbed the Joker yet
	if Oblivion.corruption_map[card_key] == 'j_ovn_apache_tears' then
		local apache_absorption = false
		for _,tear_card in ipairs(SMODS.find_card('j_ovn_apache_tears')) do
			if tear_card.ability.extra.track_corrupts[card_key] == true then
				apache_absorption = true
				break
			end
		end
		if not apache_absorption then return false end
	end

	-- DIE
	return true
end



--------------------------------
---- MODIFIER TRANSMUTATION ----
--------------------------------

-- Transmutes a playing card's regular modifiers into their corrupted variants.
---@param card Card
---@return nil
Ovn_f.corrupt_modifiers = function(card)
	local transmuted = false
	local corrupt_keys = {}
	local old_keys = {}

	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
		table.insert(corrupt_keys, new_enhancement)
		table.insert(old_keys, enhancement_key)
	end

	local seal_key = card.seal
	local cseal, new_seal
	if seal_key then
		cseal = Oblivion.seal_corrupt
		new_seal = cseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
			table.insert(corrupt_keys, new_seal)
			table.insert(old_keys, seal_key)
		end
	end

	if transmuted then
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "corrupt", card = card, from = old_keys, to = corrupt_keys }

		add_simple_event('immediate', nil, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)

			if new_enhancement then
				card:calculate_enhancement(Ovn_f.calculate_corrupted_from(enhancement_key))
				SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Enhancement", enhancement_key, card))
			end

			if new_seal then
				card:calculate_seal(Ovn_f.calculate_corrupted_from(seal_key))
				SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Seal", seal_key, card))
			end
		end)
	end
end

-- Transmutes a playing card's regular enhancement_key into it corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "corrupt", card = card, from = enhancement_key, to = new_enhancement }
		add_simple_event('immediate', nil, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)
			card:calculate_enhancement(Ovn_f.calculate_corrupted_from(enhancement_key))
			SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Enhancement", enhancement_key, card))
		end)
	end
end

-- Transmutes a playing card's corrupted modifiers into their regular variants.
---@param card Card
---@return nil
Ovn_f.purify_modifiers = function(card)
	local transmuted = false
	local pure_keys = {}
	local old_keys = {}

	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
		table.insert(old_keys, enhancement_key)
		table.insert(pure_keys, new_enhancement)
	end

	local seal_key = card.seal
	local pseal, new_seal
	if seal_key then
		pseal = Oblivion.seal_purify
		new_seal = pseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
			table.insert(old_keys, seal_key)
			table.insert(pure_keys, new_seal)
		end
	end

	if transmuted then
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "purify", card = card, from = old_keys, to = pure_keys }

		add_simple_event('immediate', nil, function()
			play_sound('ovn_purifying', 1, 1.1)
			card:juice_up(0.5, 0.5)

			if new_enhancement then
				card:calculate_enhancement(Ovn_f.calculate_purified_from(enhancement_key))
				SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Enhancement", enhancement_key, card))
			end

			if new_seal then
				card:calculate_seal(Ovn_f.calculate_purified_from(seal_key))
				SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Seal", seal_key, card))
			end
		end)
	end
end

-- Transmutes a playing card's corrupted enhancement_key into its regular variant.
---@param card Card
---@return nil
Ovn_f.purify_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "purify", card = card, from = enhancement_key, to = new_enhancement }
		add_simple_event('immediate', nil, function()
			play_sound('ovn_purifying', 1, 1.1)
			card:juice_up(0.5, 0.5)
			card:calculate_enhancement(Ovn_f.calculate_purified_from(enhancement_key))
			SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Enhancement", enhancement_key, card))
		end)
	end
end



---------------------------
---- MASTER OF PUPPETS ----
---------------------------

-- Prepares a list of applicable modifiers for Master of Puppets.
---@param rarity integer|string The key of a rarity. Vanilla rarities still use integer values.
---@return {string: string[]}
Ovn_f.prepare_modifier_options = function(rarity)
	local rarity_modi_def = Oblivion.rarity_modifier_map[rarity]

	local include   = rarity_modi_def.include or {}
	local whitelist = (
		rarity_modi_def.whitelist
		and Ovn_f.bi_shallow_copy(rarity_modi_def.whitelist)
		or {}
	)
	local blacklist = (
		rarity_modi_def.blacklist
		and Ovn_f.bi_shallow_copy(rarity_modi_def.blacklist)
		or {}
	)

	local all_options = whitelist or {}
	for _,modifier in ipairs(rarity_modi_def.modifiers --[[@as string[] ]]) do
		local modi_def = Oblivion.modifier_def[modifier]

		-- Below table pre-exists if whitelist specifies it
		all_options[modifier] = all_options[modifier] or get_current_pool(modi_def.pool)
		all_options[modifier] = SMODS.shallow_copy(all_options[modifier])
		local modi_options = all_options[modifier]

		-- Apply include
		local modi_include = include[modifier] or {}
		modi_options = SMODS.merge_lists({modi_options}, {modi_include})

		-- Apply blacklist
		local modi_blacklist = blacklist[modifier] or {}
		for i, value in ipairs(modi_options) do
			for j,blacklisted_value in ipairs(modi_blacklist) do
				if value == blacklisted_value then
					modi_options[i] = "UNAVAILABLE"
					table.remove(modi_blacklist, j)
					break
				end
			end
			if #modi_blacklist < 1 then break end
		end
	end

	return all_options
end

-- Gets a list of Jacks that do not have certain modifier types.
---@param rarity integer|string The key of a rarity. Vanilla rarities still use integer values.
---@return Card[]
Ovn_f.get_puppet_jacks = function(rarity)
	local rarity_modi_def = Oblivion.rarity_modifier_map[rarity] --[[@as string[] ]]

	local jack_list = {}
	for _,playing_card in ipairs(G.playing_cards) do
		local has_no_modifiers = false
		if rarity_modi_def then
			for _,modifier in ipairs(rarity_modi_def.modifiers) do
				local modi_def = Oblivion.modifier_def[modifier]
				-- True if at least one modifier type is found to be missing
				has_no_modifiers = (
					has_no_modifiers
					or modi_def.has_no_modifier(playing_card)
				)
			end
		else
			for _,modi_def in pairs(Oblivion.modifier_def) do
				has_no_modifiers = (
					has_no_modifiers
					or modi_def.has_no_modifier(playing_card)
				)
			end
		end

		if (
			playing_card.base.value == "Jack"
			and not SMODS.has_no_rank(playing_card)
			and has_no_modifiers
			and not playing_card.ovn_targetted_by_master -- flag added by Master
		) then
			table.insert(jack_list, playing_card)
		end
	end

	return jack_list
end



----------------------------
---- CALCULATION MACROS ----
----------------------------



---@class CorruptedFromContext
---@field ovn_corrupted_from true
---@field ovn_former_form_key string Corresponds to the key of an item.
---@field ovn_former_form_ability {string: any}|nil If Joker was corrupted into something new, this is its ability table prior to corruption.

---@class CorruptionOccurredContext
---@field ovn_corruption_occurred true
---@field ovn_corruption_type "Joker"|"Enhancement"|"Seal"
---@field ovn_former_form_key string Corresponds to the key an item.
---@field ovn_corrupted_card Card|nil The card that experienced the corruption.

---@class PurifiedFromContext
---@field ovn_corrupted_from true
---@field ovn_former_form_key string Corresponds to the key of an item.
---@field ovn_former_form_ability {string: any}|nil If Joker was purified into something new, this is its ability table prior to purification.

---@class PurificationOccurredContext
---@field ovn_purification_occurred true
---@field ovn_purification_type "Joker"|"Enhancement"|"Seal"
---@field ovn_former_form_key string Corresponds to the key an item.
---@field ovn_purified_card Card|nil The card that experienced the purification.

-- Prepares a context table corresponding to `ovn_corrupted_from`.
---@param key string
---@param ability? {string: any}
---@return CorruptedFromContext
Ovn_f.calculate_corrupted_from = function(key, ability)
	return {
		ovn_corrupted_from = true,
		ovn_former_form_key = key,
		ovn_former_form_ability = ability
	}
end

-- Prepares a context table corresponding to `ovn_corruption_occurred`.
---@param corruption_type string
---@param key string
---@param corrupted_card? Card
---@return CorruptionOccurredContext
Ovn_f.calculate_corruption_occurred = function(corruption_type, key, corrupted_card)
	return {
		ovn_corruption_occurred = true,
		ovn_corruption_type = corruption_type,
		ovn_former_form_key = key,
		ovn_corrupted_card = corrupted_card
	}
end

-- Prepares a context table corresponding to `ovn_purified_from`.
---@param key string
---@param ability? {string: any}
---@return PurifiedFromContext
Ovn_f.calculate_purified_from = function(key, ability)
	return {
		ovn_purified_from = true,
		ovn_former_form_key = key,
		ovn_former_form_ability = ability
	}
end

-- Prepares a context table corresponding to `ovn_purification_occurred`.
---@param purification_type string
---@param key string
---@param purified_card? Card
---@return PurificationOccurredContext
Ovn_f.calculate_purification_occurred = function(purification_type, key, purified_card)
	return {
		ovn_purification_occurred = true,
		ovn_purification_type = purification_type,
		ovn_former_form_key = key,
		ovn_purified_card = purified_card
	}
end



------------------------
---- OTHER GAMEPLAY ----
------------------------

-- Changes blind requirement.
---@param mod number
---@return nil
Ovn_f.ease_blind_requirement = function(mod)
	if not G.GAME.blind.in_blind then return end
	add_simple_event('immediate', nil, function ()
		local blind_req_UI = G.HUD_blind:get_UIE_by_ID('HUD_blind_count') --[[@as UIElement]]
		mod = mod or 0

		G.GAME.blind.chips = G.GAME.blind.chips + mod
		G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
		G.HUD_blind:recalculate()
		blind_req_UI:juice_up()
	end)
end

-- Temporarily changes hand size, just for the round.
---@param amount integer
---@return nil
Ovn_f.temp_handsize_change = function(amount)
	G.hand:change_size(amount)
	G.GAME.round_resets.temp_handsize = (G.GAME.round_resets.temp_handsize or 0) + math.floor(amount)
end

-- Sets a guaranteed modifier (enhancement, seal, edition) on a card,\
-- if it doesn't have one already.
---@param card Card
---@param card_index number
---@return nil
Ovn_f.guaranteed_modifier = function(card, card_index)
	if ( -- skip if card already has modifier
		next(SMODS.get_enhancements(card) --[[@as table]])
		or card.seal
		or card.edition
	) then return end

	card_index = card_index or ""
	-- 1 = enhancement
	-- 2 = seal
	-- 3 = edition
	local modifier_weights = {1, 1, 1, 2, 2, 3}
	local function seedkey(input)
		return (
			"ovn_guaranteed_modifier"
			.. (input and ("_" .. input) or "")
			.. card_index
		)
	end

	-- Set the first modifier applied
	local selected_modifier = pseudorandom_element(modifier_weights, seedkey("modweight"))
	if selected_modifier == 1 then
		local enhancement = SMODS.poll_enhancement{
			guaranteed = true,
			type_key = seedkey("enhancement")
		}
		if enhancement then card:set_ability(enhancement) end
	elseif selected_modifier == 2 then
		card:set_seal(SMODS.poll_seal{
			guaranteed = true,
			type_key = seedkey("seal")
		})
	elseif selected_modifier == 3 then
		card:set_edition(poll_edition(
			seedkey("edition"),
			nil, true, true
		))
	end

	-- Set the rest of the modifiers, but only if chance is struck
	if selected_modifier ~= 1 then
		local enhancement = SMODS.poll_enhancement{
			key = seedkey("enhancement_2_chance"),
			type_key = seedkey("enhancement_2")
		}
		if enhancement then card:set_ability(enhancement) end
	end
	if selected_modifier ~= 2 then
		card:set_seal(SMODS.poll_seal{
			key = seedkey("seal_2_chance"),
			type_key = seedkey("seal_2")
		})
	end
	if selected_modifier ~= 3 then
		card:set_edition(poll_edition(
			seedkey("edition_2"),
			nil, true, false, {
				"e_polychrome",
				"e_holo",
				"e_foil"
			}
		))
	end
end

-- Updates the hands last-played tracker.
---@param scoring_name string|nil
---@return nil
Ovn_f.update_hands_last_played = function(scoring_name)
	for key,count in pairs(G.GAME.hands_last_played) do
		if G.GAME.hands_last_played[key] ~= -1 then
			G.GAME.hands_last_played[key] = count + 1
		end
	end
	if scoring_name then
		G.GAME.hands_last_played[scoring_name] = 0
	end
end

-- Plays the Event Horizon juice animation when Black Hole is used.
---@param card Card
---@param all_event_horizons Card[]
---@return nil
Ovn_f.blackhole_upgrade_eventhorizon = function(card, all_event_horizons)
	for i,event_horizon in ipairs(all_event_horizons) do
		local speed = 1 + (i-1)*0.1
		-- Mult
		Ovn_f.add_simple_event('after', 0.2/speed, function ()
			play_sound('tarot1')
			if card then card:juice_up(0.8, 0.5) end
			event_horizon:juice_up(0.8, 0.5)
			card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
				message = localize('k_upgrade_ex'),
				colour = G.C.MULT,
				instant = true
			})
		end)
		-- Chip
		Ovn_f.add_simple_event('after', 0.9/speed, function ()
			play_sound('tarot1')
			if card then card:juice_up(0.8, 0.5) end
			event_horizon:juice_up(0.8, 0.5)
			card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
				message = localize('k_upgrade_ex'),
				colour = G.C.CHIPS,
				instant = true
			})
		end)
		if i == #all_event_horizons then
			speed = 1
		end
		delay(1.3/speed)
	end
	for hand_key in pairs(G.GAME.hands) do
		level_up_hand(card, hand_key, true)
	end
end

-- Skips blind without needing a button attached
---@return nil
function Ovn_f.detached_skip_blind()
    stop_use()
    G.CONTROLLER.locks.skip_blind = true
    G.E_MANAGER:add_event(Event({
        no_delete = true,
        trigger = 'after',
        blocking = false,blockable = false,
        delay = 2.5,
        timer = 'TOTAL',
        func = function()
          G.CONTROLLER.locks.skip_blind = nil
          return true
        end
      }))
    local _tag = Tag(G.GAME.round_resets.blind_tags[G.GAME.blind_on_deck])
    G.GAME.skips = (G.GAME.skips or 0) + 1
    if _tag then
      add_tag(_tag)
      local skipped, skip_to = G.GAME.blind_on_deck or 'Small',
      G.GAME.blind_on_deck == 'Small' and 'Big' or G.GAME.blind_on_deck == 'Big' and 'Boss' or 'Boss'
      G.GAME.round_resets.blind_states[skipped] = 'Skipped'
      G.GAME.round_resets.blind_states[skip_to] = 'Select'
      G.GAME.blind_on_deck = skip_to
      play_sound('generic1')
      G.E_MANAGER:add_event(Event({
        trigger = 'immediate',
        func = function()
          delay(0.3)
          for i = 1, #G.jokers.cards do
            G.jokers.cards[i]:calculate_joker({skip_blind = true})
          end
          save_run()
          for i = 1, #G.GAME.tags do
            G.GAME.tags[i]:apply_to_run({type = 'immediate'})
          end
          for i = 1, #G.GAME.tags do
            if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
          end
          return true
        end
      }))
    end
  end
