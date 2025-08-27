return {
	m_ovn_radiant = {
		name = 'Radiant Card',
		text = {
			"While held in hand,",
			"{C:attention}scoring {}cards get bonus {C:chips}chips",
			"equal to {C:attention}this card's {C:chips}chip {}value"
		}
	},
	m_ovn_dynamo = {
		name = 'Dynamo Card',
		text = {
			"If this card is {C:attention}played {}and {C:attention}unscoring,",
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
			"{C:attention}+#1#{} hand size",
			"this round when played",
			"{C:inactive,s:0.8}(Overdraws when first visible){}"
		}
	},
}