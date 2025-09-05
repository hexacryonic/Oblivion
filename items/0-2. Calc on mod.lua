SMODS.current_mod.calculate = function (self, context)
    -- Increase instability when Optic playing cards are added
    if context.playing_card_added then
        local optics_count = 0
        for _,playing_card in ipairs(context.cards) do
            if playing_card.base and playing_card.base.suit == "ovn_Optics" then
                optics_count = optics_count + 1
            end
        end
        Ovn_f.optic_instability(optics_count)
    end

    -- Increase instability when corrupt Joker is added, or Joker corruption occurs
    if context.card_added and context.card.config.center.rarity == "ovn_corrupted" then
        Ovn_f.corruption_instability(1)
    end

    -- Increase instability when playing card converted to Optics
    if context.change_suit and context.new_suit == "ovn_Optics" then
        Ovn_f.optic_instability(1)
    end
end