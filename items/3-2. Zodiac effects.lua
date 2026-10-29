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
    end,
    remove_from_deck = function (self)
        G.GAME.interest_mult = G.GAME.interest_mult / self.config.interest_mult
    end,
}
-- todo implement interest_mult

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
        if context.card_added and context.card.ability.consumeable then
            SMODS.copy_card(context.card)
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
        G.GAME.cost_multiplier = G.GAME.cost_multiplier*self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
    remove_from_deck_deck = function (self)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - self.config.hands
        ease_hands_played(-self.config.hands)
        G.GAME.cost_multiplier = G.GAME.cost_multiplier/self.config.cost_multiplier
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
        if context.final_scoring_step then
            return {
                balance = false,
                func = function ()
                    ease_dollars(0)
                end
            }
        end
    end
}
-- todo: implement cashout skip

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
        G.GAME.cost_multiplier = G.GAME.cost_multiplier*self.config.cost_multiplier
        for _,other_card in ipairs(G.I.CARD) do
            if other_card.set_cost then other_card:set_cost() end
        end
    end,
    remove_from_deck_deck = function (self)
        G.GAME.cost_multiplier = G.GAME.cost_multiplier/self.config.cost_multiplier
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