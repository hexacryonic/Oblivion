--------------------------
-- Supplementary functions
--------------------------
local add_simple_event = Ovn_f.add_simple_event
to_big = to_big or function(x)
	return x
end
local function achievement_get(key)
	return SMODS.Achievements["ach_ovn_" .. key].earned
end

----------------

--------------
-- Ocular Deck
--------------
SMODS.Back { key = "ocular",
	pos = { x = 0, y = 0 },
	atlas = "decks",

	apply = function(self)
		G.GAME.ovn_has_ocular = true
		G.GAME.starting_params.extra_cards = G.GAME.starting_params.extra_cards or {}

		local ranks = {"A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"}
		for _,rank in ipairs(ranks) do
			table.insert(G.GAME.starting_params.extra_cards, {s='ovn_O',r=rank})
		end
	end,
}

----------------

-------------------
-- Corrupt Red Deck
-------------------
SMODS.Back { key = "c_red",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
	pos = { x = 0, y = 0 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("red_rum") then return true end
	end,

	calculate = function(self, card, context)
		if context.after then add_simple_event(nil, nil, function ()
			local any_selected = nil
			local discarded_cards = {}
			for _,hand_card in ipairs(G.hand.cards) do
				table.insert(discarded_cards, hand_card)
			end

			for i = 1, 5 do
				if G.hand.cards[i] then
					local selected_card, card_key = pseudorandom_element(discarded_cards, pseudoseed("CRed"))
					G.hand:add_to_highlighted(selected_card, true)
					table.remove(discarded_cards, card_key --[[@as integer]])
					any_selected = true
				end
			end

			if any_selected then
				delay(1.5)
				G.FUNCS.discard_cards_from_highlighted(nil, true)
			end
		end) end
	end,
}

--------------------
-- Corrupt Blue Deck
--------------------
SMODS.Back { key = "c_blue",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
	pos = { x = 1, y = 0 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("blue_blitz") then return true end
	end,

	apply = function(self)
		G.GAME.starting_params.hands = G.GAME.starting_params.hands + 2
	end,

	calculate = function(self, card, context)
		G.GAME.round_resets.hands = G.GAME.current_round.hands_left --[[@as integer]]
		if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
			G.GAME.round_resets.hands = G.GAME.round_resets.hands + 3
		end
	end,
}

----------------------
-- Corrupt Yellow Deck
----------------------
SMODS.Back { key = "c_yellow",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
	pos = { x = 2, y = 0 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("yellow_yearlong") then return true end
	end,

	apply = function(self)
		G.GAME.cy_dollarsperante = 120
		G.GAME.cy_handcost = 10
		G.GAME.cy_discardcost = 5
		G.GAME.modifiers.money_per_hand = 0
		G.GAME.round_resets.hands = G.GAME.cy_handcost
		G.GAME.round_resets.discards = G.GAME.cy_discardcost
		G.GAME.c_yellow_current_round = {
			hands_cost = "$" .. G.GAME.cy_handcost,
			discard_cost = "$" .. G.GAME.cy_discardcost
		}

		add_simple_event(nil, nil, function ()
			ease_dollars(G.GAME.cy_dollarsperante)
		end)
	end,

	calculate = function(self, card, context)
		if context.before then
			ease_dollars(-G.GAME.cy_handcost)
			delay(0.2)
		end

		if context.pre_discard then
			ease_dollars(-G.GAME.cy_discardcost)
		end

		if context.starting_shop then
			G.GAME.gave_money = false
		end

		if context.beat_boss and not G.GAME.gave_money then
			add_simple_event(nil, nil, function()
				Ovn_f.ease_hand_cost(math.floor(G.GAME.cy_handcost * 1.25 - G.GAME.cy_handcost))
				delay(0.75)
				Ovn_f.ease_discard_cost(math.floor(G.GAME.cy_discardcost * 1.25 - G.GAME.cy_discardcost))
				delay(1)
				ease_dollars(G.GAME.cy_dollarsperante)
			end)
			G.GAME.gave_money = true
		end

		if G.GAME.dollars >= (math.floor(G.GAME.dollars) + math.floor(G.GAME.dollars)) then
			G.STATE = G.STATES.GAME_OVER
			G.STATE_COMPLETE = false
		end
	end,
}

---------------------
-- Corrupt Green Deck
---------------------
SMODS.Back { key = "c_green",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
	pos = { x = 3, y = 0 },

	unlocked = false,
	check_for_unlock = function (self, args)
		if achievement_get("groundless_greenery") then return true end
	end,

	apply = function (self)
		G.GAME.dollars_i = 0
		G.GAME.dollars_complex = tostring(G.GAME.dollars)
		Ovn_f.ease_complex_dollars(0,0)
		G.GAME.modifiers.money_per_hand = 1
        G.GAME.modifiers.money_per_discard = 1 -- i
	end
}

---------------------
-- Corrupt Black Deck
---------------------
SMODS.Back { key = "c_black",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
    pos = { x = 4, y = 0 },

	unlocked = false,
	check_for_unlock = function (self, args)
        if achievement_get("bleakest_blackout") then return true end
	end,

	apply = function(self)
        G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots + 4
        G.GAME.starting_params.hands = G.GAME.starting_params.hands - 1
        G.GAME.starting_params.discards = G.GAME.starting_params.discards - 1
        G.GAME.starting_params.consumable_slots = G.GAME.starting_params.consumable_slots - 1
        G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size - 1
	end
}

---------------------
-- Corrupt Ghost Deck
---------------------
SMODS.Back { key = "c_ghost",
	ovn_corrupt_deck = true,
	config = { spectral_rate = 6 },

	atlas = "decks_corrupt",
	pos = { x = 2, y = 1 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("ghostly_gall") then return true end
	end,

	apply = function(self)
		G.GAME.ovn_cghost = true
		G.GAME.ovn_cghost_ghostspec = nil
		G.GAME.ovn_cghost_pseudorandom = {}
	end,

	calculate = function(self, card, context)
		if context.setting_blind then
			G.GAME.ovn_cghost_first_hand_drawn = false
		end

		if context.first_hand_drawn or (
			not G.GAME.ovn_cghost_first_hand_drawn
			and context.ovn_run_started
			and G.STATE == G.STATES.SELECTING_HAND
		) then
			add_simple_event(nil, nil, function ()
				Ovn_f.activate_ghostly_adversary()
			end)

			add_simple_event(nil, nil, function ()
				G.GAME.ovn_cghost_first_hand_drawn = true
			end)
		end
	end,
}

-----------------------
-- Corrupt Abandoned Deck
-----------------------
SMODS.Back { key = "c_abandoned",
	ovn_corrupt_deck = true,
	loc_vars = function (self, info_queue, card)
		return {vars = {
			self.config.tag_count,
			localize { type = 'name_text', key = 'tag_standard', set = 'Tag' }
		}}
	end,
	config = {
		tag_count = 10,
		ovn_empty_deck = true,
	},

	atlas = "decks_corrupt",
    pos = { x = 3, y = 1 },

	unlocked = false,
	check_for_unlock = function (self, args)
        if achievement_get("absolved_abandonment") then return true end
	end,

	apply = function (self)
		add_simple_event('immediate', nil, function()
			for _ = 1, self.config.tag_count do
				add_tag(Tag("tag_standard"))
			end
		end)
    end,
}

-----------------------
-- Corrupt Painted Deck
-----------------------
SMODS.Back { key = "c_painted",
	ovn_corrupt_deck = true,

	atlas = "decks_corrupt",
	pos = { x = 1, y = 2 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("painted_paladin") then return true end
	end,

	apply = function(self)
		G.GAME.joker_rate = 0
		G.GAME.starting_params.joker_slots = 0
		G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + 5
		-- Booster Packs
		G.GAME.banned_keys["p_buffoon_normal_1"] = true
		G.GAME.banned_keys["p_buffoon_normal_2"] = true
		G.GAME.banned_keys["p_buffoon_jumbo_1"] = true
		G.GAME.banned_keys["p_buffoon_mega_1"] = true
		-- Consumables
		G.GAME.banned_keys["c_judgement"] = true
		G.GAME.banned_keys["c_wraith"] = true
		G.GAME.banned_keys["c_soul"] = true
		G.GAME.banned_keys["v_antimatter"] = true
		-- Tags
		G.GAME.banned_keys["tag_uncommon"] = true
		G.GAME.banned_keys["tag_rare"] = true
		G.GAME.banned_keys["tag_negative"] = true
		G.GAME.banned_keys["tag_foil"] = true
		G.GAME.banned_keys["tag_holographic"] = true
		G.GAME.banned_keys["tag_polychrome"] = true
		G.GAME.banned_keys["tag_buffoon"] = true
		G.GAME.banned_keys["tag_top_up"] = true
		-- Blinds
		G.GAME.banned_keys["bl_final_heart"] = true
		G.GAME.banned_keys["bl_final_leaf"] = true
		G.GAME.banned_keys["bl_final_acorn"] = true
	end,

	calculate = function(self, card, context)
		if context.repetition and context.other_card.ability.effect ~= "Base" then
			return {
				message = localize("k_again_ex"),
				repetitions = 1,
			}
		end
	end,
}

----------------------
-- Corrupt Plasma Deck
----------------------
Oblivion.DescriptionDummy { key = "instability_description" }

SMODS.Back { key = "c_plasma",
	ovn_corrupt_deck = true,
	loc_vars = function(self, info_queue, back)
		return { vars = {
			localize { type = 'name_text', key = 'dd_ovn_instability_description', set = 'DescriptionDummy' },
			localize { type = 'name_text', key = self.config.jokers[1], set = 'Joker' },
			localize { type = 'name_text', key = self.config.consumables[1], set = 'Tarot' },
			localize { type = 'name_text', key = self.config.consumables[2], set = 'Tarot' },
		} }
	end,

	atlas = "decks_corrupt",
	pos = { x = 3, y = 2 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("plasma_plight") then return true end
	end,

	config = {
		consumables = {'c_ovn_abyss', 'c_ovn_perception'},
		jokers = {'j_joker'}
	},

	apply = function(self)
		G.GAME.corrumod = 0.2
		G.GAME.opticmod = 0.025
		G.GAME.opticclamp = 2
		-- Scoring calculation set in Game:start_run hook
	end,

	calculate = function(self, card, context)
		if context.after then
			Oblivion.play_instability_noise = true
			Ovn_f.change_instability(-0.05)
		end
	end,
}

-----------------------
-- Corrupt Erratic Deck
-----------------------

-- THANK YOU MARIO!
-- YOUR QUEST IS OVER.
-- WE PRESENT YOU A NEW QUEST:

SMODS.DynaTextEffect { key = "c_erratic_desc",
	func = function(dynatext, index, letter)
		-- ignore spaces
		local og_char = dynatext.strings[1].letters[index].char
		if og_char == " " then return end

		local rnd = math.random(33, 126)
		local char = string.char(rnd)
		letter.letter:set(char)
	end,
}

SMODS.Shader {
	key = "crt_override",
	path = "CRTOverride.fs",
}

SMODS.Back {
	key = "c_erratic",
	ovn_corrupt_deck = true,
	atlas = "decks_corrupt",
	pos = { x = 4, y = 2 },

	unlocked = false,
	check_for_unlock = function(self, args)
		if achievement_get("erratic_eruption") then
			return true
		end
	end,

	apply = function(self)
		G.GAME.c_erratic = true -- good luck.
		G.GAME.override_crt = true
		G.GAME.erratic_fx_block_probability = 0
		G.GAME.erratic_fx_matrix_colour = HEX("00ff00")

		add_simple_event(nil, nil, function()
			Ovn_f.erratic_randomize_deck("starting_deck")
		end)
	end,

	calculate = function(self, card, context)
		if context.end_of_round and context.main_eval then
            local intensity = Ovn_f.get_erratic_intensity()

            -- Randomize deck again
			if context.beat_boss then
				Ovn_f.erratic_randomize_deck("post_boss")
			end

            -- Increase glitchiness of entire screen
			Ovn_f.set_glitch_vfx(intensity)

			-- Change cardarea sizes
			local max_lost = 1
			local max_gained = 4
			for k, area in pairs(G.I.CARDAREA) do
				area:change_size(math.ceil(Ovn_f.round_to_nearest(Ovn_f.pseudoerratic("slots" .. k), 1 / intensity)))
				local mod = area.config.card_limits.mod
				local base = area.config.card_limits.base
				local underflow = -math.max((base + mod) - (base - max_lost), 0)
				local overflow = -math.min((base + mod) - (base + max_gained), 0)
				area:change_size(math.ceil(underflow + overflow))
			end

            -- Change current cash
			ease_dollars(math.ceil(Ovn_f.pseudoerratic("money") * 3))

			-- Visual changes
            local ui_rotate_amount = 0.0005*Ovn_f.pseudoerratic("drift1")*Ovn_f.pseudoerratic("drift2")
			Ovn_f.ui_rotation_drift(ui_rotate_amount)
			Ovn_f.colour_drift(0.002 * intensity)
			Ovn_f.card_size_random()
		end

		if context.ovn_run_started and G.STATE == G.STATES.SELECTING_HAND then
            local intensity = Ovn_f.get_erratic_intensity()

            local ui_rotate_amount = 0.0005*Ovn_f.pseudoerratic("drift1")*Ovn_f.pseudoerratic("drift2")
			Ovn_f.ui_rotation_drift(ui_rotate_amount)
			Ovn_f.colour_drift(0.002 * intensity)
			Ovn_f.card_size_random()
		end

		if context.setting_blind then
			ease_hands_played(math.ceil(Ovn_f.pseudoerratic("hands")))
			ease_discard(math.ceil(Ovn_f.pseudoerratic("hands")))
		end

		if context.destroying_card then
			if pseudorandom("cerratic_destruction") <= 0.05 then
				return { remove = true }
			end
		end

		if context.individual and context.cardarea == G.play and pseudorandom("cerratic_duplication") <= 0.05 then
			local copy = copy_card(context.other_card)
			G.hand:emplace(copy)
			copy:add_to_deck()
		end
	end,
}