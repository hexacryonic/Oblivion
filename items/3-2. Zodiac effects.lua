--------
-- Aries
--------
Oblivion.PassiveEffect {
    key = 'zodiac_aries',
    config = {
        xmult = 1.5,
        discards = -1
    },
    calculate = function (self, context)
        if context.main_scoring then
            return {
                xmult = self.config.xmult
            }
        end
    end,
    add_to_deck = function (self)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + self.config.discards
        ease_discard(self.config.discards)
    end,
    remove_from_deck = function (self)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - self.config.discards
        ease_discard(-self.config.discards)
    end,
}

--------
-- Taurus
--------
Oblivion.PassiveEffect {
    key = 'zodiac_taurus',
    config = {
        interest_mult = 2,
    },
    add_to_deck = function (self)
        G.GAME.interest_mult = G.GAME.interest_mult * self.config.interest_mult
        G.GAME.force_stop_rerolls = true
    end,
    remove_from_deck = function (self)
        G.GAME.interest_mult = G.GAME.interest_mult / self.config.interest_mult
        G.GAME.force_stop_rerolls = nil
    end,
}
-- For G.GAME.interest_mult, see also: G.FUNCS.evaluate_round patch, complex_economy.toml

local gfuncs_canreroll_hook = G.FUNCS.can_reroll
function G.FUNCS.can_reroll(e)
    if G.GAME.force_stop_rerolls then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        gfuncs_canreroll_hook(e)
    end
end

---------
-- Gemini
---------
Oblivion.PassiveEffect {
    key = 'zodiac_gemini',
    config = {
        xmult_min = 0.5,
        xmult_max = 0.9,
    },
    calculate = function (self, context)
        if (
            context.card_added
            and context.card.ability.consumeable
            and not G.GAME.ovn_stop_stupid_recursion
        ) then
            G.GAME.ovn_stop_stupid_recursion = true
            SMODS.copy_card(context.card)
            G.GAME.ovn_stop_stupid_recursion = nil
        end

        if context.main_scoring then
            local xmult = pseudorandom("ovn_zodiac_gemini", self.config.xmult_min, self.config.xmult_max)
            return {
                xmult = xmult
            }
        end
    end
}

---------
-- Cancer
---------
Oblivion.PassiveEffect {
    key = 'zodiac_cancer',
    config = {
        hand_size = 2,
        dollars = -2
    },
    calculate = function (self, context)
        if context.press_play then
            return {
                dollars = self.config.dollars
            }
        end
    end,
    add_to_deck = function (self)
        G.hand:change_size(self.config.hand_size)
    end,
    remove_from_deck = function (self)
        G.hand:change_size(-self.config.hand_size)
    end,
}

------
-- Leo
------
Oblivion.PassiveEffect {
    key = 'zodiac_leo',
    config = {
        chips_multiplier = 3,
    },
    add_to_deck = function (self)
        G.GAME.immutable_deck = true
    end,
    remove_from_deck = function (self)
        G.GAME.immutable_deck = nil
    end,
}

local card_chipbonus_hook = Card.get_chip_bonus
function Card:get_chip_bonus()
    local ret = card_chipbonus_hook(self)
    local pfx_leo = G.GAME.active_passive_effects.pfx_ovn_zodiac_leo
    if pfx_leo and (
        self:is_suit("Hearts")
        or self:is_suit("Diamonds")
        or self:is_suit("ovn_Optics")
    ) then
        ret = ret*pfx_leo.config.chips_multiplier
    end
    return ret
end

local card_canuseconsumable_hook = Card.can_use_consumeable
function Card:can_use_consumeable(any_state, skip_check)
    if (
        G.GAME.immutable_deck
        and (
            self:has_attribute('modify_card')
            or self:has_attribute('destroy_card')
        )
    ) then
        return false
    end
    return card_canuseconsumable_hook(self, any_state, skip_check)
end

--------
-- Virgo
--------
Oblivion.PassiveEffect {
    key = 'zodiac_virgo',
    config = {
        cost_multiplier = 0.5,
        hands = -1
    },
    add_to_deck = function (self)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + self.config.hands
        ease_hands_played(self.config.hands)
        G.GAME.global_cost_multiplier = G.GAME.global_cost_multiplier*self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
    remove_from_deck_deck = function (self)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - self.config.hands
        ease_hands_played(-self.config.hands)
        G.GAME.global_cost_multiplier = G.GAME.global_cost_multiplier/self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
}

--------
-- Libra
--------
Oblivion.PassiveEffect {
    key = 'zodiac_libra',
    calculate = function (self, context)
        if context.final_scoring_step and G.GAME.current_round.hands_left == 0 then
            G.GAME.skip_cashout = true
            return {
                balance = true,
                func = function ()
                    ease_dollars(G.GAME.dollars)
                end
            }
        end
        if context.starting_shop then
            G.GAME.skip_cashout = nil
        end
    end,
}

local g_upd8roundeval_hook = Game.update_round_eval
function Game:update_round_eval(e)
    if not G.GAME.skip_cashout then
        return g_upd8roundeval_hook(self, e)
    end

    if self.buttons then self.buttons:remove(); self.buttons = nil end
    if self.shop then self.shop:remove(); self.shop = nil end

    if not G.STATE_COMPLETE then
        stop_use()
        G.STATE_COMPLETE = true
        Ovn_f.event.simple(nil, function ()
            G.GAME.facing_blind = nil
            save_run()
            ease_background_colour_blind(G.STATES.ROUND_EVAL)
            -- this required as G.FUNCS.cash_out checks for G.round_eval
            G.round_eval = UIBox{
                definition = create_UIBox_round_evaluation(),
                config = {align="bm", offset = {x=0,y=G.ROOM.T.y + 19},major = G.hand, bond = 'Weak'}
            }
            Ovn_f.event.simple(nil, function ()
                delay(0.1)
                -- G.FUNCS.evaluate_round would occur here
                Ovn_f.event.simple({0.7}, function ()
                    G.GAME.blind:defeat()
                end)
                delay(0.2)
                Ovn_f.event.simple(nil, function ()
                    ease_background_colour_blind(G.STATES.ROUND_EVAL, '')
                end)
                -- Cash-out button would be clicked here
                -- input table required as G.FUNCS.cash_out checks for e.config.button
                G.FUNCS.cash_out({config={}})
            end)
        end)
    end
end
-- See also: G.FUNCS.cash_out patch, complex_economy.toml

----------
-- Scorpio
----------
Oblivion.PassiveEffect {
    key = 'zodiac_scorpio',
}

--------------
-- Sagittarius
--------------
Oblivion.PassiveEffect {
    key = 'zodiac_sagittarius',
    config = {
        mult_per_card = 3,
        cost_multiplier = 2
    },
    calculate = function (self, context)
        if context.individual then
            for _,other_card in ipairs(context.scoring_hand) do
                if (
                    other_card:is_suit("Spades")
                    or other_card:is_suit("Clubs")
                    or other_card:is_suit("ovn_Optics")
                ) then
                    return {
                        mult = self.config.mult_per_card
                    }
                end
            end
        end
    end,
    add_to_deck = function (self)
        G.GAME.global_cost_multiplier = G.GAME.global_cost_multiplier*self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
    remove_from_deck_deck = function (self)
        G.GAME.global_cost_multiplier = G.GAME.global_cost_multiplier/self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
}

------------
-- Capricorn
------------
Oblivion.PassiveEffect {
    key = 'zodiac_capricorn',
}

-----------
-- Aquarius
-----------
Oblivion.PassiveEffect {
    key = 'zodiac_aquarius',
}

---------
-- Pisces
---------
Oblivion.PassiveEffect {
    key = 'zodiac_pisces',
    config = {
        hands = 1,
        discards = 1
    },
    calculate = function (self, context)
        if context.stay_flipped and context.to_area == G.hand then
            return {
                stay_flipped = true
            }
        end
    end,
    add_to_deck = function (self)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + self.config.hands
        ease_hands_played(self.config.hands)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + self.config.discards
        ease_discard(self.config.discards)
    end,
    remove_from_deck_deck = function (self)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - self.config.hands
        ease_hands_played(-self.config.hands)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - self.config.discards
        ease_discard(-self.config.discards)
    end,
}