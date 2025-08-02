local add_simple_event = Ovn_f.add_simple_event

SMODS.Rarity({
	key = "corrupted",
	badge_colour = HEX('2349cb'),
})

-- Nyarlathotep (and W.D. Gaster with Cryptid) is internally classified as a separate rarity
-- so that it can't appear in the usual Corrupted summoning pools
SMODS.Rarity({
	key = "supercorrupted",
	badge_colour = HEX('2349cb'),
})

----

SMODS.Joker {
	key = 'john',

	atlas = 'notcorrupted',
	pos = { x = 0, y = 0 },
	
	blueprint_compat = false,
	discovered = true,
	unlocked = true,
	rarity = 2,
	cost = 6,

	calculate = function(self, card, context)
		if context.selling_self and not context.blueprint and not context.retrigger_joker then
			card_eval_status_text(
				card,
				"extra",
				nil,
				nil,
				nil,
				{ message = localize("k_plus_joker"), colour = G.C.RARITY["ovn_corrupted"] }
			)
			local new_card = create_card("Joker", G.jokers, nil, "ovn_corrupted", nil, nil, nil, "ovn_john")

			new_card:add_to_deck()
			G.jokers:emplace(new_card)
			new_card:start_materialize()
			return nil, true
		end
	end,
}

SMODS.Consumable {
	set = "Tarot",
	name = "ovn_The Abyss",
	key = "abyss",

	atlas = "abyss_atlas",
	pos = {x=0, y=0},

	cost = 2,

	in_pool = function()
		local held_jokers = G.jokers.cards
		for _,joker in ipairs(held_jokers) do
			local joker_key = joker.config.center.key
			if Oblivion.corruption_map[joker_key] then return true end
		end
		return false
	end,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Parallel Tarot', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	set_ability = function(self, card, initial, delay_sprites)
		if G.your_collection then return end

		local held_jokers = G.jokers.cards
		for _,joker in ipairs(held_jokers) do
			local joker_key = joker.config.center.key
			if not Oblivion.corruption_map[joker_key] then goto continue_ovn_The_Abyss_set_ability end

			local eval = function()
				return Ovn_f.has_joker("c_ovn_abyss") and not G.RESET_JIGGLES
			end
			juice_card_until(joker, eval, true)

			::continue_ovn_The_Abyss_set_ability::
		end
	end,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		if #selected_jokers ~= 1 then return false end

		local selected_joker = selected_jokers[1]
		local selected_joker_key = selected_joker.config.center.key
		return Ovn_f.joker_is_corruptible(selected_joker_key)
	end,

	use = function(self, card, area, copier)
		-- established by can_use that selected_card ~= nil
		local selected_card = G.jokers.highlighted[1]
		local selected_card_key = selected_card.config.center.key
		local corrupted_card_key = Oblivion.corruption_map[selected_card_key]

		G.GAME.justcorrupted = corrupted_card_key
		Ovn_f.corrupt_joker(selected_card)

		G.GAME.justcorrupted = nil
		if G.GAME.in_corrupt_plasma then
			add_simple_event('after', 0.7, function()
				play_sound("ovn_increment", 1, 0.9)
				G.GAME.instability = (G.GAME.instability + G.GAME.corrumod)
			end)
		end
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_charybdis",
	key = "charybdis",
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.create } }
	end,

	atlas = "charybdis_atlas",
	pos = {x=0, y=0},

	config = { create = 2 },
	cost = 4,

	can_use = function(self, card)
		return true
	end,
	use = function(self, card, area, copier)
		local create_count = self.config.create
		local empty_joker_slot_count = G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)
		local jokers_to_create_count = math.min(create_count, empty_joker_slot_count)

		G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create_count
		local deletable_jokers = {}
		for _,held_joker in pairs(G.jokers.cards) do
			if not held_joker.ability.eternal then
				table.insert(deletable_jokers, held_joker)
			end
		end
		
		local _first_dissolve = nil

		add_simple_event('before', 0.75, function ()
			for _,deletable_joker in ipairs(deletable_jokers) do
				deletable_joker:start_dissolve(nil, _first_dissolve)
				_first_dissolve = true
			end
		end)

		add_simple_event('after', 0.4, function ()
			for _=1,jokers_to_create_count do
				local new_card = create_card('Joker', G.jokers, nil , 'ovn_corrupted', nil, nil, nil, 'ovn_charybdis')
				new_card:add_to_deck()
				G.jokers:emplace(new_card)
				new_card:start_materialize()
				G.GAME.joker_buffer = 0
			end
		end)
		delay(0.6)
	end,
}

SMODS.Joker {
	key = 'darkjoker',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips } }
	end,
	config = { extra = { chips = 50 } },

	atlas = 'corrupted',
	pos = { x = 0, y = 0 },
	
	blueprint_compat = true,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 3,
	
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips,
			}
		end
	end
}

SMODS.Joker {
	key = 'lucasseries',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.29 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 0 },

	blueprint_compat = true,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 11,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			local rank = SMODS.Ranks[context.other_card.base.value].key
			local target_ranks = {
				["2"] = true, ["3"] = true, ["4"] = true,
				["7"] = true, ["Ace"] = true
			}
			if target_ranks[rank] then
				return {
					x_mult = card.ability.extra.xmult,
					color = G.C.MULT,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'perpendicular',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	config = { extra = { money = 1 } },
	
	atlas = 'corrupted',
	pos = { x = 1, y = 0 },

	blueprint_compat = true,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			local scored_card = context.other_card
			local scored_card_rank = SMODS.Ranks[scored_card.base.value].key

			for _,held_card in ipairs(G.hand.cards) do
				local held_card_rank = held_card.base.value

				if scored_card_rank == held_card_rank then
					G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.money
					return {
						dollars = card.ability.extra.money,
						func = function()
							G.E_MANAGER:add_event(Event {func = function()
								G.GAME.dollar_buffer = 0
								return true
							end})
						end
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'yolo',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.5 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 1 },

	blueprint_compat = true,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.before and context.cardarea == G.jokers then
			ease_hands_played(-G.GAME.current_round.hands_left)
			G.GAME.current_round.hands_left = 'nan'
			G.GAME.yolo = true
			return nil, true
		end
		
		if context.individual and context.cardarea == G.play then
			return {
				x_mult = card.ability.extra.xmult,
				color = G.C.MULT,
				card = card
			}
		end
		
		if G.GAME.yolo then
			if G.GAME.current_round.hands_played > 0 and G.GAME.chips/G.GAME.blind.chips < 1 then
				G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false
				return true
			end
			
			if context.end_of_round and context.cardarea == G.jokers and not context.game_over then
				G.GAME.yolo = false
				return nil, true
			end
		end
	end,
}

SMODS.Joker {
	key = 'supplydrop',
	loc_vars = function(self, info_queue, center)
		local stored = (
			G.PROFILES[G.SETTINGS.profile].ovn_supply_drop
			and localize{
				type = "name_text",
				set = "Joker",
				key = G.PROFILES[G.SETTINGS.profile].ovn_supply_drop
			}
			or localize("k_none")
		)
		return { vars = { stored } }
	end,

	atlas = 'corrupted',
	pos = { x = 3, y = 1 },

	blueprint_compat = false,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.selling_self and not context.retrigger_joker and not context.blueprint then
			for i = 2, #G.jokers.cards do
				if G.jokers.cards[i] == card then

					local left_joker = G.jokers.cards[i-1]
					local left_joker_rarity = left_joker.config.center.rarity

					-- greater than rarity or not corrupted
					if not (
						left_joker_rarity < 3
						or left_joker_rarity == "ovn_corrupted"
					) then break end

					local save_file = G.PROFILES[G.SETTINGS.profile]
					if not save_file.ovn_supply_drop then
						local left_joker_key = left_joker.config.center.key
						save_file.ovn_supply_drop = left_joker_key

						add_simple_event('after', 0.1, function ()
							left_joker:start_dissolve({G.C.RARITY['ovn_corrupted']})
						end)
						card_eval_status_text(
							card,
							"extra",
							nil,
							nil,
							nil,
							{ message = localize("stored"), colour = G.C.DARK_EDITION }
						)
					end
					break
				end
			end
		end
	end,

	add_to_deck = function(self, card, from_debuff)
		if from_debuff then return end
		if not G.PROFILES[G.SETTINGS.profile].ovn_supply_drop then return end

		local stored_card = create_card("Joker", G.joker, nil, nil, nil, nil, G.PROFILES[G.SETTINGS.profile].ovn_supply_drop)
		stored_card:add_to_deck()
		G.jokers:emplace(stored_card)
		G.PROFILES[G.SETTINGS.profile].ovn_supply_drop = nil
		return {
			card_eval_status_text(stored_card, "extra", nil, nil, nil, {
				message = localize("empty"),
				colour = G.C.DARK_EDITION,
			}),
		}
	end,
}

SMODS.Joker {
	key = 'pmo',

	atlas = 'corrupted',
	pos = { x = 3, y = 0 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,
}

SMODS.Joker {
	key = 'showneverends',

	atlas = 'corrupted',
	pos = { x = 1, y = 2 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	-- Functionality implemented in Card:update hook
}

SMODS.Joker {
	key = 'airstrike',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 0.2 } },
	
	atlas = 'corrupted',
	pos = { x = 0, y = 2 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function (self, card, context)
		if context.individual and (context.cardarea == 'unscored' or context.cardarea == G.hand) then
			context.other_card.ability.perma_x_mult = (
				(context.other_card.ability.perma_x_mult or 0)
				+ card.ability.extra.xmult
			)
		end

		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card.base.value == '10'
		) then context.other_card.ability.perma_x_mult = 0 end
	end
}

SMODS.Joker {
	key = 'bombastic',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 13 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 2 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'insightful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	config = { extra = { chips = 110 } },

	atlas = 'corrupted',
	pos = { x = 3, y = 2 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				chips = card.ability.extra.chips,
			}
		end
	end
}

SMODS.Joker {
	key = 'breach',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { xmult = 4 } },
	
	atlas = 'corrupted',
	pos = { x = 2, y = 1 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end
}

SMODS.Joker {
	key = 'prideful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 6 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 2 },

	blueprint_compat = true,
	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card:is_suit("ovn_Optics")
		) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'cultivar',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.Xmult,
			G.GAME.probabilities.normal or 1,
			card.ability.extra.odds
		}}
	end,
	config = { extra = { Xmult = 4, odds = 4 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end

		if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
			local extinct_odds = G.GAME.probabilities.normal / card.ability.extra.odds
			if pseudorandom('cultivar') >= extinct_odds then return { message = 'Safe!' } end

			-- Odd is hit
			add_simple_event(nil, nil, function ()
				play_sound('tarot1')
				card.T.r = -0.2
				card:juice_up(0.3, 0.4)
				card.states.drag.is = true
				card.children.center.pinch.x = true

				G.E_MANAGER:add_event(Event {
					trigger = 'after',
					delay = 0.3,
					blockable = false,
					func = function()
						G.jokers:remove_card(card)
						card:remove()
						card = nil
						return true;
					end
				})
			end)

			G.GAME.pool_flags.gros_michel_extinct = false
			G.GAME.corruptiblemichel = true
			return { message = 'Extinct!' }
		end
	end
}

SMODS.Joker {
	key = 'apartfalling',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.x_mult,
			card.ability.extra.extra
		}}
	end,
	config = {
		extra = {
			extra = 0.75,
			x_mult = 1,
		},
	},

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,
	calculate = function(self, card, context)
		if context.joker_main and card.ability.extra.x_mult > 1 then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end

		if context.ovn_corruption_occurred and context.ovn_corruption_type == "Joker" then
			card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.extra
			card_eval_status_text(card, "extra", nil, nil, nil, {
				message = localize {
					type = "variable",
					key = "a_xmult",
					vars = { card.ability.extra.x_mult },
				},
			})
			return nil, true
		end
	end
}

SMODS.Joker {
	key = 'aeon',
	config = { extra = { Xmult = 4} },
	loc_vars = function(self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.j_cavendish)
		return {vars = {
			card.ability.extra.Xmult,
		}}
	end,

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end
	end
}