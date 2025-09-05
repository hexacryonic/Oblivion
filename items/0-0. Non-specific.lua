------------
-- RARITY
-- Corrupted
------------
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

------------
-- RARITY
-- Corrupted (Internal variant)
------------
-- Nyarlathotep (and W.D. Gaster with Cryptid) is internally classified as a separate rarity
-- so that it can't appear in the usual Corrupted summoning pools
SMODS.Rarity({
	key = "supercorrupted",
	badge_colour = HEX('2349cb'),
})

---------
-- SUIT
-- Optics
---------
SMODS.Suit{
	key = 'Optics',
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
booster_wicked_normal(4)

Oblivion.play_instability_noise = true

--------------------
-- SCORING PARAMETER
-- Instability
--------------------
-- Values are dummy; to change instability, use Ovn_f.change_instability
SMODS.Scoring_Parameter {
	key = 'instability',
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
		local instability_max = 2
		if G.GAME.ovn_instability >= instability_max then return end

		if Oblivion.play_instability_noise then
			if amount < 0 then
				play_sound("ovn_decrement", 1, 0.8)
			elseif amount > 0 then
				play_sound("ovn_increment", 1, 0.9)
			end
			-- Prevention of sound spam (often occurs with consumables)
			if G.STATE == G.STATES.PLAY_TAROT then
				Oblivion.play_instability_noise = false
			end
		end

		G.GAME.ovn_instability = G.GAME.ovn_instability + amount
	end,
}

-------------------
-- SCORING OPERATOR
-- Instable
-------------------
SMODS.Scoring_Calculation {
	key = "instable",
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
			op("X", op_scale, G.C.UI_MULT),
			container("mult", "hand_mult_container", text_scale, w, h),
			op(")", op_scale, G.C.RARITY['ovn_corrupted']),
			op("^", op_scale, G.C.RARITY['ovn_corrupted']),
			container("ovn_instability", "instability_container", text_scale, w, h, G.C.RARITY['ovn_corrupted']),
		}}
	end
}

---------
-- SHADER
-- Miasma
---------
SMODS.Shader{
	key = 'miasma',
	path = 'miasma.fs'
}

-------------
-- DECK SKIN
-- Optics
-- Nova Drift
-------------
SMODS.DeckSkin{
	key = 'novadrift',
	suit = 'ovn_Optics',
	loc_txt = {["en-us"] = "Nova Drift"},

	palettes = {
		{
			key = 'lc',
			ranks = {"King", "Queen", "Jack"},
			display_ranks = {"King", "Queen", "Jack"},
			atlas = "ovn_skin_nd_lc",
			pos_style = 'collab',
		},
		{
			key = 'hc',
			ranks = {"King", "Queen", "Jack"},
			display_ranks = {"King", "Queen", "Jack"},
			atlas = "ovn_skin_nd_hc",
			pos_style = 'collab',
		},
	}
}