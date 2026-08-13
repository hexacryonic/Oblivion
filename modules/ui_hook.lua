-- These functions append certain behaviors onto existing UI functions
-- to easily add/conditionally replace new UI features

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. UI DEFINITION HOOKS
-- 3. UI FUNCTION HOOKS

local JTML = Ovn_f.JTML

---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

-- Generates the UIBox definition for Corrupted Red Deck play/discard buttons.
---@return UINode
local uiboxbuttons_hook_c_red = function()
	-- This is NOT based on the regular functions/UI_definitions.lua
	-- It is instead based on the Lovely dump of functions/UI_definitions.lua with Steamodded installed
	local text_scale = 0.45
	local button_height = 1.3

	local styles = {
		["action_button"] = { ---@type JTML.flex.style
			align = "top-middle",
			WH = {2.5, button_height},
			padding = 0.3,
			roundCorners = true,
			hover = true,
			shadow = true,
		},
		["row_styles"] = { align = "center-middle", padding = 0 },
		---@type JTML.text.style
		["top_label"]   = { scale = text_scale, color = G.C.UI.TEXT_LIGHT, },
		---@type JTML.text.style
		["bottom_label"] = { scale = text_scale * 0.65, color = G.C.UI.TEXT_LIGHT },
		["playdiscard_root"] = { ---@type JTML.flex.style
			WH = {1, 0.3},
			align = "center-middle",
			padding = 0.15,
			roundCorners = true,
			colour = G.C.CLEAR
		},
		["other_actions"] = { ---@type JTML.flex.style
			align = "center-middle",
			padding = 0.1,
			roundCorners = true,
			clour = G.C.UI.TRANSPARENT_DARK,
			outline = {1.5, mix_colours(G.C.WHITE, G.C.JOKER_GREY, 0.7), 1}
		},
		---@type JTML.text.style
		["sorthand_text"] = { scale = text_scale*0.8, colour = G.C.UI.TEXT_LIGHT },
		["sorthand_button"] = { ---@type JTML.flex.style
			align = "center-middle",
			WH = {0.9, 0.7},
			padding = 0.1,
			roundCorners = true,
			hover = true,
			colour = G.C.ORANGE,
			shadow = true
		},
		---@type JTML.text.style
		["sorthand_button__text"] = { scale = text_scale*0.7, colour = G.C.UI.TEXT_LIGHT }
	}

	local hand_sort_options =
	JTML.flex{mode="row", style=styles.other_actions, {
		JTML.flex{mode="row", style=styles.row_styles, {
			JTML.text{style={styles.row_styles, styles.sorthand_text}, text=localize('b_sort_hand')},
			JTML.flex{mode="column", style={styles.row_styles, {padding=0.1}}, {
				JTML.flex{style=styles.sorthand_button, on_click="sort_hand_value", {
					JTML.text{style=styles.sorthand_button__text, text=localize('k_rank')}
				}},
				JTML.flex{style=styles.sorthand_button, on_click="sort_hand_suit", {
					JTML.text{style=styles.sorthand_button__text, text=localize('k_suit')}
				}},
			}}
		}}
	}}

	local play_click = {"play_cards_from_highlighted", one_press=true}
	local play_button =
	JTML.flex{mode="row", id="play_button", style={styles.action_button, {fillColour=G.C.BLUE}}, on_click=play_click, on_draw="can_play", {
		JTML.text{style={styles.row_styles, styles.top_label}, on_draw='set_button_pip', gamepad_focus={button='x', orientation='bm'}, text=localize('b_play_hand')},
		JTML.text{style={styles.row_styles, styles.bottom_label}, reference={SMODS.hand_limit_strings, "play"}}
	}}

	local discard_click = {"discard_cards_from_held", one_press=true}
	local discard_button =
	JTML.flex{mode="row", id="discard_button", style={styles.action_button, {fillColour=G.C.RED}}, on_click=discard_click, on_draw="can_weirddiscard", {
		JTML.text{style={styles.row_styles, styles.top_label}, on_draw='set_button_pip', gamepad_focus={button='y', orientation='bm'}, text=localize('b_ovn_datcard')},
		JTML.text{style={styles.row_styles, styles.bottom_label}, reference={SMODS.hand_limit_strings, "discard"}}
	}}

	return
	JTML.flex{mode="column", style=styles.playdiscard_root, {
		G.SETTINGS.play_button_pos == 1 and discard_button or play_button,
		hand_sort_options,
		G.SETTINGS.play_button_pos == 1 and play_button or discard_button,
	}}
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

---@class sell_and_other_buttons.args
---@field card Card
---@field other_order? "first"|"last"
---@field other_on_click? string
---@field other_on_draw? string
---@field other_label? string

---@param args table
---@return UINode
local function sell_and_other_buttons(args)
	args.other_order = args.other_order or "first"
	local card = args.card
	local sell_button_ref = (
		Ovn_f.on_deck('c_green')
		and {card.ability, 'complex_sell_label'}
		or {card, 'sell_cost_label'}
	)

	local styles = {
		["button"] = {
			align = "center-right",
			padding = 0.1,
			roundCorners = true,
			WH = {1.25,nil},
			hover = true,
			shadow = true,
			colour = G.C.UI.BACKGROUND_INACTIVE,
		},
		["toptext"] = {
			colour = G.C.UI.TEXT_LIGHT,
			scale = 0.4,
			shadow = true
		},
		["btmtext1"] = {
			colour = G.C.WHITE,
			shadow = true,
			scale = 0.4
		},
		["btmtext2"] = {
			colour = G.C.WHITE,
			shadow = true,
			scale = 0.55
		},
	}

	local sell_button =
	JTML.flex{mode="column", style={align="center-right"}, {
		JTML.flex{mode="column", style={styles.button}, reference={card, nil}, on_click={"sell_card", one_press=true}, on_draw="can_sell_card", {
			JTML.flex{style={WH={0.1, 0.6}}},
			JTML.flex{mode="row", style={align="center-middle"}, {
				JTML.flex{style={align="center-middle", wh={1.25,nil}}, {
					JTML.text{style=styles.toptext, text=localize("b_sell")}
				}},
				JTML.flex{style={align="center-middle"}, {
					JTML.text{style=styles.btmtext1, text=localize('$')},
					JTML.text{style=styles.btmtext2, reference=sell_button_ref},
				}}
			}}
		}}
	}}

	local other_button =
	JTML.flex{mode="column", style={align="center-right"}, {
		JTML.flex{mode="column", style={styles.button}, reference={card, nil}, on_click={args.other_on_click, one_press=true}, on_draw=args.other_on_draw, {
			JTML.flex{style={WH={0.2, 0.6}}},
			JTML.flex{mode="row", style={align="center-middle"}, {
				JTML.flex{style={align="center-middle", wh={1.25,nil}}, {
					JTML.text{style=styles.toptext, text=args.other_label}
				}}
			}}
		}}
	}}

	local top_button = args.other_order == "last" and sell_button or other_button
	local btm_button = args.other_order == "last" and other_button or sell_button
	return
	JTML.flex{mode="column", style={padding=0, colour=G.C.CLEAR}, {
		JTML.flex{mode="row", style={padding=0, align="center-left"}, {
			JTML.flex{mode="column", style={align="center-left"}, {top_button}},
			JTML.flex{style={WH={nil,0.1}, colour=G.C.CLEAR}},
			JTML.flex{mode="column", style={align="center-left"}, {btm_button}},
		}}
	}}
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

function Ovn_f.poo()
	local suit_count = {}
	local suit_list = {}
	for _,card in ipairs(G.playing_cards) do
		if not SMODS.has_no_suit(card) then
			if not suit_count[card.base.suit] then
				suit_count[card.base.suit] = 0
				table.insert(suit_list, card.base.suit)
			end
			suit_count[card.base.suit] = suit_count[card.base.suit] + 1
		end
	end
	table.sort(suit_list, function(a,b)
		return suit_count[a] < suit_count[b] or SMODS.Suits[a].sort_id > SMODS.Suits[b].sort_id
	end)

	local w,h = 75, 75
	local c = SMODS.CanvasSprite{
		W=2,H=2, canvasW=w,canvasH=h, canvasScale=1
	}
	love.graphics.push()
	love.graphics.origin()
	c.canvas:renderTo(function ()
		local previous_angle = -math.pi/2
		for _,suit in ipairs(suit_list) do
			local colour = lighten(G.C.SUITS[suit], 0.1)
			local arclength = -2*math.pi*(suit_count[suit]/#G.playing_cards)
			love.graphics.setColor(unpack(colour))
			love.graphics.arc("fill", w/2, w/2, w/2, previous_angle, previous_angle + arclength)
			previous_angle = previous_angle + arclength
		end
	end)
	love.graphics.pop()
	return
	{n=G.UIT.C, config={align="cm", padding=0.1}, nodes={
		{n=G.UIT.O, config={ minw=2, minh=2, colour=G.C.RED, object=c }}
	}}
end

-- Hook to show pie chart on Corrupt Checkered Deck
local uidef_deckpreview_hook = G.UIDEF.deck_preview
function G.UIDEF.deck_preview(args)
	local t = uidef_deckpreview_hook(args)
	if Ovn_f.on_deck("c_checkered") then
		table.insert(t.nodes[1].nodes[1].nodes, Ovn_f.poo())
	end
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
			shadow = true
		})
		table.insert(name_rows, corrupted_from_row)
	end
	return ret_val
end

-- Hook to insert additional buttons for several Jokers
local uidef_usesellbtn_hook = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
	local uidef = uidef_usesellbtn_hook(card)
	if card.area ~= G.jokers then return uidef end
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

	return uidef
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