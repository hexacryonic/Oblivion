return {
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
		},
		unlock = {
			"On {C:attention}Red {}Deck with",
			"{C:blue}Blue Stake {}or higher,",
			"win without discarding whilst",
			"holding {C:attention}Spiral of Addiction"
		}
	},
	b_ovn_c_blue = {
		name = 'Corrupt Blue Deck',
		text = {
			"{C:chips}+2{} starting Hands",
			"Hands {C:mult}never reset{}",
			"{C:chips}+3{} Hands when {C:attention}Boss Blind{} defeated",
		},
		unlock = {
			"On {C:attention}Blue {}Deck with",
			"{C:blue}Blue Stake {}or higher,",
			"win whilst having beaten",
			"every played blind in 1 hand"
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
		},
		unlock = {
			"On {C:attention}Yellow {}Deck with",
			"{C:blue}Blue Stake {}or higher,",
			"with at least {C:money}$365 {}in bank",
		}
	},
	b_ovn_c_ghost = {
		name = 'Corrupt Ghost Deck',
		text = {
			"{C:spectral}Spectral {}cards frequently",
			"appear in the shop",
			"When starting a round, a {C:attention}random",
			"{C:spectral}Spectral {}card is used against you"
		},
		unlock = {
			"On {C:attention}Ghost {}Deck with",
			"{C:blue}Blue Stake {}or higher,",
			"win without using",
			"any {C:spectral}Spectral {}cards,"
		}
	},
	b_ovn_c_painted = {
		name = 'Corrupt Painted Deck',
		text = {
			"{C:attention}Enhanced{} cards retrigger once",
			"{C:attention}+5{} hand size",
			"{C:mult}Jokerless{}"
		},
		unlock = {
			"On {C:attention}Painted {}Deck with",
			"{C:blue}Blue Stake {}or higher,",
			"win whilst holding {C:attention}7",
			"or more Jokers at once"
		}
	},
	b_ovn_c_plasma = {
		name = 'Corrupt Plasma Deck',
		text = {
			"{C:ovn_corrupted,T:j_ovn_instabilitytooltip}#1#{} exponent operand",
			"added to score calculation",
			"{s:0.3} {}",
			"Start with {C:attention,T:j_joker}#2#{},",
			"{C:attention,T:c_ovn_abyss}#3#{}, and {C:attention,T:c_ovn_perception}#4#{}"
		},
		unlock = {
			"{s:0.9}On {s:0.9,C:attention}Plasma {s:0.9}Deck with",
			"{s:0.9,C:blue}Blue Stake {s:0.9}or higher,",
			"{s:0.9}win with a score at least",
			"{s:0.9,C:attention}20 {s:0.9}times greater than",
			"{s:0.9}the Showdown Boss",
			"{s:0.9}Blind requirement"
		}
	}
}