SMODS.Suit{
	key = 'Optics',
	card_key = 'O',
	hidden = true,

	lc_atlas = 'optics',
	hc_atlas = 'optics_hc',

	lc_ui_atlas = 'suits',
	hc_ui_atlas = 'suits_hc',

	loc_txt = {
	singular = 'Optic',
	plural = 'Optics'
	},

	pos = { x = 0, y = 0 },
	ui_pos = { x = 0, y = 0 },

	lc_colour = HEX('7E41B6'),
	hc_colour = HEX('8806FF'),

	in_pool = function(self, args)
		if args and args.initial_deck then
		return false
		end
	end,
}

SMODS.Back{
	key = "ocular",
	pos = { x = 0, y = 0 },
	atlas = "deck_atlas",
	loc_txt = {
		name = 'Ocular Deck',
		text = {
			"Start with a full set of {C:ovn_optic}Optics{}",
			"in addition to the standard deck"
		}
	},
	apply = function(self)
	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		func = function()
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'A']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'K']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'Q']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'J']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'T']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'9']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'8']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'7']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'6']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'5']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'4']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'3']}, G.deck, nil, nil, nil)
		create_playing_card({front = G.P_CARDS['ovn_O'..'_'..'2']}, G.deck, nil, nil, nil)
		return true
		end,
	}))
	end,
}

SMODS.PokerHandPart{ -- Spectrum base (yoink)
	key = 'spectrum',
	func = function(hand)
		local suits = {}
		for _, v in ipairs(SMODS.Suit.obj_buffer) do
			suits[v] = 0
		end
		if #hand < 5 then return {} end
		if G.GAME.hands["ovn_Spectrum"].played > 0 then
			for i = 1, #hand do
				if hand[i].config.center_key == 'm_wild' then
				for k, v in pairs(suits) do
					if hand[i]:is_suit(k, nil, true) and v == 0 then
						suits[k] = v + 1; break
					end
				end
				end
			end
		end
		for i = 1, #hand do
			if hand[i].config.center_key ~= 'm_wild' then
				for k, v in pairs(suits) do
					if hand[i]:is_suit(k, nil, true) and v == 0 then
						suits[k] = v + 1; break
					end
				end
			end
		end
		local num_suits = 0
		for _, v in pairs(suits) do
			if v > 0 then num_suits = num_suits + 1 end
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
		{ 'ovn_O_A',    true },
		{ 'S_7',    true },
		{ 'H_9', true },
		{ 'C_K', true },
		{ 'D_4',    true },
	},
	loc_txt = {
			name = 'Spectrum',
			description = {
				'5 cards with 5 different suits.'
			}
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
		{ 'ovn_O_K',    true },
		{ 'S_Q', true },
		{ 'H_J',    true },
		{ 'C_T', true },
		{ 'D_9',    true }
	},
		loc_txt = {
				name = 'Straight Spectrum',
				description = {
					'A Straight and a Spectrum together.'
				}
		},
	process_loc_text = function(self)
		SMODS.PokerHand.process_loc_text(self)
		SMODS.process_loc_text(G.localization.misc.poker_hands, self.key..' (Royal)', self.loc_txt, 'extra')
	end,
	evaluate = function(parts)
		if not next(parts.ovn_spectrum) or not next(parts._straight) then return {} end
		return { SMODS.merge_lists (parts.ovn_spectrum, parts._straight) }
	end,
	modify_display_text = function(self, _cards, scoring_hand)
		local royal = true
		for j = 1, #scoring_hand do
			local rank = SMODS.Ranks[scoring_hand[j].base.value]
			royal = royal and (rank.key == 'Ace' or rank.key == '10' or rank.face)
		end
		if royal then
			return self.key..' (Royal)'
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
		{ 'ovn_O_K',    true },
		{ 'S_K', true },
		{ 'H_K',    true },
		{ 'C_8',    true },
		{ 'D_8',    true }
	},
		loc_txt = {
				name = 'Spectrum House',
				description = {
					'A Full House and a Spectrum together.'
				}
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
		{ 'ovn_O_A',    true },
		{ 'S_A', true },
		{ 'H_A',    true },
		{ 'C_A',    true },
		{ 'D_A',    true }
	},
		loc_txt = {
				name = 'Spectrum Five',
				description = {
					'A Spectrum with all 5 cards of the same rank.'
				}
		},
	evaluate = function(parts)
		if not next(parts._5)or  not next(parts.ovn_spectrum) then return {} end
		return {SMODS.merge_lists (parts._5, parts.ovn_spectrum)}
	end
}

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

SMODS.Enhancement{
	key = "ice",
	loc_txt = {
		name = 'Ice Card',
		text = {
				"{X:mult,C:white}X#2#{} Mult, loses {X:mult,C:white}X#1#{} Mult",
				"each time it's played",
				"Melts at {X:mult,C:white}X1{}"
		}
	},
	atlas = "opticenhance_atlas",
	pos = { x = 0, y = 0 },
	in_pool = false,
	config = {extra = {x_mult_loss = 0.1, current_x_mult = 2}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card and card.ability.extra.x_mult_loss or self.config.extra.x_mult_loss, card and card.ability.extra.current_x_mult or self.config.extra.current_x_mult } }
	end,
	calculate = function(self,card,context)
	local melting = false
		if context.cardarea == G.play and context.main_scoring then
		melting = true
		return {
		x_mult = card.ability.extra.current_x_mult,
		}
		end
		if (context.after and melting) then
		card.ability.extra.current_x_mult = card.ability.extra.current_x_mult - card.ability.extra.x_mult_loss
		end
		if card.ability.extra.current_x_mult <= 1 then
		G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.1,
			func = function()
			play_sound("tarot1")
			card:start_dissolve({G.C.RARITY['ovn_corrupted']})
			return true
			end,
			}))
		end
	end,
}

SMODS.Enhancement{
	key = "dense",
	loc_txt = {
		name = 'Tungsten Card',
		text = {
				"{C:attention}-#1#{} hand size",
				"while held in hand",
				"{C:attention}+#1#{} hand size",
				"this round when played",
				"{C:inactive,s:0.8}(Overdraws when first visible){}"
		}
	},
	atlas = "opticenhance_atlas",
	pos = { x = 1, y = 0 },
	in_pool = false,
	config = {extra = {tungsten_handsize_mod = 1, holdingthis = 0}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card and card.ability.extra.tungsten_handsize_mod or self.config.extra.tungsten_handsize_mod,
		card and card.ability.extra.holdingthis or self.config.extra.holdingthis } }
	end,
	update = function(self, card, dt)
		if card.area and (card.area == G.hand and not card.debuff) and (card.ability.extra.holdingthis == 0) then
		G.hand:change_size(-self.config.extra.tungsten_handsize_mod)
		card.ability.extra.holdingthis = 1
		end
		if card.area and card.area ~= G.hand and card.ability.extra.holdingthis == 1 then
		G.hand:change_size(self.config.extra.tungsten_handsize_mod)
		card.ability.extra.holdingthis = 0
		end
	end,
	calculate = function(self,card,context)
		if context.cardarea == G.play and context.before then
		G.hand:change_size(card.ability.extra.tungsten_handsize_mod)
		G.GAME.round_resets.temp_handsize = (G.GAME.round_resets.temp_handsize or 0) + math.floor(card.ability.extra.tungsten_handsize_mod)
		end
	end,
}

function change_rank(card, new_rank)
	local new_code = (card.base.suit == 'Diamonds' and 'D_') or
	(card.base.suit == 'Spades' and 'S_') or
	(card.base.suit == 'Clubs' and 'C_') or
	(card.base.suit == 'Hearts' and 'H_') or
	(card.base.suit == 'ovn_Optics' and 'ovn_O_')
	local new_val = (new_rank == 'Ace' and 'A') or
	(new_rank == 'King' and 'K') or
	(new_rank == 'Queen' and 'Q') or
	(new_rank == 'Jack' and 'J') or
	(new_rank == '10' and 'T') or
	(new_rank)
	local new_card = G.P_CARDS[new_code..new_val]

	card:set_base(new_card)
	G.GAME.blind:debuff_card(card)
end

SMODS.Enhancement{
	key = "coord",
	loc_txt = {
		name = 'Coordinate Card',
		text = {
			"Copies the rank of the",
			"card to its {C:attention}left{}",
		}
	},
	atlas = "opticenhance_atlas",
	pos = { x = 2, y = 1 },
	in_pool = false,
	config = { },
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	calculate = function(self, card, context)
		if context.modify_scoring_hand or context.check then
			local cardTable = G.hand.cards

			local cardIndex = -1

			for i = 1, #cardTable do
				if cardTable[i] == card then
					cardIndex = i
				end
			end

			if cardIndex > 1 then
				local otherCardValue = cardTable[cardIndex - 1].base.value
				if card.base.value == otherCardValue then return end
				card:flip()
				change_rank(card, otherCardValue)
				card:flip()
			end
		end
	end,
}

SMODS.Enhancement{
	key = "unob",
	loc_txt = {
		name = 'Unobtanium Card',
		text = {
				"{C:attention}Retrigger{} all scoring cards",
				"{C:attention}#1#{} time while held in hand",
				"{C:mult}Cannot be played{}",
		}
	},
	atlas = "opticenhance_atlas",
	pos = { x = 2, y = 0 },
	in_pool = false,
	config = {extra = {repetitions = 1}},
	loc_vars = function(self, info_queue, card)
		return { vars = { card and card.ability.extra.repetitions or self.config.extra.repetitions }}
	end,
	calculate = function(self, card, context)
	end,
}

local gu = Game.update
function Game:update(dt)
	gu(self, dt)
	if G.STATE == SELECTING_HAND then
	local unobtally = {}
	for i=1, #G.hand.cards do
		if G.hand.cards[i].config.center.key == 'm_ovn_unob' then
		unobtally[#unobtally + 1] = G.hand.cards[i]
		end
	end
	if #unobtally >= G.hand.config.card_limit and G.GAME.current_round.discards_left <= 0 then
		G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false
		return true
	end
	end
end

SMODS.Consumable {
	set = "Tarot",
	name = "ovn_Perception",
	key = "perception",
	loc_txt = {
		name = 'Perception',
		text = {
			"{C:ovn_corrupted}Corrupts{} up to",
			"{C:attention}#1#{} selected cards",
			"to {C:ovn_optic}Optics{}"
		}
	},
	cost = 2,
	atlas = "abyss_atlas",
	config = {max_highlighted = 2, suit_conv = 'ovn_Optics'},
	loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,
	pos = {x=1, y=0},
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Parallel Tarot', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	use = function(self)
		for i=1, #G.hand.highlighted do
			local percent = 1.15 - (i-0.999)/(#G.hand.highlighted-0.998)*0.3
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
				G.GAME.corruptingCard = true;G.hand.highlighted[i]:flip();play_sound('card1', percent);G.hand.highlighted[i]:juice_up(0.3, 0.3);G.GAME.corruptingCard = false;
			return true end }))
			G.GAME.corruptingCard = false
		end
		delay(0.2)
		for i=1, #G.hand.highlighted do
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
				G.hand.highlighted[i]:change_suit(self.config.suit_conv);
			return true end }))
		end
		for i=1, #G.hand.highlighted do
			local percent = 0.85 + ( i - 0.999 ) / ( #G.hand.highlighted - 0.998 ) * 0.3
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.15, func = function()
				G.hand.highlighted[i]:flip(); play_sound('ovn_optic', percent, 1.1); G.hand.highlighted[i]:juice_up(0.3, 0.3);
			return true end }))
		end
		if G.GAME.in_corrupt_plasma then
			G.E_MANAGER:add_event(Event({
			trigger = "after",
			delay = 0.2,
			func = function()
				play_sound("ovn_increment", 1, 0.9)
				G.GAME.instability = (G.GAME.instability + (G.GAME.opticmod * #G.hand.highlighted))
				return true
			end,
			}))
		end
		G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
			G.hand:unhighlight_all();
		return true end }))
		delay(0.5)
	end,
}
