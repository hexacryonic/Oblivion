local __og__  = { id = 'ovn_og'     }
local __new__ = { id = 'ovn_new'    }
local _but_   = { id = 'ovn_but'    }
local _spacer = { id = 'ovn_spacer' }

-------------------
-- Corrupt Omelette
-------------------
local c_egg = { id = 'j_egg', edition = 'negative' }
SMODS.Challenge {
    key = 'corrupt_omelette',
    rules = {
        custom = {
			__og__,
			_spacer,
            { id = 'no_reward'               },
            { id = 'no_extra_hand_money'     },
            { id = 'no_interest'             },
			_spacer,
			_spacer,

			__new__,
			_spacer,
			{ id = 'ovn_egg_all_eggs'        },
			_but_,
			{ id = 'ovn_egg_eternal_egg'     },
			{ id = 'ovn_egg_no_swashbuckler' },
        }
    },
    jokers = {
        c_egg, c_egg, c_egg, c_egg, c_egg,
		c_egg, c_egg, c_egg, c_egg, c_egg,
    },
    restrictions = {
        banned_cards = {
            { id = 'v_seed_money'   },
            { id = 'v_money_tree'   },
            { id = 'j_to_the_moon'  },
            { id = 'j_rocket'       },
            { id = 'j_golden'       },
            { id = 'j_satellite'    },
			{ id = 'j_swashbuckler' }
        }
    },
	calculate = function (self, context)
		if context.end_of_round and context.main_eval then
			local all_eggs = SMODS.find_card('j_egg')
			if #all_eggs == 0 then return end

			local selected_egg = pseudorandom_element(all_eggs, 'ovn_corrupt_omlette') --[[@as Card]]
			selected_egg:add_sticker('eternal', true)
			selected_egg:juice_up()
			play_sound('generic1')
		end
	end
}

---------------
-- Corrupt Edge
---------------
SMODS.Challenge {
    key = 'corrupt_edge',
	rules = {
		custom = {
			__new__,
			_spacer,
            { id = 'ovn_edge_foil'  },
			_but_,
            { id = 'ovn_edge_knife' },
		},
        modifiers = { {id = 'joker_slots', value = 2} }
	},
	jokers = {
        {id = 'j_ceremonial', eternal = true, pinned = true, edition = 'foil'}
	},
	consumeables = { },
    vouchers = { },
	deck = {
		type = 'Challenge Deck'
	},
	restrictions = {
		banned_cards = { },
		banned_tags = { },
		banned_other = {
		}
	}
}

----------------
-- Corrupt World
----------------
local function corrupt_world_deck_cards()
	local cards = {}

	local suits = {'D', 'C', 'H', 'S'}
	local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', 'A'}

	for _,suit in ipairs(suits) do
		for _,rank in ipairs(ranks) do
			table.insert(cards, {s=suit, r=rank})
		end
	end

	table.insert(cards, {s='ovn_O',r='A',})
	return cards
end

SMODS.Challenge {
	key = 'corrupt_world',
	rules = {
		custom = {
			__og__,
			_spacer,
			{ id = 'no_extra_hand_money' },
			{ id = 'no_interest'         },
			_spacer,
			_spacer,

			__new__,
			_spacer,
			{ id = 'ovn_world_aces'      },
			_but_,
			{ id = 'ovn_world_pmo'       },
		},
		modifiers = { }
	},
	jokers = {
		{id = 'j_ovn_pmo', edition = 'negative', eternal = true},
		{id = 'j_business', eternal = true},
	},
	consumeables = { },
	vouchers = { },
	deck = {
		cards = corrupt_world_deck_cards(),
		type = 'Challenge Deck'
	},
	restrictions = {
		banned_cards = { },
		banned_tags = { },
		banned_other = {
			{id = 'bl_plant', type = 'blind'},
		}
	}
}

-------------------
-- Corrupt Eternity
-------------------
SMODS.Challenge {
    key = 'corrupt_eternity',
    rules = {
        custom = {
			__og__,
			{ id = 'ovn_spacer'           },
            { id = 'ovn_all_eternal'      },
			{ id = 'ovn_spacer'           },
			{ id = 'ovn_spacer'           },

			__new__,
			{ id = 'ovn_spacer'           },
			{ id = 'ovn_eternal_none_eternal'     },
			_but_,
			{ id = 'ovn_eternal_extra_perishable' }, -- This has an effect; see joker_effects.toml
        }
    },
    restrictions = {
        banned_cards = {
            { id = 'j_ceremonial'    },
            { id = 'j_ride_the_bus'  },
            { id = 'j_runner'        },
            { id = 'j_constellation' },
            { id = 'j_green_joker'   },
            { id = 'j_red_card'      },
            { id = 'j_madness'       },
            { id = 'j_square'        },
            { id = 'j_vampire'       },
            { id = 'j_hologram'      },
            { id = 'j_rocket'        },
            { id = 'j_obelisk'       },
            { id = 'j_lucky_cat'     },
            { id = 'j_flash'         },
            { id = 'j_trousers'      },
            { id = 'j_castle'        },
            { id = 'j_glass'         },
            { id = 'j_wee'           },
        },
    },
	apply = function (self)
		G.GAME.perishable_rounds = 2
	end
}

------------------
-- Corrupt Quintet
------------------
SMODS.Challenge {
    key = 'corrupt_quintet',
    rules = {
		custom = {
			__new__,
			_spacer,
            { id = 'ovn_quintet_jokerslot' },
            { id = 'ovn_quintet_discard'   },
			_but_,
            { id = 'ovn_quintet_addiction' },
		},
        modifiers = {
            { id = 'discards',    value = 7 },
            { id = 'hand_size',   value = 5 },
            { id = 'joker_slots', value = 8 },
        }
    },
    jokers = {
        { id = 'j_card_sharp' },
        { id = 'j_joker' },
		{ id = 'j_ovn_spiral_of_addiction', edition = 'negative', eternal = true }
    },
    restrictions = {
        banned_cards = {
            { id = 'j_juggler' },
            { id = 'j_troubadour' },
            { id = 'j_turtle_bean' },
        }
    }
}
