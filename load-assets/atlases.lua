--[[local cryptid_is_loaded = function ()
	return (SMODS.Mods["Cryptid"] or {}).can_load
end]]

local dim = {
	CARD = { 71, 95 },
	TAG = { 34, 34 },
	SUIT_ICON = {18, 18}
}

local atlases = {
	{      dim.CARD, "booster_packs"             },
	{      dim.CARD, "consumables"               },
	{      dim.CARD, "decks"                     },
	{      dim.CARD, "decks_corrupt"             },
	{      dim.CARD, "enhancements"              },
	{      dim.CARD, "jokers"                    },
	{      dim.CARD, "jokers_corrupt"            },
	{      dim.CARD, "mutations"                 },
	{      dim.CARD, "optics"                    },
	{      dim.CARD, "optics_hc"                 },
	{      dim.CARD, "placeholder"               },
	{      dim.CARD, "seals"                     },
	{      dim.CARD, "seals_marks"               },
	{ dim.SUIT_ICON, "suits"                     },
	{ dim.SUIT_ICON, "suits_hc"                  },
	{       dim.TAG, "tags"                      },
	{      dim.CARD, "vouchers"                  },
	{      dim.CARD, "itemspecific/apache_tears" },
	--{      dim.CARD, "crossmod/cryptid_planets", cryptid_is_loaded },
	-- Deck skin atlases are found in load-assets/deckskins.lua
}

for _,def in ipairs(atlases) do
	local condition = def[3]
	if (condition and not condition()) then return end

	local path = def[2]
	local px, py = def[1][1], def[1][2]

	local file_name = path .. ".png"
	local key = path:gsub("/", "_")

	SMODS.Atlas { key = key,
		path = file_name,
		px = px, py = py
	}
end

----

SMODS.Atlas {
	key = "blinds",
	path = "blinds.png",
	px = 34, py = 34,
	atlas_table = "ANIMATION_ATLAS",
	frames = 21
}

SMODS.Atlas {
	key = "itemspecific_apartfalling",
	path = "itemspecific/apartfalling.png",
	px = 71, py = 95,
	atlas_table = "STATE_ATLAS",
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
