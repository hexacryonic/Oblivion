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

local __sp__ = "{s:0.3} "

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

		DescriptionDummy = {
			-- DescriptionDummies are used for custom UI infoqueue boxes and deck hover-text tooltips
			dd_ovn_credits = {
				name = "Credits",
				text = {""},
				-- this is just here for rapid reference
				labels = {
					art = "Art",
					code = "Code",
					concept = "Concept",
					shader = "Shader",
					sound = "Sounds",
					music = "Music"
				}
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
				name = {"Thank you for", "installing {C:ovn_corrupted}Oblivion{}!"},
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
			ovn_opticinfo = {
				name = "Optic Suit",
				text = {
					'Doubles base chips and',
					'{C:ovn_corrupted}transforms{} modifiers',
					'into {C:ovn_corrupted}unique{} versions',
				},
			},
			ovn_library_of_babel_last_played = {
				name = "Current hand last played",
				text = {
					"{C:attention}#1# {}last played",
					"{C:attention}#2# {}hands ago"
				}
			},
			ovn_library_of_babel_last_played_never = {
				name = "Current hand last played",
				text = {
					"{C:attention}#1# {}never played",
					"(not within last {C:attention}#2# {}hands)"
				}
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

		Edition = {
			e_ovn_miasma = {
				name = "Miasma",
				text = {
					"{C:attention}Retriggers{} thrice,",
					"then {C:ovn_corrupted}corrupts{} if possible,",
					"otherwise {S:1.1,C:red,E:2}self-destructs{}",
					__sp__,
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
					__sp__,
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
				name = 'Stygian Tag',
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
					"appear in the Joker pool"
				}
			}
		},
	},

	misc = {
		labels = {
			ovn_miasma = "Miasma",
				-- Developer's note: Corrupted and Supercorrupted are superficially equivalent, hence they should have the same text
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
			ovn_indigo_seal = "Indigo Seal",
			ovn_ruby_mark_seal = "Mark of Ruby",
			ovn_sapphire_mark_seal = "Mark of Sapphire",
			ovn_citrine_mark_seal = "Mark of Citrine",
			ovn_amethyst_mark_seal = "Mark of Amethyst",
			ovn_iolite_mark_seal = "Mark of Iolite",
		},
		dictionary = {
			stored = "Stored!",
			empty = "Emptied!",
			k_ovn_corrupted = "Corrupted",
			k_ovn_supercorrupted = "Corrupted",
			k_ovn_wicked_pack = "Wicked Pack",
			ovn_ion_zap = "Zap!",
			ovn_ion_misfire = "...",
			k_primary_contributors = "Primary contributors",
			k_additional_credits = "Additional credits",
			k_sources = "Sources",
				-- Developer's note: This will be formatted like (ovn_corrupted_from .. 'X, X, or X') -> "Corrupted from X, X, or X"
			ovn_corrupted_from = "Corrupted from",
				-- Developer's note: "Datcard" is a portmanteau of "dat" and "discard", i.e. "dis and dat", "this and that"
			b_ovn_datcard = "Datcard",

			-- Used in Master of Puppets desc
			k_enhancement = "Enhancement",
			k_seal = "Seal",
			k_ovn_other_rarity = "(other)",
			k_ovn_random_modifier = "(random)",

			k_toggle = "Toggle",
			k_name = "Name",
			k_description = "Description",
		},
		v_dictionary = {
			a_hands_minus = "-#1# Hands",
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
			}
		},
			-- Developer's note: Corrupt Challenge names are based on vanilla challenges; localization should try to reflect such to the best of one's ability
			-- E.g. The Omlette -> Corrupt Omlette
			-- E.g. On a Knife's Edge -> Corrupt Edge
			-- Exceptions will be noted as the rest of the challenges are implemented
		challenge_names = {
			c_ovn_corrupt_omelette = "Corrupt Omlette",
			c_ovn_corrupt_edge = "Corrupt Edge",
			c_ovn_corrupt_world = "Corrupt World",
				-- EXCEPTION - Perishable Sticker -> Eternal Sticker
			c_ovn_corrupt_eternity = "Corrupt Eternity",
				-- partial EXCEPTION - "Five-Card" -> "Quintet"
			c_ovn_corrupt_quintet = "Corrupt Quintet"
		},
		v_text = {
			ch_c_ovn_og = { "{C:attention,s:1.5}Original Rules:{}" },
			ch_c_ovn_new = { "{C:ovn_corrupted,s:1.5}Changes:{}" },
			ch_c_ovn_but = { "{C:ovn_corrupted,s:1.3}BUT{}" },
			ch_c_ovn_spacer = { __sp__ },
			ovn_corrupt_challenge = { "" }, -- Leave blank

			-- Corrupt Omelette
			ch_c_ovn_egg_all_eggs = { "WHY ARE THERE {C:dark_edition}SO MANY {C:attention}EGGS" },
			ch_c_ovn_egg_eternal_egg = { "A random {C:attention}Egg {}becomes {C:eternal}Eternal {}after each round" },
				-- Developer's note: Note "motherfuckler", a forced rhyme between "Swashbuckler" (Joker) and "motherfuckler"
			ch_c_ovn_egg_no_swashbuckler = { "DON'T EVEN THINK ABOUT USING {C:attention}SWASHBUCKLER {}YOU MOTHERFUCKLER" },

			-- Corrupt Edge
			ch_c_ovn_edge_foil = { "The {C:attention}Ceremonial Dagger{} is now {C:dark_edition}Foil{}" },
				-- Developer's note: A play on the challenge name "On a Knife's Edge", referring to the removal of the space not targetted by Ceremonial Dagger
			ch_c_ovn_edge_knife = { "There is no edge, only knife" },

			-- Corrupt World
			ch_c_ovn_world_aces = { "You have an {C:attention}Ace{} of each suit" },
				-- Developer's note: Refers to the Joker
			ch_c_ovn_world_pmo = { "{C:ovn_corrupted}Prosopometamorphopsia{}" },

			-- Corrupt Eternity
			ch_c_ovn_all_eternal = G.localization.misc.v_text.ch_c_all_eternal, -- duplicate to prevent eternals from occurring
			ch_c_ovn_eternal_none_eternal = { "All Jokers are no longer {C:eternal}Eternal{}" },
				-- Developer's note: Should reference the Perishable Sticker, if possible
			ch_c_ovn_eternal_extra_perishable = { "Extra {C:perishable}Perishable" },

			-- Corrupt Quintet
			ch_c_ovn_quintet_jokerslot = { "{C:attention}+1 {}Joker slot" },
			ch_c_ovn_quintet_discard = { "{C:attention}+1 {}more discard per round" },
			ch_c_ovn_quintet_addiction = { "The addiction has a heavy grip on your life" },
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
			["ovn_Royal Spectrum"] = "Royal Spectrum",
			["ovn_Spectrum House"] = "Spectrum House",
			["ovn_Spectrum Five"] = "Spectrum Five",
			["ovn_5DDeck"] = "5D Fucking Deck With Multiverse Time Travel",
		},
		poker_hand_descriptions = {
			["ovn_Spectrum"] = {
				"5 cards with 5 different suits"
			},
			["ovn_Straight Spectrum"] = {
				"A Straight and a Spectrum together"
			},
			["ovn_Royal Spectrum"] = {
				"A Straight and a Spectrum together"
			},
			["ovn_Spectrum House"] = {
				"A Full House and a Spectrum together"
			},
			["ovn_Spectrum Five"] = {
				"A Spectrum with all 5 cards of the same rank"
			},
			["ovn_5DDeck"] = {
				"A hand that contains every single",
				"card found in a 52-card deck, plus",
				"an entire full set of Optics",
				" ",
				"What the actual fuck is wrong with you?",
			}
		},
			-- Developer's note: Please only translate the second and third item of each tuple
		credits = {
			{"HexaCryonic", {"Creator", "Lead Developer"}},
			{"Oinite", {"Developer", "Artist"}},
			{"Lil Mr. Slipstream", "Artist"},
		},
		credits_additional = {
			{"thaun0",         "Concept",  "Database"},
			{"Zero (null)",    "Concept",  "A Part Falling"},
			{"SyntaxTsundere", "Concept",  "THE SHOW NEVER ENDS"},
			{"AlexZGreat",     "Concepts", {"Master of Puppets", "Coordinate Cards"}},
			{"Inspector_Bee",  "Concepts", {"Corrupt Yellow Deck", "Cigarette Card"}},
			{"NinjaBanana",    "Concepts", {"Library of Babel", "Event Horizon"}},
			{"QueenChloe",     "Concepts", {"Mark of Amethyst", "Philosopher's Stone"}},
			{"Andromeda",      "Art",      {"Airstrike", "Sludge"}},
			{"cassknows",      "Shader",   "Miasma"},
			{"Airtoum",        "Code",     "Prosopometamorphopsia"},
			{"Lily",           "Code",     "Corrupt Erratic Deck (initial)"},
			{"MathIsFun_",     "Code",     "Corrupt Plasma Deck (initial)"},
		},
		credits_long = {
			"Corrupt Deck music composed by {C:blue}HexaCryonic",
			"",
			'Music used by A Part Falling is "A Part Falling",',
			"composed by {C:red}Hakita {}for {C:hearts}ULTRAKILL",
			"",
			"Sounds for Miasma, instability decrease,",
			"and part of instability increase are",
			"by the {C:attention}PONOS Corporation {}for {C:purple}The Battle {C:attention}Cats",
			"",
			"Sounds for Ion Cards, instability increase,",
			"Joker corruption, Optics, and purification are",
			"made by {C:blue}HexaCryonic {}using sounds from {C:green}Pixabay",
			"",
			"Code for counting repetitions from card modifiers",
			"used from {C:attention}Paperback {}(mod),",
			"which is under the MIT License",
		},
	},
}

Ovn_f.compile_localization(loc, "en-us")
return loc
