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

local loc =  {
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

		Other = {
			ovn_corruptible = {
				name = "Corruptible",
				text = {
					'#1# has',
					'{C:ovn_corrupted}corruption potential{}',
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
			ovn_indigo_seal = {
				name = "Indigo Seal",
				text = {
					"Creates a {C:spectral}Spectral {}card",
					"when a Joker is {C:ovn_corrupted}corrupted{}",
					"while this card is visible",
                    "{C:inactive}(Must have room)",
				}
			},
			p_ovn_wicked_normal_1 = macro.p_ovn_wicked_normal,
			p_ovn_wicked_normal_2 = macro.p_ovn_wicked_normal,
			p_ovn_wicked_normal_3 = macro.p_ovn_wicked_normal
		},

		Edition = {
			e_ovn_miasma = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} in scoring thrice, then {C:ovn_corrupted}corrupts{}",
					"if possible, otherwise {C:mult}self-destructs{}"
				}
			}
		},

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
					"to {C:ovn_optic}Optics{}"
				}
			}
		},
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
					"{s:0.3} {}",
					"Next {C:ovn_mutation}non-Unique Mutation{} is used",
					"{C:attention}#1#{} additional times, then banished"
				}
			}
		},
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
				name = 'Styigan Tag',
				text = {
					"Gives a free",
					"{C:ovn_corrupted}Wicked Pack"
				}
			},
		},
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
					"appear in the shop"
				}
			}
		}
	},

	misc = {
		labels = {
			ovn_miasma = "Miasma",
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
			ovn_indigo_seal = "Indigo Seal"
		},
		dictionary = {
			stored = "Stored!",
			empty = "Emptied!",
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
			k_ovn_wicked_pack = "Wicked Pack",
		},
		challenge_names = {
			c_ovn_corrupt_world = "Corrupt World",
		},
		v_text = {
			ch_c_ovn_og = { "{C:attention,s:1.5}Original Rules:{}" },
			ch_c_ovn_new = { "{C:ovn_corrupted,s:1.5}New Rules:{}" },
			ch_c_ovn_but = { "{C:ovn_corrupted,s:1.3}BUT{}" },
			ch_c_ovn_spacer = { "{s:0.3} {}" },
			ch_c_ovn_world_aces = { "You have an {C:attention}Ace{} of each suit" },
			ch_c_ovn_world_pmo = { "{C:ovn_corrupted}Prosopometamorphopsia{}" },
		},
		suits_singular = {
			ovn_Optics = "Optic"
		},
		suits_plural = {
			ovn_Optics = "Optics"
		},
		poker_hands = {
			["ovn_Spectrum"] = "Spectrum",
			["ovn_Straight Spectrum"] = "Straight Spectrum",
			["ovn_Spectrum House"] = "Spectrum House",
			["ovn_Spectrum Five"] = "Spectrum Five",
			["ovn_5DDeck"] = "5D Fucking Deck With Multiverse Time Travel",
		},
		poker_hand_descriptions = {
			["ovn_Spectrum"] = {
				"5 cards with 5 different suits."
			},
			["ovn_Straight Spectrum"] = {
				"A Straight and a Spectrum together."
			},
			["ovn_Spectrum House"] = {
				"A Full House and a Spectrum together."
			},
			["ovn_Spectrum Five"] = {
				"A Spectrum with all 5 cards of the same rank."
			},
		}
	},
}

Ovn_f.compile_localization(loc, "en-us")
return loc