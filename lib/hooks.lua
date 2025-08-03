local calc_hook = Card.calculate_joker
function Card:calculate_joker(context)
	-- Wiggle if corruption method is found
	if Ovn_f.joker_is_corruptible(self.key) then
		local eval = function(card) return SMODS.find_card("c_ovn_abyss") and not G.RESET_JIGGLES end
		juice_card_until(self, eval, true)
	end

	local has_pmo = Ovn_f.has_joker('j_ovn_pmo')
	local has_pareidolia = Ovn_f.has_joker('j_pareidolia')

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
	local has_pmo = Ovn_f.has_joker('j_ovn_pmo')

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
	if G.STAGE == G.STAGES.RUN then
		-- required to preserve enhancements in Collection
		if self.area == G.hand or self.area == G.pack_cards then
			local card_suit = self.base.suit
			if card_suit == 'ovn_Optics' then
				if not G.GAME.ovn_has_ocular then
					G.GAME.ovn_has_ocular = true
				end
				Ovn_f.corrupt_enhancement(self)
			else
				Ovn_f.purify_enhancement(self)
			end
		end
	end

	cardupd8_hook(self, dt)

	if G.STATE == G.STATES.SELECTING_HAND then
		local unob_tally = 0

		for _,card in ipairs(G.hand.cards) do
			if card.config.center.key == 'm_ovn_unob' then
				unob_tally = unob_tally + 1
			end
		end

		if unob_tally >= G.hand.config.card_limit and G.GAME.current_round.discards_left <= 0 then
			G.STATE = G.STATES.GAME_OVER
			G.STATE_COMPLETE = false
			return true
		end
	end

	if self.area == G.jokers then
		-- Destroy card if it is corruptbanished
		local card_key = self.config.center.key
		if not card_key then return end

		if Ovn_f.is_corruptbanished(card_key) and not (
			self.ability.extra
			and type(self.ability.extra) == "table"
			and self.ability.extra.getting_corrupt_banished
		) then
			SMODS.destroy_cards(self)
			if not self.ability.extra or type(self.ability.extra) ~= "table" then
				self.ability.extra = {}
			end
			self.ability.extra.getting_corrupt_banished = true
		end
	end
end

----

--[[
calculate_repetitions hook is modified from Paperback utilities/hooks.lua
https://github.com/Balatro-Paperback/paperback/?tab=MIT-1-ov-file

MIT License

Copyright (c) 2025 Nether

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local calcrep_hook = SMODS.calculate_repetitions
SMODS.calculate_repetitions = function(card, context, reps)
	for _,area in ipairs(SMODS.get_card_areas('playing_cards')) do
		for _,area_card  in ipairs(area.cards or {}) do
			if area_card ~= card then
				local eval = area_card:calculate_enhancement {
					other_card = card,
					cardarea = card.area,
					scoring_hand = context.scoring_hand,
					ovn_repetition_from_playing_card = true,
				}

				if eval and eval.repetitions then
					for _ = 1, eval.repetitions do
						eval.card = eval.card or card
						eval.message = eval.message or (not eval.remove_default_message and localize('k_again_ex'))
						reps[#reps + 1] = { key = eval }
					end
				end
			end
		end
	end

	return calcrep_hook(card, context, reps)
end

----

local cardclick_hook = Card.click
function Card:click()
	-- Prevent card selection on C-Ghost Deck draw
	if G.GAME.ovn_cghost_first_hand_drawn ~= nil then
		if G.GAME.ovn_cghost_first_hand_drawn then
			cardclick_hook(self)
		end
	else
		cardclick_hook(self)
	end
end

----

local startrun_hook = Game.start_run
function Game:start_run(args)
	-- For use in C-Ghost deck
	self.ovn_ghostspec = CardArea(
		G.ROOM.T.x + 9,
		G.ROOM.T.y*1.1,
		G.CARD_W*1.1,
		1.05*G.CARD_H,
		{card_limit = 1, type = 'consumeable', highlight_limit = 0}
	)
	G.ovn_ghostspec = self.ovn_ghostspec
	Ovn_f.add_simple_event(nil, nil, function()
		-- C-Ghost anti-cheese :P
		SMODS.calculate_context({
			ovn_run_started = true
		})
	end)
	startrun_hook(self, args)
end