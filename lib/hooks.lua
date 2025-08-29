-- lib/hooks.lua
-- These functions append certain behaviors onto existing functions
-- in a manner easier than patching

-- 1. GLOBAL FUNCTIONS
-- 2. CARD OBJECT
-- 3. GAME OBJECT
-- 4. STEAMODDED HOOKS
-- 5. OBJECT OWNERSHIP



--------------------------
---- GLOBAL FUNCTIONS ----
--------------------------

-- Hook for Event Horizon effect
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

-- Hook for transmuting modifiers on created Optic cards
local createcard_hook = create_card
function create_card(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	local card = createcard_hook(_type, area, legendary, _rarity, skip_materialize, soulable, forced_key, key_append)
	if card and card.base.suit == "ovn_Optics" then
		G.GAME.ovn_has_ocular = true
		-- Only occurs if conditionals within function are true
		Ovn_f.corrupt_modifiers(card)
	end
	return card
end

-- Hook for never_scores behavior change
local gethighest_hook = get_highest
function get_highest(hand)
	local has_never_scores = false
	for _,card in ipairs(hand) do
		if SMODS.never_scores(card) then
			has_never_scores = true
			break
		end
	end
	-- Since this hook is for never_scores support,
	-- a lack of such does not require special calculation.
	if not has_never_scores then return gethighest_hook(hand) end

	local highest = nil
	for _,card in ipairs(hand) do
		if (
			not SMODS.never_scores(card)
			and (
				not highest
				or card:get_nominal() > highest:get_nominal()
			)
		) then highest = card end
	end

	-- For cases where all played cards never score,
	-- we still need something to send back.
	-- Without this hook, a never-scoring card can still be
	-- the highest card, even if it never scores
	-- hence this fallback.
	if not highest then return gethighest_hook(hand) end

	if #hand > 0 then return {{highest}} else return {} end
end

-- Hook to disable DISCARD easing on Corrupt Yellow Deck
local easediscard_hook = ease_discard
function ease_discard(mod, instant, silent)
	if not G.GAME.in_corrupt_yellow then
		easediscard_hook(mod, instant, silent)
	end
end

-- Hook to disable HAND easing on Corrupt Yellow Deck
local easehand_hook = ease_hands_played
function ease_hands_played(mod, instant)
	if not G.GAME.in_corrupt_yellow then
		easehand_hook(mod, instant)
	end
end



---------------------
---- CARD OBJECT ----
---------------------

-- Hook for PMO functionality
local card_calcjoker_hook = Card.calculate_joker
function Card:calculate_joker(context)
	-- Wiggle if corruption method is found
	if Ovn_f.joker_is_corruptible(self.key) then
		local eval = function(card) return SMODS.find_card("c_ovn_abyss") and not G.RESET_JIGGLES end
		juice_card_until(self, eval, true)
	end

	local has_pmo = Ovn_f.has_joker('j_ovn_pmo')
	local has_pareidolia = Ovn_f.has_joker('j_pareidolia')

	-- PMO functionality
	-- Credit to Airtoum for initial code
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
			local regular_calc_value = card_calcjoker_hook(self, context)
			card_base.id = -1
			local aced_calc_value = card_calcjoker_hook(self, context)
			card_base.id = initial_id

			-- one of them being nil implies a rank check
			if not (regular_calc_value ~= nil and aced_calc_value ~= nil) then
				return
			end
		end

		if card_base.id ~= 14 then return card_calcjoker_hook(self, context) end

		-- jackify, queenify, kingify
		-- and 2ify -> 10ify if pareidolia
		for rank = start_rank, end_rank do
			card_base.id = rank
			local return_value = card_calcjoker_hook(self, context)
			card_base.id = 14
			if return_value then return return_value end
		end
	end

	-- if nothing fancy applies (eg. number or ace-targeting stuff, or still nil effects) it will reach here
	return card_calcjoker_hook(self, context)
end

-- Hook for PMO functionality
local card_isface_hook = Card.is_face
function Card:is_face()
	local has_pmo = Ovn_f.has_joker('j_ovn_pmo')

	-- PMO functionality
	if has_pmo then
		return self.base and self.base.id == 14 or false
	end

	-- If nothing else
	return card_isface_hook(self)
end

-- Hook for:
---- Losing if all held cards are Unobtainium
---- Corruptbanish destruction
local card_upd8_hook = Card.update
function Card:update(dt)
	card_upd8_hook(self, dt)

	-- If all held cards are Unobtainium, lose the run
	-- Todo: move to something like game:update since card_count^2 checks
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
	
	-- Destroy card if it is corruptbanished
	if self.area == G.jokers then
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

-- Hook for no-click if first hand is being drawn on Corrupt Ghost Deck (prevent unexpected behaviors)
local card_click_hook = Card.click
function Card:click()
	-- Prevent card selection on C-Ghost Deck draw
	if G.GAME.ovn_cghost_first_hand_drawn ~= nil then
		if G.GAME.ovn_cghost_first_hand_drawn then
			card_click_hook(self)
		end
	else
		card_click_hook(self)
	end
end

-- Hook to transmute modifiers on cards with changed suits
local card_changesuit_hook = Card.change_suit
function Card:change_suit(new_suit)
	if new_suit == "ovn_Optics" then
		G.GAME.ovn_has_ocular = true
	end

	local transmute_type = "none"
	-- Non-Optics -> Optics - Corrupt modifiers
	if (
		self.base.suit ~= "ovn_Optics"
		and new_suit == "ovn_Optics"
	) then transmute_type = "corrupt"
	-- Optics -> Non-Optics - Purify modifiers
	elseif (
		self.base.suit == "ovn_Optics"
		and new_suit ~= "ovn_Optics"
	) then transmute_type = "purify"
	end

	card_changesuit_hook(self, new_suit)

	if transmute_type ~= "none" then
		Ovn_f[transmute_type .. "_modifiers"](self)
	end
end

-- Hook for:
---- Increasing Instability after obtaining Optic cards
---- Counting unique Jokers
local card_addtodeck_hook = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	card_addtodeck_hook(self, from_debuff)
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

-- Hook for corrupting enhancements on Optic cards if set (by Tarots, etc)
local card_setability_hook = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	card_setability_hook(self, center, initial, delay_sprites)
	if (
		self.config.card
		and self.config.card.suit == "ovn_Optics"
		and Oblivion.enhancement_corrupt[self.config.center.key]
	) then
		Ovn_f.corrupt_modifiers(self)
	end
end

-- Hook for corrupting seals on Optic cards if set (by Spectrals, etc)
local card_setseal_hook = Card.set_seal
function Card:set_seal(_seal, silent, immediate)
	card_setseal_hook(self, _seal, silent, immediate)
	if (
		self.config.card
		and self.config.card.suit == "ovn_Optics"
		and self.seal
		and Oblivion.seal_corrupt[self.seal]
	) then
		Ovn_f.corrupt_modifiers(self)
	end
end



---------------------
---- GAME OBJECT ----
---------------------

-- Hook for:
---- Creating the Ghost Spectral cardarea
---- context.ovn_run_started
---- G.GAME values:
------ ovn_instability NUMBER
------ cumulative_unique_joker_count INTEGER
------ cumulative_unique_jokers { STRING: BOOLEAN }
------ hands_last_played { STRING: INTEGER }
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



--------------------------
---- STEAMODDED HOOKS ----
--------------------------

--[[
Hook for counting repetitions from enhancements, seals, and editions

This hook is modified from Paperback utilities/hooks.lua
More specifically, calculating seals and edition repetitions were added by Oinite
Paperback is released under the MIT license, as shown in the following link:
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
local smods_calcrep_hook = SMODS.calculate_repetitions
SMODS.calculate_repetitions = function(card, context, reps)
	for _,area in ipairs(SMODS.get_card_areas('playing_cards')) do
		for _,area_card  in ipairs(area.cards or {}) do
			if area_card ~= card then
				local cardarea = area
				if area == G.play then
					cardarea = SMODS.in_scoring(area_card, context.scoring_hand) and G.play or 'unscored'
				end

				local evals = {}
				local area_card_context = {
					other_card = card,
					cardarea = cardarea,
					scoring_hand = context.scoring_hand,
					ovn_repetition_from_playing_card = true,
				}

				if area_card.ability.set == 'Enhanced' then
					evals.enhancement = area_card:calculate_enhancement(area_card_context)
				end
				if area_card.seal then
					evals.seal = area_card:calculate_seal(area_card_context)
				end
				if area_card.edition then
					evals.edition = area_card:calculate_edition(area_card_context)
				end
				for _,k in ipairs(SMODS.Sticker.obj_buffer) do
					local v = SMODS.Stickers[k]
					area_card[v] = area_card:calculate_sticker(area_card_context, k)
				end

				for _,eval in pairs(evals) do
					if eval and eval.repetitions then
						for _ = 1, eval.repetitions do
							eval.card = eval.card or card
							eval.message = eval.message or (not eval.remove_default_message and localize('k_again_ex'))
							reps[#reps + 1] = { key = eval }
						end
					end
				end
				----
			end
		end
	end

	return smods_calcrep_hook(card, context, reps)
end

-- Hook for redirecting Instability scoring parameter value (not stored in SMODS.ScoringParameter)
local smods_getscoringparam_hook = SMODS.get_scoring_parameter
function SMODS.get_scoring_parameter(key, flames)
    if key == "ovn_instability" then return G.GAME.ovn_instability end
    return smods_getscoringparam_hook(key, flames)
end



--------------------------
---- OBJECT OWNERSHIP ----
--------------------------

-- Ownership of Black Hole for Event Horizon effect
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

-- Supplementary function
-- TODO wait for them to put this in utils.lua
local function juice_flip(used_tarot)
	G.E_MANAGER:add_event(Event({
		trigger = 'after',
		delay = 0.4,
		func = function()
			play_sound('tarot1')
			used_tarot:juice_up(0.3, 0.5)
			return true
		end
	}))
	for i = 1, #G.hand.cards do
		local percent = 1.15 - (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
		G.E_MANAGER:add_event(Event({
			trigger = 'after',
			delay = 0.15,
			func = function()
				G.hand.cards[i]:flip(); play_sound('card1', percent); G.hand.cards[i]:juice_up(0.3, 0.3); return true
			end
		}))
	end
end

-- Ownership of Sigil for Instability increase
SMODS.Consumable:take_ownership('sigil', {
	-- all of this code taken from SMODS game_object.lua
	-- and then modified a little bit for instability support
	use = function(self, card, area, copier)
		local used_tarot = copier or card
		juice_flip(used_tarot)
		local _suit = pseudorandom_element(SMODS.Suits, pseudoseed('sigil'))
		for i = 1, #G.hand.cards do
			G.E_MANAGER:add_event(Event({
				func = function()
					local _card = G.hand.cards[i]
					assert(SMODS.change_base(_card, _suit.key))
					return true
				end
			}))
		end
		for i = 1, #G.hand.cards do
			local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
			G.E_MANAGER:add_event(Event({
				trigger = 'after',
				delay = 0.15,
				func = function()
					G.hand.cards[i]:flip(); play_sound('tarot2', percent, 0.6); G.hand.cards[i]:juice_up(0.3, 0.3); return true
				end
			}))
		end
		delay(0.5)
		if _suit.key == "ovn_Optics" then Ovn_f.optic_instability(#G.hand.cards) end
	end
})