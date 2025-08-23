local function corrupted_from(text)
	local format = "{C:inactive,s:0.8}Corrupted from{} {C:attention,s:0.8}%s{}"
	return format:format(text)
end

return {
	-- Dummy Joker; see items/5. CorruptDecks (Corrupted Plasma Deck)
	j_ovn_instabilitytooltip = {
		name = "Instability",
		text = {
			"{C:ovn_corrupted}-0.05 {}after playing a hand",
			"{C:ovn_corrupted}+0.2 {}when obtaining a {C:ovn_corrupted}Corrupted Joker",
			"{C:ovn_corrupted}+0.025 {}when obtaining an {C:ovn_optic}Optics{} card",
		}
	},
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
			corrupted_from("Joker"),
		}
	},
	j_ovn_lucasseries = {
		name = 'Lucas Series',
		text = {
			"Each played",
			"{C:attention}2, 3, 4, 7,{} or {C:attention}Ace{}",
			"gives {X:mult,C:white} X#1# {} Mult when scored",
			corrupted_from("Fibonacci"),
		}
	},
	j_ovn_perpendicular = {
		name = 'Perpendicular Parking',
		text = {
			"Scored cards earn {C:attention}$#1#{} if another",
			"card of its {C:attention}same rank{} is held in hand",
			corrupted_from("Reserved Parking"),
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
			corrupted_from("Acrobat"),
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
			corrupted_from("Gift Card"),
		}
	},
	j_ovn_pmo = {
		name = 'Prosopometamorphopsia',
		text = {
			"Effects that would target",
			"{C:attention}any face card{} target {C:attention}Aces{} instead",
			corrupted_from("Pareidolia"),
			"{s:0.3} {}",
			"{C:inactive,s:0.8}Code by Airtoum{}"
		}
	},
	j_ovn_showneverends = {
		name = 'THE SHOW NEVER ENDS',
		text = {
			"{C:ovn_corrupted}Corrupted{} {C:attention}Jokers{} no longer",
			"banish or destroy their counterparts",
			corrupted_from("Showman"),
		}
	},
	j_ovn_airstrike = {
		name = 'Air Strike',
		text = {
			"Held or unscoring {C:attention}10{}s stockpile",
			"{X:mult,C:white} X#1# {} Mult every hand played",
			"When scored, {C:attention}10{}s give their stockpiled Mult",
			"and reset their stockpile after the hand",
			corrupted_from("Walkie Talkie"),
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
			corrupted_from("Droll Joker"),
		}
	},
	j_ovn_insightful = {
		name = 'Insightful Joker',
		text = {
			"{C:chips}+#1#{} Chips if played",
			"hand contains",
			"a {C:attention}Spectrum{}",
			corrupted_from("Crafty Joker"),
		}
	},
	j_ovn_breach = {
		name = 'The Breach',
		text = {
			"{X:mult,C:white} X#1# {} Mult if played",
			"hand contains",
			"a {C:attention}Spectrum{}",
			corrupted_from("The Tribe"),
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
			corrupted_from("Cavendish"),
		}
	},
	j_ovn_apartfalling = {
		name = 'A Part Falling',
		text = {
			"This Joker gains {X:mult,C:white} X#2# {} Mult",
			"whenever a Joker {C:ovn_corrupted}corrupts{}",
			"{C:inactive}(Currently {X:mult,C:white}X#1# {C:inactive}Mult)",
			corrupted_from("Hologram"),
		}
	},
	j_ovn_aeon = {
		name = 'Aeon Cavendish',
		text = {
			"{X:mult,C:white} X#1# {} Mult",
			"{C:attention}Cavendish {}is no longer extinct",
			"and can be obtained multiple times",
			corrupted_from("Gros Michel"),
		}
	},
	j_ovn_spiral_of_addiction = {
		name = "Spiral of Addiction",
		text = {
			"This Joker gains {X:mult,C:white}X#1# {} Mult per round",
			"where {C:attention}every discard {}is used",
			"{C:inactive}(Currently {X:mult,C:white}X#2# {C:inactive}Mult)",
			"{C:red}#3# {}hand size next round if",
			"at least {C:attention}1 {}discard remains",
			corrupted_from("Drunkard"),
		}
	},
	j_ovn_collapsing_world = {
		name = "Edge of a Collapsing World",
		text = {
			"The {C:attention}rightmost and leftmost {}cards",
			"discarded in the {C:attention}final Discard",
			"of the round are {C:red}destroyed,",
			"then this Joker gains {C:mult}+#1# {}Mult",
			"{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult)",
			corrupted_from("Mystic Summit or Erosion"),
		}
	},
	j_ovn_master_of_puppets = {
		name = "Master of Puppets",
		text = {
			"When selling a {C:blue}Common{C:inactive}/{C:green}Uncommon{C:inactive}/{C:red}Rare {}Joker,",
			"a random {C:attention}Jack {}in your deck is given",
			"an {C:blue}Enhancement{C:inactive}/{C:green}Seal{C:inactive}/{C:red}Edition {}respectively",
			corrupted_from("Hit the Road"),
		}
	},
	j_ovn_infinitesimal = {
		name = "Infinitesimal Joker",
		text = {
			"{C:dark_edition}+#1#{} Joker slot",
			"This Joker gains {C:mult}+#2# {}Mult",
			"when a {C:attention}3 {}is scored",
			"{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult)",
			corrupted_from("Wee Joker"),
		}
	},
	j_ovn_migraine = {
		name = "Migraine",
		text = {
			"{C:attention}Standard Packs {}only",
			"contain modified {C:ovn_optic}Optic {}cards",
			corrupted_from("Hallucination"),
		}
	}
}