------------------
-- POKER HAND PART
-- Spectrum
------------------
SMODS.PokerHandPart{ -- Spectrum base (yoink)
	key = 'spectrum',
	func = function(hand)
		local suits = {}
        local has_wild = 0
		if #hand < 5 then return {} end

		for _, hand_card in ipairs(hand) do
			if hand_card.config.center_key == 'm_wild' then
                has_wild = has_wild + 1
			end
			suits[hand_card.base.suit] = true
		end

		local num_suits = 0
		for _ in pairs(suits) do
			num_suits = num_suits + 1
		end

		if (
            num_suits = 5 - has_wild
            and has_wild >= 1
			and G.GAME.hands["ovn_Spectrum"].played > 0
		) then
			return {hand}
		elseif num_suits >= 5 then
			return {hand}
		else
			return {}
		end
	end
}

----------------

-------------
-- POKER HAND
-- Spectrum
-------------
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

--------------------
-- POKER HAND
-- Straight Spectrum
--------------------
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
			is_royal = is_royal and (rank.key == 'Ace' or rank.key == '10' or rank.face) or false
		end
		if is_royal then
			return 'ovn_Royal Spectrum'
		end
	end
}

-----------------
-- POKER HAND
-- Spectrum House
-----------------
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

--------------------
-- POKER HAND
-- Spectrum Five
--------------------
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
