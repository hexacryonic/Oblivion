--[[local cryptid_is_loaded = function ()
	return (SMODS.Mods["Cryptid"] or {}).can_load
end]]

local D = {
	CARD = { 71, 95 },
	TAG = { 34, 34 },
	SUIT_ICON = { 18, 18 },
	BLIND = { 34, 34 }
}

local function load_atlas(dims, path, cfg)
	cfg = cfg or {}
	local condition = cfg.condition
	if (condition and not condition()) then return end

	local px, py = dims[1], dims[2]
	local file_name = path .. ".png"
	local key = path:gsub("/", "_")

	local mode, frames
	if type(cfg.anim) == "number" then
		frames = cfg.anim
		mode = "ANIMATION_ATLAS"
	elseif cfg.anim == "state" then
		mode = "STATE_ATLAS"
	end

	SMODS.Atlas { key = key,
		path = file_name,
		px = px, py = py,
		atlas_table = mode,
		frames = frames
	}
end

load_atlas(     D.BLIND, "blinds", {anim=21} )
load_atlas(      D.CARD, "booster_packs"     )
load_atlas(      D.CARD, "consumables"       )
load_atlas(      D.CARD, "decks"             )
load_atlas(      D.CARD, "decks_corrupt"     )
load_atlas(      D.CARD, "enhancements"      )
load_atlas(      D.CARD, "jokers"            )
load_atlas(      D.CARD, "jokers_corrupt"    )
load_atlas(      D.CARD, "mutations"         )
load_atlas(      D.CARD, "optics"            )
load_atlas(      D.CARD, "optics_hc"         )
load_atlas(      D.CARD, "placeholder"       )
load_atlas(      D.CARD, "seals"             )
load_atlas(      D.CARD, "seals_marks"       )
load_atlas( D.SUIT_ICON, "suits"             )
load_atlas( D.SUIT_ICON, "suits_hc"          )
load_atlas(       D.TAG, "tags"              )
load_atlas(      D.CARD, "vouchers"          )
load_atlas(      D.CARD, "itemspecific/apache_tears" )
load_atlas(      D.CARD, "itemspecific/apartfalling", {anim="state"} )
--load_atlas(      D.CARD, "crossmod/cryptid_planets", {condition=cryptid_is_loaded} )

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
