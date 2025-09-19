-- lib/funcs.lua
-- These commonly called functions are used across the mod

-- 1. INTERNAL FUNCTIONS
-- 2. DECK PROPERTIES
-- 3. JOKER TRANSMUTATION
-- 4. JOKER TRANSMUTATION STATES
-- 5. MODIFIER TRANSMUTATION
-- 6. INSTABILITY
-- 7. MISCELLANEOUS



----------------------------
---- INTERNAL FUNCTIONS ----
----------------------------

local add_simple_event = Ovn_f.add_simple_event

-- Compiles all localization present in the directory <lang>, usually the name of the localization folder.\
-- I.e. on en-us.lua, <lang> = "en-us", load files in the directory \en-us.
---@param loc_table table
---@param lang string
---@return nil
function Ovn_f.compile_localization(loc_table, lang)
	local loc_folder = ("localization/%s/"):format(lang)
	local loc_path = Oblivion.mod_path .. loc_folder
	local loc_sections = {"descriptions", "misc"}

	for _,section in ipairs(loc_sections) do
		loc_table[section] = loc_table[section] or {}
		local files = NFS.getDirectoryItems(loc_path .. section)
		local folder = loc_folder .. section
		for __,file_name in ipairs(files) do
			local subsection_name = file_name:gsub(".lua", "")
			local loc_func, err = SMODS.load_file(folder .. "/" .. file_name, "Oblivion")
			if err then error(err) end

			if loc_func then
				local subloc_table = loc_func()
				loc_table[section][subsection_name] = subloc_table
			end
		end
	end
end



-------------------------
---- DECK PROPERTIES ----
-------------------------

-- Checks if the current Deck is corrupt.
---@return boolean
Ovn_f.deck_is_corrupt = function ()
	return G.GAME.selected_back and G.GAME.selected_back.effect.center.ovn_corrupt_deck or false
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

	if corrupted_card_key ~= card_key then
		card:set_ability(G.P_CENTERS[corrupted_card_key], false, true)
	end
    add_simple_event(nil, nil, function()
        play_sound("ovn_abyss")
        card:juice_up(0.3, 0.5)

		card.ability.ovn_former_form = card_key
		card:calculate_joker{
			ovn_corrupted_from = true,
			ovn_former_form_key = card_key,
			ovn_former_form_ability = ability
		}
		SMODS.calculate_context({
			ovn_corruption_occurred = true,
			ovn_corruption_type = "Joker",
			ovn_former_form_key = card_key,
			ovn_corrupted_card = card
		})

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
    add_simple_event(nil, nil, function()
        play_sound("ovn_pure")
		card:juice_up(0.3, 0.5)

		card:calculate_joker{
			ovn_purified_from = true,
			ovn_former_form_key = card_key,
			ovn_former_form_ability = ability
		}
		SMODS.calculate_context({
			ovn_purification_occurred = true,
			ovn_purification_type = "Joker",
			ovn_former_form_key = card_key,
			ovn_purified_card = card
		})
    end)
	add_simple_event('after', 1, function() G.GAME.purifyingJoker = false end)
end



------------------------------------
---- JOKER TRANSMUTATION STATES ----
------------------------------------

-- Determines whether a Joker is corruptible based on its defined corruption conditions.
---@param card_key string
---@return boolean
Ovn_f.joker_is_corruptible = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return false end

	local condition_func = Oblivion.corruption_condition[card_key]
	if condition_func == nil then return true end

	return condition_func()
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

	-- In pool if Joker's corrupt variant is not hled
	local has_corrupt_joker = Ovn_f.has_joker(corrupt_key)
	if not has_corrupt_joker then return false end

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

	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
	end

	local seal_key = card.seal
	if seal_key then
		local cseal = Oblivion.seal_corrupt
		local new_seal = cseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
		end
	end

	if transmuted then
		add_simple_event('immediate', nil, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)
		end)
	end
end

-- Transmutes a playing card's corrupted modifiers into their regular variants.
---@param card Card
---@return nil
Ovn_f.purify_modifiers = function(card)
	local transmuted = false

	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
	end

	local seal_key = card.seal
	if seal_key then
		local pseal = Oblivion.seal_purify
		local new_seal = pseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
		end
	end

	if transmuted then
		add_simple_event('immediate', nil, function()
			play_sound('ovn_pure', 1, 1.1)
			card:juice_up(0.5, 0.5)
		end)
	end
end



---------------------
---- INSTABILITY ----
---------------------

-- Changes Instability if enabled.
---@param amount number
---@return nil
Ovn_f.change_instability = function(amount)
	add_simple_event(nil, nil, function ()
		delay(0.25)
		SMODS.Scoring_Parameters.ovn_instability:modify(amount)
		update_hand_text({immediate = true, delay = 0}, {["ovn_instability"] = G.GAME.ovn_instability})
	end)
end

-- This increase of instability is used when a corrupted Joker is obtained.
---@param factor? integer
---@return nil
Ovn_f.corruption_instability = function(factor)
	factor = factor or 1
	local mod = G.GAME.corrumod or 0
	Ovn_f.change_instability(mod*factor)
end

-- This increase of instability is used when a playing card of Optics is obtained.
---@param factor? integer
---@return nil
Ovn_f.optic_instability = function(factor)
	factor = factor or 1
	local mod = G.GAME.opticmod or 0
	Ovn_f.change_instability(mod*factor)
end



-----------------------
---- MISCELLANEOUS ----
-----------------------

-- Changes blind requirement.
---@param mod number
---@return nil
Ovn_f.ease_blind_requirement = function(mod)
	if not G.GAME.blind.in_blind then return end
	add_simple_event('immediate', nil, function ()
		local blind_req_UI = G.HUD_blind:get_UIE_by_ID('HUD_blind_count') --[[@as UIElement]]
		mod = mod or 0

		G.GAME.blind.chips = G.GAME.blind.chips + mod
		G.GAME.blind.chip_text = G.GAME.blind.chips
		G.HUD_blind:recalculate()
		blind_req_UI:juice_up()
	end)
end

-- Determines whether the player is holding the Joker of specified card key.
---@param card_key string
---@return boolean
Ovn_f.has_joker = function(card_key)
	return next(SMODS.find_card(card_key)) and true or false
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
		G.GAME.hands_last_played[key] = count + 1
	end
	if scoring_name then
		G.GAME.hands_last_played[scoring_name] = 0
	end
end

-- When called, the game itself plays a random Spectral card in an adversarial manner.
-- Only works on Corrupt Ghost Deck.
---@return nil
Ovn_f.activate_ghostly_adversary = function()
	-- Select a Spectral card
	local selected_spec

	-- Ghostspec was not saved - grab one and save
	if not G.GAME.ovn_cghost_ghostspec then
		-- Determine which Spectral cards can actually be used
		local valid_specs = {}
		for spec_key, spec_info in pairs(Oblivion.spectral_logic) do
			if spec_info.usable() and not (
				next(SMODS.find_card(spec_key))
				and not Ovn_f.has_joker('j_ring_master') -- Showman
			) then
				table.insert(valid_specs, spec_key)
			end
		end

		-- If no Spectral card can be used (for some god forsaken reason)
		-- then don't even bother continuing
		if #valid_specs == 0 then
			G.GAME.ovn_cghost_ghostspec = nil
			G.GAME.ovn_cghost_pseudorandom = {}
			save_run()
			return
		end

		-- Select the Spectral card
		selected_spec = pseudorandom_element(valid_specs, pseudoseed('c_ghost'))
		G.GAME.ovn_cghost_ghostspec = selected_spec

	-- Ghostspec was saved - use it
	else
		print('N I C E   T R Y ,   P L A Y E R .')
		selected_spec = G.GAME.ovn_cghost_ghostspec
	end

	----

	-- Select playing cards, if needed
	local selected_logic = Oblivion.spectral_logic[selected_spec]
	local selected_cards = {}
	local select_areas = selected_logic.select_area()

	if selected_logic.select > 0 and #select_areas > 0 and selected_logic.card_point_calc then
		-- card_points indexes point_list in a sorted manner
		local point_list = {}
		local card_points = {} -- key number, value cards

		-- Calculate each card's point value
		for _,area in ipairs(select_areas) do
			for _,area_card in ipairs(area.cards) do
				local area_card_point = selected_logic.card_point_calc(area_card)
				if not card_points[area_card_point] then
					card_points[area_card_point] = {}
				end
				table.insert(point_list, area_card_point)
				table.insert(card_points[area_card_point], area_card)
			end
		end

		-- Time to select cards
		table.sort(point_list)
		local select_count = selected_logic.select
		while select_count > 0 do
			local max_point = point_list[#point_list]
			local point_cards = card_points[max_point]

			-- Save pseudorandom values since rerolled between sessions
			local pseudo_index = selected_logic.select - select_count + 1
			local pseudolist = G.GAME.ovn_cghost_pseudorandom
			pseudolist[pseudo_index] = pseudolist[pseudo_index] or pseudoseed('c_ghost_pick')

			-- Select card
			local random_card,i = pseudorandom_element(point_cards, pseudolist[pseudo_index])
			table.insert(selected_cards, random_card)

			table.remove(point_cards, i)
			point_list[#point_list] = nil
			select_count = select_count - 1
		end
	end

	----

	-- Run animations
	add_simple_event(nil, nil, function()
		G.CONTROLLER.locks.use = true -- Prevents interaction
		G.STATE = G.STATES.PLAY_TAROT -- Move cards like when consumable is being used
		local spectral = SMODS.add_card{
			set = 'Spectral',
			key = selected_spec,
			area = G.play,
			edition = 'e_ovn_miasma'
		}

		-- god-awful requirement of timings
		-- to prevent premature deselection crashing everything
		local function use_event(is_selectcards)
			local shorten = is_selectcards and 0 or 0.75

			add_simple_event('after', 1.5 - shorten, function()
				spectral:use_consumeable()

				add_simple_event('after', 2 - shorten, function()
					SMODS.destroy_cards(spectral)
					for _,area in ipairs(select_areas) do
						area:unhighlight_all()
					end

					-- Finishing point
					add_simple_event('after', 2.5 - shorten, function()
						G.CONTROLLER.locks.use = false
						G.STATE = G.STATES.SELECTING_HAND
						G.GAME.ovn_cghost_ghostspec = nil
						G.GAME.ovn_cghost_pseudorandom = {}
						save_run()
					end)
				end)
			end)
		end

		if #selected_cards > 0 then
			add_simple_event('after', 1, function()
				for _,selected_card in ipairs(selected_cards) do
					selected_card.area:add_to_highlighted(selected_card)
				end
				use_event(true)
			end)
		else
			use_event(false)
		end
	end)
end