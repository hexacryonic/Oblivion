-- All stuff related to SMODS.Mods["Oblivion"]

-- 1. CALCULATE
-- 2. MINOR PROPERTIES
-- 3. CONFIGURATION TAB
-- 4. CREDITS TAB

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
    end

	-----------------
	-- On suit change
	-----------------
    if context.change_suit and context.new_suit == "ovn_Optics" then
        -- Increase instability when playing card converted to Optics
        Ovn_f.optic_instability(1)
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

	--------------------------------
	-- On NEW run start (Ovn-custom)
	--------------------------------
    if context.ovn_run_started and context.new_run then
        -- Reverse Wicked Invocation effect
        G.P_CENTERS["p_ovn_wicked_normal_1"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_2"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_3"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_4"].weight = 0
    end

	--------------------
	-- On run start/load
	--------------------
    if context.ovn_run_started then
        ease_background_colour_blind()
    end
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
	local jtml_style = {
		[".root"] = {
			align = "center-middle",
			padding = 0.2,
			fillColour = G.C.BLACK,
			roundness = 0.1,
			emboss = 0.05,
		}
	}

	local header_row = {
		{text=localize("k_toggle"), colour=G.C.UI.TEXT_DARK, scale=0.5},
		{text=localize("k_name"), colour=G.C.UI.TEXT_DARK, scale=0.5},
		{text=localize("k_description"), colour=G.C.UI.TEXT_DARK, scale=0.5}
	}

	local tbl = Ovn_f.generate_table_ui({
		header_row,
		generate_config_row("family_friendly", Ovn_f.reload_localization),
		generate_config_row("disable_c_erratic_shader"),
		generate_config_row("disable_c_erratic_warning"),
		generate_config_row("disable_a_part_falling_music"),
	}, {
		default_text_colour = G.C.WHITE,
		default_text_scale = 0.4
	})

	local config_ui =
	{"root", class="root", {tbl}}

	return Ovn_f.jtml_to_uiboxdef(config_ui, jtml_style)
end



---------------------
---- CREDITS TAB ----
---------------------

local credits_ui_style = {
	[".credits_ui_style"] = {
		align = "center-middle",
		padding = 0.2,
		fillColour = G.C.BLACK,
		roundness = 0.1,
		emboss = 0.05,
		minWidth = 6,
		minHeight = 6
	},
	[".credits_header"] = {
		align = "center-middle",
		padding = 0.2,
		outlineColour = G.C.JOKER_GREY,
		roundness = 0.1,
		outlineWidth = 1
	},
	[".credits_header_text"] = {
		scale = 0.45,
		colour = G.C.UI.TEXT_LIGHT
	},
	[".credits_text"] = {
		scale = 0.4,
		colour = G.C.UI.TEXT_LIGHT,
		padding = 0.05,
	},
}

local credits_table_config = {
	no_header = true,
	default_text_colour = G.C.UI.TEXT_LIGHT,
	default_text_scale = 0.36,
	outline_colour = darken(G.C.JOKER_GREY, 0.5)
}

local function primary_contributors()
	local credits_copy = Ovn_f.bi_shallow_copy(G.localization.misc.credits)
	for _,row in ipairs(credits_copy) do
		row[1] = {
			text = row[1],
			colour = G.C.BLUE,
			align = "cr"
		}
		row[2] = {text = row[2]}
	end
	return Ovn_f.generate_table_ui(credits_copy, credits_table_config)
end

local function additional_credits()
	local credits_copy = Ovn_f.bi_shallow_copy(G.localization.misc.credits_additional)
	for _, row in ipairs(credits_copy) do
		row[1] = {
			text = row[1],
			colour = G.C.BLUE,
			align = "cr"
		}
		row[2] = {
			text = row[2],
			colour = G.C.ORANGE,
			align = "cm"
		}
		row[3] = {text = row[3]}
	end
	return Ovn_f.generate_table_ui(credits_copy, credits_table_config)
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
    local credits_ui =
	{"root", class="credits_ui_style", {
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

	return Ovn_f.jtml_to_uiboxdef(credits_ui, credits_ui_style)
end