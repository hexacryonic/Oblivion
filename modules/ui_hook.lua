-- These functions append certain behaviors onto existing UI functions
-- to easily add/conditionally replace new UI features

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. UI DEFINITION HOOKS
-- 3. UI FUNCTION HOOKS



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

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

-- On Corrupt Green Deck, replaces the dollar display with a complex dollar display.
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
					{n=G.UIT.T, config={ref_table = Ovn_f.on_deck('c_green') and card.ability or card, ref_value = Ovn_f.on_deck('c_green') and 'complex_sell_label' or 'sell_cost_label',colour = G.C.WHITE, scale = 0.55, shadow = true}}
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
	if Ovn_f.on_deck('c_red') then return uiboxbuttons_hook_c_red() end
	return uiboxbuttons_hook()
end

-- Hook to:
---- enable Corrupt Yellow Deck's hand/discard cost display
---- enable Corrupt Green Deck's complex dollar display
local uiboxhud_hook = create_UIBox_HUD
function create_UIBox_HUD()
	local ret = uiboxhud_hook()
	if Ovn_f.on_deck('c_yellow') then
		hud_ui_c_yellow(ret)
	elseif Ovn_f.on_deck('c_green') then
		hud_ui_c_green(ret)
	end
	return ret
end



---------------------------
---- UI FUNCTION HOOKS ----
---------------------------

-- Hook to add additional text to card tooltips, especially those involved with Corruption
local uidef_cardhpopup_hook = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
	local ret_val = uidef_cardhpopup_hook(card)
	local name_rows = ret_val.nodes[1].nodes[1].nodes[1].nodes[1].nodes
	local scale = 0.275

	local j_locs = G.localization.descriptions.Joker
	if (
		card
		and card.config.center
		and card.config.center.key
		and j_locs[card.config.center.key]
		and j_locs[card.config.center.key].corrupted_from
	) then
		local corrupted_from_list = j_locs[card.config.center.key].corrupted_from
		local corrupted_from_row1 =
		{n=G.UIT.R, config={align="cm"}, nodes={
			{n=G.UIT.T, config={align="cm", colour = G.C.WHITE, text=localize('ovn_corrupted_from').." ", scale=scale, padding=0}},
			{n=G.UIT.T, config={align="cm", colour = G.C.ORANGE, text=corrupted_from_list[1], scale=scale, padding=0}},
		}}
		table.insert(name_rows, corrupted_from_row1)

		for i=2,#corrupted_from_list do
			local corrupted_from_text = corrupted_from_list[i]
			local corrupted_from_row =
			{n=G.UIT.R, config={align="cm"}, nodes={
				{n=G.UIT.T, config={align="cm", colour = G.C.ORANGE, text=corrupted_from_text, scale=scale, padding=0}},
			}}
			table.insert(name_rows, corrupted_from_row)
		end
	end
	return ret_val
end

-- Hook to insert an additional button for Pure Visage
local uidef_usesellbtn_hook = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	if card.area ~= G.jokers then return uidef_usesellbtn_hook(card) end
	if card.config.center.key == "j_ovn_pure_visage" then
		return uidef_usesellbtn_hook_pure_visage(card)
	end

	return uidef_usesellbtn_hook(card)
end

-- Hook to prevent playing if an Unobtainium card is selected
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
	funcs_canplay_hook(e)
end

-- Hook to reset played hand status for the round
local funcs_cashout_hook = G.FUNCS.cash_out
function G.FUNCS.cash_out(e)
	funcs_cashout_hook(e)
	G.GAME.current_round.played_royal_flush = false
	G.GAME.current_round.played_straight_spec = false
end

-- Hook to reset instability volume after using a consumable (often the object used in mass-suit change)
-- (See 0-0 SCORING PARAMETER Instability - Oblivion.play_instability_noise == false if G.STATE == G.STATES.PLAY_TAROT;
-- The state is set as such in G.FUNCS.use_card)
local funcs_usecard_hook = G.FUNCS.use_card
G.FUNCS.use_card = function(e, mute, nosave)
	funcs_usecard_hook(e, mute, nosave)
	Oblivion.play_instability_noise = true
end