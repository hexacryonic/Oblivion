SMODS.Challenge{
  key = 'corrupt_world',
  rules = {
      custom = {
          {id = 'ovn_og'},
          {id = 'ovn_spacer'},
          {id = 'no_extra_hand_money'},
          {id = 'no_interest'},
          {id = 'ovn_spacer'},
          {id = 'ovn_spacer'},
          {id = 'ovn_new'},
          {id = 'ovn_spacer'},
          {id = 'ovn_world_aces'},
          {id = 'ovn_but'},
          {id = 'ovn_world_pmo'},
      },
      modifiers = {
      }
  },
  jokers = {
      {id = 'j_ovn_pmo', edition = 'negative', eternal = true},
      {id = 'j_business', eternal = true},
  },
  consumeables = {
  },
  vouchers = {
  },
  deck = {
      cards = {{s='D',r='2',},{s='D',r='3',},{s='D',r='4',},{s='D',r='5',},{s='D',r='6',},{s='D',r='7',},{s='D',r='8',},{s='D',r='9',},{s='D',r='A',},{s='C',r='2',},{s='C',r='3',},{s='C',r='4',},{s='C',r='5',},{s='C',r='6',},{s='C',r='7',},{s='C',r='8',},{s='C',r='9',},{s='C',r='A',},{s='H',r='2',},{s='H',r='3',},{s='H',r='4',},{s='H',r='5',},{s='H',r='6',},{s='H',r='7',},{s='H',r='8',},{s='H',r='9',},{s='H',r='A',},{s='S',r='2',},{s='S',r='3',},{s='S',r='4',},{s='S',r='5',},{s='S',r='6',},{s='S',r='7',},{s='S',r='8',},{s='S',r='9',},{s='S',r='A',},{s='ovn_O',r='A',}},
      type = 'Challenge Deck'
  },
  restrictions = {
      banned_cards = {
      },
      banned_tags = {
      },
      banned_other = {
          {id = 'bl_plant', type = 'blind'},
      }
  }
}
