---------
-- SHADER
-- Miasma
---------
SMODS.Shader { key = 'miasma',
	path = 'miasma.fs'
}

-------------------------------
-- SCREEN SHADER
-- Corrupt Erratic Deck overlay
-------------------------------
SMODS.ScreenShader { key = "corrupt_erratic",
	path = "corrupt_erratic.fs",
	order = 99,

	should_apply = function(self)
		return G.GAME.override_crt and not (Oblivion.config.disable_c_erratic_shader or G.SETTINGS.reduced_motion)
	end,
	send_vars = function(self)
		return {
			iTime             = -G.TIMERS.REAL,
			resolution        = {love.graphics.getWidth(), love.graphics.getHeight()},
			matrix_intensity  = G.GAME.erratic_fx_matrix_intensity or 0,
			matrix_lines      = G.GAME.erratic_fx_matrix_lines or 30,
			block_size        = G.GAME.erratic_fx_block_size or 8,
			block_offset      = G.GAME.erratic_fx_block_offset or 10,
			block_probability = G.GAME.erratic_fx_block_probability or 0.2,
			matrix_color      = G.GAME.erratic_fx_matrix_colour or {0.2, 1, 0.2, 0},
		}
	end
}