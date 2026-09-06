-- modules/item-specific/costly_hands.lua
-- Not as complex as Corrupt Green Deck (pun not intended)
-- but still good to collect things in one place

-- Other files associated with costly hands/Corrupt Yellow Deck:
---- items/3-0. Decks.lua                 - Corrupt Yellow Deck register
---- modules/ui_hooks.lua                 - function create_UIBox_HUD
---- modules/item-specific/mod_object.lua - Calculation

-- 1. FUNCTIONS
-- 2. HOOKS

local add_simple_event = Ovn_f.add_simple_event



-------------------
---- FUNCTIONS ----
-------------------

---@class Ovn_f.enable_costly_hands.args
---@field hand_cost? integer
---@field discard_cost? integer
---@field punish_unaffordable? boolean If true, the game ends if player cannot afford to play a hand.
---@field skip_update_ui? boolean If true, UI will NOT updated. Set to true when calling this function at the start of a run.

-- Enable Corrupt Yellow Deck's effect, where hands and discards cost money.
---@param args Ovn_f.enable_costly_hands.args
---@return nil
function Ovn_f.enable_costly_hands(args)
	if G.GAME.ovn_costly_hands then return end
	local hand_cost = args.hand_cost or 0
	local discard_cost = args.discard_cost or 0
	local punish_unaffordable = args.punish_unaffordable or false
	local skip_update_ui = args.skip_update_ui

	G.GAME.ovn_costly_hands = {
		hand_cost = hand_cost,
		discard_cost = discard_cost,
		hand_cost_label = "$" .. hand_cost,
		discard_cost_label = "$" .. discard_cost,
		punish_unaffordable = punish_unaffordable,

		old_money_per_hand = G.GAME.modifiers.money_per_hand,
		old_money_per_discard = G.GAME.modifiers.money_per_discard,
		old_hands_reset = G.GAME.round_resets.hands,
		old_discards_reset = G.GAME.round_resets.discards,
	}
	G.GAME.round_resets.hands = hand_cost
	G.GAME.round_resets.discards = discard_cost
	G.GAME.modifiers.money_per_hand = 0

	if skip_update_ui then return end

	local hands_text = G.HUD:get_UIE_by_ID("hand_UI_count").config.object
	hands_text.config.string[1].ref_table = G.GAME.ovn_costly_hands
	hands_text.config.string[1].ref_value = "hand_cost_label"
	hands_text.config.colours[1] = G.C.ORANGE
	hands_text:update_text()

	local discards_text = G.HUD:get_UIE_by_ID("discard_UI_count").config.object
	discards_text.config.string[1].ref_table = G.GAME.ovn_costly_hands
	discards_text.config.string[1].ref_value = "discard_cost_label"
	discards_text.config.colours[1] = G.C.ORANGE
	discards_text:update_text()
end

-- Disable Corrupt Yellow Deck's effect.
---@return nil
function Ovn_f.disable_costly_hands()
	if not G.GAME.ovn_costly_hands then return end

	G.GAME.modifiers.money_per_hand = G.GAME.ovn_costly_hands.old_money_per_hand
	G.GAME.modifiers.money_per_discard = G.GAME.ovn_costly_hands.old_money_per_discard
	G.GAME.round_resets.hands = G.GAME.ovn_costly_hands.old_hands_reset
	G.GAME.round_resets.discards = G.GAME.ovn_costly_hands.old_discards_reset

	local hands_text = G.HUD:get_UIE_by_ID("hand_UI_count").config.object
	hands_text.config.string[1].ref_table = G.GAME.current_round
	hands_text.config.string[1].ref_value = "hands_left"
	hands_text.config.colours[1] = G.C.BLUE
	hands_text:update_text()

	local discards_text = G.HUD:get_UIE_by_ID("discard_UI_count").config.object
	discards_text.config.string[1].ref_table = G.GAME.current_round
	discards_text.config.string[1].ref_value = "discards_left"
	discards_text.config.colours[1] = G.C.RED
	discards_text:update_text()

	G.GAME.ovn_costly_hands = nil
end

-- If costly hands are enabled, try to end the game if the player cannot afford to play a hand. 
Ovn_f.try_punish_unaffordable_hand = function()
	if not (
		G.GAME.ovn_costly_hands
		and G.GAME.ovn_costly_hands.punish_unaffordable
		and G.GAME.ovn_costly_hands.hand_cost ~= 0
	) then return end
	Ovn_f.nested_event(1, nil, nil, function ()
		if G.GAME.dollars < G.GAME.ovn_costly_hands.hand_cost then
			G.STATE = G.STATES.GAME_OVER
			G.STATE_COMPLETE = false
		end
	end)
end

-- If costly hands are enabled, increases the hand cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_hand_cost = function(amount, instant)
	-- Primarily used in C-Yellow Deck
	if not G.GAME.ovn_costly_hands then return end
	local _mod = function(mod)
		local hand_UI = G.HUD:get_UIE_by_ID('hand_UI_count')
		if not hand_UI then
			print("[OVN_F] ease_hand_cost - hand_UI_count not found")
			return
		end

		mod = mod or 0
		local text = '+'
		local col = G.C.MONEY
		if mod < 0 then
			text = ''
			col = G.C.RED
		end

		--Ease from current chips to the new number of chips
		G.GAME.ovn_costly_hands.hand_cost = G.GAME.ovn_costly_hands.hand_cost + mod
		G.GAME.ovn_costly_hands.hand_cost_label =  "$" .. G.GAME.ovn_costly_hands.hand_cost
		hand_UI.config.object:update()
		G.HUD:recalculate()

		--Popup text next to the chips in UI showing number of chips gained/lost
		attention_text({
			text = text..mod,
			scale = 0.8,
			hold = 0.7,
			cover = hand_UI.parent,
			cover_colour = col,
			align = 'cm',
		})

		--Play a chip sound
		play_sound('coin6')
	end

	add_simple_event(instant and 'instant' or 'immediate', nil, function()
		_mod(amount)
	end)
end

-- If costly hands are enabled, increases the discard cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_discard_cost = function(amount, instant)
	if not G.GAME.ovn_costly_hands then return end
	local _mod = function(mod)
		local discard_UI = G.HUD:get_UIE_by_ID('discard_UI_count')
		if not discard_UI then
			print("[OVN_F] ease_discard_cost - discard_UI_count not found")
			return
		end

		mod = mod or 0
		local text = '+'
		local col = G.C.MONEY
		if mod < 0 then
			text = ''
			col = G.C.RED
		end

		--Ease from current chips to the new number of chips
		G.GAME.ovn_costly_hands.discard_cost = G.GAME.ovn_costly_hands.discard_cost + mod
		G.GAME.ovn_costly_hands.discard_cost_label =  "$" .. G.GAME.ovn_costly_hands.discard_cost
		discard_UI.config.object:update()
		G.HUD:recalculate()

		--Popup text next to the chips in UI showing number of chips gained/lost
		attention_text({
			text = text..mod,
			scale = 0.8,
			hold = 0.7,
			cover = discard_UI.parent,
			cover_colour = col,
			align = 'cm',
		})

		--Play a chip sound
		play_sound('coin6')
	end

	add_simple_event(instant and 'instant' or 'immediate', nil, function()
		_mod(amount)
	end)
end



---------------
---- HOOKS ----
---------------

-- Hook to disable DISCARD easing if costly hands are enabled
local easediscard_hook = ease_discard
function ease_discard(mod, instant, silent)
	if not G.GAME.ovn_costly_hands then
		easediscard_hook(mod, instant, silent)
	end
end

-- Hook to disable HAND easing if costly hands are enabled
local easehand_hook = ease_hands_played
function ease_hands_played(mod, instant)
	if not G.GAME.ovn_costly_hands then
		easehand_hook(mod, instant)
	end
end