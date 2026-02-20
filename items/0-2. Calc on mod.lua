local function corrupt_juice_eval(card)
    return (
        G.GAME.ovn_abyss_juicing
        and Ovn_f.joker_is_corruptible(card.config.center.key)
        and not G.RESET_JIGGLES
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

SMODS.current_mod.calculate = function (self, context)
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

    if context.change_suit and context.new_suit == "ovn_Optics" then
        -- Increase instability when playing card converted to Optics
        Ovn_f.optic_instability(1)
    end

    if context.card_added then
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

    if context.ovn_card_removed then -- This is a custom context, please see docs
        -- Stop juicing corruptible Jokers if no more corrupting consumables are present
        check_stop_juice_corruptibles()
    end

    if context.open_booster then
        -- Juice Jokers when a booster pack contains a corrupting consumable
        -- Event necessary since G.pack_cards is nil when context.open_booster is sent
        Ovn_f.add_simple_event(nil, nil, function ()
            for _,card in ipairs(G.pack_cards.cards) do
                if card.config.center.corrupts_jokers then
                    mass_juice_corruptibles()
                    break
                end
            end
        end)
    end

    if context.ending_booster then
        -- Stop juicing corruptible Jokers after ending booster pack, if appropriate
        check_stop_juice_corruptibles()
    end

    if (
        context.individual
        and context.cardarea == G.play
        and context.other_card:is_suit("ovn_Optics")
    ) then
        -- This flag is added by Apache Tears
        context.other_card.ovn_apache_counted = nil
    end

    if context.ovn_run_started and context.new_run then
        G.P_CENTERS["p_ovn_wicked_normal_1"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_2"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_3"].weight = 0
        G.P_CENTERS["p_ovn_wicked_normal_4"].weight = 0
    end
end