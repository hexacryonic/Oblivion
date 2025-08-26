local add_simple_event = Ovn_f.add_simple_event
to_big = to_big or function(x)
	return x
end

SMODS.Rarity({
	key = "corrupted",
	badge_colour = HEX('2349cb'),
	default_weight = 0,
    get_weight = function(self, weight, object_type)
        return (
			G.GAME.used_vouchers.v_ovn_call_of_the_void
			and 0.25
			or 0
		)
    end,
	pools = {
		["Joker"] = true
	}
})

-- Nyarlathotep (and W.D. Gaster with Cryptid) is internally classified as a separate rarity
-- so that it can't appear in the usual Corrupted summoning pools
SMODS.Rarity({
	key = "supercorrupted",
	badge_colour = HEX('2349cb'),
})

----

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
			card_extra.xmult = card_extra.xmult + card_extra.xmult_gain
			return {
				message = localize('k_upgrade_ex'),
				colour = G.C.MULT,
				message_card = card
			}
		end

		if context.remove_playing_cards and not context.blueprint then
			local ice_cards = 0
			for _,removed_card in ipairs(context.removed) do
				if removed_card.ice_melted then
					ice_cards = ice_cards + 1
				end
			end
			if ice_cards > 0 then
				card_extra.xmult_gain = card_extra.xmult_gain + card_extra.xmult_gain_gain*ice_cards
					return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}, true
			end
		end
	end
}

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

-- Corrupt Visage goes here for immediate viewing after Pure Visage
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
				card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}
			end
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}

----

SMODS.Consumable {
	set = "Tarot",
	name = "ovn_The Abyss",
	key = "abyss",

	atlas = "abyss_atlas",
	pos = {x=0, y=0},

	cost = 2,

	in_pool = function()
		local held_jokers = G.jokers.cards
		for _,joker in ipairs(held_jokers) do
			local joker_key = joker.config.center.key
			if Oblivion.corruption_map[joker_key] then return true end
		end
		return false
	end,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Parallel Tarot', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	set_ability = function(self, card, initial, delay_sprites)
		if G.your_collection then return end

		local held_jokers = G.jokers.cards
		for _,joker in ipairs(held_jokers) do
			local joker_key = joker.config.center.key
			if not Oblivion.corruption_map[joker_key] then goto continue_ovn_The_Abyss_set_ability end

			local eval = function()
				return Ovn_f.has_joker("c_ovn_abyss") and not G.RESET_JIGGLES
			end
			juice_card_until(joker, eval, true)

			::continue_ovn_The_Abyss_set_ability::
		end
	end,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		if #selected_jokers ~= 1 then return false end

		local selected_joker = selected_jokers[1]
		local selected_joker_key = selected_joker.config.center.key
		return Ovn_f.joker_is_corruptible(selected_joker_key)
	end,

	use = function(self, card, area, copier)
		-- established by can_use that selected_card ~= nil
		local selected_card = G.jokers.highlighted[1]
		local selected_card_key = selected_card.config.center.key
		local corrupted_card_key = Oblivion.corruption_map[selected_card_key]

		G.GAME.justcorrupted = corrupted_card_key
		Ovn_f.corrupt_joker(selected_card)

		G.GAME.justcorrupted = nil
		Ovn_f.corruption_instability(1)
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_charybdis",
	key = "charybdis",
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.create } }
	end,

	atlas = "charybdis_atlas",
	pos = {x=0, y=0},

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	config = { create = 2 },
	cost = 4,

	can_use = function(self, card)
		return #G.jokers.cards < G.jokers.config.card_limit
	end,
	use = function(self, card, area, copier)
		local create_count = self.config.create
		local empty_joker_slot_count = G.jokers.config.card_limit - (#G.jokers.cards + G.GAME.joker_buffer)
		local jokers_to_create_count = math.min(create_count, empty_joker_slot_count)

		G.GAME.joker_buffer = G.GAME.joker_buffer + jokers_to_create_count
		local deletable_jokers = {}
		for _,held_joker in pairs(G.jokers.cards) do
			if not held_joker.ability.eternal then
				table.insert(deletable_jokers, held_joker)
			end
		end

		if #deletable_jokers > 0 then
			add_simple_event(nil, nil, function ()
				SMODS.destroy_cards(deletable_jokers)
			end)
		end

		add_simple_event('after', 0.4, function ()
			for _=1,jokers_to_create_count do
				SMODS.add_card{
					set = 'Joker',
					area = G.joker,
					rarity = 'ovn_corrupted',
					skip_materialize = false,
					key_append = 'ovn_charybdis'
				}
				G.GAME.joker_buffer = 0
			end
		end)
		delay(0.6)
	end,
}

----

local function booster_wicked_normal(num)
	SMODS.Booster {
		key = "wicked_normal_" .. num,
		kind = 'ovn_Wicked',
		group_key = 'k_ovn_wicked_pack',
		loc_vars = function(self, info_queue, card)
			table.insert(info_queue, G.P_CENTERS['c_ovn_abyss'])
			return {
				vars = {
					card.ability.choose,
					card.ability.extra - 1,
					localize { type = 'name_text', key = 'c_ovn_abyss', set = 'Tarot' }
				}
			}
		end,

		atlas = 'cboosters_atlas',
		pos = {x=num - 1, y=0},

		config = { extra = 4, choose = 1 },
		weight = 0,
		cost = 6,

		particles = function(self)
			G.booster_pack_sparkles = Particles(1, 1, 0, 0, {
				timer = 0.015,
				scale = 0.1,
				initialize = true,
				lifespan = 2,
				speed = 1.5,
				padding = 1,
				attach = G.ROOM_ATTACH,
				colours = {
					G.ARGS.LOC_COLOURS.ovn_corrupted,
					G.ARGS.LOC_COLOURS.ovn_mutation,
					G.ARGS.LOC_COLOURS.ovn_indigo,
				},
				fill = true
			})
			G.booster_pack_sparkles.fade_alpha = 1
			G.booster_pack_sparkles:fade(1, 0)
		end,

		ease_background_colour = function(self)
			ease_colour(G.C.DYN_UI.MAIN, lighten(G.ARGS.LOC_COLOURS.ovn_corrupt1, 0.2))
			ease_background_colour{
				new_colour = darken(G.ARGS.LOC_COLOURS.ovn_corrupt1, 0.5),
				contrast = 1
			}
		end,

		create_card = function(self, card, i)
			local _card
			if i == 1 then
				_card = {
					set = "Tarot",
					area = G.pack_cards,
					skip_materialize = true,
					key = 'c_ovn_abyss'
				}
			else
				_card = {
					set = "Joker",
					area = G.pack_cards,
					skip_materialize = true,
					rarity = 'ovn_corrupted',
					key_append = 'ovn_wicked_pack'
				}
			end
			return _card
		end,
	}
end

booster_wicked_normal(1)
booster_wicked_normal(2)
booster_wicked_normal(3)

SMODS.Voucher {
	key = "wicked_invocation",

	atlas = "voucher_atlas",
	pos = {x=0, y=0},
	cost = 10,

	redeem = function(self, card)
		add_simple_event(nil, nil, function()
			G.P_CENTERS["p_ovn_wicked_normal_1"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_3"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_2"].weight = 0.6
		end)
	end,
}

SMODS.Voucher {
	key = "call_of_the_void",
	requires = {'v_ovn_wicked_invocation'},

	atlas = "voucher_atlas",
	pos = {x=1, y=0},
	cost = 10,

	redeem = function(self, card)
		G.GAME.ovn_corrupted_mod = 2
	end
}

----

SMODS.Joker {
	key = 'darkjoker',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult } }
	end,
	config = { extra = { mult = 2 } },

	atlas = 'corrupted',
	pos = { x = 0, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 3,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}
SMODS.Joker {
	key = 'lucasseries',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.29 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			local rank = SMODS.Ranks[context.other_card.base.value].key
			local target_ranks = {
				["2"] = true, ["3"] = true, ["4"] = true,
				["7"] = true, ["Ace"] = true
			}
			if target_ranks[rank] then
				return {
					x_mult = card.ability.extra.xmult,
					color = G.C.MULT,
					card = card
				}
			end
		end
	end
}

SMODS.Joker {
	key = 'perpendicular',
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.money } }
	end,
	config = { extra = { money = 1 } },

	atlas = 'corrupted',
	pos = { x = 1, y = 0 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and context.other_card then
			local scored_card_rank = SMODS.Ranks[context.other_card.base.value].key

			for _,held_card in ipairs(G.hand.cards) do
				local held_card_rank = held_card.base.value

				if scored_card_rank == held_card_rank then
					return {
						dollars = card.ability.extra.money,
					}
				end
			end
		end
	end
}

SMODS.Joker {
	key = 'yolo',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 1.5 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 1 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.before and context.cardarea == G.jokers then
			ease_hands_played(-G.GAME.current_round.hands_left)
			G.GAME.current_round.hands_left = 'nan'
			G.GAME.yolo = true
			return nil, true
		end

		if context.individual and context.cardarea == G.play then
			return {
				x_mult = card.ability.extra.xmult,
				color = G.C.MULT,
				card = card
			}
		end

		if G.GAME.yolo then
			if to_big(G.GAME.current_round.hands_played) > to_big(0) and to_big(G.GAME.chips/G.GAME.blind.chips) < to_big(1) then
				G.STATE = G.STATES.GAME_OVER
				G.STATE_COMPLETE = false
				G.GAME.yolo = false
				return nil, true
			end

			if context.end_of_round and context.cardarea == G.jokers and not context.game_over then
				G.GAME.yolo = false
				return nil, true
			end
		end
	end,
}

SMODS.Joker {
	key = 'supplydrop',
	loc_vars = function(self, info_queue, center)
		local stored
		local stored_joker = G.PROFILES[G.SETTINGS.profile].ovn_supply_drop

		if stored_joker then
			table.insert(info_queue, G.P_CENTERS[stored_joker])
			stored = localize{
				type = "name_text",
				set = "Joker",
				key = stored_joker
			}
		else
			stored = localize("k_none")
		end

		return { vars = { stored } }
	end,

	atlas = 'corrupted',
	pos = { x = 3, y = 1 },

	blueprint_compat = false,
	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.selling_self and not context.retrigger_joker and not context.blueprint then
			if not G.PROFILES[G.SETTINGS.profile].ovn_supply_drop then
				local card_index
				for i = 2, #G.jokers.cards do
					if G.jokers.cards[i] == card then
						card_index = i
						break
					end
				end

				if not card_index then return end
				local left_joker = G.jokers.cards[card_index-1]
				local left_joker_rarity = left_joker.config.center.rarity

				-- greater than rare or not corrupted
				if not (
					(type(left_joker_rarity) == "number" and left_joker_rarity <= 3)
					or left_joker_rarity == "ovn_corrupted"
				) then return end

				local save_file = G.PROFILES[G.SETTINGS.profile]
				if not save_file.ovn_supply_drop then
					local left_joker_key = left_joker.config.center.key
					local left_joker_edition = left_joker.edition and left_joker.edition.key
					local left_joker_stickers = {}
					for sticker_key in pairs(SMODS.Stickers) do
						if left_joker.ability[sticker_key] then
							table.insert(left_joker_stickers, sticker_key)
						end
					end

					save_file.ovn_supply_drop = left_joker_key
					save_file.ovn_supply_drop_edition = left_joker_edition
					save_file.ovn_supply_drop_sticker = left_joker_stickers

					add_simple_event('after', 0.1, function ()
						left_joker:start_dissolve({G.C.RARITY['ovn_corrupted']})
					end)
					card_eval_status_text(
						card,
						"extra",
						nil,
						nil,
						nil,
						{ message = localize("stored"), colour = G.C.DARK_EDITION }
					)
				end
			else
				local save_file = G.PROFILES[G.SETTINGS.profile]

				local stored_joker_key = save_file.ovn_supply_drop
				local stored_joker_edition = save_file.ovn_supply_drop_edition
				local stored_joker_sticker = save_file.ovn_supply_drop_sticker

				local stored_card = SMODS.add_card{
					set = 'Joker',
					area = G.joker,
					key = stored_joker_key,
					edition = stored_joker_edition,
					stickers = stored_joker_sticker
				}

				G.PROFILES[G.SETTINGS.profile].ovn_supply_drop = nil
				G.PROFILES[G.SETTINGS.profile].ovn_supply_drop_edition = nil
				G.PROFILES[G.SETTINGS.profile].ovn_supply_drop_sticker = nil

				return {
					card_eval_status_text(stored_card, "extra", nil, nil, nil, {
						message = localize("empty"),
						colour = G.C.DARK_EDITION,
					}),
				}
			end
		end
	end,

}

SMODS.Joker {
	key = 'pmo',

	atlas = 'corrupted',
	pos = { x = 3, y = 0 },

	rarity = "ovn_corrupted",
	cost = 7,
}

SMODS.Joker {
	key = 'showneverends',

	atlas = 'corrupted',
	pos = { x = 1, y = 2 },

	rarity = "ovn_corrupted",
	cost = 8,

	-- Functionality implemented in Card:update hook
}

SMODS.Joker {
	key = 'airstrike',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 0.2 } },

	atlas = 'corrupted',
	pos = { x = 0, y = 2 },

	rarity = "ovn_corrupted",
	cost = 6,

	calculate = function (self, card, context)
		if context.individual and context.other_card.base.value == '10' then
			local c_ability = context.other_card.ability
			if context.cardarea == 'unscored' or context.cardarea == G.hand then
				local fallback = c_ability and c_ability.perma_x_mult or 0
				c_ability.perma_x_mult = fallback + card.ability.extra.xmult
			elseif context.cardarea == G.play then
				c_ability.perma_x_mult = 0
			end
		end
	end
}

SMODS.Joker {
	key = 'bombastic',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 13 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 2 },

	rarity = "ovn_corrupted",
	cost = 5,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'insightful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.chips } }
	end,
	config = { extra = { chips = 110 } },

	atlas = 'corrupted',
	pos = { x = 3, y = 2 },

	rarity = "ovn_corrupted",
	cost = 5,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				chips = card.ability.extra.chips,
			}
		end
	end
}

SMODS.Joker {
	key = 'breach',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.xmult } }
	end,
	config = { extra = { xmult = 4 } },

	atlas = 'corrupted',
	pos = { x = 2, y = 1 },

	rarity = "ovn_corrupted",
	cost = 9,

	calculate = function(self, card, context)
		if context.joker_main and context.poker_hands and next(context.poker_hands["ovn_Spectrum"]) then
			return {
				xmult = card.ability.extra.xmult,
			}
		end
	end
}

SMODS.Joker {
	key = 'prideful',
	loc_vars = function(self, info_queue, center)
		return { vars = { center.ability.extra.mult } }
	end,
	config = { extra = { mult = 6 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 2 },

	blueprint_compat = true,
	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card:is_suit("ovn_Optics")
		) then
			return {
				mult = card.ability.extra.mult,
			}
		end
	end
}

SMODS.Joker {
	key = 'cultivar',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.Xmult,
			G.GAME.probabilities.normal or 1,
			card.ability.extra.odds
		}}
	end,
	config = { extra = { Xmult = 4, odds = 4 } },

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	rarity = "ovn_corrupted",
	cost = 7,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end

		if context.end_of_round and context.game_over == false and not context.repetition and not context.blueprint then
			local extinct_odds = G.GAME.probabilities.normal / card.ability.extra.odds
			if pseudorandom('cultivar') >= extinct_odds then return { message = 'Safe!' } end

			-- Odd is hit
			add_simple_event(nil, nil, function ()
				play_sound('tarot1')
				card.T.r = -0.2
				card:juice_up(0.3, 0.4)
				card.states.drag.is = true
				card.children.center.pinch.x = true

				G.E_MANAGER:add_event(Event {
					trigger = 'after',
					delay = 0.3,
					blockable = false,
					func = function()
						G.jokers:remove_card(card)
						card:remove()
						card = nil
						return true;
					end
				})
			end)

			G.GAME.pool_flags.gros_michel_extinct = false
			G.GAME.corruptiblemichel = true
			return { message = 'Extinct!' }
		end
	end,
    in_pool = function(self, args)
        return G.GAME.pool_flags.gros_michel_extinct
    end
}

SMODS.Joker {
	key = 'aeon',
	config = { extra = { Xmult = 4} },
	loc_vars = function(self, info_queue, card)
		table.insert(info_queue, G.P_CENTERS.j_cavendish)
		return {vars = {
			card.ability.extra.Xmult,
		}}
	end,

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	rarity = "ovn_corrupted",
	cost = 8,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				xmult = card.ability.extra.Xmult
			}
		end
	end,
    in_pool = function(self, args)
        return G.GAME.corruptiblemichel
    end
}

SMODS.Joker {
	key = 'apartfalling',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.x_mult,
			card.ability.extra.xmult_increase
		}}
	end,
	config = {
		extra = {
			xmult_increase = 0.75,
			x_mult = 1,
		},
	},

	atlas = 'corrupted',
	pos = { x = 4, y = 0 },

	rarity = "ovn_corrupted",
	cost = 8,
	calculate = function(self, card, context)
		if context.joker_main and card.ability.extra.x_mult > 1 then
			return {
				xmult = card.ability.extra.x_mult,
			}
		end

		if (
			context.ovn_corruption_occurred
			and context.ovn_corruption_type == "Joker"
			and not context.blueprint
		) then
			card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.xmult_increase
			return {
				message = localize{
					key = "a_xmult",
					type = "variable",
					vars = { card.ability.extra.x_mult }
				},
				colour = G.C.MULT,
				message_card = card
			}
		end
	end
}

SMODS.Joker {
	key = 'spiral_of_addiction',
	loc_vars = function(self, info_queue, card)
		return { vars = {
			card.ability.extra.xmult_gain,
			card.ability.extra.xmult,
			card.ability.extra.handsize_change
		}}
	end,
	config = {
		extra = {
			xmult = 1,
			xmult_gain = 0.15,
			handsize_change = -2,
			do_handsize_change = false,
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = "ovn_corrupted",
	cost = 6,

	calculate = function(self, card, context)
		local card_extra = card.ability.extra

		if context.joker_main then
			return {
				xmult = card_extra.xmult
			}
		end

		if (
			context.end_of_round
			and not context.game_over
			and context.main_eval
			and not context.blueprint
		) then
			if G.GAME.current_round.discards_left <= 0 then
				card_extra.xmult = card_extra.xmult + card_extra.xmult_gain
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}
			else
				card_extra.do_handsize_change = true
			end
		end

		if context.setting_blind and card_extra.do_handsize_change then
			add_simple_event(nil, nil, function()
				Ovn_f.temp_handsize_change(card_extra.handsize_change)
				SMODS.calculate_effect(
					{ message = localize {
						type = 'variable',
						key = card_extra.handsize_change >= 0 and 'a_hands' or 'a_hands_minus',
						vars = { math.abs(card_extra.handsize_change) }
					}},
					context.blueprint_card or card
				)
			end)
			card_extra.do_handsize_change = false
		end
	end
}

SMODS.Joker {
	key = 'collapsing_world',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.mult_set[card.ability.ovn_former_form or "j_mystic_summit"],
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			mult_set = {
				j_mystic_summit = 3,
				j_erosion = 4,
			},
			mult = 0
		}
	},

	atlas = 'corrupted',
	pos = {x=0, y=4},

	rarity = 'ovn_corrupted',
	cost = 7,
	blueprint_compat = false,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function(self, card, context)
		if (
			context.discard
			and not context.blueprint
			and G.GAME.current_round.discards_left == 1
			and (
				context.other_card == G.hand.highlighted[1]
				or context.other_card == G.hand.highlighted[#G.hand.highlighted]
			)
		) then
			local message, colour
			-- only give mult on first card (i.e. give mult once per discard)
			if context.other_card == G.hand.highlighted[1] then
				local cardextra = card.ability.extra
				cardextra.mult = cardextra.mult + cardextra.mult_set[cardextra.ovn_former_form]
				message = localize {
					type = 'variable',
					key = 'a_mult',
					vars = { cardextra.mult_set[cardextra.ovn_former_form] }
				}
				colour = G.C.RED
			end
			return {
				remove = true,
				message = message,
				colour = colour
			}
		end

		if context.joker_main then return {
			mult = card.ability.extra.mult
		} end
	end
}

SMODS.Joker {
	key = 'master_of_puppets',
	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if context.selling_card and context.cardarea == G.jokers then
			local sold_rarity = context.card.config.center.rarity
			local jack_list = {}
			for _,playing_card in ipairs(G.playing_cards) do
				if (
					playing_card.base.value == "Jack"
					and playing_card.config.center.key ~= "m_stone"
					and (
						(sold_rarity == 1 and playing_card.config.center.key == "c_base")
						or (sold_rarity == 2 and playing_card.seal == nil)
						or (sold_rarity == 3 and playing_card.edition == nil)
					)
				) then
					table.insert(jack_list, playing_card)
				end
			end
			if #jack_list < 1 then return end
			local selected_jack = pseudorandom_element(
				jack_list,
				"ovn_master_of_puppets_jack"
			) --[[@as Card]]


			add_simple_event(nil, nil, function()
				-- Common generates enhancement
				if sold_rarity == 1 then
					local enhancement = SMODS.poll_enhancement{
						guaranteed = true,
						type_key = "ovn_master_of_puppets"
					}
					selected_jack:set_ability(enhancement)

				-- Uncommon generates seal
				elseif sold_rarity == 2 then
					local seal = SMODS.poll_seal{
						guaranteed = true,
						type_key = "ovn_master_of_puppets"
					}
					selected_jack:set_seal(seal)

				-- Rare generates edition
				elseif sold_rarity == 3 then
					local edition = poll_edition(
						"ovn_master_of_puppets",
						nil, true, true,
						{"e_foil", "e_holo", "e_polychrome"}
					)
					selected_jack:set_edition(edition)
				end

				selected_jack:juice_up()
				card:juice_up()
				play_sound('tarot1')
			end)
		end
	end
}

SMODS.Joker {
	key = 'infinitesimal',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.joker_slots,
			card.ability.extra.mult_gain,
			card.ability.extra.mult
		}}
	end,
	config = {
		extra = {
			joker_slots = 1,
			mult_gain = 2,
			mult = 0,
		},
	},

	atlas = 'corrupted',
	pos = {x=1, y=3},

	rarity = 'ovn_corrupted',
	cost = 10,

	add_to_deck = function(self, card, fron_debuff)
		G.jokers:change_size(card.ability.extra.joker_slots)
	end,
	remove_from_deck = function(self, card, fron_debuff)
		G.jokers:change_size(-card.ability.extra.joker_slots)
	end,
	calculate = function(self, card, context)
		if (
			context.individual
			and context.cardarea == G.play
			and context.other_card.base.value == "3"
			and not context.blueprint
		) then
			card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_gain
			return {
                message = localize('k_upgrade_ex'),
                colour = G.C.MULT,
                message_card = card
            }
		end

		if context.joker_main then
			return {
				mult = card.ability.extra.mult
			}
		end
	end
}

SMODS.Joker {
	key = 'migraine',
	atlas = 'corrupted',
	pos = {x=2, y=3},
	rarity = 'ovn_corrupted',
	cost = 6
	-- Functionality implemented in "Migraine makes all standard pack cards Optics" Lovely patch 
}

SMODS.Joker {
	key = 'database',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.chips_per,
			card.ability.extra.chips_per*(G.GAME.cumulative_unique_joker_count or 0)
		}}
	end,
	config = {
		extra = {
			chips_per = 10
		},
	},

	atlas = 'corrupted',
	pos = {x=3, y=3},

	rarity = 'ovn_corrupted',
	cost = 6,

	calculate = function(self, card, context)
		if context.joker_main then
			return {
				chips = card.ability.extra.chips_per*G.GAME.cumulative_unique_joker_count
			}
		end
	end
}

SMODS.Joker {
	key = 'cigarette_card',
	loc_vars = function(self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult = 1.5
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=3},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function(self, card, context)
		if context.other_joker and context.other_joker.config.center.rarity == "ovn_corrupted" then
			return {
				xmult = card.ability.extra.xmult,
				message_card = context.other_joker
			}
		end
	end,
	-- Additional functionality implemented in
	-- "Cigarette Card makes all Uncommons Miasma" Lovely patch 
}

SMODS.Joker {
	key = 'library_of_babel',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult_set[card.ability.ovn_former_form or "j_todo_list"],
			card.ability.extra.last_played_threshold,
			card.ability.extra.xmult
		}}
	end,
	config = {
		extra = {
			xmult_set = {
				j_todo_list = 0.2,
				j_card_sharp = 0.3,
				j_obelisk = 0.4
			},
			xmult = 1,
			last_played_threshold = 3
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	add_to_deck = function(self, card, context)
		Ovn_f.set_random_former_form(card)
	end,
	calculate = function (self, card, context)
		if context.before then
			local hand = context.scoring_name
			if G.GAME.hands_last_played[hand] >= card.ability.extra.last_played_threshold then
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_set[card.ability.ovn_former_form]
				return {
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}
			end
		end

		if context.joker_main then
			return {
				xmult = card.ability.extra.xmult
			}
		end
	end
}

SMODS.Joker {
	key = 'bottled_ship_of_theseus',
	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 10,

	calculate = function (self, card, context)
		if context.remove_playing_cards and not context.blueprint then
			for _,removed_card in ipairs(context.removed) do
				if removed_card.config.center.key ~= "m_glass" then
					local rank = removed_card.base.value
					local suit = removed_card.base.suit
					add_simple_event(nil, nil, function ()
						SMODS.add_card { -- Random enhanced 3 of Clubs
							set = "Enhanced",
							rank = rank,
							suit = suit,
							enhancement = "m_glass"
						}
					end)
				end
			end
		end
	end
}

-- MAJOR BUG: Description does not update regardless if values changed
SMODS.Joker {
	key = 'nexus_point',
	loc_vars = function (self, info_queue, card)
		return {vars = {
			card.ability.extra.xmult,
			card.ability.extra.xmult_gain
		}}
	end,
	config = {
		extra = {
			xmult_gain = 0.2,
			xmult = 1.1,
		}
	},

	atlas = 'corrupted',
	pos = {x=4, y=0},

	rarity = 'ovn_corrupted',
	cost = 7,

	calculate = function (self, card, context)
		if (
			context.ovn_corrupted_from
			and context.ovn_former_form_key == "j_ovn_nexus_point"
		) then
			local former_ability = context.ovn_former_form_ability
			add_simple_event("after", 0.1, function ()
				card.ability.extra.xmult_gain = former_ability.extra.xmult_gain
				card.ability.extra.xmult = former_ability.extra.xmult + card.ability.extra.xmult_gain
				SMODS.calculate_effect({
					message = localize('k_upgrade_ex'),
					colour = G.C.MULT,
					message_card = card
				}, card)
			end)
		end

		if context.individual and context.cardarea == G.play then
			return {
				xmult = card.ability.extra.xmult
			}
		end
	end
}