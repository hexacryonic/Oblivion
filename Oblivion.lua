SMODS.current_mod.description_loc_vars = function()
return { background_colour = G.C.CLEAR, text_colour = G.C.WHITE, scale = 1.2 }
end

local mod_path = ''..SMODS.current_mod.path

local files = NFS.getDirectoryItems(mod_path .. "lib")
for _, file in ipairs(files) do
	print("[OBLIVION] Loading library file " .. file)
	local f, err = SMODS.load_file("lib/" .. file)
	if err then
		error(err) --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
	end
	f()
end
local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[OBLIVION] Loading file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
		error(err) --Steamodded actually does a really good job of displaying this info! So we don't need to do anything else.
	end
	f()
	-- You can honestly just do f() here unless you want to do something fancy
end

--Localization colors
local lc = loc_colour
function loc_colour(_c, _default)
	if not G.ARGS.LOC_COLOURS then lc() end
	G.ARGS.LOC_COLOURS.ovn_corrupted = G.C.RARITY['ovn_corrupted']
	G.ARGS.LOC_COLOURS.ovn_corrupt2 = HEX('001764')
	G.ARGS.LOC_COLOURS.ovn_corrupt1 = HEX('04248f')
	G.ARGS.LOC_COLOURS.ovn_mutation = G.C.SET.Mutation
	G.ARGS.LOC_COLOURS.heart = G.C.SUITS.Hearts
	G.ARGS.LOC_COLOURS.diamond = G.C.SUITS.Diamonds
	G.ARGS.LOC_COLOURS.spade = G.C.SUITS.Spades
	G.ARGS.LOC_COLOURS.club = G.C.SUITS.Clubs
	G.ARGS.LOC_COLOURS.ovn_optic = G.C.SUITS.ovn_Optics
	return lc(_c, _default)
end

SMODS.Atlas {
	key = "corrupted",
	path = "corrupted.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "notcorrupted",
	path = "notcorrupted.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "charybdis_atlas",
	path = "charybdis.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "abyss_atlas",
	path = "abyss.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "opticenhance_atlas",
	path = "opticenhance.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "cataclysm_atlas",
	path = "cataclysm.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "spectrum_atlas",
	path = "spectrum.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "deck_atlas",
	path = "deck.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "cdeck_atlas",
	path = "corruptdeck.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "mutation_atlas",
	path = "mutation.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "cboosters_atlas",
	path = "cbooster.png",
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = "ctags_atlas",
	path = "ctags.png",
	px = 34,
	py = 34
}

SMODS.Atlas {
	key = "ovn_blinds_atlas",
	atlas_table = "ANIMATION_ATLAS",
	path = "ovn_blinds.png",
	px = 34,
	py = 34,
	frames = 21
}

SMODS.Sound({
	key = "abyss",
	path = "abyss.ogg",
})

SMODS.Sound({
	key = "optic",
	path = "optic.ogg",
})

SMODS.Sound({
	key = "pure",
	path = "pure.ogg",
})

SMODS.Sound({
	key = "e_miasma",
	path = "e_miasma.ogg",
})

SMODS.Sound({
	key = "insecurity",
	path = "insecurity.ogg",
})

SMODS.Sound({
	key = "tres",
	path = "tres.ogg",
})

SMODS.Sound({
	key = "recall",
	path = "recall.ogg",
})

SMODS.Sound({
	key = "decrement",
	path = "powerdecrement.ogg",
})

SMODS.Sound({
	key = "increment",
	path = "powerincrement.ogg",
})


SMODS.Sound({
	key = "musicDoom",
	path = "musicDoom.ogg",
	sync = false,
	pitch = 1,
	volume = 1.2,
	select_music_track = function()
		return (G.GAME and G.GAME.used_insecurity) and
	(G.GAME and G.GAME.used_tres) and
	(G.GAME and G.GAME.used_recall) and not (G.GAME and G.GAME.imcoming)
	end,
})

SMODS.Sound({
	key = "musicApproaching",
	path = "musicApproaching.ogg",
	sync = false,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.imcoming)
	end,
})

SMODS.Sound({
	key = "musicCorrupt",
	path = "musicCorrupt.ogg",
	sync = true,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.in_corrupt and not G.shop and not G.booster_pack and not G.booster_pack_sparkles and not G.booster_pack_meteors and not (G.GAME.blind and G.GAME.blind.boss))
	end,
})

SMODS.Sound({
	key = "musicCorruptShop",
	path = "musicCorruptShop.ogg",
	sync = true,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.in_corrupt and G.shop and not G.shop.REMOVED and not G.booster_pack and not G.booster_pack_sparkles and not G.booster_pack_meteors)
	end,
})

SMODS.Sound({
	key = "musicCorruptPack1",
	path = "musicCorruptPack1.ogg",
	sync = true,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.in_corrupt and G.booster_pack and not G.booster_pack.REMOVED and not G.booster_pack_meteors)
	end,
})

SMODS.Sound({
	key = "musicCorruptPack2",
	path = "musicCorruptPack2.ogg",
	sync = true,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.in_corrupt and G.booster_pack_meteors and not G.booster_pack_meteors.REMOVED and not G.booster_pack_sparkles)
	end,
})

SMODS.Sound({
	key = "musicCorruptBoss",
	path = "musicCorruptBoss.ogg",
	sync = true,
	pitch = 1,
	select_music_track = function()
		return
	(G.GAME and G.GAME.in_corrupt and G.GAME.blind and G.GAME.blind.boss)
	end,
})

SMODS.Atlas({key = 'optics', path = 'optics.png', px = 71, py = 95})
SMODS.Atlas({key = 'optics_hc', path = 'opticsHC.png', px = 71, py = 95})

SMODS.Atlas({key = 'suits', path = 'suits.png', px = 18, py = 18})
SMODS.Atlas({key = 'suits_hc', path = 'suitsHC.png', px = 18, py = 18})

SMODS.current_mod.optional_features = {
retrigger_joker = true,
post_trigger = true,
cardareas = {
	unscored = true,
	deck = true,
	discard = true,
}
}

corruptionTable = {
["j_joker"] = "j_ovn_darkjoker",
["j_fibonacci"] = "j_ovn_lucasseries",
["j_reserved_parking"] = "j_ovn_perpendicular",
["j_gift"] = "j_ovn_supplydrop",
["j_acrobat"] = "j_ovn_yolo",
["j_pareidolia"] = "j_ovn_pmo",
["j_ring_master"] = "j_ovn_showneverends",
["j_droll"] = "j_ovn_bombastic",
["j_crafty"] = "j_ovn_insightful",
["j_tribe"] = "j_ovn_breach",
["j_lusty_joker"] = "j_ovn_prideful",
["j_wrathful_joker"] = "j_ovn_prideful",
["j_gluttenous_joker"] = "j_ovn_prideful",
["j_greedy_joker"] = "j_ovn_prideful",
["j_cavendish"] = "j_ovn_cultivar",
["j_hologram"] = "j_ovn_apartfalling",
}

if G.GAME and G.GAME.corruptiblemichel then corruptionTable["j_gros_michel"] = "j_ovn_aeon" end

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

G.FUNCS.discard_cards_from_held = function(e)
	stop_use()
	G.CONTROLLER.interrupt.focus = true
	G.CONTROLLER:save_cardarea_focus('hand')

	for k, v in ipairs(G.playing_cards) do
		v.ability.forced_selection = nil
	end

	if G.CONTROLLER.focused.target and G.CONTROLLER.focused.target.area == G.hand then G.card_area_focus_reset = {area = G.hand, rank = G.CONTROLLER.focused.target.rank} end
	local markedfordiscard = {}
	for i = 1, #G.hand.cards do
	markedfordiscard[#markedfordiscard+1] = G.hand.cards[i]
	end
	for i = 1, #markedfordiscard do
	for k, v in ipairs(G.hand.highlighted) do
		if markedfordiscard[i] == v then
		table.remove(markedfordiscard, i)
		end
	end
	end
	if #markedfordiscard > 0 then
		update_hand_text({immediate = true, nopulse = true, delay = 0}, {mult = 0, chips = 0, level = '', handname = ''})
		table.sort(markedfordiscard, function(a,b) return a.T.x < b.T.x end)
		inc_career_stat('c_cards_discarded', #markedfordiscard)
		for j = 1, #G.jokers.cards do
			G.jokers.cards[j]:calculate_joker({pre_discard = true, full_hand = markedfordiscard})
		end
		local cards = {}
		local destroyed_cards = {}
		for i=1, #markedfordiscard do
			markedfordiscard[i]:calculate_seal({discard = true})
			local removed = false
			for j = 1, #G.jokers.cards do
				local eval = nil
				eval = G.jokers.cards[j]:calculate_joker({discard = true, other_card =  markedfordiscard[i], full_hand = markedfordiscard})
				if eval then
					if eval.remove then removed = true end
					card_eval_status_text(G.jokers.cards[j], 'jokers', nil, 1, nil, eval)
				end
			end
			table.insert(cards, markedfordiscard[i])
			if removed then
				destroyed_cards[#destroyed_cards + 1] = markedfordiscard[i]
				if markedfordiscard[i].ability.name == 'Glass Card' then
					markedfordiscard[i]:shatter()
				else
					markedfordiscard[i]:start_dissolve()
				end
			else
				markedfordiscard[i].ability.discarded = true
				draw_card(G.hand, G.discard, i*100/#markedfordiscard, 'down', false, markedfordiscard[i])
			end
		end

		if destroyed_cards[1] then
			for j=1, #G.jokers.cards do
				eval_card(G.jokers.cards[j], {cardarea = G.jokers, remove_playing_cards = true, removed = destroyed_cards})
			end
		end

		G.GAME.round_scores.cards_discarded.amt = G.GAME.round_scores.cards_discarded.amt + #cards
		check_for_unlock({type = 'discard_custom', cards = cards})
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
end
