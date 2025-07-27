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
		
		Other = {
			ovn_corruptible = {
				name = "Corruptible",
				text = {
					'This Joker has',
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
		},

		Back = {
			b_ovn_ocular = {
				name = "Ocular Deck",
				text = {
					"Start with a full set of {C:ovn_optic}Optics{}",
					"in addition to the standard deck"
				}
			},
			b_ovn_c_red = {
				name = 'Corrupt Red Deck',
				text = {
					"{C:mult}+1{} discard per round",
					"When you {C:mult}discard{}, all cards",
					"{C:attention}EXCEPT{} selected are {C:mult}discarded{}",
					"After a hand, {C:mult}discard{} up to",
					"{C:attention}5{} held cards at random"
				}
			},
			b_ovn_c_blue = {
				name = 'Corrupt Blue Deck',
				text = {
					"{C:chips}+2{} starting Hands",
					"Hands {C:mult}never reset{}",
					"{C:chips}+3{} Hands when {C:attention}Boss Blind{} defeated",
				}
			},
			b_ovn_c_yellow = {
				name = 'Corrupt Yellow Deck',
				text = {
					"+{C:money}$120{} each {C:attention}Ante{}",
					"{C:attention}Infinite{} Hands and discards,",
					"each cost {C:money}$10{} and {C:money}$5{} respectively",
					"Cost increases by {X:money,C:white} X1.25 {} (floored) each {C:attention}Ante{}",
					"{s:0.3} {}",
					"At less than {C:money}$1{}, {C:mult}Game Over{}",
				}
			},
			b_ovn_c_painted = {
				name = 'Corrupt Painted Deck',
				text = {
					"{C:attention}Enhanced{} cards retrigger once",
					"{C:attention}+5{} hand size",
					"{C:mult}Jokerless{}"
				}
			},
			b_ovn_c_plasma = {
				name = 'Corrupt Plasma Deck',
				text = {
					"{C:ovn_corrupted}Instability{} exponent operand",
					"added to score calculation",
					"{s:0.3} {}",
					"Start with {C:attention}Joker{},",
					"{C:attention}The Abyss{}, and {C:attention}Perception{}"
				}
			}
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
					'When entering Blind:',
					'Corrupt all possible Jokers and',
					'convert enhanced cards to Optics'
				}
			},
		},

		Tag = {
			tag_cry_corrtag = {
				name = 'Corrupted Tag',
				text = {
					"Shop has a free",
					"{C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
				}
			}
		},

		Enhanced = {
			m_ovn_ice = {
				name = 'Ice Card',
				text = {
					"{X:mult,C:white}X#2#{} Mult, loses {X:mult,C:white}X#1#{} Mult",
					"each time it's played",
					"Melts at {X:mult,C:white}X1{}"
				}
			},
			m_ovn_dense = {
				name = 'Tungsten Card',
				text = {
					"{C:attention}-#1#{} hand size",
					"while held in hand",
					"{C:attention}+#1#{} hand size",
					"this round when played",
					"{C:inactive,s:0.8}(Overdraws when first visible){}"
				}
			},
			m_ovn_coord = {
				name = 'Coordinate Card',
				text = {
					"Copies the rank of the",
					"card to its {C:attention}left{}",
				}
			},
			m_ovn_unob = {
				name = 'Unobtanium Card',
				text = {
					"{C:attention}Retrigger{} all scoring cards",
					"{C:attention}#1#{} time while held in hand",
					"{C:mult}Cannot be played{}",
				}
			},
		},

		Edition = {
			e_cry_miasma = {
				name = "Miasma",
				label = "Miasma",
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
					"{C:ovn_corrupted}Corrupt{} a selected {C:attention}Corruptible Joker{}"
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

		Planet = {
			c_ovn_tres = {
				name = 'TrEs-2b',
				text = {
					"{C:ovn_corrupted}The world around you{}",
					"{C:ovn_corrupted}begins to darken{}"
				}
			},
			c_ovn_reality = {
				name = "The Complete Fucking Annihilation of Reality",
				text = {
					"{S:0.8}({S:0.8,V:1}lvl.#1#{S:0.8}){} Level up",
					"{C:attention}#2#",
					"{C:mult}+#3#{} Mult and",
					"{C:chips}+#4#{} chip#<s>4#",
				},
			},
			c_ovn_optinen = {
				name = "Optinen",
				text = {
					"({V:1}lvl.#5#{})({V:2}lvl.#6#{})",
					"({V:3}lvl.#7#{})({V:4}lvl.#8#{})",
					"Level up",
					"{C:attention}#1#{},",
					"{C:attention}#2#{},",
					"{C:attention}#3#{},",
					"and {C:attention}#4#{}",
				},
			},
		},

		Spectral = {
			c_ovn_recall = {
				name = 'Recall',
				text = {
					"{C:ovn_corrupted}Memories of a cataclysm{}",
					"{C:ovn_corrupted}begin to resurface{}"
				}
			},
			c_ovn_charybdis = {
				name = 'Charybdis',
				text = {
					"Create {C:attention}#1#{} random {C:ovn_corrupted}Corrupted{} {C:attention}Jokers{}",
					"Destroy all other {C:attention}Jokers{}"
				}
			},
			c_ovn_oblivion = {
				name = 'Oblivion',
				text = {
					"Add {C:ovn_corrupted}Miasma{} {C:attention}Edition{} to",
					"{C:attention}#1#{} selected playing card or {C:attention}Joker{}"
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

		Joker = {
			j_ovn_john = {
				name = 'John Oblivion',
				text = {
					"Creates a {C:ovn_corrupted}Corrupted{} {C:attention}Joker{}",
					"when sold"
				}
			},
			j_ovn_darkjoker = {
				name = 'Parallel Joker',
				text = {
					"{C:chips}+#1#{} Chips",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Joker{}"
				}
			},
			j_ovn_lucasseries = {
				name = 'Lucas Series',
				text = {
					"Each played",
					"{C:attention}2, 3, 4, 7,{} or {C:attention}Ace{}",
					"gives {X:mult,C:white} X#1# {} Mult when scored",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Fibonacci{}"
				}
			},
			j_ovn_perpendicular = {
				name = 'Perpendicular Parking',
				text = {
					"Scored cards earn {C:attention}$#1#{} if another",
					"card of its {C:attention}same rank{} is held in hand",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Reserved Parking{}"
				}
			},
			j_ovn_yolo = {
				name = 'Fuck It, We Ball',
				text = {
					"Each played card gives",
					"{X:mult,C:white} X#1# {} Mult when scored",
					"{s:0.3} {}",
					"{C:chips}-a fucktillion{} Hands",
					"when hand played",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Acrobat{}"
				}
			},
			j_ovn_supplydrop = {
				name = 'Supply Drop',
				text = {
					"Sell this Joker to {C:attention}store{} the",
					"Joker to its left, if its rarity",
					"is not higher than {C:red}Rare{}",
					"{s:0.3} {}",

					"When this Joker is sold",
					"again, even between runs,",
					"create the stored Joker",
					"and remove it from storage",
					"{s:0.3} {}",
					"{s:0.8}Currently storing: {C:attention,s:0.8}#1#",
					"{s:0.2} {}",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Gift Card{}"
				}
			},
			j_ovn_pmo = {
				name = 'Prosopometamorphopsia',
				text = {
					"Effects that would target",
					"{C:attention}any face card{} target {C:attention}Aces{} instead",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Pareidolia{}",
					"{s:0.3} {}",
					"{C:inactive,s:0.8}Code by Airtoum{}"
				}
			},
			j_ovn_showneverends = {
				name = 'THE SHOW NEVER ENDS',
				text = {
					"{C:ovn_corrupted}Corrupted{} {C:attention}Jokers{} no longer",
					"banish or destroy their counterparts",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Showman{}"
				}
			},
			j_ovn_airstrike = {
				name = 'Air Strike',
				text = {
					"Held or unscoring {C:attention}10{}s stockpile",
					"{X:mult,C:white} X#1# {} Mult every hand played",
					"When scored, {C:attention}10{}s give their stockpiled Mult",
					"and reset their stockpile after the hand",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Walkie Talkie{}",
					"{s:0.3} {}",
					"{C:inactive,s:0.8}Art by Andromeda{}"
				}
			},
			j_ovn_bombastic = {
				name = 'Bombastic Joker',
				text = {
					"{C:mult}+#1#{} Mult if played",
					"hand contains",
					"a {C:attention}Spectrum{}",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Droll Joker{}",
				}
			},
			j_ovn_insightful = {
				name = 'Insightful Joker',
				text = {
					"{C:chips}+#1#{} Chips if played",
					"hand contains",
					"a {C:attention}Spectrum{}",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Crafty Joker{}",
				}
			},
			j_ovn_breach = {
				name = 'The Breach',
				text = {
					"{X:mult,C:white} X#1# {} Mult if played",
					"hand contains",
					"a {C:attention}Spectrum{}",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}The Tribe{}",
				}
			},
			j_ovn_prideful = {
				name = 'Prideful Joker',
				text = {
					"Played cards with {C:ovn_optic}Optic{} suit",
					"give {C:mult}+#1#{} Mult when scored",
					"{C:inactive,s:0.8}Corrupted from the{} {C:attention,s:0.8}Sinful Jokers{}"
				}
			},
			j_ovn_cultivar = {
				name = 'Theoretical Cultivar',
				text = {
					"{X:mult,C:white} X#1# {} Mult",
					"{C:green}#2# in #3#{} chance this",
					"card is destroyed",
					"at end of round",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Cavendish{}",
				}
			},
			j_ovn_apartfalling = {
				name = 'A Part Falling',
				text = {
					"This Joker gains {X:mult,C:white} X#2# {} Mult",
					"whenever a Joker {C:ovn_corrupted}corrupts{}",
					"{C:inactive}Currently{} {X:mult,C:white} X#1# {}",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Hologram{}",
				}
			},
			j_ovn_aeon = {
				name = 'Aeon Cavendish',
				text = {
					"{X:mult,C:white} X#1# {} Mult",
					"{C:green}#2# in #3#{} chance this",
					"card is destroyed",
					"at end of round",
					"{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}Cavendish{}",
				}
			}
		},
	},

	misc = {
		dictionary = {
			stored = "Stored!",
			empty = "Emptied!",
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