-- Defines definitions for apply-check on cards, and random application on cards
-- and defines rarity-modifier mappings for Master of Puppets

-- Please read documentation for how to add to this table

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

----

Oblivion.modifier_def = Oblivion.modifier_def or {}
local modi_def = Oblivion.modifier_def
modi_def["enhancement"] = {
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
}
modi_def["seal"] = {
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
}
modi_def["edition"] = {
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
}

----

Oblivion.rarity_modifier_map = Oblivion.rarity_modifier_map or {}
local rarity_modi = Oblivion.rarity_modifier_map

-- Common -> Enhancements
rarity_modi[1] = {
    display_order = 1,
    modifiers = {"enhancement"},

    rarity_loc_key = "k_common",
    modifier_loc_key = "k_enhancement", -- added by Oblivion
}

-- Uncommon -> Seal
rarity_modi[2] = {
    display_order = 2,
    modifiers = {"seal"},

    rarity_loc_key = "k_uncommon",
    modifier_loc_key = "k_seal", -- added by Oblivion
}

-- Rare -> Edition
rarity_modi[3] = {
    display_order = 3,
    modifiers = {"edition"},
    blacklist = {edition = {"e_negative"}},

    rarity_loc_key = "k_rare",
    modifier_loc_key = "k_edition",
}

-- Corrupted -> Twisted Enhancements
rarity_modi["ovn_corrupted"] = {
    display_order = 4,
    modifiers = {"enhancement"},
    whitelist = {enhancement = twisted_enhancements},

    rarity_loc_key = "k_ovn_corrupted",
    modifier_loc_key = "k_enhancement", -- added by Oblivion
    modifier_loc_colour = HEX('2349cb'),
}

-- Legendary -> All
rarity_modi[4] = {
    hidden = true,
    modifiers = "*",
}

-- Supercorrupted -> All Corrupted
rarity_modi["ovn_supercorrupted"] = {
    hidden = true,
    modifiers = "*",
    whitelist = {
        enhancement = twisted_enhancements,
        seal = marks,
        edition = {"e_ovn_miasma"}
    },
}

-- dummy rarity-modi-def to note that other -> random
rarity_modi["~"] = {
    rarity_loc_key = "k_ovn_other_rarity",
    rarity_loc_colour = G.C.UI.TEXT_INACTIVE,
    modifier_loc_key = "k_ovn_random_modifier",
    modifier_loc_colour = G.C.UI.TEXT_INACTIVE,
}