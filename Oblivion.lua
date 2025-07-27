SMODS.current_mod.optional_features = {
	retrigger_joker = true,
	post_trigger = true,
	cardareas = {
		unscored = true,
		deck = true,
		discard = true,
	}
}

if not Oblivion then Oblivion = {} end
Oblivion.f = {}
Oblivion.mod_path = tostring(SMODS.current_mod.path)

SMODS.current_mod.description_loc_vars = function()
	return {
		background_colour = G.C.CLEAR,
		text_colour = G.C.WHITE,
		scale = 1.2
	}
end

local function load_directory(folder_name)
	local mod_path = Oblivion.mod_path
	local files = NFS.getDirectoryItems(mod_path .. folder_name)
	for _,file_name in ipairs(files) do
		print("[OBLIVION] Loading file " .. file_name)
		local file_format = ("%s/%s")
		local file_func, err = SMODS.load_file(file_format:format(folder_name, file_name))
		if err then error(err) end --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
		file_func()
	end
end

load_directory("lib")
load_directory("load-assets")
load_directory("items")

-- Mapping this way so other mods can add define_corruption if it's nonexistent
-- and thus define their own corruptions
if not Oblivion.corruption_map then Oblivion.corruption_map = {} end
local cmap = Oblivion.corruption_map
cmap["j_joker"]            = "j_ovn_darkjoker"
cmap["j_fibonacci"]        = "j_ovn_lucasseries"
cmap["j_reserved_parking"] = "j_ovn_perpendicular"
cmap["j_gift"]             = "j_ovn_supplydrop"
cmap["j_acrobat"]          = "j_ovn_yolo"
cmap["j_pareidolia"]       = "j_ovn_pmo"
cmap["j_ring_master"]      = "j_ovn_showneverends"
cmap["j_droll"]            = "j_ovn_bombastic"
cmap["j_crafty"]           = "j_ovn_insightful"
cmap["j_tribe"]            = "j_ovn_breach"
cmap["j_lusty_joker"]      = "j_ovn_prideful"
cmap["j_wrathful_joker"]   = "j_ovn_prideful"
cmap["j_gluttenous_joker"] = "j_ovn_prideful"
cmap["j_greedy_joker"]     = "j_ovn_prideful"
cmap["j_cavendish"]        = "j_ovn_cultivar"
cmap["j_hologram"]         = "j_ovn_apartfalling"
cmap["j_gros_michel"]      = "j_ovn_aeon"

if not Oblivion.corruption_condition then Oblivion.corruption_condition = {} end
Oblivion.corruption_condition["j_gros_michel"] = function()
	return G.GAME and G.GAME.corruptiblemichel
end

-- Generates immediately after the game finishes loading
G.E_MANAGER:add_event(Event {
	blocking = false,
	func = function()
		Oblivion.purity_map = {}
		local pmap = Oblivion.purity_map

		for pure_key,corrupt_key in pairs(Oblivion.corruption_map) do
			if not pmap[corrupt_key] then
				pmap[corrupt_key] = pure_key
			elseif type(pmap[corrupt_key]) == "string" then
				pmap[corrupt_key] = {pmap[corrupt_key]}
				table.insert(pmap[corrupt_key], pure_key)
			else
				table.insert(pmap[corrupt_key], pure_key)
			end
		end

		-- Purity map entries map to either a string (only pure form) or a list of strings (list of pure forms)
		return true
	end
})

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

G.C.INST = HEX('04248F')
G.C.UI_INST = G.C.INST
G.FUNCS.hand_inst_UI_set = function(e)
	local new_inst_text = number_format(((G.GAME and G.GAME.instability) or 1))
	if new_inst_text ~= G.GAME.current_round.current_hand.inst_text then
		G.GAME.current_round.current_hand.inst_text = new_inst_text
		e.config.object.scale = scale_number(G.GAME.current_round.current_hand.inst, 0.69, 1000)
		e.config.object:update_text()
		if not G.TAROT_INTERRUPT_PULSE then G.FUNCS.text_super_juice(e, math.max(0,math.floor(math.log10(type(G.GAME.current_round.current_hand.inst) == 'number' and G.GAME.current_round.current_hand.inst or 1)))) end
	end
end

----

local function get_cards_to_discard()
	local cards_to_discard = {}

	for i = 1, #G.hand.cards do
		cards_to_discard[#cards_to_discard + 1] = G.hand.cards[i]
	end

	-- (Iterate backwards due to table.remove shifting stuff around)
	for i = #cards_to_discard, 1, -1 do
		for _,selected_card in ipairs(G.hand.highlighted) do
			if cards_to_discard[i] == selected_card then
				table.remove(cards_to_discard, i)
			end
		end
	end

	return cards_to_discard
end

local function send_discard_contexts(cards_to_discard)
	local discarded_cards = {}
	local destroyed_cards = {}
	local current_jokers = G.jokers.cards

	for i, current_card_to_discard in ipairs(cards_to_discard) do
		current_card_to_discard:calculate_seal({discard = true})
		local card_is_removed = false

		for _,current_joker in ipairs(current_jokers) do
			local card_evaluation = current_joker:calculate_joker({discard = true, other_card = current_card_to_discard, full_hand = cards_to_discard})
			if card_evaluation ~= nil then
				if card_evaluation.remove then card_is_removed = true end
				card_eval_status_text(current_joker, 'jokers', nil, 1, nil, card_evaluation)
			end
		end

		table.insert(discarded_cards, current_card_to_discard)

		if card_is_removed then
			table.insert(destroyed_cards, current_card_to_discard)
			if current_card_to_discard.ability.name == 'Glass Card' then
				current_card_to_discard:shatter()
			else
				current_card_to_discard:start_dissolve()
			end
		else
			current_card_to_discard.ability.discarded = true
			draw_card(G.hand, G.discard, i*100/#cards_to_discard, 'down', false, current_card_to_discard)
		end
	end

	if #destroyed_cards > 0 then
		for _,current_joker in ipairs(current_jokers) do
			eval_card(current_joker, {cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards})
		end
	end

	G.GAME.round_scores.cards_discarded.amt = G.GAME.round_scores.cards_discarded.amt + #discarded_cards
	check_for_unlock({type = 'discard_custom', cards = discarded_cards})
end

G.FUNCS.discard_cards_from_held = function(e)
	stop_use()
	G.CONTROLLER.interrupt.focus = true
	G.CONTROLLER:save_cardarea_focus('hand')

	-- == Card deselection
	for _, card in ipairs(G.playing_cards) do
		card.ability.forced_selection = nil
	end
	if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.area == G.hand then
		G.card_area_focus_reset = {area = G.hand, rank = G.CONTROLLER.focused.target.rank}
	end

	-- == Determine which cards need to be discarded
	local cards_to_discard = get_cards_to_discard()
	if #cards_to_discard == 0 then return end

	local current_jokers = G.jokers.cards

	update_hand_text(
		{immediate = true, nopulse = true, delay = 0},
		{mult = 0, chips = 0, level = '', handname = ''}
	)

	table.sort(cards_to_discard, function(a,b) return a.T.x < b.T.x end)
	inc_career_stat('c_cards_discarded', #cards_to_discard)
	for _,current_joker in ipairs(current_jokers) do
		current_joker:calculate_joker({pre_discard = true, full_hand = cards_to_discard})
	end

	send_discard_contexts(cards_to_discard)

	if not hook then
		if G.GAME.modifiers.discard_cost then
			ease_dollars(-G.GAME.modifiers.discard_cost)
		end
		ease_discard(-1)
		G.GAME.current_round.discards_used = G.GAME.current_round.discards_used + 1
		G.STATE = G.STATES.DRAW_TO_HAND
		G.E_MANAGER:add_event(Event({
			trigger = 'immediate',
			func = function()
				G.STATE_COMPLETE = false
				return true
			end
		}))
	end
end