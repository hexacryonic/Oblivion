local card_atlases = {
	-- For atlases with px = 71, py = 95
	-- true means path is <key>.png ("ditto case")
	-- <string> means path is <string>.png
	corrupted    = true,
	notcorrupted = true,

	charybdis_atlas    = "charybdis",
	abyss_atlas        = "abyss",
	opticenhance_atlas = "opticenhance",
	cataclysm_atlas    = "cataclysm",
	spectrum_atlas     = "spectrum",
	deck_atlas         = "deck",
	cdeck_atlas        = "corruptdeck",
	mutation_atlas     = "mutation",
	cboosters_atlas    = "cbooster",
	seals_atlas        = "seals",
	marks_atlas        = "marks",
	voucher_atlas      = "atlasvoucher",
	skin_nd_lc         = "skinND_lc",
	skin_nd_hc         = "skinND_hc",
	skin_ism_lc        = "skinISM_lc",
	skin_ism_hc        = "skinISM_hc",
	skin_acgt_lc       = "skinACGT_lc",
	skin_acgt_hc       = "skinACGT_hc",
	apache_tears       = "ApacheTears",
	apart_falling      = "APartFalling",
}

for key, path in pairs(card_atlases) do
	local file_name = (path == true and key or path) .. ".png"
	SMODS.Atlas {
		key = key,
		path = file_name,
		px = 71,
		py = 95
	}
end

----

SMODS.Atlas {
	key = "ctags_atlas",
	path = "ctags.png",
	px = 34,
	py = 34
}

SMODS.Atlas {
	key = "ovn_blinds_atlas",
	atlas_table = "ANIMATION_ATLAS",
	path = "ovn_blinds.png",
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
	path = 'opticsHC.png',
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
	path = 'suitsHC.png',
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
