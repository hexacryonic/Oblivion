Oblivion.modifier_def = {
	enhancement = {
		pool = "Enhanced",
		has_no_modifier = function(card)
			return card.config.center.key == "c_base"
		end,
		apply_random_modifier = function(card, options)
			local enhancement = SMODS.poll_enhancement{
				guaranteed = true,
				type_key = "ovn_master_of_puppets",
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
				type_key = "ovn_master_of_puppets",
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
				"ovn_master_of_puppets",
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

Oblivion.modifier_def["*"] = {
	has_no_modifier = function(card)
		local no_mod = true
		for name, modi_def in pairs(Oblivion.modifier_def) do
			if name ~= "*" then
				no_mod = no_mod and modi_def.has_no_modifier(card)
			end
		end
		return no_mod
	end,
	apply_random_modifier = function(card, options)
		for name, modi_def in pairs(Oblivion.modifier_def) do
			if name ~= "*" and name ~= "*C" and modi_def.has_no_modifier(card) then
				local modi_options = get_current_pool(modi_def.pool)
				modi_def.apply_random_modifier(card, modi_options)
			end
		end
	end
}

Oblivion.modifier_def["*C"] = {
	has_no_modifier = function(card)
		local no_mod = true
		for name, modi_def in pairs(Oblivion.modifier_def) do
			if name ~= "*" and name ~= "*C" then
				no_mod = no_mod and modi_def.has_no_modifier(card)
			end
		end
		return no_mod
	end,
	apply_random_modifier = function(card, options)
		for name, modi_def in pairs(Oblivion.modifier_def) do
			if name ~= "*" and name ~= "*C" and modi_def.has_no_modifier(card) then
				local modi_options
				if name == "enhancement" then
					modi_options = twisted_enhancements
				elseif name == "seals" then
					modi_options = marks
				elseif name == "editions" then
					modi_options = {"e_ovn_miasma"}
				else
					modi_options = get_current_pool(modi_def.pool)
				end
				modi_def.apply_random_modifier(card, modi_options)
			end
		end
	end
}

Oblivion.rarity_modifier_map = {
	[1] = { -- Common -> Enhancements
		display_order = 1,
		rarity_loc_key = "k_common",
		modifier = "enhancement",
		modifier_loc_key = "k_enhancement", -- added by Oblivion
	},
	[2] = { -- Uncommon -> Seal
		display_order = 2,
		rarity_loc_key = "k_uncommon",
		modifier = "seal",
		modifier_loc_key = "k_seal", -- added by Oblivion
	},
	[3] = { -- Rare -> Edition
		display_order = 3,
		rarity_loc_key = "k_rare",
		modifier = "edition",
		modifier_loc_key = "k_edition",
		blacklist = {"e_negative"},
	},
	["ovn_corrupted"] = { -- Corrupted -> Twisted Enhancements
		display_order = 4,
		rarity_loc_key = "k_ovn_corrupted",
		modifier = "enhancement",
		modifier_loc_key = "k_enhancement", -- added by Oblivion
		modifier_loc_colour = HEX('2349cb'),
		whitelist = twisted_enhancements,
	},
	[4] = { -- Legendary -> All
		hidden = true,
		modifier = "*",
	},
	["ovn_supercorrupted"] = { -- Supercorrupted -> All Corrupted
		hidden = true,
		modifier = "*C",
	},
	["~"] = { -- dummy rarity-modi-def to note that other -> random
		rarity_loc_key = "k_ovn_other_rarity",
		rarity_loc_colour = G.C.UI.TEXT_INACTIVE,
		modifier_loc_key = "k_ovn_random_modifier",
		modifier_loc_colour = G.C.UI.TEXT_INACTIVE,
	}
}