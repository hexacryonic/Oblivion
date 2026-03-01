-- Defines enhancement and seal corruptions

--[[

Oblivion.corruption_map takes key-value pairs,
where the key is the key of the enhancement being transformed
and the value is the key of the enhancement to transform into

Oblivion.seal_corrupt follows similarly,
but keys and values are instead for keys of seals

]]

Oblivion.enhancement_corrupt = Oblivion.enhancement_corrupt or {}
local cenh = Oblivion.enhancement_corrupt
cenh["m_glass"] = "m_ovn_ice"
cenh["m_gold"]  = "m_ovn_dense"
cenh["m_steel"] = "m_ovn_unob"
cenh["m_wild"]  = "m_ovn_coord"
cenh["m_stone"] = "m_ovn_crystal"
cenh["m_bonus"] = "m_ovn_radiant"
cenh["m_mult"]  = "m_ovn_dynamo"
cenh["m_lucky"] = "m_ovn_ion"

Oblivion.seal_corrupt = Oblivion.seal_corrupt or {}
local cseal         = Oblivion.seal_corrupt
cseal["Red"]        = "ovn_ruby_mark"
cseal["Blue"]       = "ovn_sapphire_mark"
cseal["Purple"]     = "ovn_amethyst_mark"
cseal["Gold"]       = "ovn_citrine_mark"
cseal["ovn_indigo"] = "ovn_iolite_mark"