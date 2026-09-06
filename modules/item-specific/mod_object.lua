-- All stuff related to SMODS.Mods["Oblivion"]

-- 1. CALCULATE
-- 2. MINOR PROPERTIES
-- 3. CONFIGURATION TAB
-- 4. CREDITS TAB

local JTML = Ovn_f.JTML

-------------------
---- CALCULATE ----
-------------------

local function corrupt_juice_eval(card)
    return (
        G.GAME.ovn_abyss_juicing
        and Ovn_f.joker_is_corruptible(card.config.center.key)
    )
end

local function mass_juice_corruptibles()
    if not G.GAME.ovn_abyss_juicing then
        G.GAME.ovn_abyss_juicing = true
        for _,joker in ipairs(G.jokers.cards) do
            if Ovn_f.joker_is_corruptible(joker.config.center.key) then
                juice_card_until(joker, corrupt_juice_eval)
            end
        end
    end
end

local function check_stop_juice_corruptibles()
    for _,consumable in ipairs(G.consumeables.cards) do
        if consumable.config.center.corrupts_jokers then return end
    end
    G.GAME.ovn_abyss_juicing = nil
end

Oblivion.obj.calculate = function (self, context)
	---------------
	-- MODE
	-- Costly Hands
	---------------
	if G.GAME.ovn_costly_hands then
		if context.pre_discard and G.GAME.ovn_costly_hands.discard_cost ~= 0 then
			ease_dollars(-G.GAME.ovn_costly_hands.discard_cost)
			delay(0.2)
			Ovn_f.try_punish_unaffordable_hand()
		end

		if context.before and G.GAME.ovn_costly_hands.hand_cost ~= 0 then
			ease_dollars(-G.GAME.ovn_costly_hands.hand_cost)
			delay(0.2)
		end
		if context.after then
			Ovn_f.try_punish_unaffordable_hand()
		end
	end

	---------------------------
	-- On adding a playing card
	---------------------------
    if context.playing_card_added then
        -- Increase instability when Optic playing cards are added
        local optics_count = 0
        for _,playing_card in ipairs(context.cards) do
            if playing_card and playing_card.base and playing_card.base.suit == "ovn_Optics" then
                optics_count = optics_count + 1
            end
        end
        Ovn_f.optic_instability(optics_count)

		-- Update suit chart
		if G.ovn_suit_chart then
			Ovn_f.update_suit_chart()
		end
    end

	-----------------
	-- On suit change
	-----------------
    if context.change_suit then
		-- Increase instability when playing card converted to Optics
		if context.new_suit == "ovn_Optics" then
	        Ovn_f.optic_instability(1)
	    end

		-- Update suit chart
		if G.ovn_suit_chart then
			Ovn_f.update_suit_chart()
		end
    end

	---------------------
	-- On adding any card
	---------------------
    if context.card_added then
		-- Update cumulative unique Joker tracking
		if context.card.ability.set == "Joker" then
			if not G.GAME.cumulative_unique_jokers[context.card.config.center.key] then
				G.GAME.cumulative_unique_joker_count = G.GAME.cumulative_unique_joker_count + 1
				G.GAME.cumulative_unique_jokers[context.card.config.center.key] = true
			end
		end

        -- Increase instability when corrupt Joker is added, or Joker corruption occurs
        if context.card.config.center.rarity == "ovn_corrupted" then
            Ovn_f.corruption_instability(1)
        end

        -- Consumables that corrupt Jokers start juicing those Jokers
        if context.card.config.center.corrupts_jokers then
            mass_juice_corruptibles()
        end

        -- Jokers that can be corrupted start juicing up if corrupting consumables are present
        if G.GAME.ovn_abyss_juicing and Ovn_f.joker_is_corruptible(context.card.config.center.key) then
            juice_card_until(context.card, corrupt_juice_eval)
        end
    end

	------------------------------------
	-- On removing any card (Ovn-custom)
	------------------------------------
    if context.ovn_card_removed then
        -- Stop juicing corruptible Jokers if no more corrupting consumables are present
        check_stop_juice_corruptibles()

		-- Update suit chart
		if G.ovn_suit_chart and context.card.base and context.card.base.suit then
			Ovn_f.update_suit_chart()
		end
    end

	--------------------------------
	-- On entering shop/On rerolling
	--------------------------------
    if context.starting_shop or context.reroll_shop then
		-- If shop contains corrupting items, juice corruptibles
        Ovn_f.add_simple_event(nil, nil, function ()
            local stop_juice = true
            for _,card in ipairs(G.shop_jokers.cards) do
                if card.config.center.corrupts_jokers then
                    mass_juice_corruptibles()
                    stop_juice = false
                    break
                end
            end
            if stop_juice then check_stop_juice_corruptibles() end
        end)
    end

	------------------
	-- On exiting shop
	------------------
    if context.ending_shop then
		-- In case only the shop contained corrupting items
        check_stop_juice_corruptibles()
    end

	---------------------
	-- On opening booster
	---------------------
    if context.open_booster then
        -- Juice Jokers when a booster pack contains a corrupting consumable
        -- Event delay necessary since G.pack_cards is nil when context.open_booster is sent
        Ovn_f.add_simple_event(nil, nil, function ()
            for _,card in ipairs(G.pack_cards.cards) do
                if card.config.center.corrupts_jokers then
                    mass_juice_corruptibles()
                    break
                end
            end
        end)
    end

	---------------------
	-- On leaving booster
	---------------------
    if context.ending_booster then
        -- Stop juicing corruptible Jokers after ending booster pack, if appropriate
        check_stop_juice_corruptibles()
    end

	------------------------------
	-- On individual playing cards
	------------------------------
    if (
        context.individual
        and context.cardarea == G.play
        and context.other_card:is_suit("ovn_Optics")
    ) then
        -- This flag is added by Apache Tears
        context.other_card.ovn_apache_counted = nil
    end

	--------------------
	-- On run start/load
	--------------------
    if context.ovn_run_started then
        ease_background_colour_blind()
    end
end

----------------------------
---- RESET GAME GLOBALS ----
----------------------------

Oblivion.obj.reset_game_globals = function (run_start)
	G.GAME.ovn_instability = G.GAME.ovn_instability or 1
	SMODS.Scoring_Parameters["ovn_instability"].current = G.GAME.ovn_instability or 1

	G.GAME.cumulative_unique_joker_count = G.GAME.cumulative_unique_joker_count or 0
	G.GAME.cumulative_unique_jokers = G.GAME.cumulative_unique_jokers or {}

	G.GAME.ovn_cghost_pseudorandom = {}

	if not G.GAME.hands_last_played then
		G.GAME.hands_last_played = {}
		for key in pairs(SMODS.PokerHands) do
			G.GAME.hands_last_played[key] = -1
		end
	end

	if not run_start then return end
end

--------------------------
---- MINOR PROPERTIES ----
--------------------------

Oblivion.obj.description_loc_vars = function()
	return {
		background_colour = G.C.CLEAR,
		text_colour = G.C.WHITE,
		scale = 1.2
	}
end



---------------------------
---- CONFIGURATION TAB ----
---------------------------

local function generate_config_row(key, callback)
	local loc = G.localization.misc.config["ovn_" .. key]
	local toggle = {element = create_toggle {
		hide_label = true,
		ref_table = Oblivion.config,
		ref_value = key,
		callback = callback
	}, align = "cm"}
	local label = {text = loc.name}
	local desc = {text = loc.text}
	return {toggle, label, desc}
end

Oblivion.obj.config_tab = function ()
	---@type JTML.flex.style
	local jtml_style = {
		align = "center-middle",
		padding = 0.2,
		colour = G.C.BLACK,
		roundCorners = true,
		emboss = 0.05,
	}

	local tbl = Ovn_f.generate_table_ui({
		{
			{text=localize("k_toggle"), colour=G.C.UI.TEXT_DARK, scale=0.5},
			{text=localize("k_name"), colour=G.C.UI.TEXT_DARK, scale=0.5},
			{text=localize("k_description"), colour=G.C.UI.TEXT_DARK, scale=0.5}
		},
		generate_config_row("family_friendly", Ovn_f.reload_localization),
		generate_config_row("disable_c_erratic_shader"),
		generate_config_row("disable_c_erratic_warning"),
		generate_config_row("disable_a_part_falling_music"),
	}, {
		default_text_colour = G.C.WHITE,
		default_text_scale = 0.4
	})

	return JTML.flex{style=jtml_style, {tbl}}
end



---------------------
---- CREDITS TAB ----
---------------------

-- List, each item is a list:
	-- 1. Username
	-- 2. One of following strings:
		-- art, code, concept, concept_pl,
		-- shader, shader_pl, sound, music

local credits_data = {
	"HexaCryonic",
	"Oinite",
	"Lil. Mr. Slipstream"
}

-- Valid keys for second item can be found in
-- the credits_labels table, localization/credits/*.lua
local additional_credits_data = {
	{"thaun0",         "concept"},
	{"SyntaxTsundere", "concept"},
	{"Zero (null)",    "concept"},
	{"AlexZGreat",     "concept_pl"},
	{"Inspector_Bee",  "concept_pl"},
	{"NinjaBanana",    "concept_pl"},
	{"QueenChloe",     "concept_pl"},
	{"Andromeda",      "art"},
	{"cassknows",      "shader"},
	{"Airtoum",        "code"},
	{"ellestuff",      "code"},
	{"lily.felli",     "code"},
	{"MathIsFun_",     "code"},
}

local credits_ui_style = {
	align = "center-middle",
	padding = 0.2,
	colour = G.C.BLACK,
	roundCorners = true,
	emboss = 0.05,
	WH = {6, 6},
}

local credits_table_config = {
	no_header = true,
	default_text_colour = G.C.UI.TEXT_LIGHT,
	default_text_scale = 0.36,
	outline_colour = darken(G.C.JOKER_GREY, 0.5)
}

local function primary_contributors()
	local credits_loc = G.localization.misc.credits
	local rows = {}
	for _,username in ipairs(credits_data) do
		local current_row = {
			{
				text = username,
				colour = G.C.BLUE,
				align = "cr"
			},
			{
				text = credits_loc[username]
			}
		}
		table.insert(rows, current_row)
	end
	return Ovn_f.generate_table_ui(rows, credits_table_config)
end

local function additional_credits()
	local additional_credits_loc = G.localization.misc.credits_additional
	local label_loc = G.localization.misc.credits_labels
	local rows = {}
	for _, current_credit_data in ipairs(additional_credits_data) do
		local username = current_credit_data[1]
		local contrib_label = current_credit_data[2]
		local current_row = {
			{
				text = username,
				colour = G.C.BLUE,
				align = "cr"
			},
			{
				text = label_loc[contrib_label],
				colour = G.C.ORANGE,
				align = "cm"
			},
			{
				text = additional_credits_loc[username]
			}
		}
		table.insert(rows, current_row)
	end
	return Ovn_f.generate_table_ui(rows, credits_table_config)
end

local function define_tab(loc_key, def_func, is_chosen)
	return {
		label = localize(loc_key),
		chosen = is_chosen or false,
		tab_definition_function = function ()
			return
			{n=G.UIT.ROOT, config={colour=G.C.CLEAR, align="cm"}, nodes={
				def_func()
			}}
		end
	}
end

Oblivion.obj.credits_tab = function ()
	return
	JTML.flex{mode="row", style=credits_ui_style, {
		create_tabs{
			snap_to_nav = true,
			colour = G.C.BLUE,
			tabs = {
				define_tab("k_primary_contributors", primary_contributors, true),
				define_tab("k_additional_credits", additional_credits),
				define_tab("k_sources", function()
					return Ovn_f.localize_desc(G.localization.misc.credits_long)
				end),
			}
		}
	}}
end