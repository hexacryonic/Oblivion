if not Oblivion.spectral_logic then Oblivion.spectral_logic = {} end
local speclogic = Oblivion.spectral_logic

local hold_enhancements = {
    ["m_steel"] = true,
    ["m_gold"] = true,
    ["m_ovn_unob"] = true
}

speclogic['c_talisman'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        -- if not joker_targets_card then p_add(2) end

        local card_enhancement = card.config.center.key
        if hold_enhancements[card_enhancement] then p_add(2) end

        local card_seal = card:get_seal()
        if card_seal == "Red" then p_add(2)
        elseif card_seal == "Blue" or card_seal == "Purple" then p_add(1)
        end

        if card.edition then p_add(-2) end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_aura'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        -- Aura cannot target cards with editions
        if card.edition then return end

        local points = 0
        local function p_add(n) points = points + n end

        -- if not joker_targets_card then p_add(2) end

        local card_enhancement = card.config.center.key
        if hold_enhancements[card_enhancement] then p_add(1) end

        local card_seal = card:get_seal()
        if card_seal == "Red" or card_seal == "Gold" then p_add(-2) end

        return points
    end,
    usable = function()
        for _,card in ipairs(G.hand.cards) do
            if not card.edition then return true end
        end
        return false
    end
}

speclogic['c_deja_vu'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        -- if not joker_targets_card then p_add(2) end

        local card_edition = card.edition and card.edition.key
        if card_edition == "e_polychrome" then p_add(-2)
        elseif card_edition then p_add(-1)
        end

        local card_enhancement = card.config.center.key
        if card_enhancement ~= "c_base" then p_add(-1) end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_trance'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        -- if joker_targets_card then p_add(2) end

        local card_seal = card:get_seal()
        if card_seal == "Red" or card_seal == "Purple" then p_add(2) end

        if card.edition then p_add(2) end

        local card_enhancement = card.config.center.key
        if hold_enhancements[card_enhancement] then p_add(-2) end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_medium'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        -- if joker_targets_card then p_add(2) end

        local card_seal = card:get_seal()
        if card_seal == "Red" or card_seal == "Gold" then p_add(2)
        elseif card_seal == "Blue" then p_add(1) end

        if card.edition then p_add(2) end

        local card_enhancement = card.config.center.key
        if hold_enhancements[card_enhancement] then p_add(2) end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_cryptid'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        -- if not joker_targets_card then p_add(2) end

        local card_edition = card.edition and card.edition.key
        if card_edition == "e_polychrome" then p_add(-2)
        elseif card_edition then p_add(-1) end

        local card_enhancement = card.config.center.key
        if card_enhancement ~= "c_base" then p_add(-1) end

        if card:get_seal() then p_add(-1) end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_ovn_oblivion'] = {
    select = 2,
    select_area = function()
        return {G.hand, G.jokers}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        if card.area == G.jokers then
            local joker_key = card.config.center.key
            if Ovn_f.joker_is_corruptible(joker_key) then
                p_add(3)
                -- if joker_has_addtodeck_effect then p_add(1) end
            end
        elseif card.area == G.hand then
            local card_suit =  card.base.suit
            if card_suit == 'ovn_Optics' then
                p_add(2)
                -- if joker_has_card_destruction_fx then p_add(-1) end
            else
                p_add(1)
            end
        end

        return points
    end,
    usable = function()
        return true
    end
}

speclogic['c_ovn_eidolon'] = {
    select = 1,
    select_area = function()
        return {G.hand}
    end,
    card_point_calc = function(card)
        local points = 0
        local function p_add(n) points = points + n end

        if card:get_seal() then p_add(1) end

        return points
    end,
    usable = function()
        return true
    end
}

----

local default_state = {
    select = 0,
    select_area = function() return {} end,
    usable = function()
        return true
    end
}

local check_edition = {
    select = 0,
    select_area = function() return {} end,
    usable = function()
        for _,card in ipairs(G.jokers.cards) do
            if not card.edition then return true end
        end
        return false
    end
}

local check_j_slots = {
    select = 0,
    select_area = function() return {} end,
    usable = function()
        return #G.jokers.cards < G.jokers.config.card_limit
    end
}

speclogic['c_familiar'] = default_state
speclogic['c_grim'] = default_state
speclogic['c_incantation'] = default_state
speclogic['c_sigil'] = default_state
speclogic['c_ouija'] = default_state
speclogic['c_immolate'] = default_state

speclogic['c_ectoplasm'] = check_edition
speclogic['c_hex'] = check_edition

speclogic['c_wraith'] = check_j_slots
speclogic['c_ovn_charybdis'] = check_j_slots

speclogic['c_ankh'] = {
    select = 0,
    select_area = {},
    usable = function()
        return 0 < #G.jokers.cards and #G.jokers.cards < G.jokers.config.card_limit
    end
}