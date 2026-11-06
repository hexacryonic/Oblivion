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
-- Key to the passive effect's atlas.
---@field atlas? string
-- Position of the center's sprite.
---@field pos? table|{x: integer, y: integer}
-- Append `badges` for additional badges on the UI display of the passive effect. To override the type badge, see `Oblivion.PassiveEffect:set_card_type_badge()`. 
---@field set_badges? fun(self: Oblivion.PassiveEffect|table, element: table, badges: table)
-- Overrides the type badges, allowing you to append `badges` to replace them. To add extra badges, see `Oblivion.PassiveEffect:set_badges()`. 
---@field set_card_type_badge? fun(self: Oblivion.PassiveEffect|table, element: table, badges: table)
-- Provides complex control over the UI display of the passive effect.
-- See [`generate_ui`](https://docs.smods.dev/API%20Documentation/Localization#generate_ui-advanced) documentation for details. 
---@field generate_ui? fun(self: Oblivion.PassiveEffect|table, info_queue: table, element: table, desc_nodes: table, specific_vars: table, full_UI_table: table)
-- Provides simple control over displaying descriptions and tooltips of the passive effect.
-- See [`loc_vars`](https://docs.smods.dev/API%20Documentation/Localization#loc_vars) documentation for return value details. 
---@field loc_vars? fun(self: Oblivion.PassiveEffect|table, info_queue: table): table?
-- Calculates effects based on parameters in `context`. See [SMODS calculation](https://docs.smods.dev/API%20Documentation/Calculate-Functions) docs for details.
---@field calculate? fun(self: Oblivion.PassiveEffect|table, context: CalcContext|table): table?, boolean?
-- Avoid calling this; instead, call `activate`.\
-- Allows modifying the game state when the passive effect is being activated.
---@field add_to_deck? fun(self: Oblivion.PassiveEffect|table)
-- Avoid calling this; instead, call `deactivate`.\
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