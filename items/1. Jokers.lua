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

SMODS.Rarity({
	key = "corrupted",
	loc_txt = {name = "Corrupted"},
	badge_colour = HEX('2349cb'),
})

SMODS.Rarity({ -- Nyarlathotep (and W.D. Gaster with Cryptid) is internally classified as a separate rarity so that it can't appear in the usual Corrupted summoning pools
	key = "supercorrupted",
	loc_txt = {name = "Corrupted"},
	badge_colour = HEX('2349cb'),
})

----

SMODS.Joker {
	key = 'john',
	loc_txt = {
		name = 'John Oblivion',
		text = {
			"Creates a {C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
			"when sold"
		}
	},
	
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
	loc_txt = {
		name = 'The Abyss',
		text = {
			"{C:ovn_corrupted}Corrupt{} a selected {C:attention}Corruptible Joker{}"
		}
	},

	atlas = "abyss_atlas",
	pos = {x=0, y=0},
	cost = 2,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		if #selected_jokers == 0 or #selected_jokers >= 2 then return false end
		
		local selected_joker = selected_jokers[1]
		local selected_joker_key = selected_joker.config.center.key

		if Oblivion.corruption_map[selected_joker_key] then return true end
		return false
	end,

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
				return next(SMODS.find_card("c_ovn_abyss")) and not G.RESET_JIGGLES
			end
			juice_card_until(joker, eval, true)

			::continue_ovn_The_Abyss_set_ability::
		end
	end,

	use = function(self, card, area, copier)
		-- established by can_use that selected_card ~= nil
		local selected_card = G.jokers.highlighted[1]
		local selected_card_key = selected_card.config.center.key
		local corrupted_card_key = Oblivion.corruption_map[selected_card_key]

		G.GAME.justcorrupted = corrupted_card_key
		add_simple_event('after', 0.4, function()
			G.GAME.corruptingJoker = true
			play_sound("ovn_abyss")
			selected_card:start_dissolve({G.C.RARITY['ovn_corrupted']})
			G.jokers:remove_from_highlighted(selected_card)

			local corrupted_card = create_card("Joker", G.jokers, nil, nil, nil, nil, corrupted_card_key)
			corrupted_card:add_to_deck()
			G.jokers:emplace(corrupted_card)
			corrupted_card:juice_up(0.3, 0.5)
			G.GAME.corruptingJoker = false
		end)

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
	loc_txt = {
		name = 'Charybdis',
		text = {
			"Create {C:attention}#1#{} random {C:ovn_corrupted}Corrupted{} {C:attention}Jokers{}",
			"Destroy all other {C:attention}Jokers{}"
		}
	},
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
	loc_txt = {
		name = 'Parallel Joker',
		text = {
			"{C:chips}+#1#{} Chips",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Joker{}"
		}
	},
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
				chip_mod = card.ability.extra.chips,
				message = localize {
					type = 'variable',
					key = 'a_chips',
					vars = { card.ability.extra.chips }
				}
			}
		end
	end
}

SMODS.Joker {
	key = 'lucasseries',
	loc_txt = {
		name = 'Lucas Series',
		text = {
			"Each played",
			"{C:attention}2, 3, 4, 7,{} or {C:attention}Ace{}",
			"gives {X:mult,C:white} X#1# {} Mult when scored",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Fibonacci{}"
		}
	},
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
	loc_txt = {
		name = 'Perpendicular Parking',
		text = {
			"Scored cards earn {C:attention}$#1#{} if another",
			"card of its {C:attention}same rank{} is held in hand",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Reserved Parking{}"
		}
	},
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

			local held_cards = G.hand.cards
			for _,held_card in ipairs(held_cards) do
				local held_card_rank = held_card.base.value
				if scored_card_rank == held_card_rank then
					local money_gain = card.ability.extra.money

					G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + money_gain
					G.E_MANAGER:add_event(Event {func = function()
						G.GAME.dollar_buffer = 0
						return true
					end})

					return {
						message = localize('$') .. money_gain,
						dollars = money_gain,
						colour = G.C.MONEY
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'yolo',
	loc_txt = {
		name = 'Fuck It, We Ball',
		text = {
			"Each played card gives",
			"{X:mult,C:white} X#1# {} Mult when scored",
			"{s:0.3} {}",
			"{C:chips}-a fucktillion{} Hands",
			"when hand played",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Acrobat{}"
		}
	},
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
	loc_txt = {
		name = 'Supply Drop',
		text = {
		"Sell this Joker to {C:attention}store{} the",
		"Joker to its left, if its rarity",
		"is not higher than {C:red}Rare{}",
		"{s:0.3} {}",

		"When this Joker is sold",
		"again, even between runs,",
		"create the stored Joker",
		"and remove it from storage",
		"{s:0.3} {}",
		"{s:0.8}Currently storing: {C:attention,s:0.8}#1#",
		"{s:0.2} {}",
		"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Gift Card{}"
		}
	},
	loc_vars = function(self, info_queue, center)
		local stored = G.PROFILES[G.SETTINGS.profile].ovn_supply_drop and localize{type = "name_text", set = "Joker", key = G.PROFILES[G.SETTINGS.profile].ovn_supply_drop} or localize("k_none")
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
				if G.jokers.cards[i] ~= card then
					goto continue_ovn_supplydrop_calculate
				end

				local left_joker = G.jokers.cards[i-1]
				local left_joker_rarity = left_joker.config.center.rarity

				-- greater than rarity or not corrupted
				if left_joker_rarity > 3 or left_joker_rarity ~= "ovn_corrupted" then break end

				if not G.PROFILES[G.SETTINGS.profile].ovn_supply_drop then
					local left_joker_key = left_joker.config.center.key
					G.PROFILES[G.SETTINGS.profile].ovn_supply_drop = left_joker_key
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

				::continue_ovn_supplydrop_calculate::
			end
		end
	end,

	add_to_deck = function(self, card, from_debuff)
		if from_debuff then return end
		if not G.PORFILES[G.SETTINGS.profile].ovn_supply_drop then return end

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
	loc_txt = {
		name = 'Prosopometamorphopsia',
		text = {
			"Effects that would target",
			"{C:attention}any face card{} target {C:attention}Aces{} instead",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Pareidolia{}",
			"{s:0.3} {}",
			"{C:inactive,s:0.8}Code by Airtoum{}"
		}
	},

	atlas = 'corrupted',
	pos = { x = 3, y = 0 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	init = function(self)
		local cgi_ref = Card.get_id
		override_pmo = false

		function Card:get_id()
			local id = cgi_ref(self)
			if next(SMODS.find_card("j_ovn_pmo")) and next(SMODS.find_card("j_pareidolia")) and not override_pmo then
				id = 14
			end
			return id
		end

		--Fix issues with View Deck
		local gui_vd = G.UIDEF.view_deck
		function G.UIDEF.view_deck(unplayed_only)
			override_pmo = true
			local ret_value = gui_vd(unplayed_only)
			override_pmo = false
			return ret_value
		end
	end,

	calculate = function(self, card, context)
		return {vars = {}}
	end
}

SMODS.Joker {
	key = 'showneverends',
	loc_txt = {
		name = 'THE SHOW NEVER ENDS',
		text = {
			"{C:ovn_corrupted}Corrupted{} {C:attention}Jokers{} no longer",
			"banish or destroy their counterparts",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Showman{}"
		}
	},

	atlas = 'corrupted',
	pos = { x = 1, y = 2 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		return {vars = {}}
	end
}

SMODS.Joker {
	key = 'airstrike',
	loc_txt = {
		name = 'Air Strike',
		text = {
			"Held or unscoring {C:attention}10{}s stockpile",
			"{X:mult,C:white} X#1# {} Mult every hand played",
			"When scored, {C:attention}10{}s give their stockpiled Mult",
			"and reset their stockpile after the hand",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Walkie Talkie{}",
			"{s:0.3} {}",
			"{C:inactive,s:0.8}Art by Andromeda{}"
		}
	},
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

	calculate = function(self, card, context)
		return {vars = {}}
	end
}

SMODS.Joker {
	key = 'bombastic',
	loc_txt = {
		name = 'Bombastic Joker',
		text = {
			"{C:mult}+#1#{} Mult if played",
			"hand contains",
			"a {C:attention}Spectrum{}",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Droll Joker{}",
		}
	},
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
				message = localize({
					type = "variable",
					key = "a_mult",
					vars = { card.ability.extra.mult },
				}),
				colour = G.C.RED,
				mult_mod = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'insightful',
	loc_txt = {
		name = 'Insightful Joker',
		text = {
			"{C:chips}+#1#{} Chips if played",
			"hand contains",
			"a {C:attention}Spectrum{}",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Crafty Joker{}",
		}
	},
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
				message = localize({
					type = "variable",
					key = "a_chips",
					vars = { card.ability.extra.chips },
				}),
				colour = G.C.BLUE,
				chip_mod = card.ability.extra.chips,
			}
		end
	end
}

SMODS.Joker {
	key = 'breach',
	loc_txt = {
		name = 'The Breach',
		text = {
			"{X:mult,C:white} X#1# {} Mult if played",
			"hand contains",
			"a {C:attention}Spectrum{}",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}The Tribe{}",
		}
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 3 } },
	
	atlas = 'corrupted',
	pos = { x = 2, y = 1 },

	discovered = true,
	unlocked = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				message = localize({
					type = "variable",
					key = "a_xmult",
					vars = { card.ability.extra.mult },
				}),
				colour = G.C.RED,
				Xmult_mod = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'prideful',
	loc_txt = {
		name = 'Prideful Joker',
		text = {
			"Played cards with {C:ovn_optic}Optic{} suit",
			"give {C:mult}+#1#{} Mult when scored",
			"{C:inactive,s:0.8}Corrupted from the{} {C:attention,s:0.8}Sinful Jokers{}"
		}
	},
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
		if context.individual and context.cardarea == G.play then
			if context.other_card:is_suit("ovn_Optics") then
				return {
					a_mult = card.ability.extra.mult,
					color = G.C.MULT,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'cultivar',
	loc_txt = {
		name = 'Theoretical Cultivar',
		text = {
			"{X:mult,C:white} X#1# {} Mult",
			"{C:green}#2# in #3#{} chance this",
			"card is destroyed",
			"at end of round",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Cavendish{}",
		}
	},
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
				message = localize {
					type = 'variable',
					key = 'a_xmult',
					vars = { card.ability.extra.Xmult }
				},
				Xmult_mod = card.ability.extra.Xmult
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
	loc_txt = {
		name = 'A Part Falling',
		text = {
			"This Joker gains {X:mult,C:white} X#2# {} Mult",
			"whenever a Joker {C:ovn_corrupted}corrupts{}",
			"{C:inactive}Currently{} {X:mult,C:white} X#1# {}",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Hologram{}",
		}
	},
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
				message = localize({
					type = "variable",
					key = "a_xmult",
					vars = { card.ability.extra.x_mult },
				}),
				Xmult_mod = card.ability.extra.x_mult,
			}

		elseif G.GAME.corruptingJoker and not context.blueprint then
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
	loc_txt = {
		name = 'Aeon Cavendish',
		text = {
			"{X:mult,C:white} X#1# {} Mult",
			"{C:green}#2# in #3#{} chance this",
			"card is destroyed",
			"at end of round",
			"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Cavendish{}",
		}
	},
	config = { extra = { Xmult = 4, odds = 4 } },
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.Xmult,
			G.GAME.probabilities.normal or 1,
			card.ability.extra.odds
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
				message = localize {
					type = 'variable',
					key = 'a_xmult',
					vars = { card.ability.extra.Xmult }
				},
				Xmult_mod = card.ability.extra.Xmult
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
