Oblivion.modifier_def = {
	enhancement = {
		pool = "Enhanced",
		has_no_modifier = function(card)
			return card.config.center.key == "c_base"
		end,
		apply_random_modifier = function(card, options)
			local enhancement = SMODS.poll_enhancement{
				guaranteed = true,
				type_key = "ovn_master_of_puppets_enhancement",
				options = options
			}
			card:set_ability(enhancement)
		end,
	},
	seal = {
		pool = "Seal",
		has_no_modifier = function(card)
			return card.seal == nil
		end,
		apply_random_modifier = function(card, options)
			local seal = SMODS.poll_seal{
				guaranteed = true,
				type_key = "ovn_master_of_puppets_seal",
				options = options
			}
			card:set_seal(seal)
		end,
	},
	edition = {
		pool = "Edition",
		has_no_modifier = function(card)
			return card.edition == nil
		end,
		apply_random_modifier = function(card, options)
			local edition = poll_edition(
				"ovn_master_of_puppets_edition",
				nil, true, true,
				options
			)
			card:set_edition(edition)
		end,
	},
}

local twisted_enhancements = {
	"m_ovn_radiant",
	"m_ovn_dynamo",
	"m_ovn_coord",
	"m_ovn_ice",
	"m_ovn_unob",
	"m_ovn_crystal",
	"m_ovn_dense",
	"m_ovn_ion",
}

local marks = {
	"ovn_ruby_mark",
	"ovn_sapphire_mark",
	"ovn_amethyst_mark",
	"ovn_citrine_mark",
	"ovn_iolite_mark",
}

Oblivion.rarity_modifier_map = {
	[1] = { -- Common -> Enhancements
		display_order = 1,
		modifiers = {"enhancement"},

		rarity_loc_key = "k_common",
		modifier_loc_key = "k_enhancement", -- added by Oblivion
	},
	[2] = { -- Uncommon -> Seal
		display_order = 2,
		modifiers = {"seal"},

		rarity_loc_key = "k_uncommon",
		modifier_loc_key = "k_seal", -- added by Oblivion
	},
	[3] = { -- Rare -> Edition
		display_order = 3,
		modifiers = {"edition"},
		blacklist = {edition = {"e_negative"}},

		rarity_loc_key = "k_rare",
		modifier_loc_key = "k_edition",
	},
	["ovn_corrupted"] = { -- Corrupted -> Twisted Enhancements
		display_order = 4,
		modifiers = {"enhancement"},
		whitelist = {enhancement = twisted_enhancements},

		rarity_loc_key = "k_ovn_corrupted",
		modifier_loc_key = "k_enhancement", -- added by Oblivion
		modifier_loc_colour = HEX('2349cb'),
	},
	[4] = { -- Legendary -> All
		hidden = true,
		modifiers = "*",
	},
	["ovn_supercorrupted"] = { -- Supercorrupted -> All Corrupted
		hidden = true,
		modifiers = "*",
		whitelist = {
			enhancement = twisted_enhancements,
			seal = marks,
			edition = {"e_ovn_miasma"}
		},
	},
	["~"] = { -- dummy rarity-modi-def to note that other -> random
		rarity_loc_key = "k_ovn_other_rarity",
		rarity_loc_colour = G.C.UI.TEXT_INACTIVE,
		modifier_loc_key = "k_ovn_random_modifier",
		modifier_loc_colour = G.C.UI.TEXT_INACTIVE,
	}
}

