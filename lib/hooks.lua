local corrupted_mod_calc_joker_func = Card.calculate_joker
function Card:calculate_joker(context) -- PMO rank redirection
	local has_pmo = next(SMODS.find_card('j_ovn_pmo')) and true or false
	local has_pareidolia = next(SMODS.find_card('j_pareidolia')) and true or false

	if not has_pmo then
		return corrupted_mod_calc_joker_func(self, context)
	end

	local discard_list = {
		[1] = false,
		[2] = has_pareidolia,
		[3] = has_pareidolia,
		[4] = has_pareidolia,
		[5] = has_pareidolia,
		[6] = has_pareidolia,
		[7] = has_pareidolia,
		[8] = has_pareidolia,
		[9] = has_pareidolia,
		[10]= has_pareidolia,
		[11]=true,
		[12]=true,
		[13]=true
	}
	local is_discarded = (
		context.other_card
		and context.other_card.base
		and discard_list[context.other_card.base.id]
	)

	-- Discard returned effects for Jacks, Queens, and Kings!
	if is_discarded then return nil end
	local return_value = corrupted_mod_calc_joker_func(self, context)

	if not (
		not return_value
		and context.other_card
		and context.other_card.base
		and context.other_card.base.id == 14
	) then return return_value end

	-- jackify, queenify, kingify
	-- and 2ify -> 10ify if pareidolia
	local start_rank = has_pareidolia and 2 or 11
	local end_rank = 13
	for rank = start_rank, end_rank do
		context.other_card.base.id = rank
		return_value = corrupted_mod_calc_joker_func(self, context)
		context.other_card.base.id = 14
		if return_value then return return_value end
	end

	-- if nothing fancy applies (eg. number or ace-targeting stuff, or still nil effects) it will reach here
	return return_value
end