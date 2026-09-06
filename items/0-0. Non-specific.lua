------------
-- RARITY
-- Corrupted
------------
SMODS.Rarity { key = "corrupted",
	badge_colour = HEX('2349cb'),
	default_weight = 0,
    get_weight = function(self, weight, object_type)
        return (
			G.GAME.used_vouchers.v_ovn_call_of_the_void
			and 0.25
			or weight
		)
    end,
	pools = {
		["Joker"] = true
	}
}

------------
-- RARITY
-- Corrupted (Internal variant)
------------
-- Nyarlathotep (and W.D. Gaster with Cryptid) is internally classified as a separate rarity
-- so that it can't appear in the usual Corrupted summoning pools
SMODS.Rarity { key = "supercorrupted",
	badge_colour = HEX('2349cb'),
}

---------
-- SUIT
-- Optics
---------
SMODS.Suit { key = 'Optics',
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
	-- Additional functionality present in "Optics' base chips are doubled", lovely.toml
}

----------------
-- BOOSTER PACKS
-- Wicked Packs
----------------
local function booster_wicked_normal(num)
	SMODS.Booster { key = "wicked_normal_" .. num,
		kind = 'ovn_Wicked',
		group_key = 'k_ovn_wicked_pack',
		credits = {
			concept = "HexaCryonic",
			code = "Oinite",
			art = "HexaCryonic",
		},
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

		atlas = 'booster_packs',
		pos = {x=num - 1, y=0},

		config = { extra = 4, choose = 1 },
		weight = 0,
		get_weight = function ()
			if #SMODS.find_card('v_ovn_wicked_invocation') > 0 then
				return 0.6
			end
			return 0
		end,
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
booster_wicked_normal(4)

------------------
-- DYNATEXT EFFECT
-- BetterFloat
------------------
SMODS.DynaTextEffect { key = "betterfloat",
	func = function(self, index, letter)
		-- taken from vanilla source
		-- and modified to be a bit more readable

		local enable_motion = G.SETTINGS.reduced_motion and 0 or 1
		local oscillation   = math.sin(2.666*G.TIMERS.REAL + 200*index)
		local apparent_size = self.font.FONTSCALE/G.TILESIZE

		letter.offset.y = 60*(letter.scale - 1) + (
			enable_motion
			*math.sqrt(self.scale)
			*(2 + (2000*oscillation*apparent_size))
		)
	end,
}

------------------
-- DYNATEXT EFFECT
-- Glitched
------------------
SMODS.DynaTextEffect { key = "glitched",
	func = function(self, index, letter)
		-- ignore spaces
		local og_char = self.strings[1].letters[index].char
		if og_char == " " then return end

		-- Slowing mechanisms for accessibility toggles
		local timing_mag = 8
		local timing_req = timing_mag*((index%3) + 1)
		letter.timing = (letter.timing or (index%timing_mag)) + 1

		local reduce_speed = (
			Oblivion.config.disable_c_erratic_shader
			or G.SETTINGS.reduced_motion
		)
		local do_change = true
		if reduce_speed then
			do_change = letter.timing >= timing_req
		end

		if do_change then
			local rnd = math.random(33, 126)
			local char = string.char(rnd)
			letter.letter:set(char)
		end

		if letter.timing >= timing_req then letter.timing = 0 end
	end,
}

--------------------
-- DESCRIPTION DUMMY
-- Card credits
--------------------
Oblivion.DescriptionDummy {
	key = "credits",
	generate_ui = function (self, info_queue, card, desc_nodes, specific_vars, full_UI_table)
		-- specific_vars is sent by generate_card_ui (patched by corruption.toml)
		-- It is a string-keyed table based on a card's `credits` value
		if not card then card = self:create_fake_card() end

		local label_loc = G.localization.misc.credits_labels
		local label_order = {"concept", "art", "shader", "music", "sound", "code"}

		local table_rows = {}
		for _,label_key in ipairs(label_order) do
			local left = {
				text = label_loc[label_key],
				colour = G.C.BLUE,
				align = "cr"
			}
			local right
			if specific_vars[label_key] then
				right = {text = specific_vars[label_key]}
			end
			if right then
				table.insert(table_rows, {left, right})
			end
		end

		local credits_ui = Ovn_f.generate_table_ui(table_rows, {no_header = true})
		desc_nodes.name = localize{type = 'name_text', key = 'dd_ovn_credits', set = "DescriptionDummy"}
		table.insert(desc_nodes, {credits_ui})
	end
}

----------------
-- PlayLog TYPE
-- transmutation
----------------
PlayLog.LogType { key = "transmute_joker",
	group = "effects",
	get_message = function(self, args)
		local loc_key
		if args.transmute_type == "corrupt" then
			loc_key = args.from == args.to and "plog_recorrupt" or "plog_corrupt"
		elseif args.transmute_type == "purify" then
			loc_key = args.from == args.to and "plog_repurify" or "plog_purify"
		end
		return PlayLog.localize(loc_key, {PlayLog.format_object(args.from), PlayLog.loc_list(PlayLog.format_object(args.to)) })
	end
}

PlayLog.LogType { key = "transmute_modifiers",
	group = "effects",
	get_message = function (self, args)
		local loc_key
		if args.transmute_type == "corrupt" then
			loc_key = "plog_corrupt_modifiers"
		elseif args.transmute_type == "purify" then
			loc_key = "plog_purify_modifiers"
		end
		return PlayLog.localize(loc_key, {PlayLog.format_object(args.card), PlayLog.loc_list(PlayLog.format_objects(args.from)), PlayLog.loc_list(PlayLog.format_objects(args.to)) })
	end
}