G.FUNCS.welcometohell = function()
  G.GAME.imcoming = true
  local text = nil
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 0.4,
    func = function()
      text = DynaText({
        string = {"I see you."},
        colours = { G.C.WHITE },
        rotate = 2,
        shadow = true,
        bump = true,
        float = true,
        scale = 0.9,
        pop_in = 1.4 / G.SPEEDFACTOR,
        pop_in_rate = 1.5 * G.SPEEDFACTOR,
        pitch_shift = 0.25,
      })
      return true
    end,
  }))
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 2.6,
    func = function()
      text:pop_out(4)
      ease_background_colour{new_colour = G.ARGS.LOC_COLOURS.ovn_corrupted, contrast = 1}
      return true
    end,
  }))
  G.GAME.win_ante = 9
end

local gu = Game.update
function Game:update(dt)
  gu(self, dt)
  if G.GAME and G.GAME.round_resets.ante == 8 and G.GAME.used_insecurity and G.GAME.used_tres and G.GAME.used_recall and G.GAME.round_resets.blind_states.Boss == 'Upcoming' and G.GAME.shop then
  if not G.GAME.imcoming then
    G.FUNCS.welcometohell()
  end
  end
end

SMODS.Consumable {
  set = "Tarot",
  name = "ovn_Insecurity",
  key = "insecurity",
  loc_txt = {
      name = 'Insecurity',
      text = {
            "{C:ovn_corrupted}You begin to feel like{}",
            "{C:ovn_corrupted}you're being watched{}"
      }
  },
  cost = 2,
  atlas = "cataclysm_atlas",
  in_pool = function()
    return G.GAME.not_used_insecurity end,
  can_use = function(self, card)
    return true end,
  pos = {x=0, y=0},
  set_card_type_badge = function(self, card, badges)
      badges[1] = create_badge('???', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.RED, 1.2)
  end,
  use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            card:juice_up(0.3, 0.4)
            play_sound("ovn_insecurity")
            card.children.center.pinch.x = true
            return true
          end,
    }))
    delay(0.6)
  G.GAME.used_insecurity = true
  G.GAME.not_used_insecurity = false
  end,
}

SMODS.Consumable {
  set = "Planet",
  name = "ovn_Tres",
  key = "tres",
  loc_txt = {
      name = 'TrEs-2b',
      text = {
            "{C:ovn_corrupted}The world around you{}",
            "{C:ovn_corrupted}begins to darken{}"
      }
  },
  cost = 2,
  atlas = "cataclysm_atlas",
  in_pool = function()
    return G.GAME.not_used_tres end,
  can_use = function(self, card)
    return true end,
  pos = {x=1, y=0},
  set_card_type_badge = function(self, card, badges)
      badges[1] = create_badge('???', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.RED, 1.2)
  end,
  use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            card:juice_up(0.3, 0.4)
            play_sound("ovn_tres", 1, 1.2)
            card.children.center.pinch.x = true
            return true
          end,
    }))
    delay(0.6)
  G.GAME.used_tres = true
  G.GAME.not_used_tres = false
  end,
}

SMODS.Consumable {
  set = "Spectral",
  name = "ovn_Recall",
  key = "recall",
  loc_txt = {
      name = 'Recall',
      text = {
            "{C:ovn_corrupted}Memories of a cataclysm{}",
            "{C:ovn_corrupted}begin to resurface{}"
      }
  },
  cost = 2,
  atlas = "cataclysm_atlas",
  in_pool = function()
    return G.GAME.not_used_recall end,
  can_use = function(self, card)
    return true end,
  pos = {x=2, y=0},
  set_card_type_badge = function(self, card, badges)
      badges[1] = create_badge('???', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.RED, 1.2)
  end,
  use = function(self, card, area, copier)
        G.E_MANAGER:add_event(Event({
          trigger = "after",
          delay = 0.4,
          func = function()
            card:juice_up(0.3, 0.4)
            play_sound("ovn_recall")
            card.children.center.pinch.x = true
            return true
          end,
    }))
    delay(0.6)
  G.GAME.used_recall = true
  G.GAME.not_used_recall = false
  end,
}
