local b_uibox_hook_c_red = function()
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
local b_uibox_hook = create_UIBox_buttons
function create_UIBox_buttons()
	if G.GAME.in_corrupt_red then return b_uibox_hook_c_red() end
	return b_uibox_hook()
end

----

-- Add Instability to UI (thanks math)
local cuih = create_UIBox_HUD
function create_UIBox_HUD()
	local ret = cuih()
	if G.GAME.in_corrupt_plasma then
		local hand_UI = ret.nodes[1].nodes[1].nodes[4].nodes[1].nodes[2].nodes
		-- Cleanly remove existing DynaText (prevent memory leaks)
		hand_UI[1].nodes[1].config.object:remove()
		hand_UI[1].nodes[2].config.object:remove()
		hand_UI[3].nodes[1].config.object:remove()
		hand_UI[3].nodes[3].config.object:remove()

		local jtml_stylesheet = {
			[".deco_text"] = {align = "center-middle"},
			[".deco_text__text"] = {scale = 0.5, colour = G.C.RARITY['ovn_corrupted'], shadow = true},
			[".score_area"] = {
				align = "center-middle",
				minimumWidth = 1.2,
				minimumHeight = 0.7,
				roundness = 0.1,
				emboss = 0.05
			},
			[".score_area__flame"] = {width = 0, height = 0},
		}

		local function quick_dynatext(type)
			return DynaText {
				string = {
					{ref_table = G.GAME.current_round.current_hand, ref_value = type .. "_text"}
				},
				colours = {G.C.UI.TEXT_LIGHT},
				font = G.LANGUAGES['en-us'].font,
				shadow = true,
				float = true,
				scale = 0.3*2.3
			}
		end

		local function quick_deco_text(text, color)
			local decotxt_jtml =
			{"column", class="deco_text", {
				{"text", class="deco_text__text", text=text, language=G.LANGUAGES['en-us'],}
			}}
			if color then decotxt_jtml[2][1].style={colour = color} end
			return Ovn_f.jtml_to_uiboxdef(decotxt_jtml, jtml_stylesheet)
		end

		local function quick_score_area(type, fillcolor)
			local type2 = type == "chip" and "chips" or type
			local scorearea_jtml =
			{"column", id="hand_"..type.."_area", class="score_area", style={fillColour = fillcolor}, {
				{"object", id="flame_"..type2, class="score_area__flame", ondraw="flame_handler", norole=true, object=Moveable(0,0,0,0)},
				{"object", id="hand_"..type2, class="score_area__text", ondraw="hand_"..type.."_UI_set", object=quick_dynatext(type)},
			}}
			return Ovn_f.jtml_to_uiboxdef(scorearea_jtml, jtml_stylesheet)
		end

		local hand_ui_jtml = {
			quick_deco_text("("),
			quick_score_area("chip", G.C.UI_CHIPS),
			quick_deco_text("X", G.C.UI_MULT),
			quick_score_area("mult", G.C.UI_MULT),
			quick_deco_text(")"),
			quick_deco_text("^"),
			quick_score_area("inst", G.C.UI_INST),
		}
		ret.nodes[1].nodes[1].nodes[4].nodes[1].nodes[2].nodes = hand_ui_jtml
	end
	return ret
end

----

local canplay_hook = G.FUNCS.can_play
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
		canplay_hook(e)
	end
end

local candiscard_hook = G.FUNCS.can_discard
function G.FUNCS.can_discard(e)
	if (
		G.GAME.ovn_cghost_first_hand_drawn ~= nil
		and not G.GAME.ovn_cghost_first_hand_drawn
	) then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
	else
		candiscard_hook(e)
	end
end