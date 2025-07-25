SMODS.Shader({ key = 'miasma', path = 'miasma.fs' })

SMODS.Sound({
	key = "increment",
	path = "powerincrement.ogg",
})

SMODS.Blind({
	loc_txt = {
		name = 'The Nerve',
		text = { 'All Optic cards', 'are debuffed' }
	},
	key = 'nerve',
	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 0},
	dollars = 5,
	mult = 2,
	boss = {min = 1, max = 10},
	boss_colour = HEX('a876d6'),
	config = { },
		debuff = {
		suit = 'ovn_Optics'
		},
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
		in_pool = function(self)
			local total_optics = 0
			if G.playing_cards then
				for k, v in pairs(G.playing_cards) do
					if v:is_suit("ovn_Optics", nil, true) then
						total_optics = total_optics + 1
					end
				end
			end
			if total_optics >= 9 then
				return true
			else
				return false
			end
		end,
})

SMODS.Blind({
	loc_txt = {
		name = 'The Purity',
		text = { 'When defeated or disabled:', 'Purify all Corrupted Jokers', 'if any hands remain' }
	},
	key = 'purity',
	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 1},
	dollars = 5,
	mult = 2,
	boss = {min = 4, max = 10},
	boss_colour = HEX('d9e58a'),
	config = { },
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
		in_pool = function()
		for _, v in pairs(Oblivion.corruptionMap) do
			if SMODS.find_card(v) then
			return true
			else
			return false
			end
		end
		end,
		defeat = function(self, silent)
			if G.GAME.current_round.hands_left >= 1 then
				for k, v in pairs(G.jokers.cards) do
					for kk, vv in pairs(Oblivion.corruptionMap) do
						if v.config.center.key == vv then
								G.E_MANAGER:add_event(Event({
									trigger = "after",
									delay = 0.4,
									func = function()
										play_sound("ovn_pure")
										v:start_dissolve({G.C.MONEY})
										local card = create_card("Joker", G.jokers, nil, nil, nil, nil, kk)
										card:add_to_deck()
										G.jokers:emplace(card)
										card:juice_up(0.3, 0.5)
										return true
									end,
								}))
						end
					end
				end
			end
		end,
		disable = function(self, silent)
			if G.GAME.current_round.hands_left >= 1 then
				for k, v in pairs(G.jokers.cards) do
					for kk, vv in pairs(Oblivion.corruptionMap) do
						if v.config.center.key == vv then
								G.E_MANAGER:add_event(Event({
									trigger = "after",
									delay = 0.4,
									func = function()
										play_sound("ovn_pure")
										v:start_dissolve({G.C.MONEY})
										local card = create_card("Joker", G.jokers, nil, nil, nil, nil, kk)
										card:add_to_deck()
										G.jokers:emplace(card)
										card:juice_up(0.3, 0.5)
										return true
									end,
								}))
						end
					end
				end
			end
		end,
})

SMODS.Blind({
	loc_txt = {
		name = 'Stygian Sigil',
		text = { 'When entering Blind:', 'Corrupt all possible Jokers and', 'convert enhanced cards to Optics' }
	},
	key = 'stygian',
	atlas = 'ovn_blinds_atlas',
	pos = {x = 0, y = 2},
	dollars = 8,
	mult = 2,
	boss = {min = 8, max = 10, showdown = true},
	boss_colour = HEX('1538af'),
	config = { },
		set_blind = function(self, reset, silent)
			for k, v in pairs(G.playing_cards) do
				if v.config.center ~= G.P_CENTERS.c_base then v:change_suit('ovn_Optics') end
			end
			for k, v in pairs(G.jokers.cards) do
				for kk, vv in pairs(Oblivion.corruptionMap) do
				if v.config.center.key == kk then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.4,
					func = function()
					play_sound("ovn_abyss")
					v:start_dissolve({G.C.RARITY['ovn_corrupted']})
					local card = create_card("Joker", G.jokers, nil, nil, nil, nil, vv)
					card:add_to_deck()
					G.jokers:emplace(card)
					card:juice_up(0.3, 0.5)
					return true
					end,
				}))
					end
				end
			end
		end,
	loc_vars = function(self, info_queue, card)
		return { }
	end,
	collection_loc_vars = function(self)
		return { }
	end,
		in_pool = function()
		for k, _ in pairs(Oblivion.corruptionMap) do
			if SMODS.find_card(k) then
			return true
			else
			return false
			end
		end
		end,
})

SMODS.Tag({
	key = "corrtag",
	loc_txt = {
		name = 'Corrupted Tag',
		text = {
		"Shop has a free",
		"{C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
		}
	},
	atlas = "ctags_atlas",
	pos = { x = 0, y = 0 },
	min_ante = 2,
	requires = "j_ovn_darkjoker",
	config = { type = "store_joker_create" },
	apply = function(self, tag, context)
		if context.type == "store_joker_create" then
			local corrupts_in_posession = { 0 }
			for k, v in ipairs(G.jokers.cards) do
				if v.config.center.rarity == "ovn_corrupted" and not corrupts_in_posession[v.config.center.key] then
					corrupts_in_posession[1] = corrupts_in_posession[1] + 1
					corrupts_in_posession[v.config.center.key] = true
				end
			end
			local card
			if #G.P_JOKER_RARITY_POOLS.ovn_corrupted > corrupts_in_posession[1] then
				card = create_card("Joker", context.area, nil, "ovn_corrupted", nil, nil, nil, "ovn_cta")
				create_shop_card_ui(card, "Joker", context.area)
				card.states.visible = false
				tag:yep("+", G.C.RARITY.ovn_corrupted, function()
					card:start_materialize()
					card.ability.couponed = true
					card:set_cost()
					return true
				end)
			else
				tag:nope()
			end
			tag.triggered = true
			return card
		end
	end,
})

SMODS.Edition {
	key = "miasma",
	loc_txt = {
		name = "Miasma",
		label = "Miasma",
		text = {
			"{C:attention}Retriggers{} in scoring thrice, then {C:ovn_corrupted}corrupts{}",
			"if possible, otherwise {C:mult}self-destructs{}"
		}
	},
	discovered = true,
	unlocked = true,
	shader = 'miasma',
	config = { retriggers = 3 },
	disable_shadow = true,
	disable_base_shader = true,
	in_shop = false,
	weight = 8,
	extra_cost = 4,
	apply_to_float = true,
	loc_vars = function(self)
		local retriggers = center and center.edition and center.edition.retriggers or self.config.retriggers
		return { vars = { retriggers } }
	end,
	sound = {
		sound = "ovn_e_miasma",
		per = 1,
		vol = 0.4,
	},
	calculate = function(self, card, context)
	local corrupting = false
	local dying = false
		if
		context.other_card == card
		and (
			(context.repetition and context.cardarea == G.play)
			or (context.retrigger_joker_check and not context.retrigger_joker)
		)
		then
		return {
		message = localize("k_again_ex"),
		repetitions = self.config.retriggers,
		card = card,
		} end
		if
		(
			context.post_joker
			and context.cardarea == G.jokers
			and card.config.trigger and not corrupting and not dying
		)
		then
		for k, v in pairs(Oblivion.corruptionMap) do
			if card.config.center.key == k then
			corrupting = true
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.0,
				func = function()
				play_sound("ovn_abyss", 1, 0.2)
				card:start_dissolve({G.C.RARITY['ovn_corrupted']})
				local card = create_card("Joker", G.jokers, nil, nil, nil, nil, v)
				card:add_to_deck()
				G.jokers:emplace(card)
				card:juice_up(0.3, 0.5)
				return true
				end,
			}))
			if G.GAME.in_corrupt_plasma then
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.7,
				func = function()
				play_sound("ovn_increment", 1, 0.9)
				G.GAME.instability = (G.GAME.instability + G.GAME.corrumod)
				return true
				end,
			}))
			end
			end
			if card.config.center.key ~= k then
			dying = true
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.0,
				func = function()
				play_sound("ovn_optic", percent, 0.2)
				card:start_dissolve({G.C.RARITY['ovn_corrupted']})
				return true
				end,
			}))
			end
		end
		if (
			context.final_scoring_step
			and context.cardarea == G.play
		)
		then
		for i=1, #scoring_hand do
			if scoring_hand[i].edition.ovn_miasma then
			if scoring_hand[i].base.suit ~= 'ovn_Optics' then
				G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.1, func = function()
					card:change_suit(ovn_Optics); card:set_edition(nil, true); play_sound('ovn_optic', percent, 1.1); card:juice_up(0.3, 0.3);
				return true end }))
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
			end
			if scoring_hand[i].base.suit == 'ovn_Optics' then
				if context.destroying_card then
				G.E_MANAGER:add_event(Event({
					trigger = "after",
					delay = 0.1,
					func = function()
					card:start_dissolve({G.C.RARITY['ovn_corrupted']})
					return true
					end,
				}))
				end
			end
			end
		end
		end
		end
		if context.joker_main then
			card.config.trigger = true
		end
		if context.after then
			card.config.trigger = nil
		end
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_Oblivion",
	key = "oblivion",
	loc_txt = {
		name = 'Oblivion',
		text = {
			"Add {C:ovn_corrupted}Miasma{} {C:attention}Edition{} to",
			"{C:attention}#1#{} selected playing card or {C:attention}Joker{}"
		}
	},
	cost = 2,
	atlas = "cataclysm_atlas",
	can_use = function(self, card)
	if
		#G.jokers.highlighted
		+ #G.hand.highlighted
		- (G.hand.highlighted[1] and G.hand.highlighted[1] == self and 1 or 0)
		== 1
	then
		if
		#G.jokers.highlighted == 1
		and G.jokers.highlighted[1].edition
		then
		return false
		end
		if #G.hand.highlighted == 1 and G.hand.highlighted[1].edition then
		return false
		end
		return true
	end
	end,
	pos = {x=2, y=0},
	config = {max_highlighted = 1},
	loc_vars = function(self, info_queue)
	info_queue[#info_queue + 1] = G.P_CENTERS.e_ovn_miasma
	return {vars = {self.config.max_highlighted}} end,
	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
	use = function(self, card, area, copier)
	if #G.jokers.highlighted == 1 then
		G.E_MANAGER:add_event(Event({
		func = function()
			play_sound("tarot1")
			G.jokers.highlighted[1]:set_edition({ ovn_miasma = true })
			G.jokers.highlighted[1]:juice_up(0.3, 0.5)
			G.jokers:remove_from_highlighted(G.jokers.highlighted[1])
			return true
		end,
		}))
	else
		G.E_MANAGER:add_event(Event({
		func = function()
			play_sound("tarot1")
			G.hand.highlighted[1]:set_edition({ ovn_miasma = true })
			G.hand.highlighted[1]:juice_up(0.3, 0.5)
			G.hand:remove_from_highlighted(G.hand.highlighted[1])
			return true
		end,
		}))
	end
	end,
}
