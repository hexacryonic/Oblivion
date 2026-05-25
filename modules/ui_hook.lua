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
			{"text", class="top_label", text=localize('b_ovn_datcard'), ondraw='set_button_pip', style={focus = {button = 'y', orientation = 'bm'}}}
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
	[".button-btmtext1"] = {
		colour = G.C.WHITE,
		shadow = true,
		scale = 0.4
	},
	[".button-btmtext2"] = {
		colour = G.C.WHITE,
		shadow = true,
		scale = 0.55
	},
}

---@class sell_and_other_buttons.args
---@field card Card
---@field other_order? "first"|"last"
---@field other_on_click? string
---@field other_on_draw? string
---@field other_label? string

---@param args table
---@return Balatro.UIBoxDefinition
local function sell_and_other_buttons(args)
	args.other_order = args.other_order or "first"
	local card = args.card
	local button_btmtext2_ref_table = Ovn_f.on_deck('c_green') and card.ability or card
	local button_btmtext2_ref_value = Ovn_f.on_deck('c_green') and 'complex_sell_label' or 'sell_cost_label'

	local sell_button =
	{"column", style={align="center-right"}, {
		{"column", reftable=card, class="button", onclick="sell_card", ondraw="can_sell_card", {
			{"box", style={width=0.1, height=0.6}},
			{"column", style={align="top-middle"}, {
				{"row", style={align="center-middle", maxWidth=1.25}, {
					{"text", class="button-toptext", text=localize("b_sell")}
				}},
				{"row", style={align="center-middle"}, {
					{"text", class="button-btmtext1", text = localize('$')},
					{"text", class="button-btmtext2", reftable=button_btmtext2_ref_table, refvalue=button_btmtext2_ref_value}
				}},
			}}
		}}
	}}

	local other_button =
	{"column", style={align="center-right"}, {
		{"column", reftable=card, class="button", onclick=args.other_on_click, ondraw=args.other_on_draw, {
			{"box", style={width=0.2, height=0.6}},
			{"column", style={align="center-middle"}, {
				{"row", style={align="center-middle", maxWidth=1.25}, {
					{"text", class="button-toptext", text=args.other_label}
				}},
			}}
		}}
	}}

	local spacing = {"row", style={minHeight=0.1, fillColour=G.C.CLEAR}}
	local nodes
	if args.other_order == "first" then
		nodes = {
			{"row", style={align="center-left"}, {other_button}},
			-- spacing
			spacing,
			{"row", style={align="center-left"}, {sell_button}},
		}
	elseif args.other_order == "last" then
		nodes = {
			{"row", style={align="center-left"}, {sell_button}},
			-- spacing
			spacing,
			{"row", style={align="center-left"}, {other_button}},
		}
	end

	local container =
	{"root", style={padding=0, fillColour=G.C.CLEAR}, {
		{"column", style={padding=0, align="center-left"}, nodes}
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

-- Hook to add the warning text element
local uidef_runsetup_hook = G.UIDEF.run_setup_option
function G.UIDEF.run_setup_option(type)
	local t = uidef_runsetup_hook(type)

	local warning_text_def =
	{n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
		{n=G.UIT.T, config={id = 'warning_text_deck', ref_table = Oblivion, ref_value = "ovn_c_erratic_warn", scale = 0.4, colour = G.C.CLEAR}}
	}}

	local poopshit = t.nodes
	table.insert(poopshit, warning_text_def)

	return t
end



---------------------------
---- UI FUNCTION HOOKS ----
---------------------------

-- Hook for Corrupt Erratic Deck warning
local funcs_setuprun_hook = G.FUNCS.start_setup_run
function G.FUNCS.start_setup_run(e)
	if (
		Oblivion.config.disable_c_erratic_warning
		or not e
		or G.GAME.viewed_back.name ~= "b_ovn_c_erratic"
		or G.SETTINGS.current_setup == 'Continue'
	) then
		funcs_setuprun_hook(e)
		return
	end

	-- this would have been three clicks, each changing the text
	-- but for some god damn reason changing Oblivion.ovn_c_erratic_warn (ref_value) crashes the game
	-- at engine/ui.lua "self.config.object:set_role(self.config.role[...]" attempt to index field "object" (a nil value)
	-- If anyone can fix this please lmk thx -Oin

	e.warning_countdown = (e.warning_countdown or 0) + 1
	--if e.warning_countdown >= 4 then
	if e.warning_countdown >= 2 then
		funcs_setuprun_hook(e)
		return
	end

	--Oblivion.ovn_c_erratic_warn = localize("k_ovn_c_erratic_warn_" .. e.warning_countdown)

	local warning_text = e.UIBox:get_UIE_by_ID('warning_text_deck')
	warning_text:juice_up()
    warning_text.config.colour = G.C.WHITE
    warning_text.config.shadow = true
    e.config.disable_button = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06, blockable = false, blocking = false, func = function()
      play_sound('tarot2', 0.76, 0.4);return true end}))

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.35, blockable = false, blocking = false, func = function()
      e.config.disable_button = nil;return true end}))

    play_sound('tarot2', 1, 0.4)
end

-- Hook to add additional text to card tooltips, especially those involved with Corruption
local uidef_cardhpopup_hook = G.UIDEF.card_h_popup
function G.UIDEF.card_h_popup(card)
	local ret_val = uidef_cardhpopup_hook(card)
	-- ret_val and ret_val.nodes and ret_val.nodes[1] and ret_val.nodes[1].nodes ...
	local name_rows = Ovn_f.descend_table{ret_val, "nodes", 1, "nodes", 1, "nodes", 1, "nodes", 1, "nodes"}
	if not name_rows then return ret_val end
	local scale = 0.275

	local j_locs = G.localization.descriptions.Joker
	if (
		Ovn_f.descend_table{card, "config", "center", "key"}
		and card.config.center.discovered
		and Ovn_f.descend_table{j_locs, card.config.center.key, "corrupted_from"}
	) then
		local corrupted_from_list = SMODS.shallow_copy(j_locs[card.config.center.key].corrupted_from)
		-- Our surprise tool that makes this code so much cleaner
		corrupted_from_list[1] = localize('ovn_corrupted_from') .. " " .. corrupted_from_list[1]
		local corrupted_from_row = Ovn_f.localize_desc(corrupted_from_list, {
			text_colour = G.C.WHITE,
			scale = scale/0.32,
			align = "middle",
		})
		table.insert(name_rows, corrupted_from_row)
	end
	return ret_val
end

-- Hook to insert additional buttons for several Jokers
local uidef_usesellbtn_hook = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	if card.config.center.key == "j_ovn_pure_visage" then
		return sell_and_other_buttons{
			card = card,
			other_on_click = "transmute_card",
			other_on_draw = "can_transmute",
			other_label = localize("b_ovn_switch"),
			other_order = "first"
		}
	elseif card.config.center.key == "j_ovn_supplydrop" then
		local label = localize("b_ovn_store")
		local on_draw = "supply_can_store"
		local on_click = "supply_store"

		local save_file = G.PROFILES[G.SETTINGS.profile]
		if save_file.ovn_supply_drop then
			label = localize("b_ovn_empty")
			on_draw = "supply_can_empty"
			on_click = "supply_empty"
		end

		return sell_and_other_buttons{
			card = card,
			other_on_click = on_click,
			other_on_draw = on_draw,
			other_label = label,
			other_order = "first"
		}
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

	if has_unob then
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
	else
		funcs_canplay_hook(e)
	end
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

-- Hook to resize overlay in Credits menu
local funcs_changetab_hook = G.FUNCS.change_tab
function G.FUNCS.change_tab(e)
	funcs_changetab_hook(e)
	if G.OVERLAY_MENU then G.OVERLAY_MENU:recalculate() end
end