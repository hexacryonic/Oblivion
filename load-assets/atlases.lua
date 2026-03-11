local card_atlases = {
	-- For atlases with px = 71, py = 95
	-- Must match file name exactly
	"booster_packs",
	"consumables",
	"decks",
	"decks_corrupt",
	"enhancements",
	"jokers",
	"jokers_corrupt",
	"mutations",
	"optics",
	"optics_hc",
	"placeholder",
	"seals",
	"seals_marks",
	"itemspecific/apache_tears",
	"itemspecific/apartfalling",
	"crossmod/cryptid_planets",
	-- Deck skin atlases are found in items/0-3. Deck skins.lua
}

for _,path in ipairs(card_atlases) do
	local file_name = path .. ".png"
	local key = path:gsub("/", "_")
	SMODS.Atlas {
		key = key,
		path = file_name,
		px = 71,
		py = 95
	}
end

----

SMODS.Atlas {
	key = "modicon",
	path = "modicon.png",
    px = 34, py = 34,
}

SMODS.Atlas {
	key = "tags",
	path = "tags.png",
	px = 34,
	py = 34
}

SMODS.Atlas {
	key = "blinds",
	atlas_table = "ANIMATION_ATLAS",
	path = "blinds.png",
	px = 34,
	py = 34,
	frames = 21
}

----

SMODS.Atlas {
	key = 'optics',
	path = 'optics.png',
	px = 71,
	py = 95
}

SMODS.Atlas {
	key = 'optics_hc',
	path = 'optics_hc.png',
	px = 71,
	py = 95
}

SMODS.Atlas{
	key = 'suits',
	path = 'suits.png',
	px = 18,
	py = 18
}

SMODS.Atlas{
	key = 'suits_hc',
	path = 'suits_hc.png',
	px = 18,
	py = 18
}

----

--[[

Note on ApacheTears.png
Cards must be layed out such that each sprite corresponds
to the following card states:

---- S--- -H-- SH--
--D- S-D- -HD- SHD-
---C S--C -H-C SH-C
--DC S-DC -HDC SHDC

Where if a state contains:
- S, Spades/Arrowhead is activated
- H, Hearts/Bloodstone is activated
- D, Diamonds/Rough Gem is activated
- C, Clubs/Onyx Agate is activated

]]
