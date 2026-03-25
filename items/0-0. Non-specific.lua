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

Oblivion.play_instability_noise = true

--------------------
-- SCORING PARAMETER
-- Instability
--------------------
-- Values are dummy; to change instability, use Ovn_f.change_instability
SMODS.Scoring_Parameter { key = 'instability',
	default_value = 1,
	colour = G.C.RARITY['ovn_corrupted'],
	flame_handler = function(self)
		return {
			id = 'flame_'..self.key,
			arg_tab = self.key..'_flames',
			colour = G.C.RARITY['ovn_corrupted'],
			accent = self.lick
		}
	end,
	level_up_hand = function() end,
	modify = function(self, amount)
		if amount == 0 then return end

		G.GAME.ovn_instability = G.GAME.ovn_instability or 1
		local instability_max = G.GAME.opticclamp or 2

		if G.GAME.ovn_instability + amount >= instability_max then
			G.GAME.ovn_instability = instability_max
		else
			G.GAME.ovn_instability = G.GAME.ovn_instability + amount
		end

		if Oblivion.play_instability_noise then
			if amount < 0 then
				play_sound("ovn_instability_decrement", 1, 0.8)
			elseif amount > 0 then
				play_sound("ovn_instability_increment", 1, 0.9)
			end
			-- Prevention of sound spam (often occurs with consumables)
			if G.STATE == G.STATES.PLAY_TAROT then
				Oblivion.play_instability_noise = false
			end
		end

		self.current = G.GAME.ovn_instability
	end,
}

-------------------
-- SCORING OPERATOR
-- Instable
-------------------
SMODS.Scoring_Calculation { key = "instable",
	func = function(self, chips, mult, flames)
		local instability = G.GAME.ovn_instability
		---@diagnostic disable-next-line: redundant-return-value
		return (chips * mult) ^ instability
	end,
	replace_ui = function (self)
		local function op(text, scale, colour)
			return
			{n=G.UIT.C, config={align = "cm"}, nodes={
				{n=G.UIT.T, config={text = text, lang = G.LANGUAGES['en-us'], scale = scale, colour = colour or G.C.WHITE, shadow = true}},
			}}
		end

		local function container(type, id, scale, w, h, colour)
			return
			{n=G.UIT.C, config={align = 'cm', id = id}, nodes = {
				SMODS.GUI.score_container({
					type = type,
					align = 'cm',
					scale = scale,
					w = w, h = h,
					colour = colour
				})
			}}
		end

		local w = 1.2
		local h = 0.7
		local text_scale = 0.69/2.3
		local op_scale = 0.5

		return
		---@diagnostic disable-next-line: redundant-return-value
		{n=G.UIT.R, config={align = "cm", minh = 1, padding = 0.05}, nodes={
			op("(", op_scale, G.C.RARITY['ovn_corrupted']),
			container("chips", "hand_chips_container", text_scale, w, h),
			SMODS.GUI.operator(op_scale/2),
			container("mult", "hand_mult_container", text_scale, w, h),
			op(")", op_scale, G.C.RARITY['ovn_corrupted']),
			op("^", op_scale, G.C.RARITY['ovn_corrupted']),
			container("ovn_instability", "instability_container", text_scale, w, h, G.C.RARITY['ovn_corrupted']),
		}}
	end
}

------------------
-- DYNATEXT EFFECT
-- Glitched
------------------
SMODS.DynaTextEffect { key = "glitched",
	func = function(dynatext, index, letter)
		-- ignore spaces
		local og_char = dynatext.strings[1].letters[index].char
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
-- Instability
--------------------
Oblivion.DescriptionDummy { key = "instability_description" }

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

		local label_loc = G.localization.descriptions.DescriptionDummy.dd_ovn_credits.labels
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
