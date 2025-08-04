local add_simple_event = Ovn_f.add_simple_event

----

SMODS.Suit{
	key = 'Optics',
	card_key = 'O',
	hidden = true,

	lc_atlas = 'optics',
	hc_atlas = 'optics_hc',

	lc_ui_atlas = 'suits',
	hc_ui_atlas = 'suits_hc',

	pos = { x = 0, y = 0 },
	ui_pos = { x = 0, y = 0 },

	lc_colour = HEX('7E41B6'),
	hc_colour = HEX('8806FF'),

	in_pool = function(self, args)
		if args and args.initial_deck then return false end
		return G.GAME.ovn_has_ocular
	end,
}

----

SMODS.Back{
	key = "ocular",
	pos = { x = 0, y = 0 },
	atlas = "deck_atlas",

	apply = function(self)
		G.GAME.ovn_has_ocular = true
		add_simple_event('immediate', nil, function()
			local ranks = {"A", "K", "Q", "J", "T", "9", "8", "7", "6", "5", "4", "3", "2"}
			for _,rank in ipairs(ranks) do
				local card_key = ('ovn_O_%s'):format(rank)
				local card_front = G.P_CARDS[card_key]
				create_playing_card({front = card_front}, G.deck)
			end
		end)
	end,
}

----

SMODS.PokerHandPart{ -- Spectrum base (yoink)
	key = 'spectrum',
	func = function(hand)
		local suits = {}
		for _, suit_key in ipairs(SMODS.Suit.obj_buffer) do
			suits[suit_key] = false
		end
		if #hand < 5 then return {} end

		local function count_card(hand_card)
			-- True if:
			--- Never played Spectrum, card is not wild
			--- Played Spectrum (wild cards are then counted)
			return (
				G.GAME.hands["ovn_Spectrum"].played == 0
				and hand_card.config.center_key ~= 'm_wild'
				or G.GAME.hands["ovn_Spectrum"].played > 0
			)
		end

		for _, hand_card in ipairs(hand) do
			if count_card(hand_card) then
				for suit_key in pairs(suits) do
					if hand_card:is_suit(suit_key, nil, true) then
						suits[suit_key] = true
						break
					end
				end
			end
		end

		local num_suits = 0
		for _, has_suit in pairs(suits) do
			if has_suit then num_suits = num_suits + 1 end
		end
		return (num_suits >= 5) and {hand} or {}
	end
}

SMODS.PokerHand{ -- Spectrum (yoink)
	key = 'Spectrum',
	visible = false,
	chips = 60,
	mult = 6,
	l_chips = 20,
	l_mult = 2,
	example = {
		{ 'ovn_O_A', true },
		{ 'S_7', true },
		{ 'H_9', true },
		{ 'C_K', true },
		{ 'D_4', true },
	},

	evaluate = function(parts)
		return parts.ovn_spectrum
	end
}

SMODS.PokerHand{ -- Straight Spectrum (yoink)
	key = 'Straight Spectrum',
	visible = false,
	chips = 130,
	mult = 10,
	l_chips = 30,
	l_mult = 3,
	example = {
		{ 'ovn_O_K', true },
		{ 'S_Q', true },
		{ 'H_J', true },
		{ 'C_T', true },
		{ 'D_9', true }
	},

	process_loc_text = function(self)
		SMODS.PokerHand.process_loc_text(self)
		SMODS.process_loc_text(G.localization.misc.poker_hands, self.key..' (Royal)', self.loc_txt, 'extra')
	end,

	evaluate = function(parts)
		if not next(parts.ovn_spectrum) or not next(parts._straight) then return {} end
		return { SMODS.merge_lists(parts.ovn_spectrum, parts._straight) }
	end,

	modify_display_text = function(self, _cards, scoring_hand)
		local is_royal = true
		for _, scoring_card in ipairs(scoring_hand) do
			local rank = SMODS.Ranks[scoring_card.base.value]
			is_royal = is_royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
		end
		if is_royal then
			return self.key .. ' (Royal)'
		end
	end
}

SMODS.PokerHand{ -- Spectrum House (yoonk)
	key = 'Spectrum House',
	visible = false,
	chips = 150,
	mult = 15,
	l_chips = 40,
	l_mult = 3,
	example = {
		{ 'ovn_O_K', true },
		{ 'S_K', true },
		{ 'H_K', true },
		{ 'C_8', true },
		{ 'D_8', true }
	},

	evaluate = function(parts)
		if #parts._3 < 1 or #parts._2 < 2 or not next(parts.ovn_spectrum) then return {} end
		return {SMODS.merge_lists (parts._all_pairs, parts.ovn_spectrum)}
	end
}

SMODS.PokerHand{ -- Spectrum Five (yonk)
	key = 'Spectrum Five',
	visible = false,
	chips = 170,
	mult = 18,
	l_chips = 50,
	l_mult = 3,
	example = {
		{ 'ovn_O_A', true },
		{ 'S_A', true },
		{ 'H_A', true },
		{ 'C_A', true },
		{ 'D_A', true }
	},

	evaluate = function(parts)
		if not next(parts._5) or not next(parts.ovn_spectrum) then return {} end
		return {SMODS.merge_lists (parts._5, parts.ovn_spectrum)}
	end
}

----

SMODS.Consumable{
	set = 'Planet',
	key = 'ganymede',
	--! `h_` prefix was removed
	config = { hand_type = 'ovn_Spectrum', softlock = true },
	pos = {x = 0, y = 0 },
	atlas = 'spectrum_atlas',
	process_loc_text = function(self)
		--use another planet's loc txt instead
		local target_text = G.localization.descriptions[self.set]['c_mercury'].text
		SMODS.Consumable.process_loc_text(self)
		G.localization.descriptions[self.set][self.key].text = target_text
	end,
	generate_ui = 0,
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	loc_txt = {
		name = 'Ganymede'
	}
}

SMODS.Consumable{
	set = 'Planet',
	key = 'callisto',
	--! `h_` prefix was removed
	config = { hand_type = 'ovn_Straight Spectrum', softlock = true },
	pos = {x = 1, y = 0 },
	atlas = 'spectrum_atlas',
	process_loc_text = function(self)
		--use another planet's loc txt instead
		local target_text = G.localization.descriptions[self.set]['c_mercury'].text
		SMODS.Consumable.process_loc_text(self)
		G.localization.descriptions[self.set][self.key].text = target_text
	end,
	generate_ui = 0,
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	loc_txt = {
			name = 'Callisto'
		}
}

SMODS.Consumable{
	set = 'Planet',
	key = 'io',
	--! `h_` prefix was removed
	config = { hand_type = 'ovn_Spectrum House', softlock = true },
	pos = {x = 2, y = 0 },
	atlas = 'spectrum_atlas',
	process_loc_text = function(self)
		--use another planet's loc txt instead
		local target_text = G.localization.descriptions[self.set]['c_mercury'].text
		SMODS.Consumable.process_loc_text(self)
		G.localization.descriptions[self.set][self.key].text = target_text
	end,
	generate_ui = 0,
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	loc_txt = {
			name = 'Io'
		}
}

SMODS.Consumable{
	set = 'Planet',
	key = 'europa',
	--! `h_` prefix was removed
	config = { hand_type = 'ovn_Spectrum Five', softlock = true },
	pos = {x = 3, y = 0 },
	atlas = 'spectrum_atlas',
	process_loc_text = function(self)
		--use another planet's loc txt instead
		local target_text = G.localization.descriptions[self.set]['c_mercury'].text
		SMODS.Consumable.process_loc_text(self)
		G.localization.descriptions[self.set][self.key].text = target_text
	end,
	generate_ui = 0,
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	loc_txt = {
			name = 'Europa'
		}
}

----

local function corruption_dissolve(card)
	add_simple_event('after', 0.1, function()
		play_sound("tarot1")
		card:start_dissolve({G.C.RARITY['ovn_corrupted']})
	end)
end

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

		if (context.after and c_extra.is_melting) then
			c_extra.current_x_mult = c_extra.current_x_mult - c_extra.x_mult_loss
			c_extra.is_melting = false
		end

		if c_extra.current_x_mult <= 1 then corruption_dissolve(card) end
	end,
}

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

----

SMODS.Consumable {
	set = "Tarot",
	name = "ovn_Perception",
	key = "perception",
	cost = 2,
	atlas = "abyss_atlas",
	config = {max_highlighted = 2, suit_conv = 'ovn_Optics'},
	loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
	pos = {x=1, y=0},

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Parallel Tarot', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	use = function(self)
		local all_highlighted_cards = G.hand.highlighted

		for i,highlighted_card in ipairs(all_highlighted_cards) do
			local percent = 1.15 - (i - 0.999)/(#all_highlighted_cards - 0.998)*0.3
			add_simple_event('after', 0.15, function()
				G.GAME.corruptingCard = true
				highlighted_card:flip()
				play_sound('card1', percent)
				highlighted_card:juice_up(0.3, 0.3)
				G.GAME.corruptingCard = false
			end)
			G.GAME.corruptingCard = false
		end

		delay(0.2)

		for _,highlighted_card in ipairs(all_highlighted_cards) do
			add_simple_event('after', 0.1, function() highlighted_card:change_suit(self.config.suit_conv) end)
		end

		for i,highlighted_card in ipairs(all_highlighted_cards) do
			local percent = 0.85 + ( i - 0.999 ) / ( #all_highlighted_cards - 0.998 ) * 0.3
			add_simple_event('after', 0.15, function()
				highlighted_card:flip()
				play_sound('ovn_optic', percent, 1.1)
				highlighted_card:juice_up(0.3, 0.3)
			end)
		end

		Ovn_f.optic_instability(#all_highlighted_cards)
		add_simple_event('after', 0.2, function() G.hand:unhighlight_all() end)

		delay(0.5)
	end,
}