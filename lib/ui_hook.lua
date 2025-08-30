-- lib/ui_hooks.lua
-- These functions append certain behaviors onto existing UI functions
-- to easily add/conditionally replace new UI features

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. UI DEFINITION HOOKS
-- 3. UI FUNCTION HOOKS



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

local add_simple_event = Ovn_f.add_simple_event

-- Generates the UIBox definition for Corrupted Red Deck play/discard buttons.
---@return Balatro.UIBoxDefinition
local uiboxbuttons_hook_c_red = function()
	-- This is NOT based on the regular functions/UI_definitions.lua
	-- It is instead based on the Lovely dump of functions/UI_definitions.lua with Steamodded installed
	local text_scale = 0.45
	local button_height = 1.3

	local jtml_stylesheet = {
		[".action_button"] = {
			align = "top-middle",
			minimumWidth = 2.5,
			padding = 0.3,
			roundness = 0.1,
			hover = true,
			onePress = true,
			shadow = true,
			minimumHeight = button_height
		},
		[".row_styles"] = { align = "center-middle", padding = 0 },
		[".top_label"]   = { scale = text_scale, color = G.C.UI.TEXT_LIGHT, },
		[".bottom_label"] = { scale = text_scale * 0.65, color = G.C.UI.TEXT_LIGHT },
		[".playdiscard_root"] = {
			align = "center-middle",
			minimumWidth = 1,
			minimumHeight = 0.3,
			padding = 0.15,
			roundness = 0.1,
			fillColour = G.C.CLEAR
		},
		[".other_actions"] = {
			align = "center-middle",
			padding = 0.1,
			roundness = 0.1,
			fillColour = G.C.UI.TRANSPARENT_DARK,
			outlineWidth = 1.5,
			outlineColour = mix_colours(G.C.WHITE, G.C.JOKER_GREY, 0.7),
			lineEmboss = 1
		},
		[".sorthand_text"] = { scale = text_scale*0.8, colour = G.C.UI.TEXT_LIGHT },
		[".sorthand_button"] = {
			align = "center-middle",
			minimumHeight = 0.7,
			minimumWidth = 0.9,
			padding = 0.1,
			roundness = 0.1,
			hover = true,
			fillColour = G.C.ORANGE,
			shadow = true
		},
		[".sorthand_button__text"] = { scale = text_scale*0.7, colour = G.C.UI.TEXT_LIGHT }
	}

	local hand_sort_options =
	{"column", class="other_actions", {
		{"row", class="row_styles", {
			{"row", class="row_styles", {
				{"text", class="sorthand_text", text=localize('b_sort_hand')}
			}},
			{"row", class="row_styles", style={padding=0.1}, {
				{"column", class="sorthand_button", onclick="sort_hand_value", {
					{"text", class="sorthand_button__text", text=localize('k_rank')}
				}},
				{"column", class="sorthand_button", onclick="sort_hand_suit", {
					{"text", class="sorthand_button__text", text=localize('k_suit')}
				}},
			}}
		}}
	}}

	local play_button =
	{"column", id="play_button", class="action_button", onclick="play_cards_from_highlighted", ondraw="can_play", style={fillColour = G.C.BLUE}, {
		{"row", class="row_styles", {
			{"text", class="top_label", text=localize('b_play_hand'), ondraw='set_button_pip', style={focus = {button = 'x', orientation = 'bm'}}}
		}},
		{"row", class="row_styles", {
			{"text", class="bottom_label", reftable=SMODS.hand_limit_strings, refvalue="play"}
		}}
	}}

	local discard_button =
	{"column", id="discard_button", class="action_button", onclick="discard_cards_from_held", ondraw="can_weirddiscard", style={fillColour = G.C.RED}, {
		{"row", class="row_styles", {
			{"text", class="top_label", text="Datcard", ondraw='set_button_pip', style={focus = {button = 'y', orientation = 'bm'}}}
		}},
		{"row", class="row_styles", {
			{"text", class="bottom_label", reftable=SMODS.hand_limit_strings, refvalue="discard"}
		}}
	}}

	local jtml =
	{"root", class="playdiscard_root", {
		G.SETTINGS.play_button_pos == 1 and discard_button or play_button,
		hand_sort_options,
		G.SETTINGS.play_button_pos == 1 and play_button or discard_button,
	}}

	return Ovn_f.jtml_to_uiboxdef(jtml, jtml_stylesheet)
end

-- On Corrupt Yellow Deck, replaces the hand/discard count display with a hand/discard COST display.
---@param ret any
---@return nil
local function hud_ui_c_yellow(ret)
	local handdiscard_UI = ret.nodes[1].nodes[1].nodes[5].nodes[2].nodes[1].nodes

	local hand_text = handdiscard_UI[1].nodes[2].nodes[1]
	local discard_text = handdiscard_UI[3].nodes[2].nodes[1].nodes[1]
	local scale = 0.3

	-- Cleanly remove existing DynaText (prevent memory leaks)
	hand_text.config.object:remove()
	discard_text.config.object:remove()

	hand_text.config.object = DynaText {
		string = {{
			ref_table = G.GAME.c_yellow_current_round,
			ref_value = 'hands_cost'
		}},
		font = G.LANGUAGES['en-us'].font,
		colours = {G.C.ORANGE},
		shadow = true,
		rotate = true,
		scale = 2*scale
	}

	discard_text.config.object = DynaText {
		string = {{
			ref_table = G.GAME.c_yellow_current_round,
			ref_value = 'discard_cost'
		}},
		font = G.LANGUAGES['en-us'].font,
		colours = {G.C.ORANGE},
		shadow = true,
		rotate = true,
		scale = 2*scale
	}
end

-- On Corrupt Yellow Deck, replaces the hand/discard count display with a hand/discard COST display.
---@param ret any
---@return nil
local function hud_ui_c_green(ret)
	local scale = 0.4
	local dollars_txt = ret.nodes[1].nodes[1].nodes[5].nodes[2].nodes[3].nodes[1].nodes[1].nodes[1].nodes[1]
	dollars_txt.config.object:remove()
	dollars_txt.config.object = DynaText{
		string = {{
			ref_table = G.GAME,
			ref_value = 'dollars_complex',
			prefix = localize('$')
		}},
		scale_function = function ()
			return scale_number(G.GAME.dollars, 2.2 * scale, 99999, 1000000)
		end,
		maxw = 1.35,
		colours = {G.C.MONEY},
		font = G.LANGUAGES['en-us'].font,
		shadow = true,
		spacing = 2,
		bump = true,
		scale = 2.2*scale
	}
end

-- Generates the UIBox definition for Pure Visage switch/sell buttons.
---@param card Card
---@return Balatro.UIBoxDefinition
local function uidef_usesellbtn_hook_pure_visage(card)
	local button_jtml_stylesheet = {
		[".button"] = {
			align = "center-right",
			padding = 0.1,
			roundness = 0.08,
			minWidth = 1.25,
			hover = true,
			shadow = true,
			fillColour = G.C.UI.BACKGROUND_INACTIVE,
			onePress = true,
		},
		[".button-toptext"] = {
			colour = G.C.UI.TEXT_LIGHT,
			scale = 0.4,
			shadow = true
		},
		["button-btmtext1"] = {
			colour = G.C.WHITE,
			shadow = true,
			scale = 0.4
		},
		["button-btmtext2"] = {
			colour = G.C.WHITE,
			shadow = true,
			scale = 0.55
		},
	}
	local sell_button =
	{"column", style={align="center-right"}, {
		{"column", reftable=card, class="button", onclick="sell_card", ondraw="can_sell_card", {
			{"box", style={width=0.1, height=0.6}},
			{"column", style={align="top-middle"}, {
				{"row", style={align="center-middle", maxWidth=1.25}, {
					{"text", class="button-toptext", text=localize("b_sell")}
				}},
				-- no idea why jtml for this doesnt work so here
				{n=G.UIT.R, config={align = "cm"}, nodes={
					{n=G.UIT.T, config={text = localize('$'),colour = G.C.WHITE, scale = 0.4, shadow = true}},
					{n=G.UIT.T, config={ref_table = card, ref_value = G.GAME.in_corrupt_green and 'complex_sell_label' or 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
				}}
			}}
		}}
	}}
	local switch_button =
	{"column", style={align="center-right"}, {
		{"column", reftable=card, class="button", onclick="transmute_card", ondraw="can_transmute", {
			{"box", style={width=0.2, height=0.6}},
			{"column", style={align="center-middle"}, {
				{"row", style={align="center-middle", maxWidth=1.25}, {
					{"text", class="button-toptext", text="Switch"}
				}},
			}}
		}}
	}}

	local function button_row(jtml)
		return {"row", style={align="center-left"}, {jtml}}
	end

	local container =
	{"root", style={padding=0, fillColour=G.C.CLEAR}, {
		{"column", style={padding=0, align="center-left"}, {
			button_row(switch_button),
			-- spacing
			{"row", style={minHeight=0.1, fillColour=G.C.CLEAR}},
			button_row(sell_button),
		}}
	}}

	return Ovn_f.jtml_to_uiboxdef(container, button_jtml_stylesheet)
end



-----------------------------
---- UI DEFINITION HOOKS ----
-----------------------------

-- Hook to enable Corrupt Red Deck's effect
local uiboxbuttons_hook = create_UIBox_buttons
function create_UIBox_buttons()
	if G.GAME.in_corrupt_red then return uiboxbuttons_hook_c_red() end
	return uiboxbuttons_hook()
end

-- Hook to enable Corrupt Yellow Deck's displays
local uiboxhud_hook = create_UIBox_HUD
function create_UIBox_HUD()
	local ret = uiboxhud_hook()
	if G.GAME.in_corrupt_yellow then
		hud_ui_c_yellow(ret)
	elseif G.GAME.in_corrupt_green then
		hud_ui_c_green(ret)
	end
	return ret
end



---------------------------
---- UI FUNCTION HOOKS ----
---------------------------

-- Hook to insert an additional button for Pure Visage
local uidef_usesellbtn_hook = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	if card.area ~= G.jokers then return uidef_usesellbtn_hook(card) end
	if card.config.center.key == "j_ovn_pure_visage" then
		return uidef_usesellbtn_hook_pure_visage(card)
	end

	return uidef_usesellbtn_hook(card)
end

-- Hook to prevent playing if:
---- An Unobtainium card is selected
---- The first hand of the round is being drawn on Corrupt Ghost Deck
local funcs_canplay_hook = G.FUNCS.can_play
function G.FUNCS.can_play(e)
	local has_unob = false
	for _,selected_card in ipairs(G.hand.highlighted) do
		local enhancement_key = selected_card.config.center.key
		if enhancement_key == "m_ovn_unob" then
			has_unob = true
			break
		end
	end

	if has_unob or (
		G.GAME.ovn_cghost_first_hand_drawn ~= nil
		and not G.GAME.ovn_cghost_first_hand_drawn
	) then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		funcs_canplay_hook(e)
	end
end

-- Hook to prevent discarding if the first hand of the round is being drawn on Corrupt Ghost Deck
local funcs_candiscard_hook = G.FUNCS.can_discard
function G.FUNCS.can_discard(e)
	if (
		G.GAME.ovn_cghost_first_hand_drawn ~= nil
		and not G.GAME.ovn_cghost_first_hand_drawn
	) then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		funcs_candiscard_hook(e)
	end
end

-- Hook to include complex evaluation rows
local funcs_evalround_hook = G.FUNCS.evaluate_round
G.FUNCS.evaluate_round = function()
	if not G.GAME.in_corrupt_green then
		funcs_evalround_hook()
		return
	end

	total_cashout_rows = 0
	local pitch = 0.95
	local dollars = 0
	local dollars_i = 0

	-- Blind reward
	if G.GAME.chips - G.GAME.blind.chips >= 0 then
		add_round_eval_row({dollars = G.GAME.blind.dollars, name='blind1', pitch = pitch})
		pitch = pitch + 0.06
		dollars = dollars + G.GAME.blind.dollars
	else
		-- Saved by Mr. Bones
		add_round_eval_row({dollars = 0, name='blind1', pitch = pitch, saved = true})
		pitch = pitch + 0.06
	end

	-- Visual stuff
	local delay_1 = 1.3*math.min(G.GAME.blind.dollars+2, 7)/2*0.15 + 0.5
	add_simple_event('before', delay_1, function ()
		G.GAME.blind:defeat()
	end)
	delay(0.2)
	add_simple_event(nil, nil, function ()
		ease_background_colour_blind(G.STATES.ROUND_EVAL, '')
	end)

	-- Send contexts
	SMODS.calculate_context{round_eval = true}
	G.GAME.selected_back:trigger_effect({context = 'eval'})

	-- $1 per hands left
	local hands_left = G.GAME.current_round.hands_left
	if hands_left > 0 then
		local hands_reward = hands_left*(G.GAME.modifiers.money_per_hand or 1)
		add_round_eval_row({dollars = hands_reward, disp = hands_left, bonus = true, name='hands', pitch = pitch})
		pitch = pitch + 0.06
		dollars = dollars + hands_reward
	end

	-- $2i per discards left
	local discards_left = G.GAME.current_round.discards_left
	if discards_left > 0 then
		local discards_reward = discards_left*(G.GAME.modifiers.money_per_discard)
		Ovn_f.add_complex_roundeval_row({dollars = discards_reward, disp = discards_left, bonus = true, name='discards', pitch = pitch})
		pitch = pitch + 0.06
		dollars_i = dollars_i + discards_reward
	end

	-- Get dollar bonus per Joker
	local i = 0
	for _, area in ipairs(SMODS.get_card_areas('jokers')) do
		for _, _card in ipairs(area.cards) do
			local ret = _card:calculate_dollar_bonus()

			-- TARGET: calc_dollar_bonus per card
			if ret then
				i = i+1
				add_round_eval_row({dollars = ret, bonus = true, name='joker'..i, pitch = pitch, card = _card})
				pitch = pitch + 0.06
				dollars = dollars + ret
			end
		end
	end
	-- Get dollar bonus per tag
	for i = 1, #G.GAME.tags do
		local ret = G.GAME.tags[i]:apply_to_run({type = 'eval'})
		if ret then
			add_round_eval_row({dollars = ret.dollars, bonus = true, name='tag'..i, pitch = pitch, condition = ret.condition, pos = ret.pos, tag = ret.tag})
			pitch = pitch + 0.06
			dollars = dollars + ret.dollars
		end
	end

	-- Evaluate interest
	if G.GAME.dollars >= 5 then
		local interest = G.GAME.interest_amount*math.min(math.floor(G.GAME.dollars/5), G.GAME.interest_cap/5)
		add_round_eval_row({bonus = true, name='interest', pitch = pitch, dollars = interest})
		pitch = pitch + 0.06
		if not G.GAME.seeded or SMODS.config.seeded_unlocks then
			local career_stats = G.PROFILES[G.SETTINGS.profile].career_stats
			if interest == G.GAME.interest_amount*G.GAME.interest_cap/5 then
				career_stats.c_round_interest_cap_streak = career_stats.c_round_interest_cap_streak + 1
			else
				career_stats.c_round_interest_cap_streak = 0
			end
		end
		check_for_unlock({type = 'interest_streak'})
		dollars = dollars + interest
	end

	-- Evaluate complex interest
	if G.GAME.dollars_i >= 5 then
		local interest_i = math.min(math.floor(G.GAME.dollars_i/5), G.GAME.interest_cap/5)
		Ovn_f.add_complex_roundeval_row({bonus = true, name = 'interest', pitch = pitch, dollars = interest_i})
		pitch = pitch + 0.06
		dollars_i = dollars_i + interest_i
	end

	pitch = pitch + 0.06

	if total_cashout_rows > 7 then
		local total_hidden = total_cashout_rows - 7
		add_simple_event('before', 0.38, function ()
			local hidden = {n=G.UIT.R, config={align = "cm"}, nodes={
				{n=G.UIT.O, config={object = DynaText({
					string = {localize{type = 'variable', key = 'cashout_hidden', vars = {total_hidden}}}, 
					colours = {G.C.WHITE}, shadow = true, float = false, 
					scale = 0.45,
					font = G.LANGUAGES['en-us'].font, pop_in = 0
				})}}
			}}

			G.round_eval:add_child(hidden, G.round_eval:get_UIE_by_ID('bonus_round_eval'))
		end)
	end
	Ovn_f.add_cashout_button({name = 'bottom', dollars = dollars, dollars_i = dollars_i})
end

-- Hook to determine if a complex cost can be bought (Corrupt Green Deck)
local funcs_canbuy_hook = G.FUNCS.can_buy
G.FUNCS.can_buy = function(e)
	if G.GAME.in_corrupt_green then
		local cost, cost_i = Ovn_f.get_complex_cost(e.config.ref_table.cost)
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
	else
		funcs_canbuy_hook(e)
	end
end

-- Hook to determine if a complex cost can be bought-then-used (Corrupt Green Deck)
local funcs_canbuyuse_hook = G.FUNCS.can_buy_and_use
G.FUNCS.can_buy_and_use = function(e)
	if G.GAME.in_corrupt_green then
		local cost, cost_i = Ovn_f.get_complex_cost(e.config.ref_table.cost)
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
	else
		funcs_canbuyuse_hook(e)
	end
end

-- Hook to determine if a complex cost can be opened (booster packs) (Corrupt Green Deck)
local funcs_canopen_hook = G.FUNCS.can_open
G.FUNCS.can_open = function(e)
	if G.GAME.in_corrupt_green then
		local cost, cost_i = Ovn_f.get_complex_cost(e.config.ref_table.cost)
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
	else
		funcs_canopen_hook(e)
	end
end

-- Hook to determine if a complex cost can be redeemed (vouchers) (Corrupt Green Deck)
local funcs_canredeem_hook = G.FUNCS.can_redeem
G.FUNCS.can_redeem = function(e)
	if G.GAME.in_corrupt_green then
		local cost, cost_i = Ovn_f.get_complex_cost(e.config.ref_table.cost)
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
	else
		funcs_canredeem_hook(e)
	end
end