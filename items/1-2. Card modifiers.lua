--------------------------
-- Supplementary functions
--------------------------
local add_simple_event = Ovn_f.add_simple_event
to_big = to_big or function(x)
	return x
end

local function change_rank(card, new_rank)
	local new_code = ({
		Diamonds = 'D_',
		Spades   = 'S_',
		Clubs    = 'C_',
		Hearts   = 'H_',
		ovn_Optics = 'ovn_O_'
	})[card.base.suit]

	local new_val = ({
		Ace    = 'A',
		King   = 'K',
		Queen  = 'Q',
		Jack   = 'J',
		['10'] = 'T'
	})[new_rank] or new_rank

	local new_card_key = new_code .. new_val
	local new_card = G.P_CARDS[new_card_key]

	card:flip()
	card:set_base(new_card)
	G.GAME.blind:debuff_card(card)
	card:flip()
end

----------------

---------------
-- ENHANCEMENT
-- Radiant Card
---------------
SMODS.Enhancement{
	key = "radiant",
	config = {extra = {bonus_chips = 0}},

	atlas = "opticenhance_atlas",
	pos = { x = 3, y = 0 },
	in_pool = function() return false end,


	set_ability = function (self, card, initial, delay_sprites)
		local all_radiant_jokers = SMODS.find_card('j_ovn_radiant_joker')
		for _,radiant_joker in ipairs(all_radiant_jokers) do
			card.ability.extra.bonus_chips = (
				card.ability.extra.bonus_chips
				+ radiant_joker.ability.extra.extra_chips
			)
		end
	end,
	calculate = function (self, card, context)
		if context.before and context.cardarea == G.hand then
			local card_chip = card.base.nominal + card.ability.extra.bonus_chips
			for _,other_card in ipairs(context.scoring_hand) do
				other_card.ability.bonus = other_card.ability.bonus + card_chip
				add_simple_event(nil, nil, function ()
					other_card:juice_up()
				end)
			end
		end
	end
}

---------------
-- ENHANCEMENT
-- Dynamo Card
---------------
SMODS.Enhancement{
	key = 'dynamo',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {mult = 7}
	},

	atlas = "opticenhance_atlas",
	pos = { x = 0, y = 1 },
	in_pool = function() return false end,

	calculate = function (self, card, context)
		if context.before and context.cardarea == 'unscored' then
			for _,other_card in ipairs(context.scoring_hand) do
				other_card.ability.mult = other_card.ability.mult + card.ability.extra.mult
			end
		end
		if context.after and context.cardarea == 'unscored' then
			for _,other_card in ipairs(context.scoring_hand) do
				other_card.ability.mult = other_card.ability.mult - card.ability.extra.mult
			end
		end
	end
}

---------------
-- ENHANCEMENT
-- Coordinate Card
---------------
SMODS.Enhancement{
	key = "coord",
	loc_vars = function(self, info_queue, card)
		return { }
	end,

	atlas = "opticenhance_atlas",
	pos = { x = 2, y = 1 },
	in_pool = function() return false end,
	config = { },

	calculate = function(self, card, context)
		if context.modify_scoring_hand or context.check then
			local card_table = G.hand.cards
			local card_index = -1

			for i,hand_card in ipairs(card_table) do
				if hand_card == card then card_index = i end
			end

			if card_index > 1 then
				local other_card_value = card_table[card_index - 1].base.value
				if card.base.value == other_card_value then return end
				change_rank(card, other_card_value)
			end
		end
	end,
}

---------------
-- ENHANCEMENT
-- Ice Card
---------------
SMODS.Enhancement{
	key = "ice",
	loc_vars = function(self, info_queue, card)
		local item = card and card.ability or self.config
		return {vars = {
			item.extra.x_mult_loss,
			item.extra.current_x_mult
		}}
	end,

	atlas = "opticenhance_atlas",
	pos = { x = 0, y = 0 },
	in_pool = function() return false end,
	config = {extra = {
		x_mult_loss = 0.1,
		current_x_mult = 2,
		is_melting = false
	}},

	calculate = function(self,card,context)
		local c_extra = card.ability.extra

		if context.cardarea == G.play and context.main_scoring then
			c_extra.is_melting = true
			return { x_mult = c_extra.current_x_mult }
		end

		if context.after and c_extra.is_melting then
			c_extra.current_x_mult = c_extra.current_x_mult - c_extra.x_mult_loss
			c_extra.is_melting = false

			if c_extra.current_x_mult > 1 then
				SMODS.calculate_context{
					ovn_ice_degraded = true,
					other_card = card,
					ovn_ice_xmult = c_extra.current_x_mult
				}
			end
		end

		if (
			context.destroy_card == card
			and context.cardarea == G.play
			and c_extra.current_x_mult <= (1 + card.ability.extra.x_mult_loss)
		) then
			card.ice_melted = true
			add_simple_event(nil, nil, function()
				play_sound("tarot1")
			end)
			return {remove = true}
		end
	end,
}

---------------
-- ENHANCEMENT
-- Unobtainium Card
---------------
SMODS.Enhancement{
	key = "unob",
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.repetitions }}
	end,

	atlas = "opticenhance_atlas",
	pos = { x = 2, y = 0 },
	in_pool = function() return false end,
	config = {extra = {repetitions = 1}},

	calculate = function(self, card, context)
		-- Custom context
		if (
			context.ovn_repetition_from_playing_card
			and card.area == G.hand
			and context.other_card.area == G.play
		) then
			return {repetitions = card.ability.extra.repetitions}
		end
	end,
	-- Additional functionality present in lib/ui_hook.lua, G.FUNCS.can_play
}

---------------
-- ENHANCEMENT
-- Crystal Card
---------------
SMODS.Enhancement{
	key = "crystal",
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.plays_left }}
	end,

	atlas = "opticenhance_atlas",
	pos = { x = 1, y = 1 },
	in_pool = function() return false end,
	config = {extra = {plays_left = 3}},

	never_scores = true,

	set_ability = function (self, card, initial, delay_sprites)
		local all_crystal_jokers = SMODS.find_card('j_ovn_crystal_joker')
		for _,crystal_joker in ipairs(all_crystal_jokers) do
			card.ability.extra.plays_left = (
				card.ability.extra.plays_left
				+ crystal_joker.ability.extra.extra_plays
			)
		end
	end,
	calculate = function(self, card, context)
		if context.before and context.cardarea == "unscored" then
			card.ability.extra.plays_left = card.ability.extra.plays_left - 1
			return {
				level_up = true,
				message = localize('k_level_up_ex')
			}
		end

		if (
			context.destroy_card == card
			and context.cardarea == "unscored"
			and card.ability.extra.plays_left <= 0
		) then
			add_simple_event(nil, nil, function ()
				play_sound('glass'..math.random(1, 6), math.random()*0.5 + 1.2,0.5)
			end)
			return {remove = true}
		end
	end,
	-- Additional functionality present in lib/ui_hook.lua, G.FUNCS.can_play
}

---------------
-- ENHANCEMENT
-- Tungsten Card
---------------
SMODS.Enhancement{
	key = "dense",
	loc_vars = function(self, info_queue, card)
		local item = card and card.ability or self.config
		return {vars = {
			item.extra.tungsten_handsize_mod,
			item.extra.holdingthis
		}}
	end,

	atlas = "opticenhance_atlas",
	pos = { x = 1, y = 0 },
	in_pool = function() return false end,
	config = {extra = {tungsten_handsize_mod = 1, holdingthis = 0}},

	update = function(self, card, dt)
		if card.area then
			if (card.area == G.hand) and not (card.debuff) and (card.ability.extra.holdingthis) == 0 then
				G.hand:change_size(-self.config.extra.tungsten_handsize_mod)
				card.ability.extra.holdingthis = 1
			elseif card.area ~= G.hand and card.ability.extra.holdingthis == 1 then
				G.hand:change_size(self.config.extra.tungsten_handsize_mod)
				card.ability.extra.holdingthis = 0
			end
		end
	end,

	calculate = function(self,card,context)
		if context.cardarea == G.play and context.before then
			G.hand:change_size(card.ability.extra.tungsten_handsize_mod)
			G.GAME.round_resets.temp_handsize = (G.GAME.round_resets.temp_handsize or 0) + math.floor(card.ability.extra.tungsten_handsize_mod)
		end
	end,
}

----------------

--------------
-- SEAL
-- Indigo Seal
--------------
SMODS.Seal {
	key = 'indigo',
	badge_colour = HEX('252fe3'),

	atlas = "seals_atlas",
	pos = {x=0, y=0},

	calculate = function(self, card, context)
		if (
			context.ovn_corruption_occurred
			and context.ovn_corruption_type == "Joker"
			and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
			and card.area == G.hand
		) then
			G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
			add_simple_event('before', 0, function ()
				SMODS.add_card({ set = 'Spectral' })
				card:juice_up(0.3, 0.5)
				G.GAME.consumeable_buffer = 0
			end)
		end
	end
}

---------------
-- SEAL
-- Mark of Ruby
---------------
SMODS.Seal {
	key = 'ruby_mark',
	config = { extra = {retriggers = 2} },
	loc_vars = function (self, info_queue, card)
		return {vars = {
			self.config.extra.retriggers
		}}
	end,
	badge_colour = darken(G.C.RED, 0.1),

	atlas = "seals_atlas",
	pos = {x=0, y=0},
	in_pool = function() return false end,
	never_scores = true,

	calculate = function (self, card, context)
		-- Custom context
		if (
			context.ovn_repetition_from_playing_card
			and context.cardarea == 'unscored'
			and context.other_card.area == G.play
		) then
			return {repetitions = self.config.extra.retriggers}
		end

		if (
			context.destroy_card == card
			and context.cardarea == 'unscored'
		) then
			return {remove = true}
		end
	end
}

-------------------
-- SEAL
-- Mark of Sapphire
-------------------
SMODS.Seal {
	key = 'sapphire_mark',
	badge_colour = darken(G.C.BLUE, 0.1),

	atlas = "seals_atlas",
	pos = {x=0, y=0},
	in_pool = function() return false end,

	calculate = function (self, card, context)
		if (
			context.before
			and context.cardarea == G.play
			and #context.full_hand == 1
		) then
			update_hand_text({
				sound = 'button',
				volume = 0.7,
				pitch = 1.1,
				delay = 0
			}, {
				mult = 0,
				chips = 0,
				handname = '',
				level = ''
			})

			local poker_hand_results = evaluate_poker_hand(G.hand.cards)
			local detected_hands = {}
			for hand_name, card_list in pairs(poker_hand_results) do
				if next(card_list) then table.insert(detected_hands, hand_name) end
			end
			table.sort(detected_hands, function(a,b)
				-- Sort from lowest to highest
				return SMODS.PokerHands[a].order > SMODS.PokerHands[b].order
			end)
			for _,hand_name in ipairs(detected_hands) do
				update_hand_text({
					sound = 'button',
					volume = 0.7,
					pitch = 0.8,
					delay = 0.3
				}, {
					handname = localize(hand_name, 'poker_hands'),
					chips = G.GAME.hands[hand_name].chips,
					mult  = G.GAME.hands[hand_name].mult,
					level = G.GAME.hands[hand_name].level
				})
				level_up_hand(card, hand_name)
			end
			update_hand_text({
				sound = 'button',
				volume = 0.7,
				pitch = 0.8,
				delay = 0.3
			}, {
				handname = localize(context.scoring_name, 'poker_hands'),
				chips = G.GAME.hands[context.scoring_name].chips,
				mult  = G.GAME.hands[context.scoring_name].mult,
				level = G.GAME.hands[context.scoring_name].level
			})
		end

		if (
			context.destroy_card == card
			and context.cardarea == G.play
			and #context.scoring_hand == 1
		) then
			return {remove = true}
		end
	end
}

------------------
-- SEAL
-- Mark of Citrine
------------------
SMODS.Seal {
	key = 'citrine_mark',
	config = { extra = {
		seal_cash = 1,
		mark_cash = 3
	}},
	loc_vars = function (self, info_queue, card)
		return {vars = {
			self.config.extra.seal_cash,
			self.config.extra.mark_cash,
		}}
	end,
	badge_colour = darken(G.C.GOLD, 0.1),

	atlas = "seals_atlas",
	pos = {x=0, y=0},
	in_pool = function() return false end,

	calculate = function (self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			local count_seals = 0
			local count_marks = 0
			local marks = {
				ovn_ruby_mark = true,
				ovn_sapphire_mark = true,
				ovn_amethyst_mark = true,
				ovn_citrine_mark = true,
				ovn_iolite_mark = true,
			}

			for _,other_card in ipairs(G.playing_cards) do
				if other_card.seal then
					if marks[other_card.seal] then count_marks = count_marks + 1
					else count_seals = count_seals + 1
					end
				end
			end


			return {
				dollars = (
					count_seals*self.config.extra.seal_cash
					+ count_marks*self.config.extra.mark_cash
				)
			}
		end

		if context.destroy_card == card and context.cardarea == G.play then
			return {remove = true}
		end
	end
}

-------------------
-- SEAL
-- Mark of Amethyst
-------------------
SMODS.Seal {
	key = 'amethyst_mark',
	loc_vars = function (self, info_queue, card)
		table.insert(info_queue, { key = 'c_fool', set = 'Tarot' })
		return { vars = {
			localize { type = 'name_text', key = 'c_fool', set = 'Tarot' }
		}}
	end,
	badge_colour = darken(G.C.PURPLE, 0.1),

	atlas = "seals_atlas",
	pos = {x=0, y=0},
	in_pool = function() return false end,

	calculate = function (self, card, context)
		if context.main_scoring and context.cardarea == G.play then
			add_simple_event(nil, nil, function ()
				SMODS.add_card{
					key = "c_fool",
					edition = "e_negative"
				}
			end)
		end

		if context.destroy_card == card and context.cardarea == G.play then
			return {remove = true}
		end
	end
}

-----------------
-- SEAL
-- Mark of Iolite
-----------------
SMODS.Seal {
	key = 'iolite_mark',
	badge_colour = darken(HEX('252fe3'), 0.1),

	atlas = "seals_atlas",
	pos = {x=0, y=0},
	in_pool = function() return false end,

	calculate = function (self, card, context)
		if context.using_consumeable and context.cardarea == G.hand then
			if context.consumeable.ability.set ~= "Spectral" then return end
			local consumable_key = context.consumeable.config.center.key
			add_simple_event(nil, nil, function ()
				SMODS.add_card{
					key = consumable_key,
					edition = "e_negative"
				}
				SMODS.destroy_cards(card)
			end)
		end
	end
}

----------------

----------
-- EDITION
-- Miasma
----------
SMODS.Edition {
	key = "miasma",
	config = {
		extra = {
			retriggers = 3,
			corrupt_retriggers = 1
		}
	},
	loc_vars = function (self, info_queue, card)
		local key = "e_ovn_miasma"

		if not (card and card.config and card.config.center) then
		elseif (
			card.base and card.base.suit == 'ovn_Optics'
			or card.config.center.rarity == 'ovn_corrupted'
		) then
			if Ovn_f.joker_is_corruptible(card.config.center.key) then
				key = "e_ovn_miasma_recursive_corrupt"
			else
				key = "e_ovn_miasma_corrupted"
			end
		elseif card.base.suit then
			key = "e_ovn_miasma_playing_card"
		elseif Ovn_f.joker_is_corruptible(card.config.center.key) then
			key = "e_ovn_miasma_corruptible_joker"
		elseif card.area == G.jokers then
			key = "e_ovn_miasma_destroy"
		end

		return {key = key}
	end,

	shader = 'miasma',
	disable_shadow = true,
	disable_base_shader = true,
	apply_to_float = true,

	in_shop = false,
	weight = 8,
	extra_cost = 4,
	sound = {
		sound = "ovn_e_miasma",
		per = 1,
		vol = 0.4,
	},

	calculate = function(self, card, context)
		if context.other_card == card and (
			context.repetition -- Repeat playing cards
			or context.retrigger_joker_check -- or retrigger Jokers
		) then
			local repetitions = self.config.extra.retriggers
			if (
				(card.base and card.base.suit == 'ovn_Optics')
				or card.config.center.rarity == 'ovn_corrupted'
			) then
				repetitions = self.config.extra.corrupt_retriggers
			end
			return { repetitions = repetitions }
		end

		-- Either corrupt or kill Joker, or do nothing if Joker is corrupt
		if context.after and context.cardarea == G.jokers then
			-- Card is corruptable, proceed to corrupt
			if Ovn_f.joker_is_corruptible(card.config.center.key) then
				add_simple_event('after', 0.1, function ()
					Ovn_f.corrupt_joker(card)
					card:set_edition(nil)
				end)

			elseif card.config.center.rarity == 'ovn_corrupted' then
				-- nothing :P

			-- Card cannot be corrupted, self-destruct
			else
				add_simple_event('after', 0.0, function ()
					play_sound("ovn_optic", nil, 0.2)
					card:start_dissolve({G.C.RARITY['ovn_corrupted']})
				end)
			end
		end

		-- Corrupt non-Optic cards
		if context.after and context.cardarea == G.play then
			if card.base.suit ~= 'ovn_Optics' then
				add_simple_event('after', 0.1, function ()
					card:set_edition(nil)
					card:change_suit('ovn_Optics')
				end)
			end
		end
	end,
}