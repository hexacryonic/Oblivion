----------------
-- Corrupted Tag
----------------
SMODS.Tag({
	key = "corrtag",

	atlas = "ctags_atlas",
	pos = { x = 0, y = 0 },

	min_ante = 2,
	requires = "j_ovn_darkjoker",

	apply = function(self, tag, context)
		if context.type == "store_joker_create" then
			local corrupts_in_posession = { 0 }

			for _,joker in ipairs(G.jokers.cards) do
				local joker_rarity = joker.config.center.rarity
				local joker_key = joker.config.center.key

				if joker_rarity == "ovn_corrupted" and not corrupts_in_posession[joker_key] then
					corrupts_in_posession[1] = corrupts_in_posession[1] + 1
					corrupts_in_posession[joker_key] = true
				end
			end

			local new_card
			if #G.P_JOKER_RARITY_POOLS.ovn_corrupted > corrupts_in_posession[1] then
				new_card = create_card("Joker", context.area, nil, "ovn_corrupted", nil, nil, nil, "ovn_cta")
				create_shop_card_ui(new_card, "Joker", context.area)
				new_card.states.visible = false

				tag:yep("+", G.C.RARITY.ovn_corrupted, function()
					new_card:start_materialize()
					new_card.ability.couponed = true
					new_card:set_cost()
					return true
				end)
			else
				tag:nope()
			end

			tag.triggered = true
			return new_card
		end
	end,
})

-------------
-- Miasma Tag
-------------
SMODS.Tag({
	key = "miasmatag",

	atlas = "ctags_atlas",
	pos = { x = 1, y = 0 },

	min_ante = 2,

	apply = function(self, tag, context)
		if context.type == 'store_joker_modify' then
			if not context.card.edition and not context.card.temp_edition and context.card.ability.set == 'Joker' then
				local lock = tag.ID
				G.CONTROLLER.locks[lock] = true
				context.card.temp_edition = true
				tag:yep('+', G.C.DARK_EDITION, function()
					context.card.temp_edition = nil
					context.card:set_edition({ ovn_miasma = true }, true)
					context.card.ability.couponed = true
					context.card:set_cost()
					G.CONTROLLER.locks[lock] = nil
					return true
				end)
				tag.triggered = true
				return true
			end
		end
	end,
})

--------------
-- Stygian Tag
--------------
SMODS.Tag({
	key = "stygiantag",

	atlas = "ctags_atlas",
	pos = { x = 3, y = 0 },

	min_ante = 2,

	apply = function(self, tag, context)
		if context.type == 'new_blind_choice' then
			local lock = tag.ID
			G.CONTROLLER.locks[lock] = true
			tag:yep('+', G.C.PURPLE, function()
				local booster = SMODS.create_card { key = 'p_ovn_wicked_normal_' .. math.random(1, 3), area = G.play }
				booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
				booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
				booster.T.w = G.CARD_W * 1.27
				booster.T.h = G.CARD_H * 1.27
				booster.cost = 0
				booster.from_tag = true
				G.FUNCS.use_card({ config = { ref_table = booster } })
				booster:start_materialize()
				G.CONTROLLER.locks[lock] = nil
				return true
			end)
			tag.triggered = true
			return true
		end
	end
})