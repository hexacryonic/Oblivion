-- modules/item-specific/datcard.lua
-- Collection of functions and hooks associated with datcarding

-- Other files associated with datcarding/Corrupt Red Deck:
---- items/3-0. Decks.lua - Corrupt Red Deck register
---- lib/ui_hooks.lua     - function create_UIBox_buttons

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. FUNCTIONS
-- 3. UI FUNCTIONS



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

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

	for i, current_card_to_discard in ipairs(cards_to_discard) do
		current_card_to_discard:calculate_seal({discard = true})
		local card_is_removed = false
		local effects = {}
		SMODS.calculate_context({discard = true, other_card =  G.hand.highlighted[i], full_hand = G.hand.highlighted, ignore_other_debuff = true}, effects)
		SMODS.trigger_effects(effects)
		for _, eval in pairs(effects) do
			if type(eval) == 'table' then
				for key, eval2 in pairs(eval) do
					if key == 'remove' or (type(eval2) == 'table' and eval2.remove) then card_is_removed = true end
				end
			end
		end

		table.insert(discarded_cards, current_card_to_discard)

		if card_is_removed then
			table.insert(destroyed_cards, current_card_to_discard)
			if SMODS.shatters(current_card_to_discard) then
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
		SMODS.calculate_context({remove_playing_cards = true, removed = destroyed_cards})
	end

	G.GAME.round_scores.cards_discarded.amt = G.GAME.round_scores.cards_discarded.amt + #discarded_cards
	check_for_unlock({type = 'discard_custom', cards = discarded_cards})
end



-------------------
---- FUNCTIONS ----
-------------------

function Ovn_f.enable_datcard()
	if G.GAME.ovn_datcard then return end
	G.GAME.ovn_datcard = true
	if G.buttons then
		local discard_button = G.buttons:get_UIE_by_ID("discard_button")
		discard_button.config.button = "discard_cards_from_held"
		discard_button.config.func   = "can_weirddiscard"
		local discard_text = discard_button.children[1].children[1]
		discard_text.config.text = localize('b_ovn_datcard')
		-- UIE:update_text (called by UIBox:recalculate) requires a nil text_drawable
		discard_text.config.text_drawable = nil
		G.buttons:recalculate()
	end
end

function Ovn_f.disable_datcard()
	if not G.GAME.ovn_datcard then return end
	G.GAME.ovn_datcard = nil
	if G.buttons then
		local discard_button = G.buttons:get_UIE_by_ID("discard_button")
		discard_button.config.button = "discard_cards_from_highlighted"
		discard_button.config.func   = "can_discard"
		local discard_text = discard_button.children[1].children[1]
		discard_text.config.text = localize('b_discard')
		-- UIE:update_text (called by UIBox:recalculate) requires a nil text_drawable
		discard_text.config.text_drawable = nil
		G.buttons:recalculate()
	end
end



----------------------
---- UI FUNCTIONS ----
----------------------

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
---@param hook? any ???
---@return nil
G.FUNCS.discard_cards_from_held = function(e, hook)
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
	table.sort(cards_to_discard, function(a,b) return a.T.x < b.T.x end)

	inc_career_stat('c_cards_discarded', #cards_to_discard)
	SMODS.calculate_context({pre_discard = true, full_hand = cards_to_discard, hook = hook})

	send_discard_contexts(cards_to_discard)
	if hook then return end

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