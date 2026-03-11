local cdeck_cond = function(deck, stake)
	stake = stake or 5
	local current_deck = G.GAME.selected_back.effect.center.key
	local current_stake = G.GAME.stake
	return current_deck == deck and current_stake >= stake
end

----------
-- Red Rum
----------
SMODS.Achievement { key = "red_rum",
	order = 1,
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

-------------
-- Blue Blitz
-------------
SMODS.Achievement { key = "blue_blitz",
	order = 2,
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

------------------
-- Yellow Yearlong
------------------
SMODS.Achievement { key = "yellow_yearlong",
	order = 3,
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

----------------------
-- Groundless Greenery
----------------------
SMODS.Achievement { key = "groundless_greenery",
	order = 4,
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

--------------------
-- Bleakest Blackout
--------------------
SMODS.Achievement { key = "bleakest_blackout",
	order = 5,
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

----------------
-- Magic Malaise
----------------
SMODS.Achievement { key = "magic_malaise",
	order = 6,
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

-----------------
-- Negated Nebula
-----------------
SMODS.Achievement { key = "negated_nebula",
	order = 7,
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

---------------
-- Ghostly Gall
---------------
SMODS.Achievement { key = "ghostly_gall",
	order = 8,
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

----------------
-- Absolved Abandonment
----------------
SMODS.Achievement { key = "absolved_abandonment",
	order = 9,
	unlock_condition = function (self, args)
		if args.type == 'win' and cdeck_cond("b_abandoned") then
			return G.GAME.current_round.played_royal_flush
		end
	end
}

-----------------------
-- Absolved Abandonment
-----------------------
SMODS.Achievement { key = "checkered_changeling",
	order = 10,
	unlock_condition = function (self, args)
		if args.type == 'win' and cdeck_cond("b_checkered") then
			return G.GAME.current_round.played_straight_spec
		end
	end
}

----------------
-- Zodiac Zenith
----------------
SMODS.Achievement { key = "zodiac_zenith",
	order = 11,
	unlock_condition = function (self, args)
		if args.type == 'win' and cdeck_cond("b_zodiac") then
			local unique_tarotplanet_count = 0
			for _,consumable_info in pairs(G.GAME.consumeable_usage) do
				if consumable_info.set == "Tarot" or consumable_info.set == "Planet" then
					unique_tarotplanet_count = unique_tarotplanet_count + 1
					if unique_tarotplanet_count == 20 then return true end
				end
			end
		end
	end
}

------------------
-- Painted Paladin
------------------
SMODS.Achievement { key = "painted_paladin",
	order = 12,
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

------------------------
-- Anticipated Anaglyphs
------------------------
SMODS.Achievement { key = "anticipated_anaglyphs",
	order = 13,
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

----------------
-- Plasma Plight
----------------
SMODS.Achievement { key = "plasma_plight",
	order = 14,
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

-------------------
-- Erratic Eruption
-------------------
SMODS.Achievement { key = "erratic_eruption",
	order = 15,
	unlock_condition = function(self, args)
		if args.type == 'win' then
			if (
				cdeck_cond("b_erratic")
				and pseudorandom("erratic_eruption") < (1/8)
			) then return true end
		end
	end
}

------------------
-- Ocular Overseer
------------------
SMODS.Achievement { key = "ocular_overseer",
	order = 16,
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

-- decoherent deity, order = 17
-- abyssal absolution, order = 18

------------------
-- Autocannibalism
------------------
SMODS.Achievement { key = "autocannibalism",
	order = 19,
	unlock_condition = function (self, args)
		if (
			args.type == 'ovn_sell_supply_drop'
			and G.PROFILES[G.SETTINGS.profile].ovn_supply_drop == "j_ovn_supplydrop"
		) then
			return true
		end
	end
}

-------------
-- Ace Combat
-------------
SMODS.Achievement { key = "ace_combat",
	order = 20,
	unlock_condition = function(self, args)
		local has_pmo = Ovn_f.has_joker('j_ovn_pmo')
		local has_pareidolia = Ovn_f.has_joker('j_ovn_pareidolia')
		if has_pmo and has_pareidolia then return true end
	end
}

--------------------------------------
-- Super Spectre Singular Strike Salvo
--------------------------------------
SMODS.Achievement { key = "singular_strike",
	order = 21,
	unlock_condition = function (self, args)
		if args.type == 'ovn_airstrike_release' then
			return true
		end
		return false
	end
}

---------------------------
-- Yanking an Exposed Nerve
---------------------------
SMODS.Achievement { key = "exposed_nerve",
	order = 22,
	unlock_condition = function (self, args)
		if args.type == 'hand' then
			local has_optics = false
			for _,other_card in ipairs(args.scoring_hand) do
				if other_card.base.suit == "ovn_Optics" then
					has_optics = true
					break
				end
			end
			return (
				args.disp_text == 'Straight Flush'
				and has_optics
				and G.GAME.blind.key == "bl_ovn_nerve"
				and G.GAME.blind.disabled
			)
		end
	end
}

-- do it first, order = 23

--------------------------------
-- This Entire Quest Was Bananas
--------------------------------
SMODS.Achievement { key = "bananas",
	order = 24,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_natural_aeon')
	end
}

-----------
-- Dark Web
-----------
SMODS.Achievement { key = "darkweb",
	order = 25,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_big_database')
	end
}

-----------------------------------------
-- Unstoppable Force Vs. Immovable Object
-----------------------------------------
SMODS.Achievement { key = "unstoppableforce",
	order = 26,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_lol_lmao_even')
	end
}

----------------
-- That Tickled!
----------------
SMODS.Achievement { key = "tickled",
	order = 28,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_ticklish_quip')
	end
}

------------------------------------------
-- Reach for the Sun and Burn! Burn! Burn!
------------------------------------------
SMODS.Achievement { key = "eventhoz_scale",
	order = 29,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_eventhoz_scale')
	end
}