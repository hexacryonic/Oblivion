------------
-- The Nerve
------------
SMODS.Blind({
	key = 'nerve',
	loc_vars = function(self, info_queue, card)
		return {}
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = {},
	boss = {min = 1, max = 10},
	boss_colour = HEX('a876d6'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 0},

	dollars = 5,
	mult = 2,
	debuff = {
		suit = 'ovn_Optics'
	},

	in_pool = function(self)
		if not G.playing_cards then return false end
		local total_optics = 0
		for _,playing_card in pairs(G.playing_cards) do
			if playing_card:is_suit("ovn_Optics", nil, true) then
				total_optics = total_optics + 1
			end
		end
		return total_optics >= 9
	end,
})

local function purify_all_jokers()
	for _,joker in pairs(G.jokers.cards) do
		local joker_key = joker.config.center.key
		if Ovn_f.joker_is_purifiable(joker_key) then
			Ovn_f.purify_joker(joker)
		end
	end
end

local function corrupt_all_jokers()
	for _,joker in pairs(G.jokers.cards) do
		local joker_key = joker.config.center.key
		if Ovn_f.joker_is_corruptible(joker_key) then
			Ovn_f.corrupt_joker(joker)
		end
	end
end

-------------
-- The Purity
-------------
SMODS.Blind({
	key = 'purity',
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = { },
	boss = {min = 4, max = 10},
	boss_colour = HEX('d9e58a'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 1},

	dollars = 5,
	mult = 2,

	in_pool = function()
		for _,corrupt_key in pairs(Oblivion.corruption_map) do
			if Ovn_f.has_joker(corrupt_key) then return true end
			return false
		end
	end,

	defeat = function(self, silent) purify_all_jokers() end,
	disable = function(self, silent) purify_all_jokers() end,
})

----------------
-- Stygian Sigil
----------------
SMODS.Blind({
	key = 'stygian',
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
	config = { },
	boss = {min = 8, max = 10, showdown = true},
	boss_colour = HEX('1538af'),

	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 2},

	dollars = 8,
	mult = 2,

	set_blind = function(self, reset, silent)
		for _,playing_card in pairs(G.playing_cards) do
			if playing_card.config.center ~= G.P_CENTERS.c_base then
				playing_card:change_suit('ovn_Optics')
			end
		end
		corrupt_all_jokers()
	end,

	in_pool = function()
		for pure_key in pairs(Oblivion.corruption_map) do
			if next(SMODS.find_card(pure_key)) then return true end
			return false
		end
	end,
})