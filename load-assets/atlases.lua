local at = {
	Card = function(key) return {key, 71, 95} end,
	Tag  = function(key) return {key, 34, 34} end,
	Suit = function(key) return {key, 18, 18} end
}

-- lua allows parenthesis exclusion for singular arguments
local atlases = {
	at.Card  "booster_packs",
	at.Card  "consumables",
	at.Card  "decks",
	at.Card  "decks_corrupt",
	at.Card  "enhancements",
	at.Card  "jokers",
	at.Card  "jokers_corrupt",
	at.Tag   "modicon",
	at.Card  "mutations",
	at.Card  "optics",
	at.Card  "optics_hc",
	at.Card  "placeholder",
	at.Card  "seals",
	at.Card  "seals_marks",
	at.Suit  "suits",
	at.Suit  "suits_hc",
	at.Tag   "tags",
	at.Card  "vouchers",
	at.Card  "itemspecific/apache_tears",
	at.Card  "itemspecific/apartfalling",
	at.Card  "crossmod/cryptid_planets",
	-- Deck skin atlases are found in items/0-3. Deck skins.lua
}

for _,def in ipairs(atlases) do
	local path = def[1]
	local px = def[2]
	local py = def[3]
	local file_name = path .. ".png"
	local key = path:gsub("/", "_")
	SMODS.Atlas {
		key = key,
		path = file_name,
		px = px,
		py = py
	}
end

----

SMODS.Atlas {
	key = "blinds",
	atlas_table = "ANIMATION_ATLAS",
	path = "blinds.png",
	px = 34,
	py = 34,
	frames = 21
}

----

--[[

Note on ApacheTears.png
Cards must be layed out such that each sprite corresponds
to the following card states:

----   S---   -H--   SH--
--D-   S-D-   -HD-   SHD-
---C   S--C   -H-C   SH-C
--DC   S-DC   -HDC   SHDC

Where if a state contains:
- S, Spades/Arrowhead is activated
- H, Hearts/Bloodstone is activated
- D, Diamonds/Rough Gem is activated
- C, Clubs/Onyx Agate is activated

]]
