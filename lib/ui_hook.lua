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

local cuih = create_UIBox_HUD
function create_UIBox_HUD()
	local ret = cuih()
	if G.GAME.in_corrupt_yellow then
		hud_ui_c_yellow(ret)
	end
	return ret
end

local easediscard_hook = ease_discard
function ease_discard(mod, instant, silent)
	if not G.GAME.in_corrupt_yellow then
		easediscard_hook(mod, instant, silent)
	end
end

local easehand_hook = ease_hands_played
function ease_hands_played(mod, instant)
	if not G.GAME.in_corrupt_yellow then
		easehand_hook(mod, instant)
	end
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

----

local function quasi_operator(scale, text, colour)
	return
	{n=G.UIT.C, config={align = "cm"}, nodes={
		{n=G.UIT.T, config={text = text, lang = G.LANGUAGES['en-us'], scale = scale, colour = colour or G.C.WHITE, shadow = true}},
	}}
end

local function chips_container(scale, w, h)
	return
	{n=G.UIT.C, config={align = 'cm', id = 'hand_chips_container'}, nodes = {
		SMODS.GUI.score_container({
			type = 'chips',
			align = 'cm',
			scale = scale,
			w = w, h = h
		})
	}}
end

local function mult_container(scale, w, h)
	return
	{n=G.UIT.C, config={align = 'cm', id = 'hand_mult_container'}, nodes = {
		SMODS.GUI.score_container {
			type = 'mult',
			align = 'cm',
			scale = scale,
			w = w, h = h
		}
	}}
end

local function instability_container(scale, w, h)
	return
	{n=G.UIT.C, config={align = 'cm', id = 'instability_container'}, nodes = {
		SMODS.GUI.score_container {
			type = 'ovn_instability',
			align = 'cm',
			colour = G.C.RARITY['ovn_corrupted'],
			scale = scale,
			w = w, h = h
		}
	}}
end

-- Instability hooking
local handchipscontainer_hook = SMODS.GUI.hand_chips_container
function SMODS.GUI.hand_chips_container(scale)
	if getmetatable(G.GAME.current_scoring_calculation).__index == SMODS.Scoring_Calculations["ovn_instable"] then
		-- sincerest apologies for these magic numbers
		-- division occurs here to anticipate scale changes

		scale = scale/0.4 -- 0.4 is default scale in score_container, taken to be actual value of scale
		local w = 1.2*scale -- 1.2 is defined width in OG code for instability UI
		local h = 0.7*scale -- 0.7 is defined height in OG code
		 -- 2.3 is text scale multiplier for score_container
		local text_scale = 0.69*scale/2.3 -- 0.69 is size of value text in OG code
		local operator_scale = 0.5*scale -- 0.5 is size of operator text in OG code

		return
		{n=G.UIT.R, config={align = "cm", minh = 1, padding = 0.1}, nodes={
			quasi_operator(operator_scale, "(", G.C.RARITY['ovn_corrupted']),
			chips_container(text_scale, w, h),
			quasi_operator(operator_scale, "X", G.C.UI_MULT),
			mult_container(text_scale, w, h),
			quasi_operator(operator_scale, ")", G.C.RARITY['ovn_corrupted']),
			quasi_operator(operator_scale, "^", G.C.RARITY['ovn_corrupted']),
			instability_container(text_scale, w, h)
		}}
	end
	return handchipscontainer_hook(scale)
end