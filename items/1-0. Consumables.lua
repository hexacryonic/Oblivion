--------------------------
-- Supplementary functions
--------------------------
local add_simple_event = Ovn_f.add_simple_event
to_big = to_big or function(x)
	return x
end

----------------

------------
-- TAROT
-- The Abyss
------------
SMODS.Consumable { key = "abyss",
	set = "Tarot",
	name = "ovn_The Abyss",
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic",
		sound = "HexaCryonic"
	},

	atlas = "consumables",
	pos = {x=0, y=0},

	cost = 2,
	corrupts_jokers = true,

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
	end,
}

-------------
-- TAROT
-- Perception
-------------
SMODS.Consumable { key = "perception",
	set = "Tarot",
	name = "ovn_Perception",
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},

    config = {max_highlighted = 3, suit_conv = 'ovn_Optics'},
	loc_vars = function(self) return {vars = {self.config.max_highlighted}} end,

	atlas = "consumables",
	pos = {x=1, y=0},
	cost = 2,

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
		add_simple_event('after', 0.2, function() G.hand:unhighlight_all() end)

		delay(0.5)
	end,
}

----------------

-- Quick reference to Planet loc_vars.
---@param self table|SMODS.Center
---@param info_queue table
---@param card table|Card
---@return table
local function planet_loc_vars(self, info_queue, card)
	local hand_type = card.ability.hand_type
	local hand_ref = G.GAME.hands[hand_type]
	return {vars = {
		hand_ref.level,
		localize(hand_type, 'poker_hands'),
		hand_ref.l_mult,
		hand_ref.l_chips,
		colours = {
			(hand_ref.level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(7, hand_ref.level)])
		}
	}}
end

-----------
-- PLANET
-- Ganymede
-----------
SMODS.Consumable { key = 'ganymede',
	set = 'Planet',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "TBD"
	},

	loc_vars = planet_loc_vars,
	config = { hand_type = 'ovn_Spectrum', softlock = true },

	atlas = 'consumables',
	pos = {x = 0, y = 1 },
	uses_placeholder_sprite = true,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
}

-----------
-- PLANET
-- Callisto
-----------
SMODS.Consumable { key = 'callisto',
	set = 'Planet',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "TBD"
	},

	loc_vars = planet_loc_vars,
	config = { hand_type = 'ovn_Straight Spectrum', softlock = true },

	atlas = 'consumables',
	pos = {x = 1, y = 1 },
	uses_placeholder_sprite = true,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
}

---------
-- PLANET
-- Io
---------
SMODS.Consumable { key = 'io',
	set = 'Planet',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "TBD"
	},

	loc_vars = planet_loc_vars,
	config = { hand_type = 'ovn_Spectrum House', softlock = true },

	atlas = 'consumables',
	pos = {x = 2, y = 1 },
	uses_placeholder_sprite = true,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
}

---------
-- PLANET
-- Europa
---------
SMODS.Consumable { key = 'europa',
	set = 'Planet',
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "TBD"
	},

	loc_vars = planet_loc_vars,
	config = { hand_type = 'ovn_Spectrum Five', softlock = true },

	atlas = 'consumables',
	pos = {x = 3, y = 1 },
	uses_placeholder_sprite = true,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Galilean Moon', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,
}

----------------

------------
-- SPECTRAL
-- Charybdis
------------
SMODS.Consumable { key = "charybdis",
	set = "Spectral",
	name = "ovn_charybdis",
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.create } }
	end,

	atlas = "consumables",
	pos = {x=0, y=2},

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

-----------
-- SPECTRAL
-- Oblivion
-----------
SMODS.Consumable { key = "oblivion",
	set = "Spectral",
	name = "ovn_Oblivion",
	credits = {
		concept = "HexaCryonic",
		art = "HexaCryonic",
		code = "HexaCryonic"
	},

	loc_vars = function(self, info_queue)
		table.insert(info_queue, G.P_CENTERS.e_ovn_miasma)
		return {vars = {self.config.max_highlighted}}
	end,
	config = {max_highlighted = 2},

	atlas = "consumables",
	pos = {x=1, y=2},

	cost = 2,

	set_card_type_badge = function(self, card, badges)
		badges[1] = create_badge('Phantasmal Spectral', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.WHITE, 1.2)
	end,

	can_use = function(self, card)
		local selected_jokers = G.jokers.highlighted
		local selected_playing_card = G.hand.highlighted
		local exclude_self = G.consumeables.highlighted[1] == self and 1 or 0

		local selected_card_count = #selected_jokers + #selected_playing_card - exclude_self
		if (selected_card_count == 0 or selected_card_count > card.ability.max_highlighted) then return false end

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

-----------
-- SPECTRAL
-- Eidolon
-----------
SMODS.Consumable { key = "eidolon",
	set = "Spectral",
	name = "ovn_Eidolon",
	credits = {
		concept = "HexaCryonic",
		code = "Oinite",
		art = {"Oinite", "idea: Airtoum"}
	},

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_SEALS[card.ability.extra.seal]
    end,
	config = { extra = { seal = 'ovn_indigo' }, max_highlighted = 1 },

	atlas = "consumables",
	pos = {x=2, y=2},

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

----------------

--------------------
-- VOUCHER
-- Wicked Invokation
--------------------
SMODS.Voucher { key = "wicked_invocation",
	credits = {
		concept = "HexaCryonic",
		art = "TBD",
		code = "Oinite"
	},

	atlas = "placeholder",
	pos = {x=0, y=1},
	uses_placeholder_sprite = true,
	cost = 10,

	redeem = function(self, card)
		add_simple_event(nil, nil, function()
			G.P_CENTERS["p_ovn_wicked_normal_1"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_2"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_3"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_4"].weight = 0.6
		end)
	end,

	calculate = function (self, card, context)
		if context.ovn_run_started then
			G.P_CENTERS["p_ovn_wicked_normal_1"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_2"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_3"].weight = 0.6
			G.P_CENTERS["p_ovn_wicked_normal_4"].weight = 0.6
		end
	end
}

-------------------
-- VOUCHER
-- Call of the Void
-------------------
SMODS.Voucher { key = "call_of_the_void",
	requires = {'v_ovn_wicked_invocation'},
	credits = {
		concept = "HexaCryonic",
		art = "TBD",
		code = "Oinite"
	},

	atlas = "placeholder",
	pos = {x=1, y=1},
	uses_placeholder_sprite = true,
	cost = 10,

	redeem = function(self, card)
		G.GAME.ovn_corrupted_mod = 2
	end
}
