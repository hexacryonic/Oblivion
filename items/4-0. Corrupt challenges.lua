-------------------
-- Corrupt Omelette
-------------------
SMODS.Challenge {
    key = 'corrupt_omelette',
    rules = {
        custom = {
			{ id = 'ovn_og'              },
			{ id = 'ovn_spacer'          },
            { id = 'no_reward'           },
            { id = 'no_extra_hand_money' },
            { id = 'no_interest'         },
			{ id = 'ovn_spacer'          },
			{ id = 'ovn_spacer'          },

			{ id = 'ovn_new'             },
			{ id = 'ovn_spacer'          },
			-- poot text here
			{ id = 'ovn_but'             },
			-- poot text here
        }
    },
    jokers = {
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
        { id = 'j_egg', edition = 'negative' },
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
		if context.end_of_round then
			for _,egg in ipairs(SMODS.find_card('j_egg')) do
				egg:add_sticker('eternal', true)
			end
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
			{ id = 'ovn_new'        },
			{ id = 'ovn_spacer'     },
            { id = 'ovn_edge_foil'  },
			{ id = 'ovn_but'        },
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
			{ id = 'ovn_og'              },
			{ id = 'ovn_spacer'          },
			{ id = 'no_extra_hand_money' },
			{ id = 'no_interest'         },
			{ id = 'ovn_spacer'          },
			{ id = 'ovn_spacer'          },

			{ id = 'ovn_new'             },
			{ id = 'ovn_spacer'          },
			{ id = 'ovn_world_aces'      },
			{ id = 'ovn_but'             },
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
			{ id = 'ovn_og'      },
			{ id = 'ovn_spacer'  },
            { id = 'all_eternal' }, -- ts actually setting stuff eternal
			{ id = 'ovn_spacer'  }, -- actually wtf all these adding to G.GAME.modifiers
			{ id = 'ovn_spacer'  }, -- there has to be a better way to add these descs ;-;

			{ id = 'ovn_new'     },
			{ id = 'ovn_spacer'  },
			-- poot text here
			{ id = 'ovn_but'     },
			-- poot text here
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
    }
}