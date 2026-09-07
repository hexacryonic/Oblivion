-- These commonly called functions are used across the mod

-- 1. INTERNAL FUNCTIONS
-- 2. DECK PROPERTIES
-- 3. MASTER OF PUPPETS
-- 4. OTHER GAMEPLAY



----------------------------
---- INTERNAL FUNCTIONS ----
----------------------------

-- A shorthand of adding an event to G.E_MANAGER that only defines the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value\
-- or if other parameters such as blocking require specification.
---@param trigger string | nil
---@param delay number | nil
---@param func function
---@return nil
Ovn_f.add_simple_event = function(trigger, delay, func)
	if trigger == "instant" then func(); return end
	-- This is here in Oblivion.lua so it's loaded before everything, which uses this function
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end
local add_simple_event = Ovn_f.add_simple_event

-- Adds a nested simple event to G.E_MANAGER, allowing the specified function to be cleanly delayed.\
-- Event function will always return true, so "return true" is not required.\
Ovn_f.nested_event = function (count, trigger, delay, func)
	if count == 0 then
		Ovn_f.add_simple_event(trigger, delay, func)
	else
		G.E_MANAGER:add_event(Event {function ()
			Ovn_f.nested_event(count - 1, trigger, delay, func)
			return true
		end})
	end
end

-- Adds a simple event to G.E_MANAGER that is also unblocking and unblockable.\
-- Event function will always return true, so "return true" is not required.\
Ovn_f.unblock_event = function (trigger, delay, func)
	if trigger == "instant" then func(); return end
	-- This is here in Oblivion.lua so it's loaded before everything, which uses this function
	G.E_MANAGER:add_event(Event {
		blocking = false,
		blockable = false,
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

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
