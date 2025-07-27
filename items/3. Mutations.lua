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
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.mult } }
	end,
	config = { mult = 4 },

	set_badges = function(self, card, badges)
			badges[#badges+1] = create_badge("Common", G.C.BLUE, G.C.WHITE, 1.2 )
	end,

	atlas = "mutation_atlas",
	pos = { x = 1, y = 0 },

	cost = 4,

	can_use = function(self, card) return true end,

	use = function(self, card, area, copier)
		local function boost_aces(card_area)
			for _,curr_card in ipairs(card_area) do
				if curr_card.base.value ~= 'Ace' then goto continue_boost_aces end

				local current_perma_mult = curr_card.ability.perma_mult
				local multiplier = self.config.mult
				local stonks = G.GAME.stonks or 0
				local rev = G.GAME.rev or 0
				local obsession = G.GAME.obsession or 0

				curr_card.ability.perma_mult = current_perma_mult + multiplier*((stonks + rev + obsession) + 1)

				::continue_boost_aces::
			end
		end

		boost_aces(G.deck.cards) -- D for Deck
		boost_aces(G.hand.cards) -- H for Hand

		G.GAME.stonks = nil
		G.GAME.rev = nil
	end,
}

SMODS.Consumable {
	set = "Mutation",
	name = "ovn_m_stonks",
	key = "stonks",
	loc_vars = function(self, info_queue, card)
		return { vars = { self.config.more } }
		end,
	config = { more = 3 },

	set_badges = function(self, card, badges)
			badges[#badges+1] = create_badge("Rare", G.C.RED, G.C.WHITE, 1.2 )
	end,

	atlas = "mutation_atlas",
	pos = { x = 2, y = 0 },

	cost = 4,

	can_use = function(self, card) return true end,
	use = function(self, card, area, copier) G.GAME.stonks = self.config.more end,
}
