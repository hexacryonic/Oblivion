--------------------------
-- Supplementary functions
--------------------------
local add_simple_event = Ovn_f.add_simple_event

---@param card Card
---@param target string
---@param scalar string
---@param colour? table
---@param message_key? string
---@return nil
local function simple_scale(card, target, scalar, colour, message_key)
	SMODS.scale_card(card, {
		ref_table = card.ability.extra,
		ref_value = target,
		scalar_value = scalar,
		message_key = message_key,
		message_colour = colour
	})
end

---@param card Card
---@param target string
---@param scalar string
---@param colour? table
---@param message_key? string
---@return nil
local function former_form_scale(card, target, scalar, colour, message_key)
	SMODS.scale_card(card, {
		ref_table = card.ability.extra,
		ref_value = target,
		scalar_table = card.ability.extra[scalar],
		scalar_value = card.ability.ovn_former_form,
		message_key = message_key,
		message_colour = colour
	})
end

----------------

-----------------
-- Parallel Joker
-----------------
SMODS.Joker {
	key = 'darkjoker',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	config = { extra = { mult = 2 } },

	atlas = 'corrupted',
	pos = { x = 0, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 3,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}

-----------------
-- Prideful Joker
-----------------
SMODS.Joker {
	key = 'prideful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 6 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 2 },

	blueprint_compat = true,
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

------------------
-- Bombastic Joker
------------------
SMODS.Joker {
	key = 'bombastic',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 13 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 2 },

	rarity = "ovn_corrupted",
	cost = 5,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end
}

-------------------
-- Insightful Joker
-------------------
SMODS.Joker {
	key = 'insightful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	config = { extra = { chips = 110 } },

	atlas = 'corrupted',
	pos = { x = 3, y = 2 },

	rarity = "ovn_corrupted",
	cost = 5,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				chips = card.ability.extra.chips,
			}
		end
	end
}

-----------------------------
-- Edge of a Collapsing World
-----------------------------
SMODS.Joker {
	key = 'collapsing_world',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.mult_set[card.ability.ovn_former_form or "j_mystic_summit"],
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			mult_set = {
				j_mystic_summit = 3,
				j_erosion = 4,
			},
			mult = 0
		}
	},

	atlas = 'corrupted',
	pos = {x=0, y=4},

	rarity = 'ovn_corrupted',
	cost = 7,
	blueprint_compat = false,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function(self, card, context)
		if (
			context.discard
			and not context.blueprint
			and G.GAME.current_round.discards_left == 1
			and (
				context.other_card == G.hand.highlighted[1]
				or context.other_card == G.hand.highlighted[#G.hand.highlighted]
			)
		) then
			-- only give mult on first card (i.e. give mult once per discard)
			if context.other_card == G.hand.highlighted[1] then
				former_form_scale(card, "mult", "mult_set", G.C.RED, "a_mult")
			end
			return { remove = true }
		end

		if context.joker_main then return {
			mult = card.ability.extra.mult
		} end
	end
}

---------------
-- Lucas Series
---------------
SMODS.Joker {
	key = 'lucasseries',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.29 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 7,

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

-----------
-- Database
-----------
SMODS.Joker {
	key = 'database',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.chips_per,
			card.ability.extra.chips_per*(G.GAME.cumulative_unique_joker_count or 0)
		}}
	end,
	config = {
		extra = {
			chips_per = 10
		},
	},

	atlas = 'corrupted',
	pos = {x=3, y=3},

	rarity = 'ovn_corrupted',
	cost = 6,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips_per*G.GAME.cumulative_unique_joker_count
			}
		end
	end
}

------------------------
-- Prosopometamorphopsia
------------------------
SMODS.Joker {
	key = 'pmo',

	atlas = 'corrupted',
	pos = { x = 3, y = 0 },

	rarity = "ovn_corrupted",
	cost = 7,
}

-----------------
-- Aeon Cavendish
-----------------
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

	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.ovn_corrupted_from then
			check_for_unlock{type="ovn_natural_aeon"}
		end
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end
	end,
    in_pool = function(self, args)
        return G.GAME.corruptiblemichel
    end
}

----------------
-- Event Horizon
----------------
SMODS.Joker {
	key = 'event_horizon',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.chips,
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			chips = 0,
			mult = 0,
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 7,

	calculate = function (self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips,
				mult  = card.ability.extra.mult
			}
		end
	end
	-- Additional funcitonality in level_up_hand hook and Black Hole ownership
}

-------------------
-- Library of Babel
-------------------
SMODS.Joker {
	key = 'library_of_babel',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult_set[card.ability.ovn_former_form or "j_todo_list"],
			card.ability.extra.last_played_threshold,
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult_set = {
                j_todo_list = 0.1,
                j_card_sharp = 0.15,
                j_obelisk = 0.2
			},
			xmult = 1,
			last_played_threshold = 3
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function (self, card, context)
		if context.before then
			local hand = context.scoring_name
			if G.GAME.hands_last_played[hand] >= card.ability.extra.last_played_threshold then
				former_form_scale(card, "xmult", "xmult_set", G.C.MULT)
			end
		end

		if context.joker_main then
			return {
				xmult = card.ability.extra.xmult
			}
		end
	end
}

-----------------------
-- Theoretical Cultivar
-----------------------
SMODS.Joker {
	key = 'cultivar',
	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'ovn_ion')
		return {vars = {
			card.ability.extra.Xmult,
			numerator,
			denominator
		}}
	end,
	config = { extra = {
		Xmult = 4,
		odds = 4
	}},

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end

		if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
			if not SMODS.pseudorandom_probability(card, 'cultivar', 1, card.ability.extra.odds) then
				return { message = 'Safe!' }
			end

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
	end,
    in_pool = function(self, args)
        return G.GAME.pool_flags.gros_michel_extinct
    end
}

-----------------
-- A Part Falling
-----------------
SMODS.Joker {
	key = 'apartfalling',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.x_mult,
			card.ability.extra.xmult_increase
		}}
	end,
	config = {
		extra = {
			xmult_increase = 0.75,
			x_mult = 1,
		},
	},

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	rarity = "ovn_corrupted",
	cost = 8,
	calculate = function(self, card, context)
		if context.joker_main and card.ability.extra.x_mult > 1 then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end

		if (
			context.ovn_corruption_occurred
			and context.ovn_corruption_type == "Joker"
			and not context.blueprint
			and context.ovn_corrupted_card ~= card
		) then
			simple_scale(card, "x_mult", "xmult_increase", G.C.MULT, "a_xmult")
		end
	end
}

----------------------
-- Philosopher's Stone
----------------------
SMODS.Joker {
	key = 'philosophers_stone',
	loc_vars = function (self, info_queue, card)
		local num, denom = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'ovn_philosophers_stone')
		return {vars = {
			num,
			denom
		}}
	end,
	config = {
		extra = {
			odds = 3
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 8,

	calculate = function (self, card, context)
		if context.final_scoring_step then
			for i,other_card in ipairs(context.scoring_hand) do
				if SMODS.pseudorandom_probability(card, 'ovn_philosophers_stone' .. i, 1, card.ability.extra.odds) then
					local enhancement = other_card.config.center.key
					-- This excludes undefined/unenhanced cards
					if Oblivion.enhancement_corrupt[enhancement] then
						Ovn_f.corrupt_enhancement(other_card)
					elseif Oblivion.enhancement_purify[enhancement] then
						Ovn_f.purify_enhancement(other_card)
					end
				end
			end
		end
	end
}

--------------
-- Supply Drop
--------------
SMODS.Joker {
	key = 'supplydrop',
	loc_vars = function(self, info_queue, center)
		local stored
		local stored_joker = G.PROFILES[G.SETTINGS.profile].ovn_supply_drop

		if stored_joker then
			-- Preventing recursion
			if stored_joker ~= "j_ovn_supplydrop" then
				table.insert(info_queue, G.P_CENTERS[stored_joker])
			end
			stored = localize{
				type = "name_text",
				set = "Joker",
				key = stored_joker
			}
		else
			stored = localize("k_none")
		end

		return { vars = { stored } }
	end,

	atlas = 'corrupted',
	pos = { x = 3, y = 1 },

	blueprint_compat = false,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.selling_self and not context.retrigger_joker and not context.blueprint then
			local save_file = G.PROFILES[G.SETTINGS.profile]
			if not save_file.ovn_supply_drop then
				local card_index
				for i = 2, #G.jokers.cards do
					if G.jokers.cards[i] == card then
						card_index = i
						break
					end
				end

				if not card_index then return end
				local left_joker = G.jokers.cards[card_index-1]
				local left_joker_rarity = left_joker.config.center.rarity

				-- greater than rare or not corrupted
				if not (
					(type(left_joker_rarity) == "number" and left_joker_rarity <= 3)
					or left_joker_rarity == "ovn_corrupted"
				) then return end

				local left_joker_key = left_joker.config.center.key
				local left_joker_edition = left_joker.edition and left_joker.edition.key
				local left_joker_stickers = {}
				for sticker_key in pairs(SMODS.Stickers) do
					if left_joker.ability[sticker_key] then
						table.insert(left_joker_stickers, sticker_key)
					end
				end

				save_file.ovn_supply_drop = left_joker_key
				save_file.ovn_supply_drop_edition = left_joker_edition
				save_file.ovn_supply_drop_sticker = left_joker_stickers
				check_for_unlock{type="ovn_sell_supply_drop"}

				add_simple_event('after', 0.1, function ()
					left_joker:start_dissolve({G.C.RARITY['ovn_corrupted']})
				end)

				return {
					message = localize("stored"),
					colour = G.C.DARK_EDITION
				}
			else
				local stored_joker_key = save_file.ovn_supply_drop
				local stored_joker_edition = save_file.ovn_supply_drop_edition
				local stored_joker_sticker = save_file.ovn_supply_drop_sticker

				local stored_card = SMODS.add_card{
					set = 'Joker',
					area = G.joker,
					key = stored_joker_key,
					edition = stored_joker_edition,
					stickers = stored_joker_sticker
				}

				save_file.ovn_supply_drop = nil
				save_file.ovn_supply_drop_edition = nil
				save_file.ovn_supply_drop_sticker = nil

				return {
					message = localize("empty"),
					colour = G.C.DARK_EDITION
				}
			end
		end
	end,
}

------------------------
-- Perpendicular Parking
------------------------
SMODS.Joker {
	key = 'perpendicular',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	config = { extra = { money = 1 } },

	atlas = 'corrupted',
	pos = { x = 1, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card then
			local scored_card_rank = SMODS.Ranks[context.other_card.base.value].key

			for _,held_card in ipairs(G.hand.cards) do
				local held_card_rank = held_card.base.value

				if scored_card_rank == held_card_rank then
					return {
						dollars = card.ability.extra.money,
					}
				end
			end
		end
	end
}

-----------
-- Migraine
-----------
SMODS.Joker {
	key = 'migraine',
	atlas = 'corrupted',
	pos = {x=2, y=3},
	rarity = 'ovn_corrupted',
	cost = 6
	-- Functionality implemented in "Migraine makes all standard pack cards Optics" Lovely patch
}

----------------------
-- Spiral of Addiction
----------------------
SMODS.Joker {
	key = 'spiral_of_addiction',
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra.xmult_gain,
			card.ability.extra.xmult,
			card.ability.extra.handsize_change
		}}
	end,
	config = {
		extra = {
			xmult = 1,
			xmult_gain = 0.15,
			handsize_change = -2,
			do_handsize_change = false,
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = "ovn_corrupted",
	cost = 6,

	calculate = function(self, card, context)
		local card_extra = card.ability.extra

		if context.joker_main then
			return {
				xmult = card_extra.xmult
			}
		end

		if (
			context.end_of_round
			and not context.game_over
			and context.main_eval
			and not context.blueprint
		) then
			if G.GAME.current_round.discards_left <= 0 then
				simple_scale(card, "xmult", "xmult_gain", G.C.MULT)
			else
				card_extra.do_handsize_change = true
			end
		end

		if context.setting_blind and card_extra.do_handsize_change then
			add_simple_event(nil, nil, function()
				Ovn_f.temp_handsize_change(card_extra.handsize_change)
				SMODS.calculate_effect(
					{ message = localize {
						type = 'variable',
						key = card_extra.handsize_change >= 0 and 'a_hands' or 'a_hands_minus',
						vars = { math.abs(card_extra.handsize_change) }
					}},
					context.blueprint_card or card
				)
			end)
			card_extra.do_handsize_change = false
		end
	end
}

-----------------
-- Cigarette Card
-----------------
SMODS.Joker {
	key = 'cigarette_card',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult = 1.5
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=3},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if context.other_joker and context.other_joker.config.center.rarity == "ovn_corrupted" then
			return {
				xmult = card.ability.extra.xmult,
				message_card = context.other_joker
			}
		end
	end,
	-- Additional functionality implemented in
	-- "Cigarette Card makes all Uncommons Miasma" Lovely patch
}

------------
-- Airstrike
------------
SMODS.Joker {
	key = 'airstrike',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 0.2 } },

	atlas = 'corrupted',
	pos = { x = 0, y = 2 },

	rarity = "ovn_corrupted",
	cost = 6,

	calculate = function (self, card, context)
		if context.individual and context.other_card.base.value == '10' then
			local c_ability = context.other_card.ability --[[@as table]]
			if context.cardarea == 'unscored' or context.cardarea == G.hand then
				SMODS.scale_card(context.other_card, {
					ref_table = c_ability,
					ref_value = "perma_x_mult",
					scalar_table = card.ability.extra,
					scalar_value = "xmult",
					colour = G.C.MULT
				})
			elseif context.cardarea == G.play then
				-- displayed mult is 1 + perma_x_mult
				-- hence this check is X1 less than the required X5
				if c_ability.perma_x_mult >= 4 then
					check_for_unlock{type="ovn_airstrike_release"}
				end
				c_ability.perma_x_mult = 0
			end
		end
	end
}

-------------------
-- Fuck it, We Ball
-------------------
SMODS.Joker {
	key = 'yolo',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.5 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 1 },

	blueprint_compat = true,
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
			if to_big(G.GAME.current_round.hands_played) > to_big(0) and to_big(G.GAME.chips/G.GAME.blind.chips) < to_big(1) then
				G.STATE = G.STATES.GAME_OVER
				G.STATE_COMPLETE = false
				G.GAME.yolo = false
				return nil, true
			end

			if context.end_of_round and context.cardarea == G.jokers and not context.game_over then
				G.GAME.yolo = false
				return nil, true
			end
		end
	end,
}

----------------------
-- THE SHOW NEVER ENDS
----------------------
SMODS.Joker {
	key = 'showneverends',
	atlas = 'corrupted',
	pos = { x = 1, y = 2 },
	rarity = "ovn_corrupted",
	cost = 8,
	-- Functionality implemented in Card:update hook
}

----------------------
-- Infinitesimal Joker
----------------------
SMODS.Joker {
	key = 'infinitesimal',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.card_limit,
			card.ability.extra.mult_gain,
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			mult_gain = 2,
			mult = 0,
		},
		card_limit = 1,
	},

	atlas = 'corrupted',
	pos = {x=1, y=3},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card.base.value == "3"
			and not context.blueprint
		) then
			simple_scale(card, "mult", "mult_gain", G.C.MULT)
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}

--------------------
-- Master of Puppets
--------------------
SMODS.Joker {
	key = 'master_of_puppets',
	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if context.selling_card and context.cardarea == G.jokers then
			local sold_rarity = context.card.config.center.rarity
			local jack_list = {}
			for _,playing_card in ipairs(G.playing_cards) do
				if (
					playing_card.base.value == "Jack"
					and playing_card.config.center.key ~= "m_stone"
					and (
						(sold_rarity == 1 and playing_card.config.center.key == "c_base")
						or (sold_rarity == 2 and playing_card.seal == nil)
						or (sold_rarity == 3 and playing_card.edition == nil)
					)
				) then
					table.insert(jack_list, playing_card)
				end
			end
			if #jack_list < 1 then return end
			local selected_jack = pseudorandom_element(
				jack_list,
				"ovn_master_of_puppets_jack"
			) --[[@as Card]]


			add_simple_event(nil, nil, function()
				-- Common generates enhancement
				if sold_rarity == 1 then
					local enhancement = SMODS.poll_enhancement{
						guaranteed = true,
						type_key = "ovn_master_of_puppets"
					}
					selected_jack:set_ability(enhancement)

				-- Uncommon generates seal
				elseif sold_rarity == 2 then
					local seal = SMODS.poll_seal{
						guaranteed = true,
						type_key = "ovn_master_of_puppets"
					}
					selected_jack:set_seal(seal)

				-- Rare generates edition
				elseif sold_rarity == 3 then
					local edition = poll_edition(
						"ovn_master_of_puppets",
						nil, true, true,
						{"e_foil", "e_holo", "e_polychrome"}
					)
					selected_jack:set_edition(edition)
				end

				selected_jack:juice_up()
				card:juice_up()
				play_sound('tarot1')
			end)
		end
	end
}

-------------
-- The Breach
-------------
SMODS.Joker {
	key = 'breach',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 4 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 1 },

	rarity = "ovn_corrupted",
	cost = 9,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end
}

--------------------------
-- Bottled Ship of Theseus
--------------------------
SMODS.Joker {
	key = 'bottled_ship_of_theseus',
	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function (self, card, context)
		if context.remove_playing_cards and not context.blueprint then
			for _,removed_card in ipairs(context.removed) do
				if removed_card.config.center.key ~= "m_glass" then
					local rank = removed_card.base.value
					local suit = removed_card.base.suit
					add_simple_event(nil, nil, function ()
						SMODS.add_card { -- Random enhanced 3 of Clubs
							set = "Enhanced",
							rank = rank,
							suit = suit,
							enhancement = "m_glass"
						}
					end)
				end
			end
		end
	end
}

--------------
-- Nexus Point
--------------
SMODS.Joker {
	key = 'nexus_point',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult,
			card.ability.extra.xmult_gain
		}}
	end,
	config = {
		extra = {
			xmult_gain = 0.2,
			xmult = 1.1,
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 7,

	calculate = function (self, card, context)
		if (
			context.ovn_corrupted_from
			and context.ovn_former_form_key == "j_ovn_nexus_point"
		) then
			simple_scale(card, "xmult", "xmult_gain", G.C.RED)
		end

		if context.individual and context.cardarea == G.play then
			return {
				xmult = card.ability.extra.xmult
			}
		end
	end
}
