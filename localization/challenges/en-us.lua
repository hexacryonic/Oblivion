return { misc = {

-----------------

    -- Developer's note: Corrupt Challenge names are based on vanilla challenges; localization should try to reflect such to the best of one's ability
    -- E.g. The Omlette -> Corrupt Omlette
    -- E.g. On a Knife's Edge -> Corrupt Edge
    -- Exceptions will be noted as the rest of the challenges are implemented
challenge_names = {
    c_ovn_corrupt_omelette = "Corrupt Omlette",
    c_ovn_corrupt_edge = "Corrupt Edge",
    c_ovn_corrupt_world = "Corrupt World",
        -- EXCEPTION - Perishable Sticker -> Eternal Sticker
    c_ovn_corrupt_eternity = "Corrupt Eternity",
        -- partial EXCEPTION - "Five-Card" -> "Quintet"
    c_ovn_corrupt_quintet = "Corrupt Quintet"
},

v_text = {
    ch_c_ovn_og = { "{C:attention,s:1.5}Original Rules:{}" },
    ch_c_ovn_new = { "{C:ovn_corrupted,s:1.5}Changes:{}" },
    ch_c_ovn_but = { "{C:ovn_corrupted,s:1.3}BUT{}" },
    ch_c_ovn_spacer = { Oblivion.sp },
    ovn_corrupt_challenge = { "" }, -- Leave blank

    -- Corrupt Omelette
    ch_c_ovn_egg_all_eggs = { "WHY ARE THERE {C:dark_edition}SO MANY {C:attention}EGGS" },
    ch_c_ovn_egg_eternal_egg = { "A random {C:attention}Egg {}becomes {C:eternal}Eternal {}after each round" },
        -- Developer's note: Note "motherfuckler", a forced rhyme between "Swashbuckler" (Joker) and "motherfuckler"
    ch_c_ovn_egg_no_swashbuckler = { "DON'T EVEN THINK ABOUT USING {C:attention}SWASHBUCKLER {}YOU MOTHERFUCKLER" },

    -- Corrupt Edge
    ch_c_ovn_edge_foil = { "The {C:attention}Ceremonial Dagger{} is now {C:dark_edition}Foil{}" },
        -- Developer's note: A play on the challenge name "On a Knife's Edge", referring to the removal of the space not targetted by Ceremonial Dagger
    ch_c_ovn_edge_knife = { "There is no edge, only knife" },

    -- Corrupt World
    ch_c_ovn_world_aces = { "You have an {C:attention}Ace{} of each suit" },
        -- Developer's note: Refers to the Joker
    ch_c_ovn_world_pmo = { "{C:ovn_corrupted}Prosopometamorphopsia{}" },

    -- Corrupt Eternity
    ch_c_ovn_all_eternal = G.localization.misc.v_text.ch_c_all_eternal, -- duplicate to prevent eternals from occurring
    ch_c_ovn_eternal_none_eternal = { "All Jokers are no longer {C:eternal}Eternal{}" },
        -- Developer's note: Should reference the Perishable Sticker, if possible
    ch_c_ovn_eternal_extra_perishable = { "Extra {C:perishable}Perishable" },

    -- Corrupt Quintet
    ch_c_ovn_quintet_jokerslot = { "{C:attention}+1 {}Joker slot" },
    ch_c_ovn_quintet_discard = { "{C:attention}+1 {}more discard per round" },
    ch_c_ovn_quintet_addiction = { "The addiction has a heavy grip on your life" },
},

-----------------

} }