-- Description writing note:
--   Text with background should be formatted as follows for good visual balance:
--   {X:mult,C:white}X#1# {} Mult
--   Note that the last node {} is surrounded by spaces on BOTH sides, not just the left

return {

------

    descriptions = {

------

        Joker = {
            j_ovn_darkjoker = {
                name = 'Parallel Joker',
                text = {
                    "Played cards give",
                    "{C:mult}+#1#{} Mult when scored"
                },
                corrupted_from = {
                    "{C:attention}Joker"
                }
            },
            j_ovn_john = {
                name = 'John Oblivion',
                text = {
                    "Creates a",
                    "{C:ovn_corrupted}Corrupted {C:attention}Joker",
                    "when sold"
                }
            },
            j_ovn_ovn = {
                name = 'ovn',
                text = {
                    "When {C:attention}Boss Blind defeated,",
                    "make the leftmost {C:attention}Joker {C:dark_edition}Miasma",
                    '{C:inactive,s:0.8}"Why do they call it oven when you of in',
                    '{C:inactive,s:0.8}the cold Joker of out hot eat the Joker"'
                }
            },
            j_ovn_bombastic = {
                name = 'Bombastic Joker',
                text = {
                    "{C:mult}+#1#{} Mult if played",
                    "hand contains",
                    "a {C:attention}Spectrum{}",
                },
            },
            j_ovn_insightful = {
                name = 'Insightful Joker',
                text = {
                    "{C:chips}+#1#{} Chips if played",
                    "hand contains",
                    "a {C:attention}Spectrum{}",
                },
            },
            j_ovn_breach = {
                name = 'The Breach',
                text = {
                    "{X:mult,C:white} X#1# {} Mult if played",
                    "hand contains",
                    "a {C:attention}Spectrum{}",
                },
            },
            j_ovn_radiant_joker = {
                name = "Radiant Joker",
                text = {
                    "{C:attention}Radiant {}Cards give scoring",
                    "cards {C:chips}+#1# {}more extra Chips",
                    "Increase this by {C:chips}+#2# {}when",
                    "a {C:attention}Radiant {}Card is scored"
                }
            },
            j_ovn_ice_joker = {
                name = 'Ice Joker',
                text = {
                    "This Joker gains {X:mult,C:white}+X#1# {} Mult",
                    "when an {C:attention}Ice {}Card degrades",
                    "{C:inactive}(Currently {X:mult,C:white}X#2# {C:inactive} Mult)",
                    "This gain increases by {C:attention}+#3#",
                    "when an {C:attention}Ice Card {}fully melts"
                }
            },
            j_ovn_crystal_joker = {
                name = "Crystal Joker",
                text = {
                    "{C:attention}Crystal Cards {}last",
                    "for {C:attention}+#1# {}extra hands"
                }
            },
            j_ovn_ion_joker = {
                name = "Ion Joker",
                text = {
                    "Instead of {C:red}increasing",
                    "blind requirement,",
                    "{C:attention}Ion {}Cards add {C:attention}double {}their",
                    "{C:chips}chip {}values to this Joker",
                    "{C:inactive}(Currently {C:chips}+#1# {C:inactive}Chips)"
                }
            },
            j_ovn_trolley_problem = {
                name = "Trolley Problem",
                text = {
                    '{C:attention}Unscoring {}cards in',
                    '{C:attention}"of a Kind" {}hands',
                    'are {C:red}destroyed'
                }
            },
            j_ovn_prism = {
                name = "Prism",
                text = {
                    "Tarot cards that {C:tarot}change",
                    "{C:tarot}suit {}are {C:attention}#1#X {}more",
                    "likely to appear"
                }
            },
            j_ovn_purifier = {
                name = "Purifier",
                text = {
                    "When Blind is selected,",
                    "the {C:attention}leftmost {C:ovn_corrupted}Corrupted {}Joker",
                    "is {C:blue}purified {}to give",
                    "this card {C:red}+#1# {}Mult",
                    "{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult)",
                }
            },
            j_ovn_pure_visage = {
                name = "Pure Visage",
                text = {
                    "In {C:inactive}[{C:attention}#1#{C:inactive}] {}rounds,",
                    "click {C:attention}side button {}to",
                    "{C:ovn_corrupted}corrupt {}this Joker"
                }
            },
            j_ovn_pure_visage_ready = {
                name = "Pure Visage",
                text = {
                    "Click {C:attention}side button {}to",
                    "{C:ovn_corrupted}corrupt {}this Joker"
                }
            },
            j_ovn_corrupt_visage = {
                name = "Corrupt Visage",
                text = {
                    "{X:mult,C:white}X#1# {} Mult",
                    "{C:blue}Purifies {}at",
                    "end of round"
                },
                corrupted_from = {
                    "{C:attention}Pure Visage"
                }
            },
            j_ovn_prideful = {
                name = 'Prideful Joker',
                text = {
                    "Played cards with",
                    "{C:ovn_optic}Optic{} suit give",
                    "{C:mult}+#1#{} Mult when scored",
                },
                corrupted_from = {
                    "the {C:attention}Sinful Jokers"
                }
            },
            j_ovn_collapsing_world = {
                name = "Edge of a Collapsing World",
                text = {
                    "On the {C:attention}final discard,",
                    "the {C:attention}rightmost and leftmost",
                    "discarded cards are {C:red}destroyed{},",
                    "then this Joker gains {C:mult}+#1# {}Mult",
                    "{C:inactive}(Currently {C:mult}+#2# {C:inactive}Mult)",
                },
                corrupted_from = {
                    "{C:attention}Mystic Summit {}or {C:attention}Erosion"
                }
            },
            j_ovn_lucasseries = {
                name = 'Lucas Series',
                text = {
                    "Each played {C:attention}Ace{},",
                    "{C:attention}2, 3, 4,{} or {C:attention}7{} gives",
                    "{X:mult,C:white} X#1# {} Mult when scored",
                },
                corrupted_from = {
                    "{C:attention}Fibonacci"
                }
            },
            j_ovn_database = {
                name = "Database",
                text = {
                    "{C:chips}+#1# {}Chips per",
                    "{C:attention}unique {}Joker obtained",
                    "cumulatively over the run",
                    "{C:inactive}(Currently {C:chips}+#2# {C:inactive}Chips)",
                },
                corrupted_from = {
                    "{C:attention}Abstract Joker"
                }
            },
            j_ovn_pmo = {
                name = 'Prosopometamorphopsia',
                text = {
                    "Effects that would",
                    "target {C:attention}any face card",
                    "target {C:attention}Aces {}instead",
                },
                corrupted_from = {
                    "{C:attention}Pareidolia"
                }
            },
            j_ovn_aeon = {
                name = 'Aeon Cavendish',
                text = {
                    "{X:mult,C:white}X#1# {} Mult",
                    "{C:attention}Cavendish {}is no longer",
                    "extinct and can be",
                    "obtained multiple times"
                },
                corrupted_from = {
                    "{C:attention}Gros Michel"
                }
            },
            j_ovn_event_horizon = {
                name = "Event Horizon",
                text = {
                    "{C:red}Hands no longer level up",
                    "Instead, this Joker gains",
                    "{C:attention}#3#X{} the upgrade's",
                    "{C:chips}Chips {C:inactive}({C:chips}+#1#{C:inactive})"
                    .. " {}and {C:mult}Mult {C:inactive}({C:mult}+#2#{C:inactive})"
                    -- above line split b/c too long
                },
                corrupted_from = {
                    "{C:attention}Supernova {}or {C:attention}Constellation"
                }
            },
            j_ovn_sludge = {
                name = "Sludge",
                text = {
                    "{C:attention}+1 {}hand size",
                    "{C:red}Played cards never score",
                    "Cards held in hand now score",
                },
                corrupted_from = {
                    "{C:attention}Splash"
                }
            },
            j_ovn_library_of_babel = {
                name = "Library of Babel",
                text = {
                    "This Joker gains {X:mult,C:white}X#1# {} Mult",
                    "when played poker hand",
                    "hasn't been played within",
                    "the {C:attention}last #2# {}hands",
                    "{C:inactive}(Currently {X:mult,C:white}X#3# {C:inactive} Mult)",
                },
                corrupted_from = {
                    "{C:attention}To-Do List{},",
                    "{C:attention}Card Sharp{}, or {C:attention}Obelisk"
                }
            },
            j_ovn_cultivar = {
                name = 'Theoretical Cultivar',
                text = {
                    "{X:mult,C:white} X#1# {} Mult",
                    "{C:green}#2# in #3#{} chance this",
                    "card is destroyed",
                    "at end of round",
                },
                corrupted_from = {
                    "{C:attention}Cavendish"
                }
            },
            j_ovn_apartfalling = {
                name = 'A Part Falling',
                text = {
                    "This Joker gains {X:mult,C:white} X#2# {} Mult",
                    "whenever a Joker {C:ovn_corrupted}corrupts{}",
                    "{C:inactive}(Currently {X:mult,C:white}X#1# {C:inactive} Mult)",
                },
                corrupted_from = {
                    "{C:attention}Hologram"
                }
            },
            j_ovn_philosophers_stone = {
                name = "Philosopher's Stone",
                text = {
                    "After playing, each scoring {C:attention}numbered {}card",
                    "has a {C:green}#1# in #2# {}chance to have",
                    "their enhancement {C:attention}transmuted",
                },
                corrupted_from = {
                    "{C:attention}Midas Mask"
                }
            },
            j_ovn_supplydrop = {
                name = 'Supply Drop',
                text = {
                    "Sell this Joker to {C:attention}store{} the",
                    "Joker to its left, if its rarity",
                    "is not higher than {C:red}Rare{}",
                    Oblivion.sp,

                    "When this Joker is sold",
                    "again, {C:attention}even between runs,",
                    "{C:attention}create {}the stored Joker",
                    "and remove it from storage",
                    Oblivion.sp,

                    "{s:0.8}Currently storing: {C:attention,s:0.8}#1#",
                },
                corrupted_from = {
                    "{C:attention}Gift Card"
                }
            },
            j_ovn_perpendicular = {
                name = 'Perpendicular Parking',
                text = {
                    "Scored cards earn {C:attention}$#1#{}",
                    "if another card of its",
                    "{C:attention}same rank{} is held in hand",
                },
                corrupted_from = {
                    "{C:attention}Reserved Parking"
                }
            },
            j_ovn_migraine = {
                name = "Migraine",
                text = {
                    "{C:attention}Standard Packs",
                    "only contain",
                    "modified {C:ovn_optic}Optic cards"
                },
                corrupted_from = {
                    "{C:attention}Hallucination"
                }
            },
            j_ovn_spiral_of_addiction = {
                name = "Spiral of Addiction",
                text = {
                    "This Joker gains {X:mult,C:white}X#1# {} Mult",
                    "per round where",
                    "{C:attention}every discard {}is used",
                    "{C:inactive}(Currently {X:mult,C:white}X#2# {C:inactive} Mult)",
                    "{C:red}#3# {}hand size next round if",
                    "at least {C:attention}1 {}discard remains",
                },
                corrupted_from = {
                    "{C:attention}Drunkard"
                }
            },
            j_ovn_cigarette_card = {
                name = "Cigarette Card",
                text = {
                    "{C:green}Uncommon {}Jokers always",
                    "spawn with {C:dark_edition}Miasma",
                    "{C:ovn_corrupted}Corrupted {}Jokers each",
                    "give {X:mult,C:white}X#1# {} Mult",
                },
                corrupted_from = {
                    "{C:attention}Baseball Card"
                }
            },
            j_ovn_airstrike = {
                name = 'Air Strike',
                text = {
                    "Held or unscoring {C:attention}10s {C:purple}stockpile",
                    "{X:mult,C:white} X#1# {} Mult every hand played",
                    Oblivion.sp,

                    "When scored, {C:attention}10s {}use",
                    "their {C:purple}stockpiled {}XMult,",
                    "which {C:purple}resets {}after scoring",
                },
                corrupted_from = {
                    "{C:attention}Walkie Talkie"
                }
            },
            j_ovn_yolo = {
                name = Ovn_f.f_f('Fuck It, We Ball', 'YOLO'),
                text = {
                    "Each played card gives",
                    "{X:mult,C:white} X#1# {} Mult when scored",
                    Oblivion.sp,
                    Ovn_f.f_f(
                        "{C:chips}-a fucktillion{} hands",
                        "{C:chips}-math.huge{} hands"
                    ),
                    "when hand played",
                },
                corrupted_from = {
                    "{C:attention}Acrobat"
                }
            },
            j_ovn_apache_tears = {
                name = 'Apache Tears',
                text = {
                    "Scored {C:ovn_optic}Optic {}cards give",
                    "{C:chips}+#1# {}Chips, {C:mult}+#2# {}Mult, and {X:mult,C:white}X#3# {} Mult",
                    "{C:attention}Every#4# {C:ovn_optic}Optic {}cards",
                    "scored {C:inactive}(#5#) {}gives {C:money}$#6#",
                    Oblivion.sp,
                    "{C:attention}Pure forms {}are not banished",
                    "This Joker {C:ovn_corrupted}absorbs {}and banishes",
                    "{C:ovn_corrupted}re-corrupted {C:attention}pure forms",
                },
                corrupted_from = {
                    "{C:attention}Arrowhead{}, {C:attention}Bloodstone{},",
                    "{C:attention}Onyx Agate{}, or {C:attention}Rough Gem"
                }
            },
            j_ovn_apache_tears_every_card_cash = {
                name = 'Apache Tears',
                text = {
                    "Scored {C:ovn_optic}Optic {}cards give",
                    "{C:chips}+#1# {}Chips, {C:mult}+#2# {}Mult, and {X:mult,C:white}X#3# {} Mult",
                    "{C:attention}Every {C:ovn_optic}Optic {}card scored gives {C:money}$#4#",
                    Oblivion.sp,
                    "{C:attention}Pure forms {}are not banished",
                    "This Joker {C:ovn_corrupted}absorbs {}and banishes",
                    "{C:ovn_corrupted}re-corrupted {C:attention}pure forms",
                }
            },
            j_ovn_showneverends = {
                name = 'THE SHOW NEVER ENDS',
                text = {
                    "{C:ovn_corrupted}Corrupted {C:attention}Jokers",
                    "no longer banish or",
                    "destroy their counterparts"
                },
                corrupted_from = {
                    "{C:attention}Showman"
                }
            },
            j_ovn_infinitesimal = {
                name = "Infinitesimal Joker",
                text = {
                    "{C:dark_edition}+#1#{} Joker slot",
                    "This Joker gains {C:mult}+#2# {}Mult",
                    "when a {C:attention}3 {}is scored",
                    "{C:inactive}(Currently {C:mult}+#3# {C:inactive}Mult)",
                },
                corrupted_from = {
                    "{C:attention}Wee Joker"
                }
            },
            j_ovn_master_of_puppets = {
                name = "Master of Puppets",
                text = {
                    "When selling a Joker, a random {C:attention}Jack",
                    "in your deck is given a {C:attention}modifier",
                    "depending on the sold Joker's rarity:",
                    Oblivion.sp,
                },
                corrupted_from = {
                    "{C:attention}Hit the Road"
                }
            },
            j_ovn_blacklight = {
                name = "Blacklight",
                text = {
                    "{C:tarot}Perception {}replaces",
                    "all Tarot cards that",
                    "{C:tarot}change suits"
                },
                corrupted_from = {
                    "{C:attention}Prism"
                }
            },
            j_ovn_bottled_ship_of_theseus = {
                name = "Bottled Ship of Theseus",
                text = {
                    "When a {C:attention}non-Glass card {}is {C:red}destroyed,",
                    "create a {C:attention}Glass Card",
                    "of its rank and suit",
                },
                corrupted_from = {
                    "{C:attention}Trolley Problem"
                }
            },
            j_ovn_nexus_point = {
                name = "Nexus Point",
                text = {
                    "This Joker can be",
                    "{C:ovn_corrupted}repeatedly corrupted",
                    Oblivion.sp,

                    "Scored cards give {X:mult,C:white}X#1# {} Mult",
                    "Increases by {X:mult,C:white}X#2# {} each",
                    "time this Joker is",
                    "{C:ovn_corrupted}corrupted {}from {C:attention}Nexus Point",
                },
                corrupted_from = {
                    "{C:attention}Purifier {}or {C:attention}Nexus Point"
                }
            },
            j_ovn_nyarlathotep = {
                name = "Nyarlathotep",
                text = {
                    "{C:attention}Retrigger {}all scoring cards",
                    "once {C:attention}per held Corrupted Joker",
                    "{C:inactive}(Currently {C:attention}#1# {C:inactive}retriggers)",
                    "Scoring cards gain",
                    "{C:white,X:mult}+X#2# {} Mult per trigger",
                },
                corrupted_from = {
                    "the {C:attention}Legendary Jokers"
                }
            },
        },

------

        Other = {
            ovn_library_of_babel_last_played = {
                name = "Current hand last played",
                text = {
                    "{C:attention}#1# {}last played",
                    "{C:attention}#2# {}hands ago"
                }
            },
            ovn_library_of_babel_last_played_never = {
                name = "Current hand last played",
                text = {
                    "{C:attention}#1# {}never played",
                    "(not within last {C:attention}#2# {}hands)"
                }
            },
            ovn_corrupt_condition_has_optic = {
                name = "Corruption condition",
                text = {
                    "{E:ovn_betterfloat}Let {E:ovn_betterfloat,C:ovn_optic}prying eyes",
                    "{E:ovn_betterfloat,C:ovn_optic}perceive {E:ovn_betterfloat}your deck."
                }
            },
            ovn_corrupt_condition_gros_michel = {
                name = "Corruption condition",
                text = {
                    "{E:ovn_betterfloat}Make a {E:ovn_betterfloat,C:ovn_corrupted}strange",
                    "{E:ovn_betterfloat,C:ovn_corrupted}banana {E:ovn_betterfloat}extinct."
                }
            },
        },
    },

------

    misc = {
        dictionary = {
			-- Used in Master of Puppets desc
			k_enhancement = "Enhancement",
			k_seal = "Seal",
			k_ovn_other_rarity = "(other)",
			k_ovn_random_modifier = "(random)",
        }
    },

------

}