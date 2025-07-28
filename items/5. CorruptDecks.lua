local add_simple_event = Oblivion.f.add_simple_event

SMODS.Back{
	key = "c_red",

	atlas = "cdeck_atlas",
	pos = { x = 0, y = 0 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.in_corrupt_red = true
		G.GAME.starting_params.discards = G.GAME.starting_params.discards + 1
	end,

	calculate = function(self, card, context)
		if context.after then add_simple_event(nil, nil, function ()
			local _cards = {}
			for _,hand_card in ipairs(G.hand.cards) do table.insert(_cards, hand_card) end

			for i = 1, 5 do if G.hand.cards[i] then
				local selected_card, card_key = pseudorandom_element(_cards, pseudoseed("CRed"))
				G.hand:add_to_highlighted(selected_card, true)
				G.FUNCS.discard_cards_from_highlighted(nil, true)
				G.hand:unhighlight_all()
			end end
		end) end
	end,
}

SMODS.Back{
	key = "c_blue",

	atlas = "cdeck_atlas",
	pos = { x = 1, y = 0 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.starting_params.hands = G.GAME.starting_params.hands + 2
	end,

	calculate = function(self, card, context)
		G.GAME.round_resets.hands = G.GAME.current_round.hands_left
		if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
			G.GAME.round_resets.hands = G.GAME.round_resets.hands + 3
		end
	end,
}

SMODS.Back{
	key = "c_yellow",

	atlas = "cdeck_atlas",
	pos = { x = 2, y = 0 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.cy_dollarsperante = 120
		G.GAME.cy_handcost = 10
		G.GAME.cy_discardcost = 5
		G.GAME.modifiers.money_per_hand = 0
		G.GAME.round_resets.hands = G.GAME.cy_handcost
		G.GAME.round_resets.discards = G.GAME.cy_discardcost
		G.GAME.current_round.hands_left = G.GAME.cy_handcost
		G.GAME.current_round.discards_left = G.GAME.cy_discardcost
		G.GAME.cy_gaveantemoney = false
		ease_dollars(G.GAME.cy_dollarsperante)
		G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + G.GAME.cy_dollarsperante
		add_simple_event(nil, nil, function () G.GAME.dollar_buffer = 0 end)
	end,

	calculate = function(self, card, context)
		G.GAME.current_round.hands_left = G.GAME.cy_handcost
		G.GAME.current_round.discards_left = G.GAME.cy_discardcost

		if context.before then
			ease_dollars(-G.GAME.cy_handcost)
			G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - G.GAME.cy_handcost
			add_simple_event(nil, nil, function () G.GAME.dollar_buffer = 0 end)
		end

		if context.pre_discard then
			ease_dollars(-G.GAME.cy_discardcost)
			G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - G.GAME.cy_discardcost
			add_simple_event(nil, nil, function () G.GAME.dollar_buffer = 0 end)
		end

		if G.GAME.round_resets.blind_states.Boss == 'Defeated' and not G.GAME.cy_gaveantemoney then
			G.GAME.cy_handcost = math.floor(G.GAME.cy_handcost * 1.25)
			G.GAME.cy_discardcost = math.floor(G.GAME.cy_discardcost * 1.25)
			ease_dollars(G.GAME.cy_dollarsperante)
			G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + G.GAME.cy_dollarsperante
			add_simple_event(nil, nil, function () G.GAME.dollar_buffer = 0 end)
			G.GAME.cy_gaveantemoney = true
		end

		if context.starting_shop then
			G.GAME.cy_gaveantemoney = false
		end

		if G.GAME.dollars >= (math.floor(G.GAME.dollars) + math.floor(G.GAME.dollars)) then
			G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false
		end
	end,
}

SMODS.Back{
	key = "c_painted",

	atlas = "cdeck_atlas",
	pos = { x = 1, y = 2 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.joker_rate = 0
		G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots - math.huge
		G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + 5
	end,

	calculate = function(self, card, context)
		if context.repetition and context.other_card.ability.effect ~= "Base" then
			return {
				message = localize("k_again_ex"),
				repetitions = 1,
				card = card,
			}
		end
	end,
}

SMODS.Back{
	key = "c_plasma",

	atlas = "cdeck_atlas",
	pos = { x = 3, y = 2 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.in_corrupt_plasma = true
		G.GAME.instability = 1
		G.GAME.corrumod = 0.2
		G.GAME.opticmod = 0.025
	end,

	calculate = function(self, card, context)
		if context.after then
			add_simple_event('immediate', 0.0, function ()
				play_sound("ovn_decrement", 1, 0.8)
				G.GAME.instability = (G.GAME.instability - 0.05)
			end)
		end
	end,
}
