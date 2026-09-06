-- modules/item-specific/complex_economy.lua
-- So many edge cases to consider...

-- Other files associated with vomplex economy/Corrupt Green Deck:
---- items/3-0. Decks.lua        - Corrupt Green Deck register
---- lib/hooks.lua               - function Game:start_run
---- lib/ui_hooks.lua            - function create_UIBox_HUD
---- lovely/complex_economy.toml - Primarily for complex dollars support

-- 1. FUNCTIONS
-- 2. HOOKS
-- 3. UI FUNCTIONS
-- 4. UI HOOKS

local add_simple_event = Ovn_f.add_simple_event



-------------------
---- FUNCTIONS ----
-------------------

---@param skip_update_ui? boolean If true, UI will NOT updated. Set to true when calling this function at the start of a run.
Ovn_f.enable_complex_economy = function(skip_update_ui)
	if G.GAME.ovn_complex_economy then return end
	G.GAME.ovn_complex_economy = true
	G.GAME.dollars_i = 0
	G.GAME.dollars_complex_label = tostring(G.GAME.dollars)
	Ovn_f.ease_complex_dollars(0,0)

	if skip_update_ui then return end

	for _,joker_card in ipairs(G.jokers.cards) do
		joker_card:set_cost()
	end
	for _,cnsm_card in ipairs(G.consumeables.cards) do
		cnsm_card:set_cost()
	end
	if G.shop_jokers then for _,shop_joker_card in ipairs(G.shop_jokers.cards) do
		shop_joker_card:set_cost()
		create_shop_card_ui(shop_joker_card)
	end end
	if G.shop_booster then for _,shop_booster_card in ipairs(G.shop_booster.cards) do
		shop_booster_card:set_cost()
		create_shop_card_ui(shop_booster_card)
	end end
	if G.shop_vouchers then for _,shop_vouchers_card in ipairs(G.shop_vouchers.cards) do
		shop_vouchers_card:set_cost()
		create_shop_card_ui(shop_vouchers_card)
	end end

	local dollars_text = G.HUD:get_UIE_by_ID("dollar_text_UI").config.object
	dollars_text.config.string[1].ref_value = "dollars_complex_label"
	dollars_text:update_text()
end

Ovn_f.disable_complex_economy = function()
	if not G.GAME.ovn_complex_economy then return end
	G.GAME.ovn_complex_economy = nil
	G.GAME.dollars_i = nil
	G.GAME.dollars_complex_label = nil
	ease_dollars(0)

	for _,joker_card in ipairs(G.jokers.cards) do
		joker_card:set_cost()
	end
	for _,cnsm_card in ipairs(G.consumeables.cards) do
		cnsm_card:set_cost()
	end
	if G.shop_jokers then for _,shop_joker_card in ipairs(G.shop_jokers.cards) do
		shop_joker_card:set_cost()
		create_shop_card_ui(shop_joker_card)
	end end
	if G.shop_booster then for _,shop_booster_card in ipairs(G.shop_booster.cards) do
		shop_booster_card:set_cost()
		create_shop_card_ui(shop_booster_card)
	end end
	if G.shop_vouchers then for _,shop_vouchers_card in ipairs(G.shop_vouchers.cards) do
		shop_vouchers_card:set_cost()
		create_shop_card_ui(shop_vouchers_card)
	end end

	local dollars_text = G.HUD:get_UIE_by_ID("dollar_text_UI").config.object
	dollars_text.config.string[1].ref_value = "dollars"
	dollars_text:update_text()
end

-- Formats a complex number a+bi.\
-- Either one parameters (table - {a,b})\
-- or two parameters (a, b).
---@param a number|table
---@param b? number
---@return string
Ovn_f.format_complex_number = function(a,b)
	if type(a) == 'table' and not b then
		b = a[2]
		a = a[1]
	end
	if a == 0 and b == 0 then return "0" end
	if b == 0 then return tostring(a) end
	if a == 0 then return b .. "i" end

	-- When converting to string, the negative b already has a negative sign
	-- hence no need to specify here
	local operator = b < 0 and "" or "+"
	return a .. operator .. b .. "i"
end

-- Formats a complex number to show it on the ease_complex_dollars attention text.
---@param mod number
---@param mod_i number
---@return string
local function format_complex_change(mod, mod_i)
	local dol = localize('$')
	if mod < 0 and mod_i < 0 then
		return "-" .. dol .. Ovn_f.format_complex_number(-mod, -mod_i)
	end

	if mod < 0 and mod_i == 0 then
		return "-" .. dol .. -mod
	end

	if mod_i < 0 and mod == 0 then
		return "-" .. dol .. -mod_i .. "i"
	end

	return "+" .. dol .. Ovn_f.format_complex_number(mod, mod_i)
end

---@param a number
---@return number
local function round(a) return math.floor(a+0.5) end

-- Sets a card's complex cost and sell cost.
---@param card Card
---@return nil
Ovn_f.set_complex_cost_labels = function(card)
    card.ability.complex_cost_label = Ovn_f.format_complex_number(Ovn_f.get_complex_cost(card))
    card.ability.complex_sell_label = card.facing == 'back' and '?' or Ovn_f.format_complex_number(Ovn_f.get_complex_sell_cost(card))
end

-- Gets a card's complex cost.
---@param card Card
---@return number
---@return number
Ovn_f.get_complex_cost = function(card)
	return card.cost, round(card.ability.ovn_proper_cost/3)
end

-- Gets a card's complex sell cost.
---@param card Card
---@return number
---@return number
Ovn_f.get_complex_sell_cost = function(card)
	return card.sell_cost, round(card.ability.ovn_proper_sell/3)
end

-- Convert a number to complex cost form.
---@param regular_cost number
---@return number
---@return number
Ovn_f.convert_complex_cost = function(regular_cost)
	-- x -> a + bi, where a = 2/3x, b = 1/3x
	return round(2*regular_cost/3), round(regular_cost/3)
end

-- Changes dollars by a complex amount.
---@param mod number
---@param mod_i number
---@param instant? boolean
---@return nil
Ovn_f.ease_complex_dollars = function(mod, mod_i, instant)
	if not G.GAME.ovn_complex_economy then return end
	local function _mod()
		local dollar_UI = G.HUD:get_UIE_by_ID('dollar_text_UI') --[[@as UIElement]]
		mod = mod or 0
		mod_i = mod_i or 0

		local text = format_complex_change(mod, mod_i)

		local col = G.C.MONEY
		if (
			(mod < 0 and mod_i < 0)
			or (mod < 0 and mod_i == 0)
			or (mod_i < 0 and mod == 0)
		) then
			col = G.C.RED
		elseif (
			(mod < 0 and mod_i > 0)
			or (mod_i < 0 and mod > 0)
		) then
			col = G.C.GREEN
		end

		-- Ease from current dollars to new number of dollars
		G.GAME.dollars = G.GAME.dollars + mod
		G.GAME.dollars_i = G.GAME.dollars_i + mod_i
		G.GAME.dollars_complex_label = Ovn_f.format_complex_number(G.GAME.dollars, G.GAME.dollars_i)
		-- career stat stuff ig
		if mod >= 0 then
			inc_career_stat('c_dollars_earned', mod)
		end

		-- check unlock stuff
		check_and_set_high_score('most_money', G.GAME.dollars)
        check_for_unlock({type = 'money'})

		-- Update UI
		dollar_UI.config.object:update()
		G.HUD:recalculate()

		-- Popup text
		attention_text{
			text = text,
			scale = 0.8,
			hold = 0.7,
			cover = dollar_UI.parent,
			cover_colour = col,
			align = 'cm'
		}
		play_sound('coin1')
	end

	add_simple_event(instant and 'instant' or 'immediate', nil, function()
		_mod(mod, mod_i)
	end)
end



---------------
---- HOOKS ----
---------------

-- Hook to use ease_complex_dollars on Corrupt Green Deck
local easedollars_hook = ease_dollars
function ease_dollars(mod, instant)
	if not G.GAME.ovn_complex_economy then
		easedollars_hook(mod, instant)
		return
	end
	Ovn_f.ease_complex_dollars(mod, 0, instant)
end

-- Hook for complex costs (visual, Corrupt Green Deck)
local card_setcost_hook = Card.set_cost
function Card:set_cost()
	card_setcost_hook(self)
	if not G.GAME.ovn_complex_economy then return end
	if self.ability.ovn_proper_cost then
		-- self.cost was changed without initialization
		local delta_cost = self.cost - self.ability.ovn_proper_cost
		self.cost = delta_cost + round(2*self.ability.ovn_proper_cost/3)
	else
		self.ability.ovn_proper_cost = self.cost
		self.cost = round(2*self.cost/3)
	end

	if self.ability.ovn_proper_sell then
		-- self.sell_cost was changed without initialization
		local delta_sell = self.sell_cost - self.ability.ovn_proper_sell
		self.sell_cost = delta_sell + round(2*self.ability.ovn_proper_sell/3)
	else
		self.ability.ovn_proper_sell = self.sell_cost
		self.sell_cost = round(2*self.sell_cost/3)
	end

	Ovn_f.set_complex_cost_labels(self)
end

-- Hook to reset proper cost
local card_setability_hook = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	card_setability_hook(self, center, initial, delay_sprites)
	if not G.GAME.ovn_complex_economy then return end
	self.ability.ovn_proper_cost = nil
	self.ability.ovn_proper_sell = nil
end



----------------------
---- UI FUNCTIONS ----
----------------------

---@class add_complex_roundeval_row.Config
---@field dollars? number
---@field name? string
---@field disp? string|number
---@field bonus? boolean
---@field pitch? number

-- Adds a round evaluation row for complex values.
---@param config add_complex_roundeval_row.Config
---@return nil
Ovn_f.add_complex_roundeval_row = function(config)
	config = config or {}
	local width = G.round_eval.T.w - 0.51
	local dollars = config.dollars or 1
	local dollars_txt = (dollars ~= 1 and dollars or "") .. "i"
	local scale = 0.9

	add_simple_event('after', 0.5, function ()
		local left_text = {}
		if config.name == 'hands' then
			table.insert(left_text, {n=G.UIT.T, config={
				text = config.disp,
				scale = 0.8*scale,
				colour = G.C.BLUE,
				shadow = true,
				juice = true
			}})
			table.insert(left_text, {n=G.UIT.O, config={
				object = DynaText({
					string = {" "..localize{
						type = 'variable',
						key = 'remaining_hand_money_i',
						vars = {(G.GAME.modifiers.money_i_per_hand or 0) ~= 1 and (G.GAME.modifiers.money_i_per_hand or 0) or ""}
					}},
					colours = {G.C.UI.TEXT_LIGHT},
					shadow = true,
					pop_in = 0,
					scale = 0.4*scale,
					silent = true
				})
			}})

		elseif config.name == 'discards' then
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
						vars = {(G.GAME.modifiers.money_i_per_discard or 0) ~= 1 and (G.GAME.modifiers.money_i_per_discard or 0) or ""}
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

---@class add_complex_cashout_button.Config
---@field dollars? number
---@field dollars_i? number
---@field pitch? number

-- Adds the cashout button, which has a complex value.
---@param dollars number
---@param dollars_i number
---@return nil
Ovn_f.add_complex_cashout_button = function(dollars, dollars_i)
	local width = G.round_eval.T.w - 0.51
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
		G.GAME.current_round.dollars = dollars
		G.GAME.current_round.dollars_i = dollars_i

		play_sound('coin6', 1)
		G.VIBRATION = G.VIBRATION + 1
	end)
end



------------------
---- UI HOOKS ----
------------------

-- Hook to determine if a complex cost can be bought (Corrupt Green Deck)
local funcs_canbuy_hook = G.FUNCS.can_buy
G.FUNCS.can_buy = function(e)
	if not G.GAME.ovn_complex_economy then
		funcs_canbuy_hook(e)
		return
	end

	local card = e.config.ref_table
	local cost, cost_i = Ovn_f.get_complex_cost(card)
	local cost_gt_dollars = (
		(cost > G.GAME.dollars - G.GAME.bankrupt_at)
		or (cost_i > G.GAME.dollars_i)
	)

	if (
		cost_gt_dollars
		and cost > 0
		and cost_i > 0
	) then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.ORANGE
		e.config.button = 'buy_from_shop'
	end

	if e.config.ref_parent and e.config.ref_parent.children.buy_and_use then
		if e.config.ref_parent.children.buy_and_use.states.visible then
			e.UIBox.alignment.offset.y = -0.6
		else
			e.UIBox.alignment.offset.y = 0
		end
	end
end

-- Hook to determine if a complex cost can be bought-then-used (Corrupt Green Deck)
local funcs_canbuyuse_hook = G.FUNCS.can_buy_and_use
G.FUNCS.can_buy_and_use = function(e)
	if not G.GAME.ovn_complex_economy then
		funcs_canbuyuse_hook(e)
		return
	end

	local card = e.config.ref_table
	local cost, cost_i = Ovn_f.get_complex_cost(card)
	local cost_gt_dollars = (
		(cost > G.GAME.dollars - G.GAME.bankrupt_at)
		or (cost_i > G.GAME.dollars_i)
	)
	local can_use = e.config.ref_table:can_use_consumeable()

	if (
		cost_gt_dollars
		and cost > 0
		and cost_i > 0
	) or not can_use then
		e.UIBox.states.visible = false
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		if e.config.ref_table.highlighted then
			e.UIBox.states.visible = true
		end
		e.config.colour = G.C.SECONDARY_SET.Voucher
		e.config.button = 'buy_from_shop'
	end
end

-- Hook to determine if a complex cost can be opened (booster packs) (Corrupt Green Deck)
local funcs_canopen_hook = G.FUNCS.can_open
G.FUNCS.can_open = function(e)
	if not G.GAME.ovn_complex_economy then
		funcs_canopen_hook(e)
		return
	end

	local card = e.config.ref_table
	local cost, cost_i = Ovn_f.get_complex_cost(card)
	local cost_gt_dollars = (
		(cost > G.GAME.dollars - G.GAME.bankrupt_at)
		or (cost_i > G.GAME.dollars_i)
	)

	if (
		cost_gt_dollars
		and cost > 0
		and cost_i > 0
	) then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.GREEN
		e.config.button = 'use_card'
	end
end

-- Hook to determine if a complex cost can be redeemed (vouchers) (Corrupt Green Deck)
local funcs_canredeem_hook = G.FUNCS.can_redeem
G.FUNCS.can_redeem = function(e)
	if not G.GAME.ovn_complex_economy then
		funcs_canredeem_hook(e)
		return
	end

	local card = e.config.ref_table
	local cost, cost_i = Ovn_f.get_complex_cost(card)
	local cost_gt_dollars = (
		(cost > G.GAME.dollars - G.GAME.bankrupt_at)
		or (cost_i > G.GAME.dollars_i)
	)

	if (
		cost_gt_dollars
		and cost > 0
		and cost_i > 0
	) then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.GREEN
		e.config.button = 'use_card'
	end
end