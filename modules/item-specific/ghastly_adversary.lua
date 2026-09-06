-- modules/item-specific/ghastly_adversary.lua
-- This thing's pretty big, hence own file

-- Other files associated with the ghastly adversary/Corrupt Ghost Deck:
---- items/3-0. Decks.lua         - Corrupt Ghost Deck register
---- data/corrupt_ghost_logic.lua - Logic for Spectral Card usage

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. FUNCTIONS



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

-- Selects a random Spectral card, if not yet chosen from the previous load.
---@return string|nil If nil, no Spectral card can be used.
local function ghast_select_spec()
	local selected_spec

	-- Ghostspec was NOT SAVED - grab one and save
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

	-- Ghostspec was SAVED - use it
	else
		print('N I C E   T R Y ,   P L A Y E R .')
		selected_spec = G.GAME.ovn_cghost_ghostspec
	end

	return selected_spec
end

-- Prepare a table of randomly selected cards.
-- (also returns select areas)
---@param spectral_key string
---@return table
---@return table[]
local function ghast_select_cards(spectral_key)
	local selected_cards = {}

	local selected_logic = Oblivion.spectral_logic[spectral_key]
	local select_areas = selected_logic.select_area and selected_logic.select_area() or {}

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

	return selected_cards, select_areas
end



-------------------
---- FUNCTIONS ----
-------------------

-- When called, the game itself plays a random Spectral card in an adversarial manner.
-- Only works on Corrupt Ghost Deck.
---@return nil
Ovn_f.activate_ghostly_adversary = function()
	local selected_spec = ghast_select_spec()
	if not selected_spec then return end
	local selected_cards, select_areas = ghast_select_cards(selected_spec)

	-- Run animations
	Ovn_f.add_simple_event(nil, nil, function()
		G.CONTROLLER.locks.use = true -- Prevents interaction
		G.STATE = G.STATES.PLAY_TAROT -- Move cards like when consumable is being used
		local spectral = SMODS.add_card{
			set = 'Spectral',
			key = selected_spec,
			area = G.play,
			edition = 'e_ovn_miasma'
		}

		local event_sequence = {}
		---@param delay number
		---@param event_func function
		local function add_seq(delay, event_func)
			table.insert(event_sequence, {delay, event_func})
		end

		if #selected_cards > 0 then
			add_seq(1, function ()
				for _,selected_card in ipairs(selected_cards) do
					selected_card.area:add_to_highlighted(selected_card)
				end
			end)
		end
		add_seq(0.5, function ()
			spectral:use_consumeable()
		end)
		add_seq(0.5, function ()
			SMODS.destroy_cards(spectral)
			for _,area in ipairs(select_areas) do
				area:unhighlight_all()
			end
		end)
		add_seq(0.5, function ()
			G.CONTROLLER.locks.use = false
			G.STATE = G.STATES.SELECTING_HAND
			G.GAME.ovn_cghost_ghostspec = nil
			G.GAME.ovn_cghost_pseudorandom = {}
			save_run()
		end)

		Ovn_f.event_sequence(event_sequence)
	end)
end