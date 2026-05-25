------------------
-- Autocannibalism
------------------
SMODS.Achievement { key = "autocannibalism",
	order = 1,
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
	order = 2,
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
	order = 3,
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
	order = 4,
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

-- do it first, order = 5

--------------------------------
-- This Entire Quest Was Bananas
--------------------------------
SMODS.Achievement { key = "bananas",
	order = 6,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_natural_aeon')
	end
}

-----------
-- Dark Web
-----------
SMODS.Achievement { key = "darkweb",
	order = 7,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_big_database')
	end
}

-----------------------------------------
-- Unstoppable Force Vs. Immovable Object
-----------------------------------------
SMODS.Achievement { key = "unstoppableforce",
	order = 8,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_lol_lmao_even')
	end
}

----------------
-- That Tickled!
----------------
SMODS.Achievement { key = "tickled",
	order = 9,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_ticklish_quip')
	end
}

------------------------------------------
-- Reach for the Sun and Burn! Burn! Burn!
------------------------------------------
SMODS.Achievement { key = "eventhoz_scale",
	order = 10,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_eventhoz_scale')
	end
}

-------------------------------
-- The Slumbering Beast Awakens
-------------------------------
SMODS.Achievement { key = "slumbering_beast",
	order = 11,
	unlock_condition = function (self, args)
		return (args.type == 'ovn_slumbering_beast')
	end
}