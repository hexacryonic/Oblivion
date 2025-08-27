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

local card_changesuit_hook = Card.change_suit
function Card:change_suit(new_suit)
	local transmute_type = "none"
	-- Non-Optics -> Optics - Corrupt enhancement
	if (
		self.base.suit ~= "ovn_Optics"
		and new_suit == "ovn_Optics"
	) then transmute_type = "corrupt"
	-- Optics -> Non-Optics - Purify enhancement
	elseif (
		self.base.suit == "ovn_Optics"
		and new_suit ~= "ovn_Optics"
	) then transmute_type = "purify"
	end
	card_changesuit_hook(self, new_suit)
	if transmute_type ~= "none" then
		Ovn_f[transmute_type .. "_enhancement"](self)
	end
end

----

local cardupd8_hook = Card.update
function Card:update(dt)
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
	G.GAME.ovn_instability = G.GAME.ovn_instability or 1
	G.GAME.cumulative_unique_joker_count = G.GAME.cumulative_unique_joker_count or 0
	G.GAME.cumulative_unique_jokers = G.GAME.cumulative_unique_jokers or {}
	if not G.GAME.hands_last_played then
		G.GAME.hands_last_played = {}
		for key in pairs(SMODS.PokerHands) do
			G.GAME.hands_last_played[key] = 0
		end
	end
end

local getscoringparam_hook = SMODS.get_scoring_parameter
function SMODS.get_scoring_parameter(key, flames)
    if key == "ovn_instability" then return G.GAME.ovn_instability end
    return getscoringparam_hook(key, flames)
end

----

local addtodeck_hook = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	addtodeck_hook(self, from_debuff)
	if (
		not from_debuff
		and self.config.card
		and self.config.card.suit == "ovn_Optics"
		and G.GAME.in_corrupt_plasma
	) then
		Ovn_f.optic_instability(1)
	end

	if self.ability.set == "Joker" then
		if not G.GAME.cumulative_unique_jokers[self.config.center.key] then
			G.GAME.cumulative_unique_joker_count = G.GAME.cumulative_unique_joker_count + 1
			G.GAME.cumulative_unique_jokers[self.config.center.key] = true
		end
	end
end

----

SMODS.Consumable:take_ownership('black_hole', {
	use = function (self, card, area, copier)
		local all_event_horizons = SMODS.find_card('j_ovn_event_horizon')
		if #all_event_horizons > 0 then
			for i,event_horizon in ipairs(all_event_horizons) do
				local speed = 1 + (i-1)*0.1
				-- Mult
				Ovn_f.add_simple_event('after', 0.2/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = localize('k_upgrade_ex'),
						colour = G.C.MULT,
						instant = true
					})
				end)
				-- Chip
				Ovn_f.add_simple_event('after', 0.9/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = localize('k_upgrade_ex'),
						colour = G.C.CHIPS,
						instant = true
					})
				end)
				if i == #all_event_horizons then
					speed = 1
				end
				delay(1.3/speed)
			end
			for k, v in pairs(G.GAME.hands) do
				level_up_hand(card, k, true)
			end
		else
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = true
				return true end }))
			update_hand_text({delay = 0}, {mult = '+', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				return true end }))
			update_hand_text({delay = 0}, {chips = '+', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = nil
				return true end }))
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
			delay(1.3)
			for k, v in pairs(G.GAME.hands) do
				level_up_hand(card, k, true)
			end
        	update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	end
}, true)

local lvluphand_hook = level_up_hand
function level_up_hand(card, hand, instant, amount)
	local all_event_horizons = SMODS.find_card('j_ovn_event_horizon')
	if #all_event_horizons > 0 then
		local mult  = G.GAME.hands[hand].l_mult
		local chips = G.GAME.hands[hand].l_chips
		for i,event_horizon in ipairs(all_event_horizons) do
			event_horizon.ability.extra.mult  = event_horizon.ability.extra.mult  + (mult /2)
			event_horizon.ability.extra.chips = event_horizon.ability.extra.chips + (chips/2)

			if not instant then
				local speed = 1 + (i-1)*0.1
				-- Mult
				Ovn_f.add_simple_event('after', 0.2/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = "+"..mult,
						colour = G.C.MULT,
						instant = true
					})
				end)
				-- Chip
				Ovn_f.add_simple_event('after', 0.9/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = "+"..chips,
						colour = G.C.CHIPS,
						instant = true
					})
				end)
				if i == #all_event_horizons then
					speed = 1
				end
				delay(1.3/speed)
			end
		end
	else
		lvluphand_hook(card, hand, instant, amount)
	end
end