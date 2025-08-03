local add_simple_event = Ovn_f.add_simple_event

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
			local any_selected = nil
			local discarded_cards = {}
			for _,hand_card in ipairs(G.hand.cards) do
				table.insert(discarded_cards, hand_card)
			end

			for i = 1, 5 do
				if G.hand.cards[i] then
					local selected_card, card_key = pseudorandom_element(discarded_cards, pseudoseed("CRed"))
					G.hand:add_to_highlighted(selected_card, true)
					table.remove(discarded_cards, card_key)
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
	key = "c_ghost",
	config = { spectral_rate = 6 },

	atlas = "cdeck_atlas",
	pos = { x = 2, y = 1 },

	apply = function(self)
		G.GAME.in_corrupt = true
		G.GAME.ovn_first_hand_drawn = false

		G.ovn_ghostspec = CardArea(
			G.ROOM.T.x + 9,
			G.ROOM.T.y,
			G.CARD_W*1.1,
			1.05*G.CARD_H,
			{card_limit = 1, type = 'consumeable', highlight_limit = 0}
		)
	end,

	calculate = function(self, card, context)
		if context.setting_blind then
			G.GAME.ovn_first_hand_drawn = false
		end

		if context.hand_drawn and not G.GAME.ovn_first_hand_drawn then
			G.GAME.ovn_first_hand_drawn = true
			local speclogic = Oblivion.spectral_logic
			local valid_specs = {}
			for spec_key, spec_info in pairs(speclogic) do
				if spec_info.usable() and not next(SMODS.find_card(spec_key)) then
					table.insert(valid_specs, spec_key)
				end
			end

			local selected_spec = pseudorandom_element(valid_specs, pseudoseed('c_ghost'))
			local logic = speclogic[selected_spec]
			print(selected_spec)
			local selected_cards = {}
			
			if logic.select > 0 and #logic.select_area > 0 and logic.card_point_calc then
				print("poopshit")
				local point_list = {}
				local card_points = {} -- key number, value cards
				for _,area in ipairs(logic.select_area) do
					for _,area_card in ipairs(G[area].cards) do
						local area_card_point = logic.card_point_calc(area_card)
						if not card_points[area_card_point] then
							card_points[area_card_point] = {}
							table.insert(point_list, area_card_point)
						end
						table.insert(card_points[area_card_point], area_card)
					end
				end

				table.sort(point_list)
				local select_count = logic.select
				while select_count > 0 do
					local max_point = point_list[#point_list]
					local point_cards = card_points[max_point]

					local random_card,i = pseudorandom_element(point_cards, pseudoseed('c_ghost_pick'))
					table.insert(selected_cards, random_card)

					table.remove(point_cards, i)
					if #point_cards == 0 then point_list[#point_list] = nil end
					select_count = select_count - 1
				end
			end

			add_simple_event(nil, nil, function()
				local spectral = SMODS.add_card{
					set = 'Spectral',
					key = selected_spec,
					area = G.ovn_ghostspec,
					edition = 'e_negative'
				}
				spectral.states.click.can = false
				spectral.states.hover.can = false
				spectral.states.drag.can = false

				local function use_event(is_selected)
					local mu = is_selected and 0 or 1
					add_simple_event('after', 1.5 - mu, function()
						spectral:use_consumeable()
						add_simple_event('after', 2 - mu, function()
							SMODS.destroy_cards(spectral)
							for _,area in ipairs(logic.select_area) do
								G[area]:unhighlight_all()
							end
						end)
					end)
				end

				if #selected_cards > 0 then
					add_simple_event('after', 1, function()
						for _,selected_card in ipairs(selected_cards) do
							selected_card:click()
						end
						use_event(true)
					end)
				else use_event(false) end
			end)
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
		G.GAME.banned_keys["p_buffoon_normal_1"] = true
		G.GAME.banned_keys["p_buffoon_normal_2"] = true
		G.GAME.banned_keys["p_buffoon_jumbo_1"] = true
		G.GAME.banned_keys["p_buffoon_mega_1"] = true
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

-- Dummy Joker used solely to hold the Instability tooltip
SMODS.Joker {
	key = "instabilitytooltip",
	no_collection = true,
	unlocked = false,
	discovered = false,
	check_for_unlock = function() return false end,
	in_pool = function() return false end,
}

SMODS.Back{
	key = "c_plasma",
	loc_vars = function(self, info_queue, back)
		return { vars = {
			localize { type = 'name_text', key = 'j_ovn_instabilitytooltip', set = 'Joker' },
			localize { type = 'name_text', key = self.config.jokers[1], set = 'Joker' },
			localize { type = 'name_text', key = self.config.consumables[1], set = 'Tarot' },
			localize { type = 'name_text', key = self.config.consumables[2], set = 'Tarot' },
		} }
	end,

	atlas = "cdeck_atlas",
	pos = { x = 3, y = 2 },

	config = {
		consumables = {'c_ovn_abyss', 'c_ovn_perception'},
		jokers = {'j_joker'}
	},

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
