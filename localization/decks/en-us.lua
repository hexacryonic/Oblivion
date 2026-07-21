local function corrupt_deck_unlock()
    return {
        "Win a run with",
        "{C:attention}#1# {}on at least",
        "{V:1}#2# {}difficulty"
    }
end

return { descriptions = { Back = {

----------------------------------

b_ovn_ocular = {
    name = "Ocular Deck",
    text = {
        "Start with a full set",
        "of {C:ovn_optic}Optics {}in addition",
        "to the standard deck"
    }
},
b_ovn_c_red = {
    name = 'Corrupt Red Deck',
    text = {
        "When you {C:mult}discard{}, all cards",
        "{C:attention}EXCEPT{} selected are {C:mult}discarded{}",
        "After a hand, {C:mult}discard{} up to",
        "{C:attention}5{} held cards at random"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_blue = {
    name = 'Corrupt Blue Deck',
    text = {
        "{C:chips}+2{} starting Hands",
        "Hands {C:mult}never reset{}",
        "{C:chips}+3{} Hands when {C:attention}Boss Blind{} defeated",
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_yellow = {
    name = 'Corrupt Yellow Deck',
    text = {
        "+{C:money}$120{} each {C:attention}Ante{}",
        "{C:attention}Infinite{} Hands and discards,",
        "each cost {C:money}$10{} and {C:money}$5{} respectively",
        "Cost increases by {X:money,C:white} X1.25 {} (floored) each {C:attention}Ante{}",
        "{s:0.3} {}",
        "At less than {C:money}$1{}, {C:mult}Game Over{}",
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_green = {
    name = 'Corrupt Green Deck',
    text = {
        "At end of each Round:",
        "{C:money}$1{s:0.85} per remaining {C:blue}Hand",
        "{C:green}$1i{s:0.85} per remaining {C:red}Discard",
        "{s:0.3} {}",
        "Shop prices are {C:green}complex",
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_black = {
    name = 'Corrupt Black Deck',
    text = {
        "{C:attention}+4{} Joker slots",
        "{C:mult}-1{} hand, discard,",
        "hand size, and",
        "consumable slot",
        "{s:0.3} {}",
        "{C:inactive,s:0.7}(Yeah, this one's just cruel)"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_ghost = {
    name = 'Corrupt Ghost Deck',
    text = {
        "{C:spectral}Spectral {}cards frequently",
        "appear in the shop",
        "When starting a round, a {C:attention}random",
        "{C:spectral}Spectral {}card is used against you"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_abandoned = {
    name = 'Corrupt Abandoned Deck',
    text = {
        "Starting deck has {C:attention}no cards{}",
        "Start with {C:attention}#1# {C:attention,T:tag_standard}#2#s"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_painted = {
    name = 'Corrupt Painted Deck',
    text = {
        "{C:attention}Enhanced{} cards retrigger once",
        "{C:attention}+5{} hand size",
        "{C:mult}Jokerless{}"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_anaglyph = {
    name = 'Corrupt Anaglyph Deck',
    text = {
        "Gain a {C:attention,T:tag_double}Double Tag{} each",
        "{C:attention}Ante{}, and {C:attention}+1{} every",
        "{C:attention}2 Boss Blinds{} defeated",
        "{s:0.3} {}",
        "{C:attention}Small Blinds{} are",
        "{C:mult}automatically skipped{}"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_plasma = {
    name = 'Corrupt Plasma Deck',
    text = {
        "{C:ovn_corrupted,T:dd_ovn_instability_description}#1#{} exponent operand",
        "added to score calculation",
        "{s:0.3} {}",
        "Start with {C:attention,T:j_joker}#2#{},",
        "{C:attention,T:c_ovn_abyss}#3#{}, and {C:attention,T:c_ovn_perception}#4#{}"
    },
    unlock = corrupt_deck_unlock()
},
b_ovn_c_erratic = {
    name = 'Corrupt Erratic Deck',
    text = {
        "{E:ovn_glitched,C:red}Infects{E:ovn_glitched} everything you know",
        "{E:ovn_glitched}with {C:ovn_corrupted}Corruption...{}",
        "{E:ovn_glitched}Its reach is {C:ovn_corrupted}Endless...",
        "{C:attention}{C:red}!! SEIZURE WARNING !!",
        "{C:attention}Reduce visuals in config",
    },
    unlock = corrupt_deck_unlock()
},

----------------------------------

} } }
