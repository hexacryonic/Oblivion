local macro = {
	p_ovn_wicked_normal = {
		name = "Wicked Pack",
		text = {
			"Choose {C:attention}#1# {}of up to {C:attention}#2#",
			"{C:ovn_corrupted}Corrupted {C:joker}Joker {}cards",
			"or a {C:attention}#3#"
		}
	}
}

return {
    descriptions = {
		Mod = {
			Oblivion = {
				name = "Oblivion",
				text = {
					'An expansion to Balatro themed around an',
					'{C:ovn_corrupted}otherworldly corruption{}!',
					' ',
					'Use many new {C:ovn_corrupted}Corrupted Jokers{},',
					'which act as sidegrades to existing Jokers.',
					' ',
					'Discover the special {C:ovn_optic}Optics{} suit that twists Enhancements',
					'and Seals, featuring the {C:ovn_optic}Spectrum{} hand types.',
					' ',
					'Test your mettle in {C:ovn_corrupted}Corrupt Challenges{}, buffed',
					'versions of the 20 vanilla challenges for the truly daring.',
					' ',
					'{C:ovn_corrupted}Corrupt Decks{} bend the rules of existing decks',
					'for a more uniquely challenging experience.',
					' ',
					'{C:mult,s:1.5}[[REDACTED]]{}',
					' ',
					'And more!',
				},
			},
		},

		DescriptionDummy = {
			-- DescriptionDummies are used for custom UI infoqueue boxes and deck hover-text tooltips
			dd_ovn_credits = {
				name = "Credits",
				text = {""},
			},
			dd_ovn_instability_description = {
				name = "Instability",
				text = {
					"{C:ovn_corrupted}-0.05{} after playing a hand",
					"{C:ovn_corrupted}+0.2{} when obtaining a {C:ovn_corrupted}Corrupted Joker",
					"{C:ovn_corrupted}+0.025{} when obtaining an {C:ovn_optic}Optics {}card",
				}
			},
		},

		Other = {
			ovn_first_install_notif = {
				name = {
					"Thank you for",
					"installing {C:ovn_corrupted}Oblivion{}!"
				},
				text = {
					"{C:attention}Credits {}can be found",
					"in the {C:attention}Collection{},",
					"and {C:attention}configuration {}can be found",
					"in {C:attention}Mods > Oblivion > Config{}."
				}
			},
			ovn_corruptible = {
				name = "Corruptible",
				text = {
					'#1# has',
					'{C:ovn_corrupted}corruption potential{}',
				},
			},
			ovn_almost_corruptible = {
				name = "Corruptible",
				text = {
					"{C:ovn_corrupted}The Abyss {}shows interest",
					"in this Joker... But it",
					"needs {C:ovn_corrupted}something more{}."
				},
			},
			ovn_opticinfo = {
				name = "Optic Suit",
				text = {
					'Doubles base chips and',
					'{C:ovn_corrupted}transforms{} modifiers',
					'into {C:ovn_corrupted}unique{} versions',
				},
			},
			ovn_placeholder_sprite = {
				name = "Placeholder sprite",
				text = {
					"This card's sprite",
					"is a {S:1.1,C:attention,E:2}placeholder{};",
					"a proper sprite will",
					"be created {C:blue}later."
				}
			},
			p_ovn_wicked_normal_1 = macro.p_ovn_wicked_normal,
			p_ovn_wicked_normal_2 = macro.p_ovn_wicked_normal,
			p_ovn_wicked_normal_3 = macro.p_ovn_wicked_normal,
			p_ovn_wicked_normal_4 = macro.p_ovn_wicked_normal,
		},

		Blind = {
			bl_ovn_nerve = {
				name = 'The Nerve',
				text = {
					'All Optic cards',
					'are debuffed'
				}
			},
			bl_ovn_purity = {
				name = 'The Purity',
				text = {
					'When defeated or disabled:',
					'Purify all Corrupted Jokers',
					'if any hands remain'
				}
			},
			bl_ovn_stygian = {
				name = 'Stygian Sigil',
				text = {
					'-1 card selection limit',
					'per Corrupted Joker owned',
					'upon entry (min. -4)'
				}
			},
		},
    },

    misc = {
		labels = {
				-- Developer's note: Corrupted and Supercorrupted are superficially equivalent, hence they should have the same text
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
		},

		dictionary = {
			b_ovn_switch = "SWITCH",
			b_ovn_store = "STORE",
			b_ovn_empty = "EMPTY",
			stored = "Stored!",
			empty = "Emptied!",
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
			k_ovn_wicked_pack = "Wicked Pack",
			k_primary_contributors = "Primary contributors",
			k_additional_credits = "Additional credits",
			k_sources = "Sources",
				-- Developer's note: This will be formatted like (ovn_corrupted_from .. 'X, X, or X') -> "Corrupted from X, X, or X"
			ovn_corrupted_from = "Corrupted from",
				-- Developer's note: "Datcard" is a portmanteau of "dat" and "discard", i.e. "dis and dat", "this and that"
			b_ovn_datcard = "Datcard",

			k_toggle = "Toggle",
			k_name = "Name",
			k_description = "Description",

			k_ovn_c_erratic_warn_1 = "Are you sure? Select again to confirm",
			k_ovn_c_erratic_warn_2 = "Are you REALLY sure? Select again to confirm",
			k_ovn_c_erratic_warn_3 = "I warned you. Select again to confirm",
		},

		v_dictionary = {
			a_hands_minus = "-#1# Hands",
			remaining_hand_money_i = "Remaining Hands ($#1#i each)",
			remaining_discard_money_i = "Remaining Discards ($#1#i each)",
			interest_i = "#1#i interest per $#2#i (#3#i max)",
		},

		config = {
			ovn_family_friendly = {
				name = "Family friendly mode",
				text = {
					"Removes vulgar and",
					"suggestive language."
				}
			},
			ovn_disable_c_erratic_shader = {
				name = {
					"Reduce Corrupt",
					"Erratic visuals"
				},
				text = {
					"Removes the glitch/matrix shader,",
					"and slows down glitched text.",
					"(Reduced motion also enables this)"
				}
			},
			ovn_disable_c_erratic_warning = {
				name = {
					"Disable Corrupt",
					"Erratic play warning"
				},
				text = {
					"Disables the extra click",
					"to play the deck."
				}
			},
			ovn_disable_a_part_falling_music = {
				name = {
					"Disable A Part",
					"Falling music"
				},
				text = {
					"(The music is",
					"stream-friendly!)"
				}
			}
		},

		suits_singular = {
			ovn_Optics = "Optic"
		},
		suits_plural = {
			ovn_Optics = "Optics"
		},
    }
}