local c_deck = function(deck, stake)
	return table.concat({"On", deck, "Deck with", stake or "Blue", (stake == "Gold" and "Stake," or "Stake or higher, "), "win "}," ")
end

return { misc = {

-----------------

achievement_names = {
	["ach_ovn_red_rum"]               = "Red Rum",
	["ach_ovn_blue_blitz"]            = "Blue Blitz",
	["ach_ovn_yellow_yearlong"]       = "Yellow Yearlong",
	["ach_ovn_groundless_greenery"]   = "Groundless Greenery",
	["ach_ovn_bleakest_blackout"]     = "Bleakest Blackout",
	["ach_ovn_magic_malaise"]         = "Magic Malaise",
	["ach_ovn_negated_nebula"]        = "Negated Nebula",
	["ach_ovn_ghostly_gall"]          = "Ghostly Gall",
	["ach_ovn_absolved_abandonment"]  = "Absolved Abandonment",
	["ach_ovn_checkered_changeling"]  = "Checkered Changeling",
	["ach_ovn_zodiac_zenith"]         = "Zodiac Zenith",
	["ach_ovn_painted_paladin"]       = "Painted Paladin",
	["ach_ovn_anticipated_anaglyphs"] = "Anticipated Anaglyphs",
	["ach_ovn_plasma_plight"]         = "Plasma Plight",
	["ach_ovn_erratic_eruption"]      = "Erratic Eruption",
	["ach_ovn_ocular_overseer"]       = "Ocular Overseer",
	["ach_ovn_decoherent_deity"]      = "Decoherent Deity",
	["ach_ovn_abyssal_absolution"]    = "Abyssal Absolution",
	["ach_ovn_autocannibalism"]       = "Autocannibalism",
	["ach_ovn_ace_combat"]            = "Ace Combat",
	["ach_ovn_singular_strike"]       = "Super Spectre Singular Strike Salvo",
	["ach_ovn_exposed_nerve"]         = "Yanking an Exposed Nerve",
	["ach_ovn_do_it_first"]           = "Not If I Do It First!",
	["ach_ovn_bananas"]               = "This Entire Quest Was Bananas",
	["ach_ovn_darkweb"]               = "Dark Web",
	["ach_ovn_unstoppableforce"]      = "Unstoppable Force Vs. Immovable Object",
	["ach_ovn_tickled"]               = "That Tickled!",
	["ach_ovn_eventhoz_scale"]        = "Reach for the Sun and Burn! Burn! Burn!",
	["ach_ovn_slumbering_beast"]      = "The Slumbering Beast Awakens",
},

-----------------

achievement_descriptions = {
	["ach_ovn_red_rum"]               = c_deck("Red") .. "without discarding whilst holding Spiral of Addiction",
	["ach_ovn_blue_blitz"]            = c_deck("Blue") .. "whilst having beaten every played blind in 1 hand",
	["ach_ovn_yellow_yearlong"]       = c_deck("Yellow") .. "with at least $365 in bank",
	["ach_ovn_groundless_greenery"]   = c_deck("Green") .. "with Seed Money and Money Tree",
	["ach_ovn_bleakest_blackout"]     = c_deck("Black") .. "whilst never having more than 4 Jokers at a time",
	["ach_ovn_magic_malaise"]         = c_deck("Magic") .. "without using any Tarot cards",
	["ach_ovn_negated_nebula"]        = c_deck("Nebula") .. "without using any Planet cards",
	["ach_ovn_ghostly_gall"]          = c_deck("Ghost") .. "without using any Spectral cards",
	["ach_ovn_absolved_abandonment"]  = c_deck("Abandoned") .. "whilst having played a Royal Flush during a Showdown Boss Blind",
	["ach_ovn_checkered_changeling"]  = c_deck("Checkered") .. "whilst having played a Straight Spectrum during a Showdown Boss Blind",
	["ach_ovn_zodiac_zenith"]         = c_deck("Zodiac") .. "whilst having used 20 different Tarot or Planet cards",
	["ach_ovn_painted_paladin"]       = c_deck("Painted") .. "whilst holding 7 or more Jokers at once",
	["ach_ovn_anticipated_anaglyphs"] = c_deck("Anaglyphs") .. "with at least 7 Double Tags stockpiled",
	["ach_ovn_plasma_plight"]         = c_deck("Plasma") .. "with a score at least 20 times greater than the Showdown Boss Blind requirement",
	["ach_ovn_erratic_eruption"]      = "On Erratic Deck with Blue Stake or higher, this achievement has a 1 in 8 chance of unlocking on win",
	["ach_ovn_ocular_overseer"]       = c_deck("Ocular", "Gold") .. "with at least 40 Optics in your deck",
	["ach_ovn_decoherent_deity"]      = c_deck("Decoherence", "Gold") .. "with 7 or less Mutations applied",
	["ach_ovn_abyssal_absolution"]    = "Win every Corrupt and Supreme Deck on Gold Stake, then on Abyssal Deck with Gold Stake, defeat the Abyss Superboss",
	["ach_ovn_autocannibalism"]       = "Store Supply Drop inside of itself",
	["ach_ovn_ace_combat"]            = "Have Pareidolia and Prosopometamorphopsia at the same time",
	["ach_ovn_singular_strike"]       = "Play a single 10 boosted to X5 Mult from Airstrike against a Boss Blind",
	["ach_ovn_exposed_nerve"]         = "Disable The Nerve, then play a Straight Flush of Optics",
	["ach_ovn_do_it_first"]           = "While The Purity is upcoming, obtain the pure versions of currently held Corrupt Jokers, then sell all Corrupt Jokers",
	["ach_ovn_bananas"]               = "Naturally obtain Aeon Cavendish",
	["ach_ovn_darkweb"]               = "Have a single Database exceed 1000 chips",
	["ach_ovn_unstoppableforce"]      = "Have your held hand full of Unobtanium Cards when you can't discard",
	["ach_ovn_tickled"]               = "I'm a deck of my word! Here's your achievement",
	["ach_ovn_eventhoz_scale"]        = "Scale Event Horizon to at least +198 Mult and +1730 Chips",
	["ach_ovn_slumbering_beast"]      = "Obtain Nyarlathotep",
},

-----------------

} }