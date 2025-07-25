SMODS.ConsumableType {
	key = "Mutation",
	primary_colour = HEX("3598ef"),
	secondary_colour = HEX("318ad7"),
	loc_txt =	{
			name = 'Mutation',
			collection = 'Mutations',
			undiscovered = {
				name = 'Unknown Mutation',
				text = { '???' },
			},
	},
	collection_rows = { 8, 3 },
	shop_rate = 0.0,
}

SMODS.Consumable {
	set = "Mutation",
	name = "ovn_m_aplus",
	key = "aplus",
	config = { mult = 4 },
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.mult } }
		end,
	loc_txt = {
		name = 'A-Plus',
		text = {
				"{C:attention}Aces{} gain {C:mult}+#1# bonus Mult{}"
		}
	},
	set_badges = function(self, card, badges)
			badges[#badges+1] = create_badge("Common", G.C.BLUE, G.C.WHITE, 1.2 )
	end,
	cost = 4,
		atlas = "mutation_atlas",
	pos = { x = 1, y = 0 },
		can_use = function(self, card)
			return true
		end,
	use = function(self, card, area, copier)
		for i = 1, #G.deck.cards do
		if G.deck.cards[i].base.value == 'Ace' then
			G.deck.cards[i].ability.perma_mult = G.deck.cards[i].ability.perma_mult
			+ ((self.config.mult) * (((G.GAME.stonks or 0) + (G.GAME.rev or 0) + (G.GAME.obsession or 0))+1))
		end
		end
		for i = 1, #G.hand.cards do
		if G.hand.cards[i].base.value == 'Ace' then
			G.hand.cards[i].ability.perma_mult = G.hand.cards[i].ability.perma_mult
			+ ((self.config.mult) * (((G.GAME.stonks or 0) + (G.GAME.rev or 0) + (G.GAME.obsession or 0))+1))
		end
		end
		G.GAME.stonks = nil
		G.GAME.rev = nil
	end,
}

SMODS.Consumable {
	set = "Mutation",
	name = "ovn_m_stonks",
	key = "stonks",
	config = { more = 3 },
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.more } }
		end,
	loc_txt = {
		name = 'Explosive Growth',
		text = {
				"{C:ovn_mutation}Unique{}: Only usable once",
				"{s:0.3} {}",
				"Next {C:ovn_mutation}non-Unique Mutation{} is used",
				"{C:attention}#1#{} additional times, then banished"
		}
	},
	set_badges = function(self, card, badges)
			badges[#badges+1] = create_badge("Rare", G.C.RED, G.C.WHITE, 1.2 )
	end,
	cost = 4,
		atlas = "mutation_atlas",
	pos = { x = 2, y = 0 },
		can_use = function(self, card)
			return true
		end,
	use = function(self, card, area, copier)
		G.GAME.stonks = self.config.more
	end,
}
