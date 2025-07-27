-- Adds an event to G.E_MANAGER that only has the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value.
---@param trigger string | nil
---@param delay number | nil
---@param func function
local function add_simple_event(trigger, delay, func)
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

----

SMODS.Shader({ key = 'miasma', path = 'miasma.fs' })

----

SMODS.Blind({
	key = 'nerve',
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = {},
	boss = {min = 1, max = 10},
	boss_colour = HEX('a876d6'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 0},

	dollars = 5,
	mult = 2,
	debuff = {
		suit = 'ovn_Optics'
	},

	in_pool = function(self)
		if not G.playing_cards then return false end
		local total_optics = 0
		for _,playing_card in pairs(G.playing_cards) do
			if playing_card:is_suit("ovn_Optics", nil, true) then
				total_optics = total_optics + 1
			end
		end
		return total_optics >= 9
	end,
})

local function transmute_jokers(mode)
	if mode ~= 'pureToCorrupt' or mode ~= 'corruptToPure' then return end
	if G.GAME.current_round.hands_left < 1 then return end
	
	for _,joker in pairs(G.jokers.cards) do
		local joker_key = joker.config.center.key
		for pure_key, corrupt_key in pairs(Oblivion.corruption_map) do
			local initial_key = 'pureToCorrupt' and pure_key or corrupt_key
			local new_key = 'pureToCorrupt' and corrupt_key or pure_key
			local transmute_sound = 'pureToCorrupt' and "ovn_abyss" or "ovn_pure"

			if joker_key == initial_key then
				add_simple_event('after', 0.4, function ()
					play_sound(transmute_sound)
					joker:start_dissolve({G.C.MONEY})

					local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, new_key)
					new_card:add_to_deck()
					G.jokers:emplace(new_card)
					new_card:juice_up(0.3, 0.5)
				end)
				break
			end
		end
	end
end

SMODS.Blind({
	key = 'purity',
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = { },
	boss = {min = 4, max = 10},
	boss_colour = HEX('d9e58a'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 1},

	dollars = 5,
	mult = 2,

	in_pool = function()
		for _,corrupt_key in pairs(Oblivion.corruption_map) do
			if SMODS.find_card(corrupt_key) then return true end
			return false
		end
	end,

	defeat = function(self, silent) transmute_jokers('corruptToPure') end,
	disable = function(self, silent) transmute_jokers('corruptToPure') end,
})

SMODS.Blind({
	key = 'stygian',
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = { },
	boss = {min = 8, max = 10, showdown = true},
	boss_colour = HEX('1538af'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 2},

	dollars = 8,
	mult = 2,

	
	set_blind = function(self, reset, silent)
		for _,playing_card in pairs(G.playing_cards) do
			if playing_card.config.center ~= G.P_CENTERS.c_base then
				playing_card:change_suit('ovn_Optics')
			end
		end
		transmute_jokers('pureToCorrupt')
	end,

	in_pool = function()
		for pure_key in pairs(Oblivion.corruption_map) do
			if SMODS.find_card(pure_key) then return true end
			return false
		end
	end,
})

----

SMODS.Tag({
	key = "corrtag",
	config = { type = "store_joker_create" },

	atlas = "ctags_atlas",
	pos = { x = 0, y = 0 },

	min_ante = 2,
	requires = "j_ovn_darkjoker",

	apply = function(self, tag, context)
		if context.type == "store_joker_create" then
			local corrupts_in_posession = { 0 }

			for _,joker in ipairs(G.jokers.cards) do
				local joker_rarity = joker.config.center.rarity
				local joker_key = joker.config.center.key

				if joker_rarity == "ovn_corrupted" and not corrupts_in_posession[joker_key] then
					corrupts_in_posession[1] = corrupts_in_posession[1] + 1
					corrupts_in_posession[joker_key] = true
				end
			end

			local new_card
			if #G.P_JOKER_RARITY_POOLS.ovn_corrupted > corrupts_in_posession[1] then
				new_card = create_card("Joker", context.area, nil, "ovn_corrupted", nil, nil, nil, "ovn_cta")
				create_shop_card_ui(new_card, "Joker", context.area)
				new_card.states.visible = false

				tag:yep("+", G.C.RARITY.ovn_corrupted, function()
					new_card:start_materialize()
					new_card.ability.couponed = true
					new_card:set_cost()
					return true
				end)
			else
				tag:nope()
			end

			tag.triggered = true
			return new_card
		end
	end,
})

SMODS.Edition {
	key = "miasma",
	config = { retriggers = 3 },
	loc_vars = function(self, info_queue, center)
		local retriggers = (
			center
			and center.edition
			and center.edition.retriggers
			or self.config.retriggers
		)
		return { vars = { retriggers } }
	end,

	shader = 'miasma',
	disable_shadow = true,
	disable_base_shader = true,
	apply_to_float = true,

	discovered = true,
	unlocked = true,
	in_shop = false,
	weight = 8,
	extra_cost = 4,
	sound = {
		sound = "ovn_e_miasma",
		per = 1,
		vol = 0.4,
	},

	calculate = function(self, card, context)
		local corrupting = false
		local dying = false

		if context.other_card == card and (
			(context.repetition and context.cardarea == G.play)
			or (context.retrigger_joker_check and not context.retrigger_joker)
		) then return {
			message = localize("k_again_ex"),
			repetitions = self.config.retriggers,
			card = card,
		} end

		if not (
			-- Conditional - Do not skip if:
			context.post_joker -- Scoring loop at post-Joker calculation
			and context.cardarea == G.jokers -- targetting Jokers
			and card.config.trigger
			and not corrupting
			and not dying
		) then goto skip_miasma_calculate end

		----

		local card_key = card.config.center.key

		-- Card is corruptable, proceed to corrupt
		if Oblivion.corruption_map[card_key] then
			corrupting = true
			add_simple_event('after', 0.0, function ()
				play_sound("ovn_abyss", 1, 0.2)
				card:start_dissolve({G.C.RARITY['ovn_corrupted']})

				local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, card_key)
				new_card:add_to_deck()
				G.jokers:emplace(new_card)
				new_card:juice_up(0.3, 0.5)
			end)

			if G.GAME.in_corrupt_plasma then add_simple_event('after', 0.7, function ()
				play_sound("ovn_increment", 1, 0.9)
				G.GAME.instability = (G.GAME.instability + G.GAME.corrumod)
			end) end
		-- Card cannot be corrupted, self-destruct
		else
			dying = true
			add_simple_event('after', 0.0, function ()
				play_sound("ovn_optic", percent, 0.2)
				card:start_dissolve({G.C.RARITY['ovn_corrupted']})
			end)
		end

		if context.final_scoring_step and context.cardarea == G.play then
			for _,scored_card in ipairs(context.scoring_hand) do
				if not scored_card.edition.ovn_miasma then goto continue_miasma_calculate_finalscoringstep end

				-- Editioned playing card is already optics, self-destruct
				if scored_card.base.suit == 'ovn_Optics' then
					if context.destroying_card then
						add_simple_event('after', 0.1, function ()
							card:start_dissolve({G.C.RARITY['ovn_corrupted']})
						end)
					end
				
				-- Editioned playing card not optics, proceed to corrupt
				else
					add_simple_event('after', 0.1, function ()
						card:change_suit('ovn_Optics')
						card:set_edition(nil, true)
						play_sound('ovn_optic', percent, 1.1)
						card:juice_up(0.3, 0.3)
					end)

					if G.GAME.in_corrupt_plasma then add_simple_event('after', 0.2, function ()
						play_sound("ovn_increment", 1, 0.9)
						G.GAME.instability = (G.GAME.instability + (G.GAME.opticmod * #G.hand.highlighted))
					end) end
				end

				::continue_miasma_calculate_finalscoringstep::
			end
		end

		::skip_miasma_calculate::

		if context.joker_main then card.config.trigger = true end
		if context.after then card.config.trigger = nil end
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_Oblivion",
	key = "oblivion",
	loc_vars = function(self, info_queue)
		table.insert(info_queue, G.P_CENTERS.e_ovn_miasma)
		return {vars = {self.config.max_highlighted}}
	end,
	config = {max_highlighted = 1},

	atlas = "cataclysm_atlas",
	pos = {x=2, y=0},

	cost = 2,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		local selected_playing_card = G.hand.highlighted

		-- idk what the value in poopshit is for -oin
		local poopshit = selected_playing_card[1] and selected_playing_card[1] == self and 1 or 0

		if (#selected_jokers + #selected_playing_card - poopshit == 1) then
			local lone_selected_joker_has_edition = #selected_jokers == 1 and selected_jokers[1].edition
			local lone_selected_pcard_has_edition = #selected_playing_card == 1 and selected_playing_card[1].edition
			
			if lone_selected_joker_has_edition or lone_selected_pcard_has_edition then
				return false
			end
			
			return true
		end
	end,

	use = function(self, card, area, copier)
		local target_cardarea = #G.jokers.highlighted == 1 and G.jokers or G.hand
		local target_card = target_cardarea.highlighted[1]
		add_simple_event(nil, nil, function ()
			play_sound('tarot1')
			target_card:set_edition({ ovn_miasma = true })
			target_card:juice_up(0.3, 0.5)
			target_cardarea:remove_from_highlighted(target_card)
		end)
	end,
}
