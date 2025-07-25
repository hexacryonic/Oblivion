local cryptid_crossplanet_atlas = {
	object_type = "Atlas",
	key = "cryptidplanets",
	path = "cryptid_crossplanets.png",
	px = 71,
	py = 95,
}

local ref = Game.start_run
function Game:start_run(args)
	ref(self, args)
	if not args.savetext then
		G.GAME.hands.ovn_5DDeck.mult = to_big(6565656565656565656565656565656565656565656)^65656565656565656565656565
		G.GAME.hands.ovn_5DDeck.l_mult = to_big(656565656565656565656565656565656565656565)^65656565656565656565656565
		G.GAME.hands.ovn_5DDeck.chips = to_big(65656565656565656565656565656565656565656565)^65656565656565656565656565
		G.GAME.hands.ovn_5DDeck.l_chips = to_big(6565656565656565656565656565656565656565656)^65656565656565656565656565
	end
end

local tefdats = {
	object_type = "PokerHand",
	key = "5DDeck",
	visible = false,
	chips = to_big(65656565656565656565656565656565656565656565)^65656565656565656565656565,
	mult = to_big(6565656565656565656565656565656565656565656)^65656565656565656565656565,
	l_chips = to_big(6565656565656565656565656565656565656565656)^65656565656565656565656565,
	l_mult = to_big(656565656565656565656565656565656565656565)^65656565656565656565656565,
	example = {
	{ "ovn_O_A", true },
		{ "S_A", true },
		{ "H_A", true },
		{ "C_A", true },
		{ "D_A", true },
	{ "ovn_O_K", true },
		{ "S_K", true },
		{ "H_K", true },
		{ "C_K", true },
		{ "D_K", true },
	{ "ovn_O_Q", true },
		{ "S_Q", true },
		{ "H_Q", true },
		{ "C_Q", true },
		{ "D_Q", true },
	{ "ovn_O_J", true },
		{ "S_J", true },
		{ "H_J", true },
		{ "C_J", true },
		{ "D_J", true },
	{ "ovn_O_T", true },
		{ "S_T", true },
		{ "H_T", true },
		{ "C_T", true },
		{ "D_T", true },
	{ "ovn_O_9", true },
		{ "S_9", true },
		{ "H_9", true },
		{ "C_9", true },
		{ "D_9", true },
	{ "ovn_O_8", true },
		{ "S_8", true },
		{ "H_8", true },
		{ "C_8", true },
		{ "D_8", true },
	{ "ovn_O_7", true },
		{ "S_7", true },
		{ "H_7", true },
		{ "C_7", true },
		{ "D_7", true },
	{ "ovn_O_6", true },
		{ "S_6", true },
		{ "H_6", true },
		{ "C_6", true },
		{ "D_6", true },
	{ "ovn_O_5", true },
		{ "S_5", true },
		{ "H_5", true },
		{ "C_5", true },
		{ "D_5", true },
	{ "ovn_O_4", true },
		{ "S_4", true },
		{ "H_4", true },
		{ "C_4", true },
		{ "D_4", true },
	{ "ovn_O_3", true },
		{ "S_3", true },
		{ "H_3", true },
		{ "C_3", true },
		{ "D_3", true },
	{ "ovn_O_2", true },
		{ "S_2", true },
		{ "H_2", true },
		{ "C_2", true },
		{ "D_2", true },
	},
	loc_txt = {
			name = 'The Entire Fucking Deck And Then Some',
			description = {
			"A hand that contains every single",
			"card found in a 52-card deck, plus",
			"an entire full set of Optics",
			" ",
			"What the actual fuck is wrong with you?",
			}
	},
	evaluate = function(parts, hand)
		if Cryptid.enabled("set_cry_poker_hand_stuff") ~= true or Cryptid.enabled("c_cry_universe") ~= true then
			return
		end
		if #hand >= 65 then
			local deck_booleans = {}
			local scored_cards = {}
			for i = 1, 65 do
				table.insert(deck_booleans, false) -- i could write this out but nobody wants to see that
			end
			local wilds = {}
			for i, card in ipairs(hand) do
				if
					(card.config.center_key ~= "m_wild" and not card.config.center.any_suit)
					and (card.config.center_key ~= "m_stone" and not card.config.center.no_rank)
				then -- i don't know if these are different... this could be completely redundant but redundant is better than broken
					local rank = card:get_id()
					local suit = card.base.suit
					local suit_int = 0
					suit_table = { "ovn_Optics", "Spades", "Hearts", "Clubs", "Diamonds" }
					for i = 1, 5 do
						if suit == suit_table[i] then
							suit_int = i
						end
					end
					if suit_int > 0 then -- check for custom rank here to prevent breakage?
						deck_booleans[suit_int + ((rank - 2) * 5)] = true
						table.insert(scored_cards, card)
					end
				elseif card.config.center_key == "m_wild" or card.config.center.any_suit then
					table.insert(wilds, card)
				end
			end
			for i, card in ipairs(wilds) do -- this 100% breaks with custom ranks
				local rank = card:get_id()
				for i = 1, 5 do
					if not deck_booleans[i + ((rank - 2) * 5)] then
						deck_booleans[i + ((rank - 2) * 5)] = true
						break
					end
				end
				table.insert(scored_cards, card)
			end
			local entire_fucking_deck = true
			for i = 1, #deck_booleans do
				if deck_booleans[i] == false then
					entire_fucking_deck = false
					break
				end
			end
			if entire_fucking_deck == true then
				return { scored_cards }
			end
		end
		return
	end,
}

local reality = {
	dependencies = {
		items = {
			"set_cry_poker_hand_stuff",
		},
	},
	object_type = "Consumable",
	set = "Planet",
	key = "reality",
	config = { hand_type = "ovn_5DDeck", softlock = true },
	pos = { x = 0, y = 0 },
	atlas = "cryptidplanets",
	aurinko = true,
	set_card_type_badge = function(self, card, badges)
	badges[1] = create_badge('WHAT THE FUCK', get_type_colour(self or card.config, card), G.C.WHITE, 1.5)
	end,
	loc_vars = function(self, info_queue, center)
		return {
			vars = {
				localize("ovn_5DDeck"),
				G.GAME.hands["ovn_5DDeck"].level,
				G.GAME.hands["ovn_5DDeck"].l_mult,
				G.GAME.hands["ovn_5DDeck"].l_chips,
				colours = {
					(
						to_big(G.GAME.hands["ovn_5DDeck"].level) == to_big(1) and G.C.UI.TEXT_DARK
						or G.C.HAND_LEVELS[to_big(math.min(7, G.GAME.hands["ovn_5DDeck"].level)):to_number()]
					),
				},
			},
		}
	end,
	generate_ui = 0,
}

local optinen = {
	dependencies = {
		items = {
			"set_cry_planet",
			"set_cry_poker_hand_stuff",
		},
	},
	object_type = "Consumable",
	set = "Planet",
	name = "ovn_Optinen",
	key = "optinen",
	pos = { x = 1, y = 0 },
	config = { hand_types = { "ovn_Spectrum", "ovn_Straight Spectrum", "ovn_Spectrum House", "ovn_Spectrum Five" }, softlock = true },
	cost = 4,
	aurinko = true,
	atlas = "cryptidplanets",
	can_use = function(self, card)
		return true
	end,
	loc_vars = function(self, info_queue, center)
		local levelone = G.GAME.hands["ovn_Spectrum"].level or 1
		local leveltwo = G.GAME.hands["ovn_Straight Spectrum"].level or 1
		local levelthree = G.GAME.hands["ovn_Spectrum House"].level or 1
	local levelfour = G.GAME.hands["ovn_Spectrum Five"].level or 1
		local planetcolourone = G.C.HAND_LEVELS[math.min(levelone, 7)]
		local planetcolourtwo = G.C.HAND_LEVELS[math.min(leveltwo, 7)]
		local planetcolourthree = G.C.HAND_LEVELS[math.min(levelthree, 7)]
	local planetcolourfour = G.C.HAND_LEVELS[math.min(levelfour, 7)]

		return {
			vars = {
				localize("ovn_Spectrum", "poker_hands"),
				localize("ovn_Straight Spectrum", "poker_hands"),
				localize("ovn_Spectrum House", "poker_hands"),
		localize("ovn_Spectrum Five", "poker_hands"),
				G.GAME.hands["ovn_Spectrum"].level,
				G.GAME.hands["ovn_Straight Spectrum"].level,
				G.GAME.hands["ovn_Spectrum House"].level,
		G.GAME.hands["ovn_Spectrum Five"].level,
				colours = {
					(
						to_big(G.GAME.hands["ovn_Spectrum"].level) == to_big(1) and G.C.UI.TEXT_DARK
						or G.C.HAND_LEVELS[to_big(math.min(7, G.GAME.hands["ovn_Spectrum"].level)):to_number()]
					),
					(
						to_big(G.GAME.hands["ovn_Straight Spectrum"].level) == to_big(1) and G.C.UI.TEXT_DARK
						or G.C.HAND_LEVELS[to_big(math.min(7, G.GAME.hands["ovn_Straight Spectrum"].level)):to_number()]
					),
					(
						to_big(G.GAME.hands["ovn_Spectrum House"].level) == to_big(1) and G.C.UI.TEXT_DARK
						or G.C.HAND_LEVELS[to_big(math.min(7, G.GAME.hands["ovn_Spectrum House"].level)):to_number()]
					),
			(
						to_big(G.GAME.hands["ovn_Spectrum Five"].level) == to_big(1) and G.C.UI.TEXT_DARK
						or G.C.HAND_LEVELS[to_big(math.min(7, G.GAME.hands["ovn_Spectrum Five"].level)):to_number()]
					),
				},
			},
		}
	end,
	use = function(self, card, area, copier)
		Cryptid.suit_level_up(card, copier, 1, card.config.center.config.hand_types)
	end,
	bulk_use = function(self, card, area, copier, number)
		Cryptid.suit_level_up(card, copier, number, card.config.center.config.hand_types)
	end,
	calculate = function(self, card, context)
		if
			G.GAME.used_vouchers.v_observatory
			and context.joker_main
			and (
				context.scoring_name == "ovn_Spectrum"
				or context.scoring_name == "ovn_Straight Spectrum"
				or context.scoring_name == "ovn_Spectrum House"
		or context.scoring_name == "ovn_Spectrum Five"
			)
		then
			local value = G.P_CENTERS.v_observatory.config.extra
			return {
				message = localize({ type = "variable", key = "a_xmult", vars = { value } }),
				Xmult_mod = value,
			}
		end
	end,
}

return {
	init = function(self)
	end,
	items = {
		cryptid_crossplanet_atlas,
		tefdats,
		reality,
		optinen,
	}
}
