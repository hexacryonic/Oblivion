---@meta
---@diagnostic disable: duplicate-doc-alias

---@alias Enhancements
---| 'm_ovn_radiant'
---| 'm_ovn_dynamo'
---| 'm_ovn_coord'
---| 'm_ovn_ice'
---| 'm_ovn_unob'
---| 'm_ovn_crystal'
---| 'm_ovn_dense'
---| 'm_ovn_ion'

---@alias Editions
---| 'e_ovn_miasma'

---@alias Seals
---| 'ovn_indigo'
---| 'ovn_ruby_mark'
---| 'ovn_sapphire_mark'
---| 'ovn_citrine_mark'
---| 'ovn_amethyst_mark'
---| 'ovn_iolite_mark'

-- stickers

---@alias PokerHands
---| 'ovn_Spectrum'
---| 'ovn_Straight Spectrum'
---| 'ovn_Spectrum House'
---| 'ovn_Spectrum Five'

-- ranks

---@alias Suits
---| 'ovn_Optics'

---@alias Rarities
---| 'ovn_corrupted'
---| 'ovn_supercorrupted'

-- playareas

---@class Oblivion.PassiveEffect: SMODS.GameObject
---@field key string
---@field config? table
-- Calculates effects based on parameters in `context`. See [SMODS calculation](https://docs.smods.dev/API%20Documentation/Calculate-Functions) docs for details.
---@field calculate? fun(self: Oblivion.PassiveEffect|table, context: CalcContext|table): table?, boolean?
-- Allows modifying the game state when the passive effect is being activated.
---@field add_to_deck? fun(self: Oblivion.PassiveEffect|table)
-- Allows modifying the game state when the passive effect is being deactivated.
---@field remove_from_deck? fun(self: Oblivion.PassiveEffect|table)
-- Marks the passive effect as active.
---@field activate? fun(self: Oblivion.PassiveEffect|table)
-- Unmarks the passive effect as active.
---@field deactivate? fun(self: Oblivion.PassiveEffect|table)
---@overload fun(self: Oblivion.PassiveEffect): Oblivion.PassiveEffect
Oblivion.PassiveEffect = setmetatable({}, {
    __call = function (self)
        return self
    end
})