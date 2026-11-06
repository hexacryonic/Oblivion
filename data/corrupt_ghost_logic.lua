-- Defines the logic for Corrupt Ghost Deck using specific consumables
-- especially for consumables that require specific cards to be selected

-- Please read documentation for how to add to this table

Oblivion.spectral_logic = Oblivion.spectral_logic or {}
local speclogic = Oblivion.spectral_logic

local hold_enhancements = {
	["m_steel"] = true,
	["m_gold"] = true,
	["m_ovn_unob"] = true
}

local rank_attrs = {
	Ace = "ace",
	[2] = "two",
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven",
	[8] = "eight",
	[9] = "nine",
	[10] = "ten",
	Jack = "jack",
	Queen = "queen",
	King = "king"
}

local suit_attrs = {
	Hearts = "hearts",
	Spades = "spades",
	Diamonds = "diamonds",
	Clubs = "clubs",
	ovn_Optics = "ovn_optics"
}

local vanilla_joker_target_card = {
	["j_idol"] = function (card)
		local idol_target = G.GAME.current_round.idol_card
		if (
			(not SMODS.has_no_rank(card) and idol_target.rank == card.base.value)
			or (not SMODS.has_no_suit(card) and idol_target.suit == card.base.suit)
		) then
			return true
		end
	end,
	["j_mail"] = function (card)
		local mail_target = G.GAME.current_round.mail_card
		if not SMODS.has_no_rank(card) and mail_target.rank == card.base.value then
			return true
		end
	end,
	["j_ancient"] = function (card)
		local ancient_target = G.GAME.current_round.ancient_card
		if not SMODS.has_no_suit(card) and ancient_target.suit == card.base.suit then
			return true
		end
	end,
	["j_castle"] = function (card)
		local castle_target = G.GAME.castle_card.suit
		if not SMODS.has_no_suit(card) and castle_target.suit == card.base.suit then
			return true
		end
	end,
}

local function jokers_target_card(card)
	local rank_attr, suit_attr, face_attr
	if not SMODS.has_no_rank(card) then
		rank_attr = rank_attrs[card.base.value]
	end
	if not SMODS.has_no_suit(card) then
		suit_attr = suit_attrs[card.base.suit]
	end
	if card:is_face() then
		face_attr = "face"
	end

	local checked_jokers = {}
	for _,joker in ipairs(G.jokers.cards) do
		if not checked_jokers[joker.config.center.key] then
			-- Check Joker's "joker_target_card"
			if type(joker.config.center.joker_target_card) == "function" then
				local ret = joker.config.center.joker_target_card(card)
				if ret then return true end
			-- Check vanilla_joker_target_card
			elseif type(vanilla_joker_target_card[joker.config.center.key]) == "function" then
				local ret = vanilla_joker_target_card[joker.config.center.key](card)
				if ret then return true end
			end

			-- Finally check rank, suit, and face attributes
			if (
				(rank_attr and joker:has_attribute(rank_attr))
				or (suit_attr and joker:has_attribute(suit_attr))
				or (face_attr and joker:has_attribute(face_attr))
			) then
				return true
			end

			checked_jokers[joker.config.center.key] = true
		end
	end
	return false
end

----

speclogic['c_talisman'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if not jokers_target_card(card) then _p(2) end

		local card_enhancement = card.config.center.key
		if hold_enhancements[card_enhancement] then _p(2) end

		local card_seal = card:get_seal()
		if card_seal == "Red" then _p(2)
		elseif card_seal == "Blue" or card_seal == "Purple" then _p(1)
		end

		if card.edition then _p(-2) end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_aura'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		-- Aura cannot target cards with editions
		if card.edition then return end

		local points = 0
		local function _p(n) points = points + n end

		if not jokers_target_card(card) then _p(2) end

		local card_enhancement = card.config.center.key
		if hold_enhancements[card_enhancement] then _p(1) end

		local card_seal = card:get_seal()
		if card_seal == "Red" or card_seal == "Gold" then _p(-2) end

		return points
	end,
	usable = function()
		for _,card in ipairs(G.hand.cards) do
			if not card.edition then return true end
		end
		return false
	end
}

speclogic['c_deja_vu'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if not jokers_target_card(card) then _p(2) end

		local card_edition = card.edition and card.edition.key
		if card_edition == "e_polychrome" then _p(-2)
		elseif card_edition then _p(-1)
		end

		local card_enhancement = card.config.center.key
		if card_enhancement ~= "c_base" then _p(-1) end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_trance'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if (
			jokers_target_card(card)
			-- and not card:has_attribute("held_in_hand")
		) then _p(2) end

		local card_seal = card:get_seal()
		if card_seal == "Red" or card_seal == "Purple" then _p(2) end

		if card.edition then _p(2) end

		local card_enhancement = card.config.center.key
		if hold_enhancements[card_enhancement] then _p(-2) end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_medium'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if (
			jokers_target_card(card)
			and not card:has_attribute("discard")
		) then _p(2) end

		local card_seal = card:get_seal()
		if card_seal == "Red" or card_seal == "Gold" then _p(2)
		elseif card_seal == "Blue" then _p(1) end

		if card.edition then _p(2) end

		local card_enhancement = card.config.center.key
		if hold_enhancements[card_enhancement] then _p(2) end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_cryptid'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if not jokers_target_card(card) then _p(2) end

		local card_edition = card.edition and card.edition.key
		if card_edition == "e_polychrome" then _p(-2)
		elseif card_edition then _p(-1) end

		local card_enhancement = card.config.center.key
		if card_enhancement ~= "c_base" then _p(-1) end

		if card:get_seal() then _p(-1) end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_ovn_oblivion'] = {
	select = 2,
	select_area = function()
		return {G.hand, G.jokers}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if card.area == G.jokers then
			local joker_key = card.config.center.key
			if not Ovn_f.joker_is_corruptible(joker_key) then
				_p(2)
			elseif card.config.center.rarity == "ovn_corrupted" then
				_p(1)
			end

			if card:has_attribute("passive") then
				_p(1)
			end
		elseif card.area == G.hand then
			if card.base.suit == "ovn_Optics" then
				_p(1)
			end
		end

		return points
	end,
	usable = function()
		return true
	end
}

speclogic['c_ovn_eidolon'] = {
	select = 1,
	select_area = function()
		return {G.hand}
	end,
	card_point_calc = function(card)
		local points = 0
		local function _p(n) points = points + n end

		if card:get_seal() then _p(1) end

		return points
	end,
	usable = function()
		return true
	end
}

----

local default_state = {
	select = 0,
	select_area = function() return {} end,
	usable = function()
		return true
	end
}

local check_edition = {
	select = 0,
	select_area = function() return {} end,
	usable = function()
		for _,card in ipairs(G.jokers.cards) do
			if not card.edition then return true end
		end
		return false
	end
}

local check_j_slots = {
	select = 0,
	select_area = function() return {} end,
	usable = function()
		return #G.jokers.cards < G.jokers.config.card_limit
	end
}

speclogic['c_familiar'] = default_state
speclogic['c_grim'] = default_state
speclogic['c_incantation'] = default_state
speclogic['c_sigil'] = default_state
speclogic['c_ouija'] = default_state
speclogic['c_immolate'] = default_state

speclogic['c_ectoplasm'] = check_edition
speclogic['c_hex'] = check_edition

speclogic['c_wraith'] = check_j_slots
speclogic['c_ovn_charybdis'] = check_j_slots

speclogic['c_ankh'] = {
	select = 0,
	select_area = function() return {} end,
	usable = function()
		return (0 < #G.jokers.cards) and (#G.jokers.cards < G.jokers.config.card_limit)
	end
}