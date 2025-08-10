local cdeck_cond = function(deck, stake)
	stake = stake or 5
	local current_deck = G.GAME.selected_back.effect.center.key
	local current_stake = G.GAME.stake
	return current_deck == deck and current_stake >= stake
end

SMODS.Achievement{
	key = "red_rum",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local has_spiral = Ovn_f.has_joker('j_ovn_sprial_of_addiction')
			if (
				cdeck_cond("b_red")
				and has_spiral
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "blue_blitz",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local round_count = G.GAME.round
			local hand_count = G.GAME.hands_played
			if (
				cdeck_cond("b_blue")
				and round_count == hand_count
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "yellow_yearlong",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local money_count = G.GAME.dollars
			if (
				cdeck_cond("b_yellow")
				and money_count == "365"
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "groundless_greenery",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local money_count = G.GAME.dollars
			local used_seedmoney = G.GAME.used_vouchers.v_seed_money
			local used_moneytree = G.GAME.used_vouchers.v_money_tree
			if (
				cdeck_cond("b_green")
				and used_seedmoney
				and used_moneytree
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "bleakest_blackout",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local max_joker_count = G.GAME.max_jokers
			if (
				cdeck_cond("b_black")
				and max_joker_count <= 4
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "magic_malaise",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local tarot_use_count = (
				G.GAME.consumeable_usage_total
				and G.GAME.consumeable_usage_total.tarot
				or 0
			)
			if (
				cdeck_cond("b_magic")
				and tarot_use_count == 0
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "negated_nebula",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local tarot_use_count = (
				G.GAME.consumeable_usage_total
				and G.GAME.consumeable_usage_total.planet
				or 0
			)
			if (
				cdeck_cond("b_nebula")
				and tarot_use_count == 0
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "ghostly_gall",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local tarot_use_count = (
				G.GAME.consumeable_usage_total
				and G.GAME.consumeable_usage_total.spectral
				or 0
			)
			if (
				cdeck_cond("b_ghost")
				and tarot_use_count == 0
			) then return true end
		end
	end
}

-- absolved abandoment
-- checkered changeling
-- zodiac zenith

SMODS.Achievement{
	key = "painted_paladin",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local joker_count = #G.jokers.cards
			if (
				cdeck_cond("b_painted")
				and joker_count >= 7
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "anticipated_anaglyphs",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local double_tag_count = 0
			for _,tag in ipairs(G.GAME.tags) do
				if tag.key == "tag_double" then
					double_tag_count = double_tag_count + 1
				end
			end
			if (
				cdeck_cond("b_painted")
				and double_tag_count >= 7
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "plasma_plight",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local blind_requirement = G.GAME.blind.chips
			local score = G.GAME.chips
			if (
				cdeck_cond("b_plasma")
				and score >= blind_requirement*20
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "erratic_eruption",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			if (
				cdeck_cond("b_erratic")
				and pseudorandom("erratic_eruption") < (1/8)
			) then return true end
		end
	end
}

SMODS.Achievement{
	key = "ocular_overseer",
	unlock_condition = function(self, args)
		if args.type == 'win' then
			local optics_count = 0
			for _,card in ipairs(G.deck.cards) do
				if card.base.suit == "ovn_Optics" then
					optics_count = optics_count + 1
				end
			end
			if (
				cdeck_cond("b_ovn_ocular", 8)
				and optics_count >= 40
			) then return true end
		end
	end
}

-- decoherent deity
-- abyssal absolution
-- autocannibalism

SMODS.Achievement{
	key = "ace_combat",
	unlock_condition = function(self, args)
		local has_pmo = Ovn_f.has_joker('j_ovn_pmo')
		local has_pareidolia = Ovn_f.has_joker('j_ovn_pareidolia')
		if has_pmo and has_pareidolia then return true end
	end
}

-- singular strike
-- exposed nerve
-- do it first
-- bananas