local planet_loc = function(name)
	return {
        name = name,
        text = {
            "{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
            "{C:attention}#2#",
            "{C:mult}+#3#{} Mult and",
            "{C:chips}+#4#{} chips",
        }
}
end

return { descriptions = {

-------------------------

Tarot = {
    c_ovn_insecurity = {
        name = 'Insecurity',
        text = {
            "{C:ovn_corrupted}You begin to feel like{}",
            "{C:ovn_corrupted}you're being watched{}"
        }
    },
    c_ovn_abyss = {
        name = 'The Abyss',
        text = {
            "{C:ovn_corrupted}Corrupt{} a selected",
            "{C:attention}Corruptible Joker{}"
        }
    },
    c_ovn_perception = {
        name = 'Perception',
        text = {
            "{C:ovn_corrupted}Corrupts{} up to",
            "{C:attention}#1#{} selected cards",
            "to {C:ovn_optic}Optics"
        }
    }
},

-------------------------

Planet = {
    c_ovn_ganymede = planet_loc("Ganymede"),
    c_ovn_callisto = planet_loc("Callisto"),
    c_ovn_io       = planet_loc("Io"),
    c_ovn_europa   = planet_loc("Europa"),
    c_ovn_tres = {
        name = 'TrEs-2b',
        text = {
            "{C:ovn_corrupted}The world around you{}",
            "{C:ovn_corrupted}begins to darken{}"
        }
    },
},

-------------------------

Spectral = {
    c_ovn_charybdis = {
        name = 'Charybdis',
        text = {
            "Create {C:attention}#1#{} random {C:dark_edition}Negative{}",
            "{C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
            "Destroy all other {C:attention}Jokers{}"
        }
    },
    c_ovn_oblivion = {
        name = 'Oblivion',
        text = {
            "Add {C:ovn_corrupted}Miasma{} {C:attention}Edition{}",
            "to {C:attention}#1#{} selected",
            "playing cards or {C:attention}Joker{}"
        }
    },
    c_ovn_eidolon = {
        name = 'Eidolon',
        text = {
            "Add an {C:ovn_indigo}Indigo Seal{}",
            "to {C:attention}1{} selected",
            "card in your hand"
        }
    },
    c_ovn_recall = {
        name = 'Recall',
        text = {
            "{C:ovn_corrupted}Memories of a cataclysm{}",
            "{C:ovn_corrupted}begin to resurface{}"
        }
    },
},

-------------------------

Mutation = {
    c_ovn_aplus = {
        name = 'A-Plus',
        text = {
            "{C:attention}Aces{} gain {C:mult}+#1# bonus Mult{}"
        }
    },
    c_ovn_stonks = {
        name = 'Explosive Growth',
        text = {
            "{C:ovn_mutation}Unique{}: Only usable once",
            Oblivion.sp,
            "Next {C:ovn_mutation}non-Unique Mutation{} is used",
            "{C:attention}#1#{} additional times, then banished"
        }
    }
},

-------------------------

Tag = {
    tag_ovn_corrtag = {
        name = 'Corrupted Tag',
        text = {
            "Shop has a free",
            "{C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
        }
    },
    tag_ovn_miasmatag = {
        name = 'Miasma Tag',
        text = {
            "Next base edition shop",
            "Joker is free and",
            "becomes {C:ovn_corrupted}Miasma"
        }
    },
    tag_ovn_stygiantag = {
        name = 'Stygian Tag',
        text = {
            "Gives a free",
            "{C:ovn_corrupted}Wicked Pack"
        }
    },
},

-------------------------

Voucher = {
    v_ovn_wicked_invocation = {
        name = 'Wicked Invocation',
        text = {
            "{C:ovn_corrupted}Wicked Packs {}now",
            "appear in the shop",
        }
    },
    v_ovn_call_of_the_void = {
        name = 'Call of the Void',
        text = {
            "{C:ovn_corrupted}Corrupted Jokers {}now",
            "appear in the Joker pool"
        }
    }
},

-------------------------

} }