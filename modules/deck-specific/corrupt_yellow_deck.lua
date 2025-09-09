-- lib/corrupt_yellow_deck.lua
-- Not as complex as Corrupt Green Deck (pun not intended)
-- but still good to collect things in one place

-- Other files associated with Corrupt Yellow Deck:
---- items/3-0. Decks.lua - Corrupt Yellow Deck register
---- lib/ui_hooks.lua     - function create_UIBox_HUD

-- 1. FUNCTIONS
-- 2. HOOKS

local add_simple_event = Ovn_f.add_simple_event



-------------------
---- FUNCTIONS ----
-------------------

-- In Corrupt Yellow Deck, increases the hand cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_hand_cost = function(amount, instant)
	-- Primarily used in C-Yellow Deck
	if not Ovn_f.on_deck('c_yellow') then return end
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
		G.GAME.cy_handcost = G.GAME.cy_handcost + mod
		G.GAME.c_yellow_current_round.hands_cost =  "$" .. G.GAME.cy_handcost
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

	if instant then
		_mod(amount)
	else
		add_simple_event('immediate', nil, function()
			_mod(amount)
		end)
	end
end

-- In Corrupt Yellow Deck, increases the discard cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_discard_cost = function(amount, instant)
	if not Ovn_f.on_deck('c_yellow') then return end
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
		G.GAME.cy_discardcost = G.GAME.cy_discardcost + mod
		G.GAME.c_yellow_current_round.discard_cost =  "$" .. G.GAME.cy_discardcost
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

	if instant then
		_mod(amount)
	else
		add_simple_event('immediate', nil, function()
			_mod(amount)
		end)
	end
end



---------------
---- HOOKS ----
---------------

-- Hook to disable DISCARD easing on Corrupt Yellow Deck
local easediscard_hook = ease_discard
function ease_discard(mod, instant, silent)
	if not Ovn_f.on_deck('c_yellow') then
		easediscard_hook(mod, instant, silent)
	end
end

-- Hook to disable HAND easing on Corrupt Yellow Deck
local easehand_hook = ease_hands_played
function ease_hands_played(mod, instant)
	if not Ovn_f.on_deck('c_yellow') then
		easehand_hook(mod, instant)
	end
end