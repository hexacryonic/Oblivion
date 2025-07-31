local calc_hook = Card.calculate_joker
function Card:calculate_joker(context)
	-- Wiggle if corruption method is found
	if Oblivion.f.joker_is_corruptible(self.key) then
		local eval = function(card) return SMODS.find_card("c_ovn_abyss") and not G.RESET_JIGGLES end
		juice_card_until(self, eval, true)
	end

	local has_pmo = next(SMODS.find_card('j_ovn_pmo')) and true or false
	local has_pareidolia = next(SMODS.find_card('j_pareidolia')) and true or false

	-- PMO functionality
	if has_pmo and (
		context.other_card
		and context.other_card.base
		and context.other_card.base.id
	) then
		local card_base = context.other_card.base
		local start_rank = has_pareidolia and 2 or 11
		local end_rank = 13

		-- Discard returned effects for Jacks, Queens, and Kings
		-- ...and 2 -> 10 if pareidolia
		if (start_rank <= card_base.id) and (card_base.id <= end_rank) then
			local initial_id = card_base.id
			local regular_calc_value = calc_hook(self, context)
			card_base.id = -1
			local aced_calc_value = calc_hook(self, context)
			card_base.id = initial_id

			print(regular_calc_value, aced_calc_value)
			
			-- one of them being nil implies a rank check
			if not (regular_calc_value ~= nil and aced_calc_value ~= nil) then
				return
			end
		end
		
		if card_base.id ~= 14 then return calc_hook(self, context) end

		-- jackify, queenify, kingify
		-- and 2ify -> 10ify if pareidolia
		for rank = start_rank, end_rank do
			card_base.id = rank
			local return_value = calc_hook(self, context)
			card_base.id = 14
			if return_value then return return_value end
		end
	end

	-- if nothing fancy applies (eg. number or ace-targeting stuff, or still nil effects) it will reach here
	return calc_hook(self, context)
end

----

local is_face_hook = Card.is_face
function Card:is_face()
	local has_pmo = next(SMODS.find_card('j_ovn_pmo')) and true or false

	-- PMO functionality
	if has_pmo then
		return self.base and self.base.id == 14 or false
	end
	
	-- If nothing else
	return is_face_hook(self)
end

----

local cardupd8_hook = Card.update
function Card:update(dt)
	if G.STAGE == G.STAGES.RUN then Oblivion.f.transmute_enhancement(self) end
	cardupd8_hook(self, dt)
end