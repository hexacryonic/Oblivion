Oblivion.PassiveEffect {
    key = 'test',
    calculate = function (self, context)
        if context.main_scoring then
            return {
                chips = 200
            }
        end
    end,
    add_to_deck = function ()
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
        ease_hands_played(1)
    end,
    remove_from_deck = function ()
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        ease_hands_played(-1)
    end,
}