local add_simple_event = Ovn_f.add_simple_event

SMODS.Shader({ key = 'miasma', path = 'miasma.fs' })

----

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

----

SMODS.Tag({
	key = "corrtag",

	atlas = "ctags_atlas",
	pos = { x = 0, y = 0 },

	min_ante = 2,
	requires = "j_ovn_darkjoker",

	apply = function(self, tag, context)
		if context.type == "store_joker_create" then
			local corrupts_in_posession = { 0 }

			for _,joker in ipairs(G.jokers.cards) do
				local joker_rarity = joker.config.center.rarity
				local joker_key = joker.config.center.key

				if joker_rarity == "ovn_corrupted" and not corrupts_in_posession[joker_key] then
					corrupts_in_posession[1] = corrupts_in_posession[1] + 1
					corrupts_in_posession[joker_key] = true
				end
			end

			local new_card
			if #G.P_JOKER_RARITY_POOLS.ovn_corrupted > corrupts_in_posession[1] then
				new_card = create_card("Joker", context.area, nil, "ovn_corrupted", nil, nil, nil, "ovn_cta")
				create_shop_card_ui(new_card, "Joker", context.area)
				new_card.states.visible = false

				tag:yep("+", G.C.RARITY.ovn_corrupted, function()
					new_card:start_materialize()
					new_card.ability.couponed = true
					new_card:set_cost()
					return true
				end)
			else
				tag:nope()
			end

			tag.triggered = true
			return new_card
		end
	end,
})

SMODS.Tag({
	key = "miasmatag",

	atlas = "ctags_atlas",
	pos = { x = 1, y = 0 },

	min_ante = 2,

	apply = function(self, tag, context)
		if context.type == 'store_joker_modify' then
			if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
				local lock = tag.ID
				G.CONTROLLER.locks[lock] = true
				context.card.temp_edition = true
				tag:yep('+', G.C.DARK_EDITION, function()
					context.card.temp_edition = nil
					context.card:set_edition({ ovn_miasma = true }, true)
					context.card.ability.couponed = true
					context.card:set_cost()
					G.CONTROLLER.locks[lock] = nil
					return true
				end)
				tag.triggered = true
				return true
			end
		end
	end,
})

SMODS.Tag({
	key = "stygiantag",

	atlas = "ctags_atlas",
	pos = { x = 3, y = 0 },

	min_ante = 2,

	apply = function(self, tag, context)
		if context.type == 'new_blind_choice' then
			local lock = tag.ID
			G.CONTROLLER.locks[lock] = true
			tag:yep('+', G.C.PURPLE, function()
				local booster = SMODS.create_card { key = 'p_ovn_wicked_normal_' .. math.random(1, 3), area = G.play }
				booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
				booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
				booster.T.w = G.CARD_W * 1.27
				booster.T.h = G.CARD_H * 1.27
				booster.cost = 0
				booster.from_tag = true
				G.FUNCS.use_card({ config = { ref_table = booster } })
				booster:start_materialize()
				G.CONTROLLER.locks[lock] = nil
				return true
			end)
			tag.triggered = true
			return true
		end
	end
})

----

SMODS.Edition {
	key = "miasma",
	config = { retriggers = 3 },
	loc_vars = function(self, info_queue, center)
		local retriggers = (
			center
			and center.edition
			and center.edition.retriggers
			or self.config.retriggers
		)
		return { vars = { retriggers } }
	end,

	shader = 'miasma',
	disable_shadow = true,
	disable_base_shader = true,
	apply_to_float = true,

	discovered = true,
	unlocked = true,
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
			-- Repeat playing cards
			(context.repetition and context.cardarea == G.play)
			-- or retrigger Jokers
			or (context.retrigger_joker_check and not context.retrigger_joker)
		) then return { repetitions = self.config.retriggers } end

		-- Either corrupt or kill Joker
		if context.after and context.cardarea == G.jokers then
			-- Card is corruptable, proceed to corrupt
			if Ovn_f.joker_is_corruptible(card.config.center.key) then
				Ovn_f.corrupt_joker(card)
				Ovn_f.corruption_instability(1)

			-- Card cannot be corrupted, self-destruct
			else
				add_simple_event('after', 0.0, function ()
					play_sound("ovn_optic", nil, 0.2)
					card:start_dissolve({G.C.RARITY['ovn_corrupted']})
				end)
			end
		end

		-- Either corrupt or kill playing card
		if context.after and context.cardarea == G.play then
			-- Editioned playing card is already optics, self-destruct
			if card.base.suit == 'ovn_Optics' then
				add_simple_event('after', 0.1, function ()
					card:start_dissolve({G.C.RARITY['ovn_corrupted']})
				end)

			-- Editioned playing card not optics, proceed to corrupt
			else
				add_simple_event('after', 0.1, function ()
					card:set_edition(nil)
					card:change_suit('ovn_Optics')
				end)
				Ovn_f.optic_instability(#G.hand.highlighted)
			end
		end
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_Oblivion",
	key = "oblivion",
	loc_vars = function(self, info_queue)
		table.insert(info_queue, G.P_CENTERS.e_ovn_miasma)
		return {vars = {self.config.max_highlighted}}
	end,
	config = {max_highlighted = 2},

	atlas = "cataclysm_atlas",
	pos = {x=2, y=0},

	cost = 2,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		local selected_playing_card = G.hand.highlighted

		local exclude_self = G.consumeables.highlighted[1] == self and 1 or 0
		if (#selected_jokers + #selected_playing_card - exclude_self ~= card.ability.max_highlighted) then return false end

		local has_edition = false
		for _,joker in ipairs(selected_jokers) do
			if joker.edition then has_edition = true end
		end
		for _,playing_card in ipairs(selected_playing_card) do
			if playing_card.edition then has_edition = true end
		end

		return not has_edition
	end,

	use = function(self, card, area, copier)
		local selected_cards = {}
		for _,joker in ipairs(G.jokers.highlighted) do table.insert(selected_cards, joker) end
		for _,playing_card in ipairs(G.hand.highlighted) do table.insert(selected_cards, playing_card) end
		add_simple_event(nil, nil, function ()
			for _,target_card in ipairs(selected_cards) do
				play_sound('tarot1')
				target_card:set_edition({ ovn_miasma = true })
				target_card:juice_up(0.3, 0.5)
				target_card.area:remove_from_highlighted(target_card)
			end
		end)
	end,
}

----

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_Eidolon",
	key = "eidolon",
	config = { extra = { seal = 'ovn_indigo' }, max_highlighted = 1 },

	atlas = "cataclysm_atlas",
	pos = {x=2, y=0},

	cost = 4,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	use = function(self, card, area, copier)
		-- Modified version of VanillaRemade Deja Vu implementation
		local converted_card = G.hand.highlighted[1]

		add_simple_event(nil, nil, function ()
			play_sound('tarot1')
			card:juice_up(0.3, 0.5)
		end)

		add_simple_event('after', 0.1, function ()
			converted_card:set_seal(card.ability.extra.seal, nil, true)
		end)
		delay(0.5)
		add_simple_event('after', 0.2, function ()
			G.hand:unhighlight_all()
		end)
	end,
}

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