-- lib/ui_funcs.lua
-- These functions are used by UI elements, usually those in lib/ui_hook.lua

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. G.FUNCS ENTRIES



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

local add_simple_event = Ovn_f.add_simple_event

-- Form a list of held but unselected playing cards, for datcarding.
---@return table
local function get_cards_to_discard()
	-- == used in discard_cards_from_held
	local cards_to_discard = {}

	for i = 1, #G.hand.cards do
		if not G.hand.cards[i].highlighted then table.insert(cards_to_discard, G.hand.cards[i]) end
	end

	return cards_to_discard
end

-- During datcarding, send contexts that are sent in typical discarding.
---@param cards_to_discard table
---@return nil
local function send_discard_contexts(cards_to_discard)
	-- == used in discard_cards_from_held
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



-------------------------
---- G.FUNCS ENTRIES ----
-------------------------

-- Determine whether datcarding can occur.
---@param e any
---@return nil
G.FUNCS.can_weirddiscard = function(e)
	-- == used in b_uibox_corrupt_red_deck
	if G.GAME.current_round.discards_left <= 0 then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.RED
		e.config.button = 'discard_cards_from_held'
	end
end

-- Datcard, or discard all unselected playing cards on hand.\
-- Primarily used in Corrupt Red Deck.
---@param e any
---@return nil
G.FUNCS.discard_cards_from_held = function(e)
	-- == used in b_uibox_corrupt_red_deck
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

	--if not hook then -- I don't know what this conditional is for - it's always nil -O
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
	--end
end

-- Corrupt Pure Visage.
---@param e any
---@return nil
function G.FUNCS.transmute_card(e)
	local card = e.config.ref_table
	if card.config.center.key == "j_ovn_pure_visage" then
		Ovn_f.corrupt_joker(card)
	end
end

-- Determine whether Pure Visage can be corrupted via its button.
---@param e any
---@return nil
function G.FUNCS.can_transmute(e)
	local card = e.config.ref_table
	if card.ability.extra.on_cooldown <= 0 then
		e.config.colour = G.C.GREEN
		e.config.button = "transmute_card"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

----

-- will move somewhere else later idk
G.C.INST = HEX('04248F')
G.C.UI_INST = G.C.INST

Ovn_f.add_complex_roundeval_row = function(config)
	config = config or {}
	local width = G.round_eval.T.w - 0.51
	local dollars = config.dollars or 1
	local dollars_txt = (dollars ~= 1 and dollars or "") .. "i"
	local scale = 0.9

	add_simple_event('after', 0.5, function ()
		local left_text = {}
		if config.name == 'discards' then
			table.insert(left_text, {n=G.UIT.T, config={
				text = config.disp,
				scale = 0.8*scale,
				colour = G.C.RED,
				shadow = true,
				juice = true
			}})
			table.insert(left_text, {n=G.UIT.O, config={
				object = DynaText({
					string = {" "..localize{
						type = 'variable',
						key = 'remaining_discard_money_i',
						vars = {(G.GAME.modifiers.money_per_discard or 0) ~= 1 and (G.GAME.modifiers.money_per_discard or 0) or ""}
					}},
					colours = {G.C.UI.TEXT_LIGHT},
					shadow = true,
					pop_in = 0,
					scale = 0.4*scale,
					silent = true
				})
			}})

		elseif config.name == 'interest' then
			table.insert(left_text, {n=G.UIT.T, config={
				text = dollars_txt,
				scale = 0.8*scale,
				colour = G.C.MONEY,
				shadow = true,
				juice = true
			}})
			table.insert(left_text,{n=G.UIT.O, config={
				object = DynaText({
					string = {" "..localize{
						type = 'variable',
						key = 'interest_i',
						vars = {G.GAME.interest_amount, 5, G.GAME.interest_amount*G.GAME.interest_cap/5}
					}},
					colours = {G.C.UI.TEXT_LIGHT},
					shadow = true,
					pop_in = 0,
					scale = 0.4*scale,
					silent = true
				})
			}})
		end

		local full_row = {n=G.UIT.R, config={align = "cm", minw = 5}, nodes={
			{n=G.UIT.C, config={padding = 0, minw = width*0.55, align = "cl"}, nodes=left_text},
			{n=G.UIT.C, config={padding = 0, minw = width*0.45, align = "cr"}, nodes={{n=G.UIT.C, config={align = "cm", id = 'dollar_'..config.name..'_i'},nodes={}}}}
		}}
		G.round_eval:add_child(full_row, G.round_eval:get_UIE_by_ID(config.bonus and 'bonus_round_eval' or 'base_round_eval'))
		play_sound('cancel', config.pitch or 1)
		play_sound('highlight1',( 1.5*config.pitch) or 1, 0.2)
	end)

	local dollar_row = 0
	add_simple_event('before', 0.38, function ()
		G.round_eval:add_child(
			{n=G.UIT.R, config={align = "cm", id = 'dollar_row_'..(dollar_row+1)..'_'..config.name}, nodes={
				{n=G.UIT.O, config={object = DynaText({string = {localize('$')..dollars_txt}, colours = {G.C.MONEY}, shadow = true, pop_in = 0, scale = 0.65, float = true})}}
			}},
			G.round_eval:get_UIE_by_ID('dollar_'..config.name..'_i')
		)
		play_sound('coin3', 0.9+0.2*math.random(), 0.7)
		play_sound('coin6', 1.3, 0.8)
	end)
end

Ovn_f.add_cashout_button = function(config)
	config = config or {}
	local width = G.round_eval.T.w - 0.51
	local dollars = config.dollars
	local dollars_i = config.dollars_i
	local dollars_txt = Ovn_f.format_complex_number(dollars, dollars_i)
	local scale = 0.9

	delay(0.4)
	add_simple_event('before', 0.5, function ()
		UIBox{
			definition =
			{n=G.UIT.ROOT, config={align = 'cm', colour = G.C.CLEAR}, nodes={
				{n=G.UIT.R, config={id = 'cash_out_button', align = "cm", padding = 0.1, minw = 7, r = 0.15, colour = G.C.ORANGE, shadow = true, hover = true, one_press = true, button = 'cash_out', focus_args = {snap_to = true}}, nodes={
					{n=G.UIT.T, config={text = localize('b_cash_out')..": ", scale = 1, colour = G.C.UI.TEXT_LIGHT, shadow = true}},
					{n=G.UIT.T, config={text = localize('$')..dollars_txt, scale = 1.2*scale, colour = G.C.WHITE, shadow = true, juice = true}}
				}},
			}},
			config = {
				align = 'tmi',
				offset ={x=0,y=0.4},
				major = G.round_eval
			}
		}
		G.GAME.current_round.dollars = config.dollars
		G.GAME.current_round.dollars_i = config.dollars_i

		play_sound('coin6', config.pitch or 1)
		G.VIBRATION = G.VIBRATION + 1
	end)
end