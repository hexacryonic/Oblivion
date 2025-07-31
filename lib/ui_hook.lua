local b_uibox_hook = create_UIBox_buttons
local b_uibox_corrupt_red_deck = function()
	-- This is NOT based on the regular functions/UI_definitions.lua
	-- It is instead based on the Lovely dump of functions/UI_definitions.lua with Steamodded installed
	local text_scale = 0.45
	local button_height = 1.3
	local play_button = {n=G.UIT.C, config={id = 'play_button', align = "tm", minw = 2.5, padding = 0.3, r = 0.1, hover = true, colour = G.C.BLUE, button = "play_cards_from_highlighted", one_press = true, shadow = true, func = 'can_play'}, nodes={
	{n=G.UIT.R, config={align = "bcm", padding = 0}, nodes={
		{n=G.UIT.T, config={text = localize('b_play_hand'), scale = text_scale, colour = G.C.UI.TEXT_LIGHT, focus_args = {button = 'x', orientation = 'bm'}, func = 'set_button_pip'}}
	}},
	{n=G.UIT.R, config={align = "bcm", padding = 0}, nodes = {
		{n=G.UIT.T, config={ref_table = SMODS.hand_limit_strings, ref_value = 'play', scale = text_scale * 0.65, colour = G.C.UI.TEXT_LIGHT}}
	}},
	}}

	local discard_button = {n=G.UIT.C, config={id = 'discard_button',align = "tm", padding = 0.3, r = 0.1, minw = 2.5, minh = button_height, hover = true, colour = G.C.RED, button = "discard_cards_from_held", one_press = true, shadow = true, func = 'can_weirddiscard'}, nodes={
	{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
		{n=G.UIT.T, config={text = "Datcard", scale = text_scale, colour = G.C.UI.TEXT_LIGHT, focus_args = {button = 'y', orientation = 'bm'}, func = 'set_button_pip'}}
	}},
	{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
		{n=G.UIT.T, config={ref_table = SMODS.hand_limit_strings, ref_value = 'discard', scale = text_scale * 0.65, colour = G.C.UI.TEXT_LIGHT}}
	}},
	}}

	local t = {
	n=G.UIT.ROOT, config = {align = "cm", minw = 1, minh = 0.3,padding = 0.15, r = 0.1, colour = G.C.CLEAR}, nodes={
		G.SETTINGS.play_button_pos == 1 and discard_button or play_button,

		{n=G.UIT.C, config={align = "cm", padding = 0.1, r = 0.1, colour =G.C.UI.TRANSPARENT_DARK, outline = 1.5, outline_colour = mix_colours(G.C.WHITE,G.C.JOKER_GREY, 0.7), line_emboss = 1}, nodes={
			{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
			{n=G.UIT.R, config={align = "cm", padding = 0}, nodes={
				{n=G.UIT.T, config={text = localize('b_sort_hand'), scale = text_scale*0.8, colour = G.C.UI.TEXT_LIGHT}}
			}},
			{n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
				{n=G.UIT.C, config={align = "cm", minh = 0.7, minw = 0.9, padding = 0.1, r = 0.1, hover = true, colour =G.C.ORANGE, button = "sort_hand_value", shadow = true}, nodes={
				{n=G.UIT.T, config={text = localize('k_rank'), scale = text_scale*0.7, colour = G.C.UI.TEXT_LIGHT}}
				}},
				{n=G.UIT.C, config={align = "cm", minh = 0.7, minw = 0.9, padding = 0.1, r = 0.1, hover = true, colour =G.C.ORANGE, button = "sort_hand_suit", shadow = true}, nodes={
				{n=G.UIT.T, config={text = localize('k_suit'), scale = text_scale*0.7, colour = G.C.UI.TEXT_LIGHT}}
				}}
			}}
			}}
		}},

		G.SETTINGS.play_button_pos == 1 and play_button or discard_button,
		}
	}
	return t
end
function create_UIBox_buttons()
	if G.GAME.in_corrupt_red then return b_uibox_corrupt_red_deck() end
	return b_uibox_hook()
end

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
		hand_UI = {
			{n=G.UIT.C, config={align = "cm"}, nodes={
			{n=G.UIT.T, config={text = "(", lang = G.LANGUAGES['en-us'], scale = 0.5, colour = G.C.RARITY['ovn_corrupted'], shadow = true}},
			}},
			{n=G.UIT.C, config={align = "cm", minw = 1.2, minh =0.7, r = 0.1,colour = G.C.UI_CHIPS, id = 'hand_chip_area', emboss = 0.05}, nodes={
				{n=G.UIT.O, config={func = 'flame_handler',no_role = true, id = 'flame_chips', object = Moveable(0,0,0,0), w = 0, h = 0}},
				{n=G.UIT.O, config={id = 'hand_chips', func = 'hand_chip_UI_set',object = DynaText({string = {{ref_table = G.GAME.current_round.current_hand, ref_value = "chip_text"}}, colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, shadow = true, float = true, scale = 0.3*2.3})}},
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
			{n=G.UIT.T, config={text = "X", lang = G.LANGUAGES['en-us'], scale = 0.5, colour = G.C.UI_MULT, shadow = true}},
			}},
			{n=G.UIT.C, config={align = "cm", minw = 1.2, minh=0.7, r = 0.1,colour = G.C.UI_MULT, id = 'hand_mult_area', emboss = 0.05}, nodes={
			{n=G.UIT.O, config={func = 'flame_handler',no_role = true, id = 'flame_mult', object = Moveable(0,0,0,0), w = 0, h = 0}},
			{n=G.UIT.O, config={id = 'hand_mult', func = 'hand_mult_UI_set',object = DynaText({string = {{ref_table = G.GAME.current_round.current_hand, ref_value = "mult_text"}}, colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, shadow = true, float = true, scale = 0.3*2.3})}},
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
			{n=G.UIT.T, config={text = ")", lang = G.LANGUAGES['en-us'], scale = 0.5, colour = G.C.RARITY['ovn_corrupted'], shadow = true}},
			}},
			{n=G.UIT.C, config={align = "cm"}, nodes={
			{n=G.UIT.T, config={text = "^", lang = G.LANGUAGES['en-us'], scale = 0.5, colour = G.C.RARITY['ovn_corrupted'], shadow = true}},
			}},
			{n=G.UIT.C, config={align = "cm", minw = 1.2, minh=0.7, r = 0.1,colour = G.C.UI_INST, id = 'hand_inst_area', emboss = 0.05}, nodes={
			{n=G.UIT.O, config={func = 'flame_handler',no_role = true, id = 'flame_inst', object = Moveable(0,0,0,0), w = 0, h = 0}},
			{n=G.UIT.O, config={id = 'hand_inst', func = 'hand_inst_UI_set',object = DynaText({string = {{ref_table = G.GAME.current_round.current_hand, ref_value = "inst_text"}}, colours = {G.C.UI.TEXT_LIGHT}, font = G.LANGUAGES['en-us'].font, shadow = true, float = true, scale = 0.3*2.3})}},
			}},
		}
		ret.nodes[1].nodes[1].nodes[4].nodes[1].nodes[2].nodes = hand_UI
	end
	return ret
end