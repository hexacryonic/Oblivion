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



--------------------------
---- MUSIC CONDITIONS ----
--------------------------

local not_removed = function(tbl)
	return tbl and not tbl.REMOVED
end

local desired_track = function ()
	if not_removed(G.booster_pack_sparkles) then
		return 'music_booster'
	end

	if not_removed(G.booster_pack_meteors) then
		return 'music_planets'
	end

	if not_removed(G.booster_pack) then
		return 'music_booster'
	end

	if not_removed(G.shop) then
		return 'music_shop'
	end

	if G.GAME.blind and G.GAME.blind.boss then
		return 'music_boss'
	end

	return 'music_normal'
end


-----------------------
---- REGULAR MUSIC ----
-----------------------
local standard_music = {
	music_corrupt       = "music_normal",
	music_corrupt_shop  = "music_shop",
	music_corrupt_pack1 = "music_booster",
	music_corrupt_pack2 = "music_planets",
	music_corrupt_boss  = "music_boss",
}

for key,track_type in pairs(standard_music) do
	SMODS.Sound({
		key = key,
		path = "music/" .. key .. ".ogg",
		pitch = 1,
		select_music_track = function()
			return G.GAME
			and Ovn_f.deck_is_corrupt()
			and (
				type(track_type) == "table"
				and track_type[desired_track()]
				or track_type == desired_track()
			)
		end
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
		return (
			not Oblivion.config.disable_a_part_falling_music
			and G.GAME
			and Ovn_f.has_joker('j_ovn_apartfalling')
			and not (
				desired_track() == "music_normal"
				or desired_track() == "music_boss"
			)
		) and 5 or false
	end,
}

SMODS.Sound {
	key = "music_apf_boss",
	path = "music/music_apf_boss.ogg",

	sync = { ovn_music_apf = true },
	pitch = 1,
	volume = 0.5,

	select_music_track = function()
		return (
			not Oblivion.config.disable_a_part_falling_music
			and G.GAME
			and Ovn_f.has_joker('j_ovn_apartfalling')
			and (
				desired_track() == "music_normal"
				or desired_track() == "music_boss"
			)
		) and 5 or false
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