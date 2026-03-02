--------------------
---- SOUNDBYTES ----
--------------------

local soundbytes = {
	-- For non-music sounds
	-- Must match file name exactly
	"corrupting_joker",
	"optic",
	"purifying",
	"e_miasma",
	"use_insecurity",
	"use_tres",
	"use_recall",
	"instability_decrement",
	"instability_increment",
	"ion_backfire",
	"ion_zap",
}

for _,key in ipairs(soundbytes) do
	local file_name = key .. ".ogg"
	SMODS.Sound {
		key = key,
		path = file_name
	}
end



-----------------------
---- REGULAR MUSIC ----
-----------------------
local standard_music = {
	music_corrupt = function()
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
	music_corrupt_shop = function()
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
	music_corrupt_pack1 = function()
		return (
			G.GAME
			and Ovn_f.deck_is_corrupt()
			and G.booster_pack
			and not G.booster_pack.REMOVED
			and not G.booster_pack_meteors
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
	music_corrupt_pack2 = function()
		return G.GAME and (
			Ovn_f.deck_is_corrupt()
			and G.booster_pack_meteors
			and not G.booster_pack_meteors.REMOVED
			and not G.booster_pack_sparkles
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
	music_corrupt_boss = function()
		return G.GAME and (
			Ovn_f.deck_is_corrupt()
			and G.GAME.blind
			and G.GAME.blind.boss
			and not Ovn_f.has_joker('j_ovn_apartfalling')
		)
	end,
}

for key,select_music_track in pairs(standard_music) do
	SMODS.Sound({
		key = key,
		path = "music/" .. key .. ".ogg",
		pitch = 1,
		select_music_track = select_music_track
	})
end



------------------------
---- A PART FALLING ----
------------------------

SMODS.Sound {
	key = "music_apf",
	path = "music/music_apf.ogg",

	sync = { ovn_music_apf_boss = true },
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
}

SMODS.Sound {
	key = "music_apf_boss",
	path = "music/music_apf_boss.ogg",

	sync = { ovn_music_apf = true },
	pitch = 1,
	volume = 0.5,

	select_music_track = function()
		return G.GAME and (
			Ovn_f.has_joker('j_ovn_apartfalling')
			and G.GAME.blind
		)
	end,
}

-------------------
---- SUPERBOSS ----
-------------------
SMODS.Sound {
	key = "music_doom",
	path = "music/music_doom.ogg",

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
}

SMODS.Sound {
	key = "music_approaching",
	path = "music/music_approaching.ogg",

	sync = false,
	pitch = 1,

	select_music_track = function()
		return G.GAME and G.GAME.imcoming
	end,
}