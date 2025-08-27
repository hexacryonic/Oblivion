--------------------------
-- Supplementary functions
--------------------------
local add_simple_event = Ovn_f.add_simple_event
to_big = to_big or function(x)
	return x
end

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

----------------
-- John Oblivion
----------------
SMODS.Joker {
	key = 'john',

	atlas = 'notcorrupted',
	pos = { x = 0, y = 0 },

	blueprint_compat = false,
	eternal_compat = false,
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
		if context.before then
			print(context.scoring_name)
		end
	end,
}

------
-- ovn
------
SMODS.Joker {
	key = 'ovn',
	atlas = 'corrupted',
	pos  = { x=4, y=0 },

	blueprint_compat = false,
	rarity = 3,
	cost = 10,

	calculate = function(self, card, context)
		if (
			context.end_of_round
			and context.cardarea == G.jokers
			and not context.game_over
			and context.beat_boss
		) then
			add_simple_event(nil, nil, function ()
				local leftmost_joker = G.jokers.cards[1]
				leftmost_joker:set_edition("e_ovn_miasma")
				leftmost_joker:juice_up()
				card:juice_up()
				play_sound('tarot1')
			end)
		end
	end
}

----------------
-- Radiant Joker
----------------
SMODS.Joker {
	key = 'radiant_joker',
	loc_vars = function (self, info_queue, card)
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

	atlas = "opticenhance_atlas",
	pos = { x=3, y=0 },

	rarity = 2,
	cost = 6,

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
SMODS.Joker {
	key = 'ice_joker',
	loc_vars = function(self, info_queue, card)
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

	-- placeholder
	atlas = "opticenhance_atlas",
	pos = { x=0, y=0 },

	rarity = 2,
	cost = 6,

	calculate = function(self, card, context)
		local card_extra = card.ability.extra
		if context.joker_main then
			return {xmult = card_extra.xmult}
		end

		if context.ovn_ice_degraded then
			simple_scale(card, "xmult", "xmult_gain", G.C.RED)
		end

		if context.remove_playing_cards and not context.blueprint then
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
SMODS.Joker {
	key = 'crystal_joker',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.extra_plays
		}}
	end,
	config = {
		extra = {
			extra_plays = 2
		}
	},

	-- placeholder
	atlas = "opticenhance_atlas",
	pos = { x=1, y=1 },

	rarity = 2,
	cost = 6,

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
					add_simple_event(nil, nil, function ()
						play_sound('glass'..math.random(1, 6), math.random()*0.5 + 1.2,0.5)
						SMODS.destroy_cards(playing_card)
					end)
				end
			end
		end
	end
	-- Additional functionality found in "set_ability", Crystal enhancement register
}

--------------
-- Pure Visage
--------------
SMODS.Joker {
	key = 'pure_visage',
	config = {
		extra = {
			on_cooldown = false
		}
	},
	-- placeholder
	atlas = "notcorrupted",
	pos = { x=1, y=0 },

	rarity = 1,
	cost = 4,

	calculate = function(self, card, context)
		if context.setting_blind then
			card.ability.extra.on_cooldown = false
		end

		if context.ovn_purified_from then
			card.ability.extra.on_cooldown = true
		end
	end
	-- Functionality implemented in G.UIDEF.use_and_sell_buttons hook
}

-----------------
-- Corrupt Visage
-----------------
-- Corrupt Visage goes here for immediate navigation after Pure Visage
SMODS.Joker {
	key = 'corrupt_visage',
	config = {
		extra = {
			on_cooldown = false
		}
	},
	atlas = 'corrupted',
	pos  = { x=0, y=3 },

	rarity = "ovn_corrupted",
	cost = 4,

	calculate = function(self, card, context)
		if context.setting_blind then
			card.ability.extra.on_cooldown = false
		end

		if context.ovn_corrupted_from then
			Ovn_f.corruption_instability(1)
			card.ability.extra.on_cooldown = true
		end
	end
	-- Functionality implemented in G.UIDEF.use_and_sell_buttons hook
}

------------------
-- Trolley Problem
------------------

SMODS.Joker {
	key = 'trolley_problem',
	config = { extra = { valid_hands = {
		["Three of a Kind"] = true,
		["Four of a Kind"] = true,
		["Five of a Kind"] = true
	}}},
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

SMODS.Joker {
	key = 'purifier',
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

	--[[
	atlas = "notcorrupted",
	pos = { x=1, y=0 },
	]]

	rarity = 2,
	cost = 5,

	calculate = function (self, card, context)
		if context.setting_blind then
			local _, leftmost = get_leftmost_corrupted_joker()
			if leftmost then
				Ovn_f.purify_joker(leftmost)
				simple_scale(card, "mult", "mult_gain", G.C.MULT)
			end
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}