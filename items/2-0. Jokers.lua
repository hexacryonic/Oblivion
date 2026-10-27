---@param card Card
---@param target string
---@param scalar string
---@param colour? table
---@param message_key? string
---@return nil
local function simple_scale(card, target, scalar, colour, message_key)
	local no_message = false
	if message_key == "NOMESSAGE" then
		message_key = nil
		colour = nil
		no_message = true
	end
	SMODS.scale_card(card, {
		ref_table = card.ability.extra,
		ref_value = target,
		scalar_value = scalar,
		message_key = message_key,
		message_colour = colour,
		no_message = no_message
	})
end

---@param card Card
---@param target string
---@param scalar string
---@param colour? table
---@param message_key? string
---@return nil
local function former_form_scale(card, target, scalar, colour, message_key)
	local no_message = false
	if message_key == "NOMESSAGE" then
		message_key = nil
		colour = nil
		no_message = true
	end
	SMODS.scale_card(card, {
		ref_table = card.ability.extra,
		ref_value = target,
		scalar_table = card.ability.extra[scalar],
		scalar_value = card.ability.ovn_former_form,
		message_key = message_key,
		message_colour = colour,
		no_message = no_message
	})
end

----------------

-----------------
-- CORRUPTED
-- Parallel Joker
-----------------
SMODS.Joker { key = 'darkjoker',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	config = { extra = { mult = 2 } },
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},

	atlas = 'jokers_corrupt',
	pos = { x = 0, y = 0 },

	attributes = { "mult" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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

----------------
-- John Oblivion
----------------
SMODS.Joker { key = 'john',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},

	atlas = 'jokers',
	pos = { x = 0, y = 0 },

	attributes = { "joker", "generation", "on_sell" },
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	rarity = 2,
	cost = 6,

	calculate = function(self, card, context)
		if context.selling_self and not context.blueprint and not context.retrigger_joker then
			SMODS.add_card{
				set = "Joker",
				area = G.jokers,
				rarity = "ovn_corrupted",
				key_append = "ovn_john"
			}
			return {
				message = localize('k_plus_joker'),
				colour = G.C.RARITY["ovn_corrupted"],
				message_card = card
			}
		end
	end,
}

------
-- ovn
------
SMODS.Joker { key = 'ovn',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Lil. Mr. Slipstream"
	},

	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.e_ovn_miasma)
	end,

    atlas = 'jokers',
	pos  = { x=2, y=1 },

	attributes = { "editions", "modify_card", "boss_blind" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 3,
	cost = 10,

	calculate = function(self, card, context)
		if (
			context.end_of_round
			and context.cardarea == G.jokers
			and not context.game_over
			and context.beat_boss
		) then
			Ovn_f.event.simple(nil, function ()
				local leftmost_joker = G.jokers.cards[1]
				leftmost_joker:set_edition("e_ovn_miasma")
				leftmost_joker:juice_up()
				card:juice_up()
				play_sound('tarot1')
			end)
		end
	end
}

------------------
-- Bombastic Joker
------------------
SMODS.Joker { key = 'bombastic',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 13 } },

	atlas = 'jokers',
	pos = { x = 0, y = 3 },

	attributes = { "mult", "hand_type" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 1,
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end,
	in_pool = function (self, args)
		return G.GAME and G.GAME.ovn_has_ocular
	end
}

-------------------
-- Insightful Joker
-------------------
SMODS.Joker { key = 'insightful',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	config = { extra = { chips = 110 } },

	atlas = 'jokers',
	pos = { x = 1, y = 3 },

	attributes = { "chips", "hand_type" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 1,
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				chips = card.ability.extra.chips,
			}
		end
	end,
	in_pool = function (self, args)
		return G.GAME and G.GAME.ovn_has_ocular
	end
}

-------------
-- The Breach
-------------
SMODS.Joker { key = 'breach',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "HexaCryonic",
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 4 } },

	atlas = 'jokers',
	pos = { x = 2, y = 3 },

	attributes = { "xmult", "hand_type" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 3,
	cost = 8,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end,
	in_pool = function (self, args)
		return G.GAME and G.GAME.ovn_has_ocular
	end
}

----------------
-- Radiant Joker
----------------
SMODS.Joker { key = 'radiant_joker',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Oinite"
	},

	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.m_ovn_radiant)
		return {vars = {
			card.ability.extra.extra_chips,
			card.ability.extra.chip_increase
		}}
	end,
	config = {
		extra = {
			extra_chips = 5,
			chip_increase = 1,
		}
	},

    atlas = 'jokers',
	pos  = { x=2, y=2 },

	attributes = { "perma_bonus", "enhancements", "chips", "scaling" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 2,
	cost = 6,
    enhancement_gate = "m_ovn_radiant",

	add_to_deck = function (self, card, from_debuff)
		if from_debuff then return end
		for _,playing_card in ipairs(G.playing_cards) do
			if playing_card.config.center.key == "m_ovn_radiant" then
				playing_card.ability.extra.bonus_chips = (
					playing_card.ability.extra.bonus_chips
					+ card.ability.extra.extra_chips
				)
			end
		end
	end,
	remove_from_deck = function (self, card, from_debuff)
		if from_debuff then return end
		for _,playing_card in ipairs(G.playing_cards) do
			if playing_card.config.center.key == "m_ovn_radiant" then
				playing_card.ability.extra.bonus_chips = (
					playing_card.ability.extra.bonus_chips
					- card.ability.extra.extra_chips
				)
			end
		end
	end,
	calculate = function (self, card, context)
		if (
			context.individual
			and context.other_card.config.center.key == "m_ovn_radiant"
			and context.cardarea == G.play
		) then
			simple_scale(card, "extra_chips", "chip_increase", G.C.CHIPS)
		end
	end
	-- Additional functionality found in "set_ability", Radiant enhancement register
}

------------
-- Ice Joker
------------
SMODS.Joker { key = 'ice_joker',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Oinite"
	},

	loc_vars = function(self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.m_ovn_ice)
		return {vars = {
			card.ability.extra.xmult_gain,
			card.ability.extra.xmult,
			card.ability.extra.xmult_gain_gain
		}}
	end,
	config = {
		extra = {
			xmult = 1,
			xmult_gain = 0.05,
			xmult_gain_gain = 0.05
		}
	},

    atlas = 'jokers',
	pos  = { x=0, y=2 },

	attributes = { "enhancements", "xmult", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 2,
	cost = 6,
    enhancement_gate = "m_ovn_ice",

	calculate = function(self, card, context)
		local card_extra = card.ability.extra
		if context.joker_main then
			return {xmult = card_extra.xmult}
		end

		if context.blueprint then return end
		-- non-blueprint calc past here

		if context.ovn_ice_degraded then
			simple_scale(card, "xmult", "xmult_gain", G.C.RED)
		end

		if context.remove_playing_cards then
			for _,removed_card in ipairs(context.removed) do
				if removed_card.ice_melted then
					simple_scale(card, "xmult_gain", "xmult_gain_gain", G.C.RED)
				end
			end
		end
	end
}

----------------
-- Crystal Joker
----------------
SMODS.Joker { key = 'crystal_joker',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Oinite",
	},
	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.m_ovn_crystal)
		return {vars = {
			card.ability.extra.extra_plays
		}}
	end,
	config = {
		extra = {
			extra_plays = 2
		}
	},

    atlas = 'jokers',
	pos  = { x=3, y=2 },

	attributes = { "enhancements", "modify_card", "passive" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 2,
	cost = 6,
    enhancement_gate = "m_ovn_crystal",

	add_to_deck = function (self, card, from_debuff)
		if from_debuff then return end
		for _,playing_card in ipairs(G.playing_cards) do
			if playing_card.config.center.key == "m_ovn_crystal" then
				-- This is not scaling, hence no simple_scale use
				playing_card.ability.extra.plays_left = (
					playing_card.ability.extra.plays_left
					+ card.ability.extra.extra_plays
				)
			end
		end
	end,
	remove_from_deck = function (self, card, from_debuff)
		if from_debuff then return end
		for _,playing_card in ipairs(G.playing_cards) do
			if playing_card.config.center.key == "m_ovn_crystal" then
				playing_card.ability.extra.plays_left = (
					playing_card.ability.extra.plays_left
					- card.ability.extra.extra_plays
				)
				if playing_card.ability.extra.plays_left <= 0 then
					Ovn_f.event.simple(nil, function ()
						play_sound('glass'..math.random(1, 6), math.random()*0.5 + 1.2,0.5)
						SMODS.destroy_cards(playing_card)
					end)
				end
			end
		end
	end
	-- Additional functionality found in "set_ability", Crystal enhancement register
}

------------
-- Ion Joker
------------
SMODS.Joker { key = 'ion_joker',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Oinite"
	},

	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.m_ovn_ion)
		return {vars = {
			card.ability.extra.chips
		}}
	end,
	config = {
		extra = {
			chips = 0
		}
	},

    atlas = 'jokers',
	pos  = { x=1, y=2 },

	attributes = { "enhancements", "chips", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 2,
	cost = 6,
    enhancement_gate = "m_ovn_ion",

	calculate = function (self, card, context)
		if context.joker_main then return {chips = card.ability.extra.chips} end
	end
	-- Additional functionality found in "calculate", Ion enhancement register
}

------------------
-- Trolley Problem
------------------

SMODS.Joker { key = 'trolley_problem',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},
	config = { extra = { valid_hands = {
		["Three of a Kind"] = true,
		["Four of a Kind"] = true,
		["Five of a Kind"] = true
	}}},

    atlas = 'jokers',
    pos  = { x=0, y=1 },

	attributes = { "hand_type", "destroy_card" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 3,
	cost = 8,

	calculate = function (self, card, context)
		if (
			context.destroy_card
			and context.cardarea == 'unscored'
			and self.config.extra.valid_hands[context.scoring_name]
		) then
			return {remove = true}
		end
	end
}

--------
-- Prism
--------

SMODS.Joker { key = 'prism',
	credits = {
		concept = {"NinjaBanana", "HexaCryonic"},
		code = "Oinite",
		art = "HexaCryonic"
	},
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.increased_odds
		}}
	end,
	config = { extra = {
		increased_odds = 2
	} },

	atlas = 'jokers',
	pos   = { x=2, y=0 },

	attributes = { "tarot", "passive" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 1,
	cost = 4,

	calculate = function (self, card, context)
		if context.modify_weights and context.pool_types["Tarot"] then
			for _,pool_item in ipairs(context.pool) do
				if Oblivion.suit_changing_tarots[pool_item.key] then
					pool_item.weight = pool_item.weight*card.ability.extra.increased_odds
				end
			end
		end
	end
}

-----------
-- Purifier
-----------

-- Get the leftmost corrupted Joker, if any.
---@return integer
---@return Card|nil
local function get_leftmost_corrupted_joker()
	for i,card in ipairs(G.jokers.cards) do
		if card.config.center.rarity == "ovn_corrupted" then
			return i, card
		end
	end
	return -1, nil
end

SMODS.Joker { key = 'purifier',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Lil. Mr. Slipstream"
	},

	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.mult_gain,
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			mult_gain = 10,
			mult = 0
		}
	},

	atlas = "jokers",
    pos = { x=1, y=1 },

	attributes = { "ovn_purifying", "mult", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 2,
	cost = 5,

	calculate = function (self, card, context)
		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end

		if context.setting_blind and not context.blueprint then
			local _, leftmost = get_leftmost_corrupted_joker()
			if leftmost then
				Ovn_f.purify_joker(leftmost)
				simple_scale(card, "mult", "mult_gain", G.C.MULT)
			end
		end
	end
}

--------------
-- Pure Visage
--------------
SMODS.Joker { key = 'pure_visage',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},

	loc_vars = function (self, info_queue, card)
		return {
			key = "j_ovn_pure_visage" .. (card.ability.extra.on_cooldown <= 0 and "_ready" or ""),
			vars = card.ability.extra.on_cooldown > 0 and {
				card.ability.extra.on_cooldown
			} or nil
		}
	end,
	config = {
		extra = {
			on_cooldown = 2
		}
	},
	atlas = "jokers",
	pos = { x=1, y=0 },

	attributes = { "ovn_corrupting" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 1,
	cost = 4,

	calculate = function(self, card, context)
		if context.setting_blind then
			local do_return = card.ability.extra.on_cooldown - 1 > -1
			card.ability.extra.on_cooldown = math.max(0, card.ability.extra.on_cooldown - 1)
			if do_return then return {
				message = "",
				colour = G.C.CLEAR,
				message_card = card
			} end
		end
	end
	-- Functionality implemented in G.UIDEF.use_and_sell_buttons hook
}

-----------------
-- CORRUPTED
-- Corrupt Visage
-----------------
SMODS.Joker { key = 'corrupt_visage',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},

	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult = 3
		}
	},
	atlas = 'jokers_corrupt',
	pos  = { x=3, y=2 },

	attributes = { "xmult", "ovn_purifying" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.xmult
			}
		end

		if context.end_of_round and context.cardarea == G.jokers then
			Ovn_f.purify_joker(card)
		end
	end
	-- Functionality implemented in G.UIDEF.use_and_sell_buttons hook
}

-----------------
-- CORRUPTED
-- Prideful Joker
-----------------
SMODS.Joker { key = 'prideful',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 6 } },

	atlas = 'jokers_corrupt',
	pos = { x = 1, y = 2 },

	attributes = { "mult", "suit", "ovn_optics" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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

--------------
-- CORRUPTED
-- Black Knife
--------------
SMODS.Joker { key = 'black_knife',
	credits = {
		concept = {"Hyperspade"},
		code = {"Oinite"},
		-- art
	},

	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.new_glass_xmult,
			card.ability.extra.xmult_gain,
			card.ability.extra.xmult,
		}}
	end,
	config = {
		extra = {
			new_glass_xmult = 1.5,
			xmult = 1,
			xmult_gain = 0.1,
		}
	},

	atlas = "placeholder",
	pos = {x=0, y=0},
	uses_placeholder_sprite = true,

	attributes = { "xmult", "enhancements", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = "ovn_corrupted",
	cost = 9,
	enhancement_gate = "m_ovn_glass",

	add_to_deck = function (self, card, from_debuff)
		if not (#SMODS.find_card("j_ovn_black_knife") == 0) then return end
		for _,pl_card in ipairs(Ovn_f.find_enhancement("m_glass")) do
			pl_card.ability.Xmult  = card.ability.extra.new_glass_xmult
			pl_card.ability.x_mult = card.ability.extra.new_glass_xmult
		end
		Ovn_f.event.simple(nil, function ()
			eval_card(card, {ovn_force_blackknife_juicecheck = true})
		end)
	end,
	remove_from_deck = function (self, card, from_debuff)
		if not (#SMODS.find_card("j_ovn_black_knife") == 0) then return end
		for _,pl_card in ipairs(Ovn_f.find_enhancement("m_glass")) do
			pl_card.ability.Xmult  = pl_card.config.center.config.Xmult
			pl_card.ability.x_mult = pl_card.config.center.config.Xmult
		end
		G.GAME.ovn_icemagic_juicing = nil
	end,
	calculate = function (self, card, context)
		if context.joker_main then
			return {xmult = card.ability.extra.xmult}
		end

		if context.after then
			for _,other_card in ipairs(context.scoring_hand) do
				if other_card.ovn_saved_blackknife then
					other_card.ovn_saved_blackknife = nil
					SMODS.calculate_effect({ message = localize('k_safe_ex'), colour=G.C.BLACK }, other_card)
					Ovn_f.event.simple(0, function ()
						other_card:juice_up()
					end)
					simple_scale(card, "xmult", "xmult_gain", G.C.RED, "a_xmult")
				end
			end
		end

		-- juice-untils
		if (
			context.hand_drawn
			or context.other_drawn
			or context.using_consumeable
			or context.card_added
			or context.ovn_force_blackknife_juicecheck -- see this Joker's add_to_deck
		) then
			Ovn_f.event.simple(nil, function ()
				local has_ice = false
				local has_magician = false
				local juice_cards = {}
				for _,pcard in ipairs(G.hand.cards) do
					if pcard.config.center.key == 'm_ovn_ice' then
						has_ice = true
						table.insert(juice_cards, pcard)
					end
				end
				for _,consumable in ipairs(G.consumeables.cards) do
					if consumable.config.center.key == 'c_magician' then
						has_magician = true
						table.insert(juice_cards, consumable)
					end
				end

				G.GAME.ovn_icemagic_juicing = nil
				if not (has_ice and has_magician) then
					return
				end

				G.GAME.ovn_icemagic_juicing = true
				for _,other_card in ipairs(juice_cards) do
					juice_card_until(other_card, function (poopshit)
						return G.GAME.ovn_icemagic_juicing
					end)
				end
			end)
		end

	end
}
-- Additional functionality in:
	-- Glass Card take-ownership

-----------------------------
-- CORRUPTED
-- Edge of a Collapsing World
-----------------------------
SMODS.Joker { key = 'collapsing_world',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "Oinite"
	},
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

	atlas = 'jokers_corrupt',
	pos = {x=3, y=3},

	attributes = { "discard", "destroy_card", "mult", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 'ovn_corrupted',
	cost = 7,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end

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
	end
}

---------------
-- CORRUPTED
-- Lucas Series
---------------
SMODS.Joker { key = 'lucasseries',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.29 } },

	atlas = 'jokers_corrupt',
	pos = { x = 2, y = 0 },

	attributes = { "rank", "ace", "two", "three", "four", "seven", "xmult" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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
-- CORRUPTED
-- Database
-----------
SMODS.Joker { key = 'database',
	credits = {
		concept = "thaun0",
		code = "Oinite",
		art = "HexaCryonic",
	},
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

	atlas = 'jokers_corrupt',
	pos = {x=0, y=3},

	attributes = { "chips" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 6,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips_per*G.GAME.cumulative_unique_joker_count
			}
		end
        if card.ability.extra.chips_per*G.GAME.cumulative_unique_joker_count >= 1000 then
            check_for_unlock({type = 'ovn_big_database'})
        end
	end
}

------------------------
-- CORRUPTED
-- Prosopometamorphopsia
------------------------
SMODS.Joker { key = 'pmo',
	credits = {
		concept = "HexaCryonic",
		code = "Airtoum",
		art = "HexaCryonic",
	},

	atlas = 'jokers_corrupt',
	pos = { x = 3, y = 0 },

	attributes = { "modify_card", "passive", "face", "rank", "ace" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 7,
	-- Functionality in Card.calculate_joker hook
}

-----------------
-- CORRUPTED
-- Aeon Cavendish
-----------------
SMODS.Joker { key = 'aeon',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "Oinite",
	},

	config = { extra = { Xmult = 4} },
	loc_vars = function(self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.j_cavendish)
		return {vars = {
			card.ability.extra.Xmult,
		}}
	end,

	atlas = 'jokers_corrupt',
	pos = { x = 4, y = 4 },

	attributes = { "xmult", "food" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.ovn_corrupted_from then
      check_for_unlock({type = 'ovn_natural_aeon'})
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
-- CORRUPTED
-- Event Horizon
----------------
SMODS.Joker { key = 'event_horizon',
	credits = {
		concept = {"NinjaBanana", "HexaCryonic"},
		code = "Oinite",
		art = "Oinite",
	},

	loc_vars = function (self, info_queue, card)
		local former_form = card.ability.ovn_former_form or "j_supernova"
		return {vars = {
			card.ability.extra.chips,
			card.ability.extra.mult,
			card.ability.extra.scalemult[former_form]
		}}
	end,
	config = {
		extra = {
			chips = 0,
			mult = 0,
      		scalemult = {
				j_supernova = 0.5,
				j_constellation = 0.75,
			},
		}
	},

	atlas = 'jokers_corrupt',
	pos = {x=0, y=4},

	attributes = { "planet", "chips", "mult", "scaling", "hand_type", "space" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
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
	-- Additional funcitonality in:
		-- level_up_hand hook
		-- Ovn_f.blackhole_upgrade_eventhorizon
		-- Card:use_consumeable patch, joker_effects.toml
}

---------
-- CORRUPTED
-- Sludge
---------
SMODS.Joker { key = 'sludge',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Andromeda",
	},

	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.hand_size
		}}
	end,
	config = {
		extra = {
			hand_size = 1
		}
	},

	atlas = 'jokers_corrupt',
	pos = {x=4, y=0},

	attributes = { "hand_size", "passive" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 5,


    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.hand_size)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.hand_size)
    end
	-- Additional funcitonality in G.FUNCS.get_poker_hand_info hook
}

-------------------
-- CORRUPTED
-- Library of Babel
-------------------
SMODS.Joker { key = 'library_of_babel',
	credits = {
		concept = {"NinjaBanana", "HexaCryonic"},
		code = "Oinite",
		art = "Oinite",
	},

	loc_vars = function (self, info_queue, card)
		local highlighted_cards = Ovn_f.descend_table{G, "hand", "highlighted"}
		if highlighted_cards then
			local current_hand = G.FUNCS.get_poker_hand_info(highlighted_cards)
			if current_hand ~= "NULL" then
				local hand_last_played = G.GAME.hands_last_played[current_hand]
				table.insert(info_queue, {
					key = hand_last_played == -1 and 'ovn_library_of_babel_last_played_never' or 'ovn_library_of_babel_last_played',
					set = 'Other',
					vars = {
						localize(current_hand, "poker_hands"),
						hand_last_played == -1 and card.ability.extra.last_played_threshold or (hand_last_played + 1)
					}
				})
			end
		end
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

	atlas = 'jokers_corrupt',
	pos = {x=1, y=4},

	attributes = { "xmult", "scaling", "hand_type" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 'ovn_corrupted',
	cost = 10,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function (self, card, context)
		if context.before and not context.blueprint then
			local hand = context.scoring_name
			local threshold = card.ability.extra.last_played_threshold
			if (
				G.GAME.hands_last_played[hand] >= threshold
				or G.GAME.hands_last_played[hand] == -1
			) then
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
-- CORRUPTED
-- Theoretical Cultivar
-----------------------
SMODS.Joker { key = 'cultivar',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "Oinite",
	},

	loc_vars = function(self, info_queue, card)
		local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'cultivar')
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

	atlas = 'jokers_corrupt',
	pos = {x=2, y=4},

	attributes = { "xmult", "food", "chance" },
	blueprint_compat = true,
	eternal_compat = false,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end

		if (
			context.end_of_round
			and context.game_over == false
			and not context.repetition
			and not context.blueprint
		) then
			if not SMODS.pseudorandom_probability(card, 'cultivar', 1, card.ability.extra.odds) then
				return { message = localize('k_safe_ex') }
			end

			-- Odd is hit
			SMODS.destroy_cards(card, nil, true, true)
			G.GAME.pool_flags.gros_michel_extinct = false
			G.GAME.corruptiblemichel = true
			return { message = localize('k_extinct_ex') }
		end
	end,
    in_pool = function(self, args)
        return G.GAME.pool_flags.gros_michel_extinct
    end
}

--------------------
-- CORRUPTED
-- Insatiable Hunger
--------------------
SMODS.Joker { key = 'insatiable_hunger',
	credits = {
		concept = {"SyntaxTsundere", "HexaCryonic"},
		code = "Oinite",
		-- art = ??
	},

	loc_vars = function (self, info_queue, card)
		if next(card.ability.extra.devoured_items) then
			-- Only way to attach vars to send to the description dummy
			G.P_CENTERS['dd_ovn_insatiable_hunger_banishing'].specific_vars = card.ability.extra.devoured_items
			table.insert(info_queue, G.P_CENTERS['dd_ovn_insatiable_hunger_banishing'])
		end

		local activity_text = localize('k_active_ex')
		if card.ability.extra.first_item_bought then
			activity_text = localize('k_inactive_ex')
		end
		return {vars = {
			activity_text,
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			mult = 0,
			devoured_items = {}, -- set
			first_item_bought = false
		}
	},

	atlas = "placeholder",
	pos = {x=0, y=0},
	uses_placeholder_sprite = true,

	attributes = { "mult", "scaling", "destroy_card", "shop" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = "ovn_corrupted",
	cost = 12,

	calculate = function (self, card, context)
		if context.starting_shop and not context.blueprint then
			card.ability.extra.first_item_bought = false
		end

		if (
			(
				context.buying_card
				and not context.buying_self
				or context.ovn_cancelled_booster
			)
			and not context.blueprint
			and not card.ability.extra.first_item_bought
			and not (
				context.card.ability.set == "Default"
				or context.card.ability.set == "Enhanced"
			)
		) then
			local mult_scale = context.card.cost -- modify as needed
			if context.card.ability.consumeable then
				-- nothing
			elseif context.card.ability.set == "Joker" then
				mult_scale = mult_scale + 1
			elseif context.card.ability.set == "Booster" then
				mult_scale = mult_scale + 1
			elseif context.card.ability.set == "Voucher" then
				mult_scale = mult_scale + 2
			end

			Ovn_f.event.simple(nil, function ()
				if not context.card.getting_sliced then
					context.card.getting_sliced = true
					SMODS.destroy_cards(context.card)
				end
			end)
			SMODS.scale_card(card, {
				ref_table = card.ability.extra,
				ref_value = "mult",
				scalar_table = {poopshit = mult_scale},
				scalar_value = "poopshit",
				message_key = "a_mult",
				message_colour = G.C.RED,
			})
			card.ability.extra.devoured_items[context.card.config.center.key] = true
			card.ability.extra.first_item_bought = true
		end

		if context.ending_sho and not context.blueprint then
			card.ability.extra.first_item_bought = true
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}
Oblivion.DescriptionDummy { key = "insatiable_hunger_banishing",
	generate_ui = function (self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		-- specific_vars is sent by Insatiable Hunger's loc_vars function
		-- It is a set of item keys
		if not card then card = self:create_fake_card() end

		local keys = {}
		for key in pairs(specific_vars) do
			if G.P_CENTERS[key].group_key then
				table.insert(keys, localize(G.P_CENTERS[key].group_key))
			else
				table.insert(keys, localize{
					type = "name_text",
					set = G.P_CENTERS[key].set,
					key = key
				})
			end
		end
		table.sort(keys)

		local groups_of_three = { {} }
		for _,key in ipairs(keys) do
			local latest_tbl = groups_of_three[#groups_of_three]
			table.insert(latest_tbl, key)
			if #latest_tbl == 3 then
				---@diagnostic disable-next-line: assign-type-mismatch
				groups_of_three[#groups_of_three] = table.concat(latest_tbl, ", ")
				table.insert(groups_of_three, {})
			end
		end
		local final_latest_tbl = groups_of_three[#groups_of_three]
		if type(final_latest_tbl) == "table" then
			---@diagnostic disable-next-line: assign-type-mismatch
			groups_of_three[#groups_of_three] = table.concat(final_latest_tbl, ", ")
			if groups_of_three[#groups_of_three] == "" then
				table.remove(groups_of_three, #groups_of_three)
			end
		end

		local list_ui = Ovn_f.localize_desc(groups_of_three, {
			text_colour = G.C.UI.TEXT_DARK,
			scale = 1,
			align = "middle",
		})
		desc_nodes.name = localize{
			type = 'name_text',
			key = 'dd_ovn_insatiable_hunger_banishing',
			set = "DescriptionDummy"
		}
		table.insert(desc_nodes, {list_ui})
	end
}

-----------------
-- CORRUPTED
-- A Part Falling
-----------------
SMODS.Joker { key = 'apartfalling',
	credits = {
		concept = {"HexaCryonic", "Zero (null)"},
		code = {"HexaCryonic", "Oinite"},
		art = "Oinite",
		music = {'"A Part Falling"', 'by Hakita for ULTRAKILL'},
	},

	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.x_mult,
			card.ability.extra.xmult_increase
		}}
	end,
	config = {
		extra = {
			visual_transition = nil, -- if number, play transition animation
			xmult_increase = 0.75,
			x_mult = 1,
			current_screen = 1, -- Needed to prevent repeats (which suck)
		},
	},

	atlas = 'itemspecific_apartfalling',
	pos = { x = 0, y = 1 },
	sprite_args = {
		states = {
			static = {
				start_pos = {x=0, y=0},
				end_pos   = {x=3, y=0},
				fps = 100,
				frame_order = {4,3,2,1}
			},
			{start_pos = {x=0, y=1}},
			{start_pos = {x=1, y=1}},
			{start_pos = {x=2, y=1}},
			{start_pos = {x=3, y=1}},
			{start_pos = {x=4, y=1}},
		},
		default_state = 1,
	},

	attributes = { "xmult", "scaling", "ovn_corrupting" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
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
			Ovn_f.event.unblock(0.25, function ()
				card:set_sprite_state("static")
			end)
			Ovn_f.event.unblock(2, function ()
				Ovn_f.event.simple(nil, function ()
					local x = pseudorandom('apartfalling_sprite', 1, 5)
					if x == card.ability.extra.current_screen then
						x = (x == 5) and (1) or (x + 1)
					end
					card:set_sprite_state(x)
					card.ability.extra.current_screen = x
				end)
			end)
		end

		if context.ovn_run_started then
			card:set_sprite_state(card.ability.extra.current_screen)
		end
	end
}

----------------------
-- CORRUPTED
-- Philosopher's Stone
----------------------
SMODS.Joker { key = 'philosophers_stone',
	credits = {
		concept = "QueenChloe",
		code = "Oinite",
		art = "Oinite"
	},

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

	atlas = 'jokers_corrupt',
	pos = { x = 3, y = 4 },

	attributes = {
		"rank", "two", "three", "four", "five", "six",
		"seven", "eight", "nine", "ten", "enhancements", "modify_card"
	},
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
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

-------------
-- CORRUPTED
-- Tiger Drop
-------------

Oblivion.tdrop_compat = {}
Oblivion.tdrop_compat.apply_on_start = {
	["bl_wall"] = true,
	["bl_water"] = true,
	["bl_manacle"] = true,
	["bl_needle"] = true,
	["bl_final_acorn"] = true,
	["bl_final_vessel"] = true,
	["bl_ovn_stygian"] = true,
}
Oblivion.tdrop_compat.on_draw_hand_down = {
	["bl_house"] = true,
	["bl_fish"] = true,
	["bl_serpent"] = true,
}
Oblivion.tdrop_compat.on_draw_card_down = {
	["bl_wheel"] = true,
	["bl_mark"] = true,
}
Oblivion.tdrop_compat.on_play_hand = {
	["bl_hook"] = true,
}
Oblivion.tdrop_compat.on_play_card = {
	["bl_tooth"] = true,
}
Oblivion.tdrop_compat.every_hand = {
	["bl_final_heart"] = true,
	["bl_final_bell"] = true,
}

SMODS.Joker { key = 'tiger_drop',
	credits = {
		concept = {"QueenChloe", "HexaCryonic"},
		code = "Oinite",
		-- art
	},

	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.mult_gain,
			card.ability.extra.mult,
		}}
	end,
	config = {
		extra = {
			mult_gain = 2,
			mult = 0
		}
	},

	atlas = "placeholder",
	pos = {x=0, y=0},
	uses_placeholder_sprite = true,

	attributes = {
		"boss_blind", "mult"
	},
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 'ovn_corrupted',
	cost = 9,

	calculate = function (self, card, context)
		-- Conditions same as Matador
		if (context.debuffed_hand or context.joker_main) and G.GAME.blind.triggered then
			simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
		end
		if Oblivion.tdrop_compat.apply_on_start[G.GAME.blind.config.blind.key] then
			if context.hand_drawn and context.first_hand_drawn then
				simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
			end
		end
		if Oblivion.tdrop_compat.on_draw_hand_down[G.GAME.blind.config.blind.key] then
			if context.hand_drawn then
				local all_cards_down = true
				for _,other_card in ipairs(context.hand_drawn) do
					if other_card.facing ~= "back" then
						all_cards_down = false
					end
				end
				if all_cards_down then
					simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
				end
			end
		end
		if Oblivion.tdrop_compat.on_draw_card_down[G.GAME.blind.config.blind.key] then
			if context.hand_drawn then
				for _,other_card in ipairs(context.hand_drawn) do
					if other_card.facing == "back" then
						simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
					end
				end
			end
		end
		if Oblivion.tdrop_compat.on_play_hand[G.GAME.blind.config.blind.key] then
			if context.press_play then
				simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
			end
		end
		if Oblivion.tdrop_compat.on_play_card[G.GAME.blind.config.blind.key] then
			if context.before then
				for _,other_card in ipairs(context.scoring_hand) do
					simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
				end
			end
		end
		if Oblivion.tdrop_compat.every_hand[G.GAME.blind.config.blind.key] then
			if (context.hand_drawn and context.first_hand_drawn) or context.after then
				simple_scale(card, "mult", "mult_gain", G.C.RED, 'a_mult')
			end
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}
-- Additional functionality in:
	-- The Nerve (Blind) register

--------------
-- CORRUPTED
-- Supply Drop
--------------
SMODS.Joker { key = 'supplydrop',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "HexaCryonic",
	},
	loc_vars = function(self, info_queue, center)
		local store_info_strings = {}
		local save_file = G.PROFILES[G.SETTINGS.profile]
		local stored_joker = save_file.ovn_supply_drop

		if stored_joker then
			-- Preventing recursion
			if stored_joker ~= "j_ovn_supplydrop" then
				table.insert(info_queue, G.P_CENTERS[stored_joker])
			end
			local joker_name_string = "{C:attention}" .. localize{
				type = "name_text",
				set = "Joker",
				key = stored_joker
			}

			local stored_joker_edition = save_file.ovn_supply_drop_edition
			local stored_joker_sticker = save_file.ovn_supply_drop_sticker

			if stored_joker_edition then
				if not center.edition or center.edition.key ~= stored_joker_edition then
					table.insert(info_queue, G.P_CENTERS[stored_joker_edition])
				end
				joker_name_string = "{C:dark_edition}" .. localize{
					type = "name_text",
					set = "Edition",
					key = stored_joker_edition
				} .. " " .. joker_name_string
			end

			table.insert(store_info_strings, joker_name_string)

			if stored_joker_sticker and #stored_joker_sticker > 0 then
				local sticker_pre_concat = {}
				for _,sticker_key in ipairs(stored_joker_sticker) do
					local sticker_vars
					if sticker_key == "perishable" then
						sticker_vars = {5, 5}
					elseif sticker_key == "rental" then
						sticker_vars = {3}
					end
					table.insert(info_queue, {
						set = "Other",
						key = sticker_key,
						vars = sticker_vars
					})
					table.insert(sticker_pre_concat, localize{
						type = "name_text",
						set = "Other",
						key = sticker_key
					})
				end
				local sticker_string = "{C:blue}" .. table.concat(sticker_pre_concat, ", ")
				table.insert(store_info_strings, sticker_string)
			end
		else
			table.insert(store_info_strings, "{C:inactive}"..localize("k_none"))
		end


		local store_info_ui = Ovn_f.localize_desc(store_info_strings, {
			text_colour = G.C.UI.TEXT_DARK,
			scale = 1,
			align = "middle",
		})

		return {box_ends = {[2] = {store_info_ui} } }
	end,

	atlas = 'jokers_corrupt',
	pos = { x = 2, y = 1 },

	attributes = { "sell_value", "economy" },
	blueprint_compat = false,
	eternal_compat = false,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.selling_self then
			local save_file = G.PROFILES[G.SETTINGS.profile]
			if not save_file.ovn_supply_drop then return end

			local stored_joker_key = save_file.ovn_supply_drop
			local stored_joker_edition = save_file.ovn_supply_drop_edition

			local payout = G.P_CENTERS[stored_joker_key].cost
			if stored_joker_edition then
				payout = payout + G.P_CENTERS[stored_joker_edition].extra_cost
			end

			return {
				dollars = payout
			}
		end
	end,
	-- Additional functionality in:
		-- modules/ui_funcs.lua
			-- G.FUNCS.supply_empty
			-- G.FUNCS.supply_can_empty
			-- G.FUNCS.supply_store
			-- G.FUNCS.supply_can_store
		-- modules/ui_hooks.lua - G.UIDEF.use_and_sell_buttons hook
}

------------------------
-- CORRUPTED
-- Perpendicular Parking
------------------------
SMODS.Joker { key = 'perpendicular',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "HexaCryonic",
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	config = { extra = { money = 1 } },

	atlas = 'jokers_corrupt',
	pos = { x = 1, y = 0 },

	attributes = { "economy" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card then
			local scored_card_rank = SMODS.Ranks[context.other_card.base.value].key
			local shared_rank_count = 0
			for _,held_card in ipairs(G.hand.cards) do
				if scored_card_rank == held_card.base.value then
					shared_rank_count = shared_rank_count + 1
				end
			end
			if shared_rank_count > 0 then
				return {
					dollars = card.ability.extra.money*shared_rank_count,
				}
			end
		end
	end
}

-----------
-- CORRUPTED
-- Migraine
-----------
SMODS.Joker { key = 'migraine',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},
	atlas = 'jokers_corrupt',
	pos = {x=5, y=2},

	attributes = { "modify_card", "ovn_optics" --[[, booster?]] },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 6
	-- Functionality implemented in "Migraine makes all standard pack cards Optics" Lovely patch
}

----------------------
-- CORRUPTED
-- Spiral of Addiction
----------------------
SMODS.Joker { key = 'spiral_of_addiction',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},
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

	atlas = 'jokers_corrupt',
	pos = {x=2, y=3},

	attributes = { "xmult", "scaling", "discard", "hand_size" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
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
			Ovn_f.event.simple(nil, function()
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
-- CORRUPTED
-- Cigarette Card
-----------------
SMODS.Joker { key = 'cigarette_card',
	credits = {
		concept = "Inspector_Bee",
		code = "Oinite",
		art = "HexaCryonic"
	},

	loc_vars = function(self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.e_ovn_miasma)
		return {vars = {
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult = 1.5
		}
	},

	atlas = 'jokers_corrupt',
	pos = {x=1, y=3},

	attributes = { "xmult", "modify_card", "editions" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
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
-- CORRUPTED
-- Air Strike
------------
SMODS.Joker { key = 'airstrike',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 0.2 } },
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Andromeda",
	},

	atlas = 'jokers_corrupt',
	pos = { x = 5, y = 1 },

	attributes = { "ten", "xmult", "scaling" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 6,

	calculate = function (self, card, context)
		if context.individual and context.other_card.base.value == '10' then
			local c_ability = context.other_card.ability --[[@as table]]
			if context.cardarea == 'unscored' or context.cardarea == G.hand then
				local old_xmult = c_ability.perma_x_mult
				SMODS.scale_card(context.other_card, {
					ref_table = c_ability,
					ref_value = "perma_x_mult",
					scalar_table = card.ability.extra,
					scalar_value = "xmult",
					colour = G.C.MULT
				})
				local new_xmult = c_ability.perma_x_mult
				local xmult_change = new_xmult - old_xmult

				c_ability.ovn_airstrike_stockpile = (c_ability.ovn_airstrike_stockpile or 0) + xmult_change
			elseif context.cardarea == G.play then
				-- displayed mult is 1 + perma_x_mult
				-- hence this check is X1 less than the required X5
				if (c_ability.ovn_airstrike_stockpile or 0) >= 4 then
          check_for_unlock({type = 'ovn_airstrike_release'})
				end
				c_ability.perma_x_mult = c_ability.perma_x_mult - (c_ability.ovn_airstrike_stockpile or 0)
				c_ability.ovn_airstrike_stockpile = nil
			end
		end
	end
}

-------------------
-- CORRUPTED
-- Fuck it, We Ball
-------------------
SMODS.Joker { key = 'yolo',
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "HexaCryonic",
	},
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.5 } },

	atlas = 'jokers_corrupt',
	pos = { x = 3, y = 1 },

	attributes = { "xmult", "hands" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.before and context.cardarea == G.jokers then
			ease_hands_played(-G.GAME.current_round.hands_left)
			Ovn_f.event.simple(nil, function ()
				G.GAME.current_round.hands_left = '-nan'
			end)
		end

		if context.individual and context.cardarea == G.play then
			return {
				x_mult = card.ability.extra.xmult,
				color = G.C.MULT,
				card = card
			}
		end

		if context.after then
			Ovn_f.event.simple(nil, function ()
				G.GAME.current_round.hands_left = 0
			end)
			Ovn_f.event.simple(nil, function ()
				if G.GAME.chips < G.GAME.blind.chips then
					G.STATE = G.STATES.GAME_OVER
					G.STATE_COMPLETE = false
				end
			end)
		end
	end,
}

---------------
-- CORRUPTED
-- Apache Tears
---------------

-- Determine which values to use for Apache Tears's effect.
---@param card Card
---@return number chips, number mult, number xmult, number cash, number cash_freq
local function determine_tear_effect(card)
	local card_ex = card.ability.extra
	local tracker = card_ex.track_corrupts
	local full_power = (
		tracker.j_rough_gem
		and tracker.j_bloodstone
		and tracker.j_arrowhead
		and tracker.j_onyx_agate
	)

	-- Determine which index to use when referring to a value list.
	---@param joker_key string
	---@return number
	local function fx_idx(joker_key)
		if full_power then return 3
		elseif tracker[joker_key] then return 2
		else return 1
		end
	end

	local chips     = card_ex.card_chips[fx_idx('j_arrowhead' )]
	local mult      = card_ex.card_mult [fx_idx('j_onyx_agate')]
	local xmult     = card_ex.card_xmult[fx_idx('j_bloodstone')]
	local cash      = card_ex.card_cash [fx_idx('j_rough_gem' )]
	local cash_freq = card_ex.cash_freq [fx_idx('j_rough_gem' )]

	return chips, mult, xmult, cash, cash_freq
end

-- Change Apache Tears's sprite depending on its tracked Jokers.
---@param card Card
---@return nil
local function change_tear_sprite(card)
	local tracker = card.ability.extra.track_corrupts
	-- e.g. Bloodstone appears from the 3rd sprite onward; Arrowhead appears every other sprite
	local x = (tracker.j_bloodstone and 2 or 0) + (tracker.j_arrowhead  and 1 or 0)
	local y = (tracker.j_rough_gem  and 2 or 0) + (tracker.j_onyx_agate and 1 or 0)
	card.children.center:set_sprite_pos({x = x, y = y})
end

SMODS.Joker { key = "apache_tears",
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic",
	},

	loc_vars = function (self, info_queue, card)
		local chips, mult, xmult, cash, cash_freq = determine_tear_effect(card)
		local card_count = cash_freq - card.ability.extra.card_count
		local cash_freq_txt = cash_freq ~= 1 and (' ' .. cash_freq) or ''
		-- space before cash freq strictly required

		local key = "j_ovn_apache_tears"
		local vars = {
			chips, mult, xmult,
			cash_freq_txt, card_count, cash,
		}
		-- If every card gives cash, change loc
		if cash_freq == 1 then
			key = "j_ovn_apache_tears_every_card_cash"
			vars = {chips, mult, xmult, cash}
		end

		return {
			key = key,
			vars = vars
		}
	end,
	config = {
		extra = {
			card_count = 0,
			track_corrupts = {
				j_rough_gem  = false,
				j_bloodstone = false,
				j_arrowhead  = false,
				j_onyx_agate = false
			},
			-- [1] - regular value
			-- [2] - corrupt value
			-- [3] - full power value
			--             [1]   [2]   [3]
			card_chips = {  20 ,  50 ,  60 },
			card_mult  = {   3 ,   7 ,   9 },
			card_xmult = { 1.1 , 1.3 , 1.5 },
			card_cash  = {   1 ,   1 ,   2 },
			cash_freq  = {   3 ,   1 ,   1 }
		}
	},

	atlas = "itemspecific_apache_tears",
	pos = {x=0, y=0},

	attributes = { "suit", "ovn_optics", "mult", "chips", "xmult", "econ", "ovn_corrupting" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = "ovn_corrupted",
	cost = 10,

	add_to_deck = function (self, card, from_debuff)
		change_tear_sprite(card)
	end,
	load = function (self, card, card_table, other_card)
		change_tear_sprite(card)
	end,
	calculate = function (self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card:is_suit("ovn_Optics")
		) then
			local chips, mult, xmult, cash, cash_freq = determine_tear_effect(card)

			-- These flags are necessary to ensure that
			-- joker copying/retriggers do not increase counter,
			-- but playing card retriggers -do-

			-- When copied, the Joker flag is only added to the "master" card

			-- The flag on the playing card is cleared in calc on mod
			-- (which occurs after Jokers and before any playing card retriggers)
			if not context.other_card.ovn_apache_counted then
				context.other_card.ovn_apache_counted = {}
			end
			if not card.ovn_apache_counted_id then
				card.ovn_apache_counted_id = tostring(math.random())
			end
			if not context.other_card.ovn_apache_counted[card.ovn_apache_counted_id] then
				context.other_card.ovn_apache_counted[card.ovn_apache_counted_id] = true
				card.ability.extra.card_count = card.ability.extra.card_count + 1
			end

			local do_cash = card.ability.extra.card_count % cash_freq == 0

			return {
				chips = chips,
				mult = mult,
				xmult = xmult,
				dollars = do_cash and cash or nil
			}
		end

		if context.after then
			local _,_,_,_, cash_freq = determine_tear_effect(card)
			card.ability.extra.card_count = card.ability.extra.card_count % cash_freq
		end

		if (
			context.ovn_corruption_occurred
			and context.ovn_corruption_type == "Joker"
			and context.ovn_corrupted_card ~= card
			and card.ability.extra.track_corrupts[context.ovn_former_form_key] ~= nil
		) then
			card.ability.extra.track_corrupts[context.ovn_former_form_key] = true
			change_tear_sprite(card)
			card:juice_up()
		end
	end,
}

----------------------
-- CORRUPTED
-- THE SHOW NEVER ENDS
----------------------
SMODS.Joker { key = 'showneverends',
	credits = {
		concept = {"SyntaxTsundere", "HexaCryonic"},
		code = "HexaCryonic",
		art = "HexaCryonic",
	},
	atlas = 'jokers_corrupt',
	pos = { x = 0, y = 2 },

	attributes = { "passive" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,
	-- Functionality implemented in Card:update hook
}

----------------------
-- CORRUPTED
-- Infinitesimal Joker
----------------------
SMODS.Joker { key = 'infinitesimal',
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
	credits = {
		concept = "HexaCryonic",
		code = "HexaCryonic",
		art = "Lil. Mr. Slipstream",
	},

	atlas = 'jokers_corrupt',
	pos = {x=4, y=2},

	attributes = { "joker_slot", "mult", "scaling", "rank", "three" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card.base.value == "3"
			and not context.blueprint
		) then
			simple_scale(card, "mult", "mult_gain", G.C.MULT, "NOMESSAGE")
			return {
				message = localize('k_upgrade_ex'),
				message_card = card
			}
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}

--------------------
-- CORRUPTED
-- Master of Puppets
--------------------

SMODS.Joker { key = 'master_of_puppets',
	credits = {
		concept = {"AlexZGreat", "HexaCryonic"},
		code = "Oinite",
		art = "HexaCryonic",
	},

	loc_vars = function (self, info_queue, card)
		-- This loc_vars primarily for making the rarity-modifier table
		local rarity_modi_map = Oblivion.rarity_modifier_map
		local rarity_modifier_list = {}
		for key in pairs(rarity_modi_map) do
			table.insert(rarity_modifier_list, key)
		end

		-- Sort by display_order, then by rarity key
		table.sort(rarity_modifier_list, function(a,b)
			local rarity_modi_def_a = rarity_modi_map[a]
			local rarity_modi_def_b = rarity_modi_map[b]

			local order_a = rarity_modi_def_a.display_order
			local order_b = rarity_modi_def_b.display_order
			if order_a then
				if order_b then
					if order_a ~= order_b then
						return order_a < order_b
					end
				else
					return true
				end
			end

			return tostring(a) < tostring(b)
		end)

		local rarity_id_to_key = {"Common", "Uncommon", "Rare"}

		local rarity_modifier_table = {{{text="Rarity"}, {text="Modifier"}}}
		for _,key in ipairs(rarity_modifier_list) do
			local rarity_modi_def = rarity_modi_map[key]
			if not rarity_modi_def.hidden then
				local rarity_def = SMODS.Rarities[rarity_id_to_key[key] or key]
				local rarity_color = rarity_def and rarity_def.badge_colour or nil

				local rarity_loc_key = rarity_modi_def.rarity_loc_key
				local modifier_loc_key = rarity_modi_def.modifier_loc_key
				table.insert(rarity_modifier_table, {
					{
						text = localize(rarity_loc_key),
						colour = rarity_modi_def.rarity_loc_colour or rarity_color
					},
					{
						text = localize(modifier_loc_key),
						colour = rarity_modi_def.modifier_loc_colour -- or nil
					}
				})
			end
		end

		local main_end = {Ovn_f.generate_table_ui(rarity_modifier_table)}
		return {main_end = main_end}
	end,

	atlas = 'jokers_corrupt',
	pos = {x=4, y=1},

	attributes = { "modify_card", "on_sell" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if context.selling_card and context.card.area == G.jokers then
			local sold_rarity = context.card.config.center.rarity
			local rarity_modi_def = Oblivion.rarity_modifier_map[sold_rarity]

			-- Jacks (so not Stone Cards etc.) without specific modifier types
			local jack_list = Ovn_f.get_puppet_jacks(sold_rarity)
			if #jack_list < 1 then return end
			local selected_jack = pseudorandom_element(
				jack_list,
				"ovn_master_of_puppets_jack"
			) --[[@as Card|table]]
			selected_jack.ovn_targetted_by_master = true

			-- Prepare options table and modifiers list
			local all_options, modifiers_list
			if not rarity_modi_def then -- Rarity not defined -> Random modifier
				local applicable_modifiers = {}
				for modifier, modi_def in pairs(Oblivion.modifier_def) do
					if modi_def.has_no_modifier(selected_jack) then
						table.insert(applicable_modifiers, modifier)
					end
				end

				local selected_modifier = pseudorandom_element(applicable_modifiers, "master_of_puppets_random_modi")
				local modi_def = Oblivion.modifier_def[selected_modifier]
				local modi_pool = get_current_pool(modi_def.pool)

				all_options = {[selected_modifier] = SMODS.shallow_copy(modi_pool)}
				modifiers_list = {selected_modifier}
			else
				all_options = Ovn_f.prepare_modifier_options(sold_rarity)
				modifiers_list = rarity_modi_def.modifiers
			end

			-- Finally add modifiers
			Ovn_f.event.simple(nil, function()
				for _,modifier in ipairs(modifiers_list) do
					local modi_def = Oblivion.modifier_def[modifier]
					local options = all_options[modifier]
					modi_def.apply_random_modifier(selected_jack, options)
				end
				selected_jack:juice_up()
				card:juice_up()
				play_sound('tarot1')
				selected_jack.ovn_targetted_by_master = nil
			end)
		end
	end,
	-- Additional functionality found in "modules/item-specific/master_of_puppets.lua"
}

-------------
-- CORRUPTED
-- Blacklight
-------------
SMODS.Joker { key = 'blacklight',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},
	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS['c_ovn_perception'])
	end,
	atlas = 'jokers_corrupt',
	pos = {x=1, y=1},

	attributes = { "tarot", "passive" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	-- Additional functionality in SMODS.poll_object hook
}

--------------------------
-- CORRUPTED
-- Bottled Ship of Theseus
--------------------------
SMODS.Joker { key = 'bottled_ship_of_theseus',
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic"
	},
	atlas = 'jokers_corrupt',
	pos = {x=2, y=2},
	uses_placeholder_sprite = true,

	attributes = { "enhancements", "generation" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function (self, card, context)
		if context.remove_playing_cards and not context.blueprint then
			for _,removed_card in ipairs(context.removed) do
				if removed_card.config.center.key ~= "m_glass" then
					local rank = removed_card.base.value
					local suit = removed_card.base.suit
					Ovn_f.event.simple(nil, function ()
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
-- CORRUPTED
-- Nexus Point
--------------
SMODS.Joker { key = 'nexus_point',
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
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "Lil. Mr. Slipstream",
	},

	atlas = 'jokers_corrupt',
	pos = {x=5, y=0},

	attributes = { "ovn_corrupting", "xmult", "scaling" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = false,
	rarity = 'ovn_corrupted',
	cost = 7,

	calculate = function (self, card, context)
		if (
			context.ovn_corrupted_from
			and context.ovn_former_form_key == "j_ovn_nexus_point"
			and not context.blueprint
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

--------------
-- CORRUPTED
-- White Cloak
--------------
SMODS.Joker { key = 'white_cloak',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.new_ice_xmult
		}}
	end,
	config = {
		extra = {
			new_ice_xmult = 3
		}
	},
	credits = {
		concept = {"Hyperspade", "SyntaxTsundere"},
		code = "Oinite",
		-- art
	},

	atlas = "placeholder",
	pos = {x=0, y=0},
	uses_placeholder_sprite = true,

	attributes = { "enhancement" },
	blueprint_compat = false,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_corrupted',
	cost = 12,
	in_pool = function (self, args)
		return false
	end,

	-- Functionality in:
		-- Ice Card register
		-- Card:set_ability hook
}

---------------
-- CORRUPTED
-- Nyarlathotep
---------------

local function count_corrupt_jokers()
	if not Ovn_f.descend_table{G, "jokers", "cards"} then return 1 end
	local count = 0
	for _,joker in pairs(G.jokers.cards) do
		local joker_key = joker.config.center.key
		if Ovn_f.joker_is_purifiable(joker_key) then
			count = count + 1
		end
	end
	return count
end

SMODS.Joker { key = 'nyarlathotep',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			count_corrupt_jokers(),
			card.ability.extra.xmult_mod
		}}
	end,
	config = {
		extra = {
			xmult_mod = 0.02
		}
	},
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = "HexaCryonic",
	},

	atlas = 'jokers_corrupt',
	pos = {x=4, y=3},
	soul_pos = {x=5, y=3},

	attributes = { "retrigger", "xmult", "perma_bonus" },
	blueprint_compat = true,
	eternal_compat = true,
	perishable_compat = true,
	rarity = 'ovn_supercorrupted',
	cost = 20,

	calculate = function (self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and not context.blueprint
		) then
			return {
				pre_func = function()
					SMODS.scale_card(context.other_card, {
						ref_table = context.other_card.ability,
						ref_value = "perma_x_mult",
						scalar_table = card.ability.extra,
						scalar_value = "xmult_mod",
						colour = G.C.MULT
					})
				end
			}
		end

		if context.repetition and context.cardarea == G.play and not context.retrigger_joker then
			return {repetitions = count_corrupt_jokers()}
		end

		if context.ovn_corrupted_from then
			check_for_unlock({type="ovn_slumbering_beast"})
		end
	end
}
