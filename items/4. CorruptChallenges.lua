local function corrupt_world_deck_cards()
	local cards = {}

	local suits = {'D', 'C', 'H', 'S'}
	local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'A'}

	for _,suit in ipairs(suits) do
		for _,rank in ipairs(ranks) do
			table.insert(cards, {s=suit, r=rank})
		end
	end

	table.insert(cards, {s='ovn_O',r='A',})
	return cards
end

SMODS.Challenge{
	key = 'corrupt_world',
	rules = {
		custom = {
			{id = 'ovn_og'},
			{id = 'ovn_spacer'},
			{id = 'no_extra_hand_money'},
			{id = 'no_interest'},
			{id = 'ovn_spacer'},
			{id = 'ovn_spacer'},
			{id = 'ovn_new'},
			{id = 'ovn_spacer'},
			{id = 'ovn_world_aces'},
			{id = 'ovn_but'},
			{id = 'ovn_world_pmo'},
		},
		modifiers = { }
	},
	jokers = {
		{id = 'j_ovn_pmo', edition = 'negative', eternal = true},
		{id = 'j_business', eternal = true},
	},
	consumeables = { },
	vouchers = { },
	deck = {
		cards = corrupt_world_deck_cards(),
		type = 'Challenge Deck'
	},
	restrictions = {
		banned_cards = { },
		banned_tags = { },
		banned_other = {
			{id = 'bl_plant', type = 'blind'},
		}
	}
}
