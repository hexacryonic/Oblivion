--------------------
-- SCORING PARAMETER
-- Instability
--------------------
Oblivion.play_instability_noise = true
-- Values are dummy; to change instability, use Ovn_f.change_instability
SMODS.Scoring_Parameter { key = 'instability',
	default_value = 1,
	colour = G.C.RARITY['ovn_corrupted'],
	flame_handler = function(self)
		return {
			id = 'flame_'..self.key,
			arg_tab = self.key..'_flames',
			colour = G.C.RARITY['ovn_corrupted'],
			accent = self.lick
		}
	end,
	level_up_hand = function() end,
	modify = function(self, amount)
		if amount == 0 then return end

		G.GAME.ovn_instability = G.GAME.ovn_instability or 1
		local instability_max = G.GAME.instability_clamp or 2

		if G.GAME.ovn_instability + amount >= instability_max then
			G.GAME.ovn_instability = instability_max
		else
			G.GAME.ovn_instability = G.GAME.ovn_instability + amount
		end

		if Oblivion.play_instability_noise then
			if amount < 0 then
				play_sound("ovn_instability_decrement", 1, 0.8)
			elseif amount > 0 then
				play_sound("ovn_instability_increment", 1, 0.9)
			end
			-- Prevention of sound spam (often occurs with consumables)
			if G.STATE == G.STATES.PLAY_TAROT then
				Oblivion.play_instability_noise = false
			end
		end

		self.current = G.GAME.ovn_instability
	end,
}

-------------------
-- SCORING OPERATOR
-- Instable
-------------------
SMODS.Scoring_Calculation { key = "instable",
	func = function(self, chips, mult, flames)
		local instability = G.GAME.ovn_instability
		---@diagnostic disable-next-line: redundant-return-value
		return (chips * mult) ^ instability
	end,
	replace_ui = function (self)
		local function op(text, scale, colour)
			return
			{n=G.UIT.C, config={align = "cm"}, nodes={
				{n=G.UIT.T, config={text = text, lang = G.LANGUAGES['en-us'], scale = scale, colour = colour or G.C.WHITE, shadow = true}},
			}}
		end

		local function container(type, id, scale, w, h, colour)
			return
			{n=G.UIT.C, config={align = 'cm', id = id}, nodes = {
				SMODS.GUI.score_container({
					type = type,
					align = 'cm',
					scale = scale,
					w = w, h = h,
					colour = colour
				})
			}}
		end

		local w = 1.2
		local h = 0.7
		local text_scale = 0.69/2.3
		local op_scale = 0.5

		return
		---@diagnostic disable-next-line: redundant-return-value
		{n=G.UIT.R, config={align = "cm", minh = 1, padding = 0.05}, nodes={
			op("(", op_scale, G.C.RARITY['ovn_corrupted']),
			container("chips", "hand_chips_container", text_scale, w, h),
			SMODS.GUI.operator(op_scale/2),
			container("mult", "hand_mult_container", text_scale, w, h),
			op(")", op_scale, G.C.RARITY['ovn_corrupted']),
			op("^", op_scale, G.C.RARITY['ovn_corrupted']),
			container("ovn_instability", "instability_container", text_scale, w, h, G.C.RARITY['ovn_corrupted']),
		}}
	end
}

--------------------
-- DESCRIPTION DUMMY
-- Instability
--------------------
Oblivion.DescriptionDummy { key = "instability_description" }