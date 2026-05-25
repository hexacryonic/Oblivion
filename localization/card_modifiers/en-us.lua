return {

--------

    descriptions = {
        Enhanced =  {
            m_ovn_radiant = {
                name = 'Radiant Card',
                text = {
                    "While held in hand,",
                    "{C:attention}scoring {}cards get",
                    "bonus {C:chips}chips equal to",
                    "{C:attention}this card's {C:chips}chip {}value"
                }
            },
            m_ovn_dynamo = {
                name = 'Dynamo Card',
                text = {
                    "If this card is",
                    "{C:attention}played {}and {C:attention}unscoring,",
                    "scored cards give {C:mult}+#1# {}Mult"
                }
            },
            m_ovn_coord = {
                name = 'Coordinate Card',
                text = {
                    "Copies the rank of the",
                    "card to its {C:attention}left{}",
                }
            },
            m_ovn_ice = {
                name = 'Ice Card',
                text = {
                    "{X:mult,C:white}X#2#{} Mult, loses {X:mult,C:white}X#1#{} Mult",
                    "each time it's played",
                    "Melts at {X:mult,C:white}X1{}"
                }
            },
            m_ovn_unob = {
                name = 'Unobtanium Card',
                text = {
                    "{C:attention}Retrigger{} all scoring cards",
                    "{C:attention}#1#{} time while held in hand",
                    "{S:1.1,C:red,E:2}Cannot be played{}",
                }
            },
            m_ovn_crystal = {
                name = 'Crystal Card',
                text = {
                    "{S:1.1,C:red,E:2}Never scores",
                    "{C:planet}Levels up {}played {C:attention}Poker Hand",
                    "{C:red}Shatters {}after being",
                    "played {C:attention}#1# {}times"
                }
            },
            m_ovn_dense = {
                name = 'Tungsten Card',
                text = {
                    "{C:attention}-#1#{} hand size",
                    "while held in hand",
                    "{C:attention}+#2#{} hand size",
                    "this round when played",
                }
            },
            m_ovn_ion = {
                name = 'Ion Card',
                text = {
                    "{C:green}-#1#%{} blind requirement",
                    "{C:green}#2# in #3# {}chance for",
                    "{C:red}+#4#% {}blind requirement instead"
                }
            }
        },

--------

        Edition = {
			e_ovn_miasma = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} thrice,",
					"then {C:ovn_corrupted}corrupts{} if possible,",
					"otherwise {S:1.1,C:red,E:2}self-destructs{}",
					Oblivion.sp,
					"{C:ovn_corrupted}Corrupt {}Jokers or {C:ovn_corrupted}Optic",
					"cards {C:attention}retrigger {}once",
					"and do {C:attention}not {}self-destruct"
				}
			},
			e_ovn_miasma_corrupted = {
				name = "Miasma",
				text = {"{C:attention}Retriggers{} once"}
			},
			e_ovn_miasma_recursive_corrupt = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} once,",
					"then {C:ovn_corrupted}corrupts{}",
				}
			},
			e_ovn_miasma_playing_card = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} thrice,",
					"then {C:ovn_corrupted}corrupts{} into {C:ovn_optic}Optics",
				}
			},
			e_ovn_miasma_corruptible_joker = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} thrice,",
					"then {C:ovn_corrupted}corrupts{}",
				}
			},
			e_ovn_miasma_destroy = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} thrice,",
					"then {S:1.1,C:red,E:2}self-destructs{}",
				}
			}
		},

--------

        Other = {
			ovn_indigo_seal = {
				name = "Indigo Seal",
				text = {
					"Creates a {C:spectral}Spectral {}card",
					"when a Joker is {C:ovn_corrupted}corrupted{}",
					"while this card is visible",
                    "{C:inactive}(Must have room)",
				}
			},
			ovn_ruby_mark_seal = {
				name = "Mark of Ruby",
				text = {
					"{S:1.1,C:red,E:2}Never scores",
					"All cards retrigger {C:attention}#1# {}times,",
					"then {S:1.1,C:red,E:2}self-destructs"
				}
			},
			ovn_sapphire_mark_seal = {
				name = "Mark of Sapphire",
				text = {
					"If {C:attention}sole {}played card,",
					"upgrade {C:attention}every {}poker hand",
					"{C:attention}contained in held hand{},",
					"then {S:1.1,C:red,E:2}self-destructs"
				}
			},
			ovn_citrine_mark_seal = {
				name = "Mark of Citrine",
				text = {
					"When scored:",
					"Gain {C:money}$#1# {}per card",
					"in {C:attention}deck {}with a {C:attention}Seal",
					"Gain {C:money}$#2# {}per card",
					"in {C:attention}deck {}with a {C:ovn_corrupted}Mark,",
					"then {S:1.1,C:red,E:2}self-destructs"
				}
			},
			ovn_amethyst_mark_seal = {
				name = "Mark of Amethyst",
				text = {
					"When scored, create a",
					"{C:spectral}Negative {C:attention}#1#",
					"then {S:1.1,C:red,E:2}self-destructs"
				}
			},
			ovn_iolite_mark_seal = {
				name = "Mark of Iolite",
				text = {
					"When held in hand",
					"and using a {C:spectral}Spectral {}card,",
					"create a {C:dark_edition}Negative {}copy",
					"of that {C:spectral}Spectral {}card,",
					"then {S:1.1,C:red,E:2}self-destructs"
				}
			},
        }
    },

--------

    misc = {
        labels = {
            ovn_miasma = "Miasma",
            ovn_indigo_seal = "Indigo Seal",
            ovn_ruby_mark_seal = "Mark of Ruby",
            ovn_sapphire_mark_seal = "Mark of Sapphire",
            ovn_citrine_mark_seal = "Mark of Citrine",
            ovn_amethyst_mark_seal = "Mark of Amethyst",
            ovn_iolite_mark_seal = "Mark of Iolite",
        },
        dictionary = {
			ovn_ion_zap = "Zap!",
			ovn_ion_misfire = "...",
        }
    },

}