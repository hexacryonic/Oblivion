local lc = loc_colour
function loc_colour(_c, _default)
	if not G.ARGS.LOC_COLOURS then lc() end

	local loc_c = G.ARGS.LOC_COLOURS
	loc_c.ovn_corrupted = G.C.RARITY['ovn_corrupted']
	loc_c.ovn_corrupt2  = HEX('001764')
	loc_c.ovn_corrupt1  = HEX('04248f')
	loc_c.ovn_mutation  = G.C.SET.Mutation
	loc_c.heart         = G.C.SUITS.Hearts
	loc_c.diamond       = G.C.SUITS.Diamonds
	loc_c.spade         = G.C.SUITS.Spades
	loc_c.club          = G.C.SUITS.Clubs
	loc_c.ovn_optic     = G.C.SUITS.ovn_Optics

	return lc(_c, _default)
end