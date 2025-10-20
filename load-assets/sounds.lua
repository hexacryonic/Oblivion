local soundbytes = {
	-- true means path is <key>.ogg ("ditto case")
	-- <string> means path is <string>.ogg
	abyss        = true,
	optic        = true,
	pure         = true,
	e_miasma     = true,
	insecurity   = true,
	tres         = true,
	recall       = true,
	decrement    = "powerdecrement",
	increment    = "powerincrement",
	ion_backfire = "ionBackfire",
	ion_zap      = "ionZap"
}

for key, path in pairs(soundbytes) do
	local file_name = (path == true and key or path) .. ".ogg"
	SMODS.Sound{
		key = key,
		path = file_name
	}
end

-- == Music

local sync_group = {
	music1 = true,
}

SMODS.Sound({
	key = "musicDoom",
	path = "musicDoom.ogg",

	sync = false,
	pitch = 1,
	volume = 1.2,

	select_music_track = function()
		return (
			G.GAME
			and G.GAME.used_insecurity
			and G.GAME.used_tres
			and G.GAME.used_recall
			and not G.GAME.imcoming -- [sic]
		)
	end,
})

SMODS.Sound({
	key = "musicApproaching",
	path = "musicApproaching.ogg",

	sync = false,
	pitch = 1,

	select_music_track = function()
		return G.GAME and G.GAME.imcoming
	end,
})

SMODS.Sound({
	key = "musicCorrupt",
	path = "musicCorrupt.ogg",

	pitch = 1,

	select_music_track = function()
		return (
			G.GAME
			and Ovn_f.deck_is_corrupt()
			and not G.shop
			and not G.booster_pack
			and not G.booster_pack_sparkles
			and not G.booster_pack_meteors
			and not (G.GAME.blind and G.GAME.blind.boss)
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
})

SMODS.Sound({
	key = "musicCorruptShop",
	path = "musicCorruptShop.ogg",

	pitch = 1,

	select_music_track = function()
		return (
			G.GAME
			and Ovn_f.deck_is_corrupt()
			and G.shop
			and not G.shop.REMOVED
			and not G.booster_pack
			and not G.booster_pack_sparkles
			and not G.booster_pack_meteors
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
})

SMODS.Sound({
	key = "musicCorruptPack1",
	path = "musicCorruptPack1.ogg",

	pitch = 1,

	select_music_track = function()
		return (
			G.GAME
			and Ovn_f.deck_is_corrupt()
			and G.booster_pack
			and not G.booster_pack.REMOVED
			and not G.booster_pack_meteors
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
})

SMODS.Sound({
	key = "musicCorruptPack2",
	path = "musicCorruptPack2.ogg",

	pitch = 1,

	select_music_track = function()
		return G.GAME and (
			Ovn_f.deck_is_corrupt()
			and G.booster_pack_meteors
			and not G.booster_pack_meteors.REMOVED
			and not G.booster_pack_sparkles
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
})

SMODS.Sound({
	key = "musicCorruptBoss",
	path = "musicCorruptBoss.ogg",

	pitch = 1,

	select_music_track = function()
		return G.GAME and (
			Ovn_f.deck_is_corrupt()
			and G.GAME.blind
			and G.GAME.blind.boss
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
})

SMODS.Sound({
	key = "musicAPF",
	path = "musicAPF.ogg",

	sync = { ovn_musicAPFBlind = true },
	pitch = 1,
	volume = 0.6,

	select_music_track = function()
	return G.GAME and (
		Ovn_f.has_joker('j_ovn_apartfalling')
		and (
			G.shop
			or G.booster_pack
			or not G.GAME.blind
			or G.blind_select
			or G.round_eval
		)
	)
	end,
})

SMODS.Sound({
	key = "musicAPFBlind",
	path = "musicAPFBlind.ogg",

	sync = { ovn_musicAPF = true },
	pitch = 1,
	volume = 0.5,

	select_music_track = function()
		return G.GAME and (
			Ovn_f.has_joker('j_ovn_apartfalling')
			and G.GAME.blind
		)
	end,
})
