-- lib/ui_funcs.lua
-- These functions are used by UI elements, usually those in lib/ui_hook.lua

-- == used in discard_cards_from_held
local function get_cards_to_discard()
	local cards_to_discard = {}

	for i = 1, #G.hand.cards do
		cards_to_discard[#cards_to_discard + 1] = G.hand.cards[i]
	end

	-- (Iterate backwards due to table.remove shifting stuff around)
	for i = #cards_to_discard, 1, -1 do
		for _,selected_card in ipairs(G.hand.highlighted) do
			if cards_to_discard[i] == selected_card then
				table.remove(cards_to_discard, i)
			end
		end
	end

	return cards_to_discard
end

-- == used in discard_cards_from_held
local function send_discard_contexts(cards_to_discard)
	local discarded_cards = {}
	local destroyed_cards = {}
	local current_jokers = G.jokers.cards

	for i, current_card_to_discard in ipairs(cards_to_discard) do
		current_card_to_discard:calculate_seal({discard = true})
		local card_is_removed = false

		for _,current_joker in ipairs(current_jokers) do
			local card_evaluation = current_joker:calculate_joker({discard = true, other_card = current_card_to_discard, full_hand = cards_to_discard})
			if card_evaluation ~= nil then
				if card_evaluation.remove then card_is_removed = true end
				card_eval_status_text(current_joker, 'jokers', nil, 1, nil, card_evaluation)
			end
		end

		table.insert(discarded_cards, current_card_to_discard)

		if card_is_removed then
			table.insert(destroyed_cards, current_card_to_discard)
			if current_card_to_discard.ability.name == 'Glass Card' then
				current_card_to_discard:shatter()
			else
				current_card_to_discard:start_dissolve()
			end
		else
			current_card_to_discard.ability.discarded = true
			draw_card(G.hand, G.discard, i*100/#cards_to_discard, 'down', false, current_card_to_discard)
		end
	end

	if #destroyed_cards > 0 then
		for _,current_joker in ipairs(current_jokers) do
			eval_card(current_joker, {cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards})
		end
	end

	G.GAME.round_scores.cards_discarded.amt = G.GAME.round_scores.cards_discarded.amt + #discarded_cards
	check_for_unlock({type = 'discard_custom', cards = discarded_cards})
end

----

-- == used in b_uibox_corrupt_red_deck
G.FUNCS.can_weirddiscard = function(e)
	if G.GAME.current_round.discards_left <= 0 then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.RED
		e.config.button = 'discard_cards_from_held'
	end
end

-- == used in b_uibox_corrupt_red_deck
G.FUNCS.discard_cards_from_held = function(e)
	stop_use()
	G.CONTROLLER.interrupt.focus = true
	G.CONTROLLER:save_cardarea_focus('hand')

	-- == Card deselection
	for _, card in ipairs(G.playing_cards) do
		card.ability.forced_selection = nil
	end
	if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.area == G.hand then
		G.card_area_focus_reset = {area = G.hand, rank = G.CONTROLLER.focused.target.rank}
	end

	-- == Determine which cards need to be discarded
	local cards_to_discard = get_cards_to_discard()
	if #cards_to_discard == 0 then return end

	local current_jokers = G.jokers.cards

	update_hand_text(
		{immediate = true, nopulse = true, delay = 0},
		{mult = 0, chips = 0, level = '', handname = ''}
	)

	table.sort(cards_to_discard, function(a,b) return a.T.x < b.T.x end)
	inc_career_stat('c_cards_discarded', #cards_to_discard)
	for _,current_joker in ipairs(current_jokers) do
		current_joker:calculate_joker({pre_discard = true, full_hand = cards_to_discard})
	end

	send_discard_contexts(cards_to_discard)

	if not hook then
		if G.GAME.modifiers.discard_cost then
			ease_dollars(-G.GAME.modifiers.discard_cost)
		end
		ease_discard(-1)
		G.GAME.current_round.discards_used = G.GAME.current_round.discards_used + 1
		G.STATE = G.STATES.DRAW_TO_HAND
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				G.STATE_COMPLETE = false
				return true
			end
		}))
	end
end

G.C.INST = HEX('04248F')
G.C.UI_INST = G.C.INST
-- == used in create_UIBox_HUD
G.FUNCS.hand_inst_UI_set = function(e)
	local new_inst_text = number_format(((G.GAME and G.GAME.instability) or 1))
	if new_inst_text ~= G.GAME.current_round.current_hand.inst_text then
		G.GAME.current_round.current_hand.inst_text = new_inst_text
		e.config.object.scale = scale_number(G.GAME.current_round.current_hand.inst, 0.69, 1000)
		e.config.object:update_text()
		if not G.TAROT_INTERRUPT_PULSE then G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10(type(G.GAME.current_round.current_hand.inst) == 'number' and G.GAME.current_round.current_hand.inst or 1)))) end
	end
end