local c_deck = function(deck, stake)
	return table.concat({"On", deck, "Deck with", stake or "Blue", (stake == "Gold" and "Stake," or "Stake or higher, "), "win "}," ")
end

return {
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
	["ach_ovn_tickled"]               = "I'm a deck of my word! Here's your achievement"
}
