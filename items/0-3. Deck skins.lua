-- Currently deck skins only add for Optic face cards;
	-- this will be extended in the future as needed

-- Deck skin spritesheets MUST:
	-- be located in the deckskins directory
	-- have both a high-contrast and low-constrast version
	-- be named "skin_<key>_hc" or "skin_<key>_lc"
		-- where <key> is the key of an SMODS.DeckSkin instance

local deckskins = {
	{"novadrift", "Nova Drift"},
	{"insoundmind", "In Sound Mind"},
	{"acgt", "ACGT Series"}, -- (Genome Guardian/Cell Command)
}

for _,tbl in ipairs(deckskins) do
	local key = tbl[1]
	local loc_txt = tbl[2]

	local lc_atlas_key = "skin_" .. key .. "_lc"
	local hc_atlas_key = "skin_" .. key .. "_hc"
	local lc_atlas_path = "deckskins/" .. lc_atlas_key .. ".png"
	local hc_atlas_path = "deckskins/" .. hc_atlas_key .. ".png"
	local lc_atlas_keyfull = "ovn_" .. lc_atlas_key
	local hc_atlas_keyfull = "ovn_" .. hc_atlas_key

	-- These atlases do not follow like atlases in load-assets/atlases.lua
	-- Keys are of the form "skin_<key>_[lc/hc]"
	-- This is different from the file name "deckskins/skin_<key>_[lc/hc]"
	SMODS.Atlas {
		key = lc_atlas_key,
		path = lc_atlas_path,
		px = 71,
		py = 95
	}

	SMODS.Atlas {
		key = hc_atlas_key,
		path = hc_atlas_path,
		px = 71,
		py = 95
	}

	SMODS.DeckSkin {
		key = key,
		suit = 'ovn_Optics',
		loc_txt = {["en-us"] = loc_txt},

		palettes = {
			{
				key = 'lc',
				ranks = {"King", "Queen", "Jack"},
				display_ranks = {"King", "Queen", "Jack"},
				atlas = lc_atlas_keyfull,
				pos_style = 'collab'
			},
			{
				key = 'hc',
				ranks = {"King", "Queen", "Jack"},
				display_ranks = {"King", "Queen", "Jack"},
				atlas = hc_atlas_keyfull,
				pos_style = 'collab',
				hc_default = true
			}
		}
	}
end