

SMODS.Back{
  key = "c_red",
  pos = { x = 0, y = 0 },
  atlas = "cdeck_atlas",
  loc_txt = {
      name = 'Corrupt Red Deck',
      text = {
            "{C:mult}+1{} discard per round",
            "When you {C:mult}discard{}, all cards",
            "{C:attention}EXCEPT{} selected are {C:mult}discarded{}",
            "After a hand, {C:mult}discard{} up to",
            "{C:attention}5{} held cards at random"
      }
  },
  apply = function(self)
    G.GAME.in_corrupt = true
    G.GAME.in_corrupt_red = true
    G.GAME.starting_params.discards = G.GAME.starting_params.discards + 1
  end,
  calculate = function(self, card, context)
    if context.after then
      G.E_MANAGER:add_event(Event({
        func = function()
          local _cards = {}
          for k, v in ipairs(G.hand.cards) do
            _cards[#_cards + 1] = v
          end
          for i = 1, 5 do
            if G.hand.cards[i] then
              local selected_card, card_key = pseudorandom_element(_cards, pseudoseed("CRed"))
              G.hand:add_to_highlighted(selected_card, true)
              G.FUNCS.discard_cards_from_highlighted(nil, true)
              G.hand:unhighlight_all()
            end
          end
          return true
        end,
      }))
    end
  end,
}

SMODS.Back{
  key = "c_blue",
  pos = { x = 1, y = 0 },
  atlas = "cdeck_atlas",
  loc_txt = {
      name = 'Corrupt Blue Deck',
      text = {
            "{C:chips}+2{} starting Hands",
            "Hands {C:mult}never reset{}",
            "{C:chips}+3{} Hands when {C:attention}Boss Blind{} defeated",
      }
  },
  apply = function(self)
    G.GAME.in_corrupt = true
    G.GAME.starting_params.hands = G.GAME.starting_params.hands + 2
  end,
  calculate = function(self, card, context)
    G.GAME.round_resets.hands = G.GAME.current_round.hands_left
    if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
      G.GAME.round_resets.hands = G.GAME.round_resets.hands + 3
    end
  end,
}

SMODS.Back{
  key = "c_yellow",
  pos = { x = 2, y = 0 },
  atlas = "cdeck_atlas",
  loc_txt = {
      name = 'Corrupt Yellow Deck',
      text = {
            "+{C:money}$120{} each {C:attention}Ante{}",
            "{C:attention}Infinite{} Hands and discards,",
            "each cost {C:money}$10{} and {C:money}$5{} respectively",
            "Cost increases by {X:money,C:white} X1.25 {} (floored) each {C:attention}Ante{}",
            "{s:0.3} {}",
            "At less than {C:money}$1{}, {C:mult}Game Over{}",
      }
  },
  apply = function(self)
    G.GAME.in_corrupt = true
    G.GAME.cy_dollarsperante = 120
    G.GAME.cy_handcost = 10
    G.GAME.cy_discardcost = 5
    G.GAME.modifiers.money_per_hand = 0
    G.GAME.round_resets.hands = G.GAME.cy_handcost
    G.GAME.round_resets.discards = G.GAME.cy_discardcost
    G.GAME.current_round.hands_left = G.GAME.cy_handcost
    G.GAME.current_round.discards_left = G.GAME.cy_discardcost
    ease_dollars(G.GAME.cy_dollarsperante)
    G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + G.GAME.cy_dollarsperante
    G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
  end,
  calculate = function(self, card, context)
      G.GAME.current_round.hands_left = G.GAME.cy_handcost
      G.GAME.current_round.discards_left = G.GAME.cy_discardcost
    if context.before then
      ease_dollars(-G.GAME.cy_handcost)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - G.GAME.cy_handcost
      G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
    end
    if context.pre_discard then
      ease_dollars(-G.GAME.cy_discardcost)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) - G.GAME.cy_discardcost
      G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
    end
    if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
      G.GAME.cy_handcost = math.floor(G.GAME.cy_handcost * 1.25)
      G.GAME.cy_discardcost = math.floor(G.GAME.cy_discardcost * 1.25)
      ease_dollars(G.GAME.cy_dollarsperante)
      G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + G.GAME.cy_dollarsperante
      G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
    end
    if G.GAME.dollars >= (math.floor(G.GAME.dollars) + math.floor(G.GAME.dollars)) then
      G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false
    end
  end,
}

SMODS.Back{
  key = "c_painted",
  pos = { x = 1, y = 2 },
  atlas = "cdeck_atlas",
  loc_txt = {
      name = 'Corrupt Painted Deck',
      text = {
            "{C:attention}Enhanced{} cards retrigger once",
            "{C:attention}+5{} hand size",
            "{C:mult}Jokerless{}"
      }
  },
  apply = function(self)
    G.GAME.in_corrupt = true
    G.GAME.joker_rate = 0
    G.GAME.starting_params.joker_slots = G.GAME.starting_params.joker_slots - math.huge
    G.GAME.starting_params.hand_size = G.GAME.starting_params.hand_size + 5
  end,
  calculate = function(self, card, context)
    if context.repetition and context.other_card.ability.effect ~= "Base" then
      return {
        message = localize("k_again_ex"),
        repetitions = 1,
        card = card,
      }
    end
  end,
}

SMODS.Back{
  key = "c_plasma",
  pos = { x = 3, y = 2 },
  atlas = "cdeck_atlas",
  loc_txt = {
      name = 'Corrupt Plasma Deck',
      text = {
            "{C:ovn_corrupted}Instability{} exponent operand",
            "added to score calculation",
            "{s:0.3} {}",
            "Start with {C:attention}Joker{},",
            "{C:attention}The Abyss{}, and {C:attention}Perception{}"
      }
  },
  apply = function(self)
    G.GAME.in_corrupt = true
    G.GAME.in_corrupt_plasma = true
    G.GAME.instability = 1
    G.GAME.corrumod = 0.2
    G.GAME.opticmod = 0.025
  end,
  calculate = function(self, card, context)
    if context.after then
      G.E_MANAGER:add_event(Event({
        trigger = "immediate",
        delay = 0.0,
        func = function()
          play_sound("ovn_decrement", 1, 0.8)
          G.GAME.instability = (G.GAME.instability - 0.05)
          return true
        end,
      }))
    end
  end,
}
