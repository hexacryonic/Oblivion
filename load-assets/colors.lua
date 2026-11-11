G.C.INST = HEX('04248F')
G.C.UI_INST = G.C.INST

loc_colour()
local loc_col = G.ARGS.LOC_COLOURS
loc_col.ovn_corrupted = G.C.RARITY['ovn_corrupted']
loc_col.ovn_corrupt2  = HEX('001764')
loc_col.ovn_corrupt1  = HEX('04248f')
--loc_col.ovn_mutation  = G.C.SET.Mutation
loc_col.ovn_optics    = G.C.SUITS.ovn_Optics
loc_col.ovn_indigo    = HEX('252fe3')

loc_col.ovn_zred    = HEX('993131')
loc_col.ovn_zyellow = HEX('998131')
loc_col.ovn_zblue   = HEX('316A99')