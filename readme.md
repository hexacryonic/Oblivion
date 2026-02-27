# Oblivion
<u>***DISCLAIMER: THIS IS A PRE-ALPHA - EVERYTHING IS SUBJECT TO CHANGE, AND MORE IS SUBJECT TO BE ADDED***</u>

An expansion to Balatro themed around an **otherworldly corruption**!
* Use many new **Corrupted Jokers**, which act as sidegrades to existing Jokers.
* Discover the special **Optics** suit that twists Enhancements and Seals, featuring the **Spectrum** hand types.
* Test your mettle in **Corrupt Challenges**, buffed versions of the 20 vanilla challenges for the truly daring.
* **Corrupt Decks** bend the rules of existing decks for a more uniquely challenging experience.
* **[[REDACTED]]**

And more!

# Technical documentation
## Cross-mod support
### Corruptible Jokers
Mods may define corruptible Jokers by adding entries to the table `Oblivion.corruption_map`:

```lua
Oblivion.corruption_map[initial_joker_key] = corrupted_joker_key
```

The purity map `Oblivion.purity_map` is automatically generated. Note that a single Joker can only corrupt into one corrupted Joker.

Additionally, a corruption condition can be defined by adding an entry to the table `Oblivion.corruption_condtion`:

```lua
Oblivion.corruption_condtion[initial_joker_key] = function() --> bool
```

If the function returns `true`, the Joker can be corrupted.

### Corruptible enhancements
Mods may define the corrupted enhancement that enhancements on Optics cards transmute into, by adding entries to the table `Oblivion.enhancement_corrupt`:

```lua
Oblivion.enhancement_corrupt[initial_enhancement_key] = corrupted_enhancement_key
```

The purity map `Oblivion.enhancement_purify` is automatically generated. Note that a single enhancement can only corrupt into one corrupted enhancement.

### Corruptible seals
Mods may define the corrupted seal that seals on Optics cards transmute into, by adding entries to the table `Oblivion.seal_corrupt`:

```lua
Oblivion.seal_corrupt[initial_seal_key] = corrupted_seal_key
```

The purity map `Oblivion.seal_purify` is automatically generated. Note that a single seal can only corrupt into one corrupted seal.

### Corrupted Ghost Deck logic
Mods may define how Spectral cards are intended to be used by the Corrupted Ghost Deck. It is highly recommended that "ultra-rare" Spectral cards (e.g. The Soul, Black Hole) are not defined.

Definition is done by adding entries to the table `Oblivion.spectral_logic`:
```lua
Oblivion.spectral_logic[spectral_key] = {
    select = '<integer>',
    select_area = function() return '<table>' end,
    card_point_calc = function(card) return '<number>' end -- OPTIONAL,
    usable = function() return '<boolean>' end
}
```
* `select` is the number of cards needed to be selected to use the consumable.
* `select_area` is a function that returns a list of CardAreas for the consumable to target. (Such as G.hand, G.jokers, etc.)
* `card_point_calc` is a function that calculates the selection priority of each card in each area, given its suit, enhancement, edition, seal, etc..
* `usable` is a function that determines whether the consumable can even be used at all, given the state of the game directly after the first hand is drawn.

(Additional note regarding Corrupted Ghost Deck: Card selection by the player is disabled while the consumable is being used.)

### Master of Puppets effect extension
Master of Puppets gives a specific card modifier type to a random Jack lacking that card modifier. By default, only Vanilla and Oblivion rarities are supported, but mods may extend the list of supported rarities by adding entries to the table `Oblivion.rarity_modifier_map`:
```lua
Oblivion.rarity_modifier_map[rarity_key] = {
    display_order = '<integer>',
    hidden = '<boolean>',
    modifier = '<string>',

    whitelist = '<list: strings>',
    blacklist = '<list: strings>',

    modifier_loc_key = '<string>',
    modifier_loc_colour = '<colourTable>',
    rarity_loc_key = '<string>',
    rarity_loc_colour = '<colourTable>',
}
```
* `display_order` (OPTIONAL) allows the rarity to be placed in specific positions.
* `hidden` (OPTIONAL) hides the rarity from the Joker's description table.
* `modifier` is a key in the table `Oblivion.modifier_def` (see below).
  * Available modifiers: "enhancement", "seal", "edition".
  * There is also "*" for applying ALL modifier types to a card, and "\*C" for applying corrupt enhancements, marks, the edition Miasma, and all other modifier types to a card.
* `whitelist` (OPTIONAL) is a list of object keys, which is used instead of the default modifier pool for the random modifier selection.
* `blacklist` (OPTIONAL) is a list of object keys that are to be removed from the default modifier pool during random modifier selection. It does nothing if `whitelist` is defined.
* `modifier_loc_key` is the localization key for the modifier type name, used in the Joker's description table.
* `modifier_loc_colour` (OPTIONAL) is the colour of the modifier type name, used in the Joker's description table.
* `rarity_loc_key` is the localization key for the rarity, used in the Joker's description table.
* `rarity_loc_colour` (OPTIONAL) is the colour of the rarity, used in the Joker's description table.

#### Modifier definition
```lua
Oblivion.modifier_def[some_key] = {
    pool = '<string>',
    has_no_modifier = function(card) return '<boolean>' end,
    apply_random_modifier = function(card, options) return nil end
}
```
* `pool` is a string that would be used as the first argument in the function `get_current_pool`.
* `has_no_modifier` returns true if `card` lacks a modifier type, false otherwise. This must be specified due to differing methods in determining this.
* `apply_random_modifier` selects a random modifier from `options` and applies it to `card`. This must be specified due to differing methods to do so.

## Card tooltip elements
The following card tooltip elements are added by the mod:
- A "Corrupted from" text is displayed under the name of a Corrupted Joker. This can be added for any Joker (but most recommended for Corrupted Jokers) by adding a `corrupted_from` parameter in a Joker's localization:
```lua
joker_key = {
    name = ...,
    text = ...,
    corrupted_from = {
        "Something,"
        "or other thing"
    }
}
```
- A placeholder sprite note is displayed in the Collection for cards registered with `uses_placeholder_sprite = true`:
```lua
SMODS.Joker {
    uses_placeholder_sprite = true
}
```
- Credits for individual cards are displayed in the Collection for cards registered with a `credits` table. This table has the following format:
```lua
SMODS.Joker {
    credits = {
        concept = "username(s)",
        art = "username(s)",
        code = "username(s)"
    }
}
```

## Contexts
<table>

<tr>
<th>Primary key</th>
<th>Context table</th>
<th>Description</th>
</tr>

<!-------------------->

<tr>
<td><code>ovn_repetition_from_playing_card</code></td>
<td>

```lua
{
    ovn_repetition_from_playing_card = true,
    other_card = Card
    cardarea = G.play --[[etc.]],
    scoring_hand = cards --[[TABLE]],
}
```

</td>
<td>

Used for adding repetitions *from* playing cards with modifiers. Sent during the main scoring loop, received by enhancements, seals, editions, and stickers, and defined by the `SMODS.calculate_repetitions` hook. (Much thanks to [Paperback](//github.com/Balatro-Paperback/paperback) for the code for this context.)

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_corrupted_from</code></td>
<td>

```lua
{
    ovn_corrupted_from = true,
    ovn_former_form_key = card_key --[[STRING]],
    ovn_former_form_ability = ability_table --[[card.ability]]
}
```

</td>
<td>

Sent to the newly transformed (corrupted) Joker after a previous Joker was corrupted. Sent by `Ovn_f.corrupt_joker`.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_purified_from</code></td>
<td>

```lua
{
    ovn_purified_from = true,
    ovn_former_form_key = card_key --[[STRING]],
    ovn_former_form_ability = ability_table --[[card.ability]]
}
```

</td>
<td>

Sent to the newly transformed (purified) Joker after a previous Joker was purified. Sent by `Ovn_f.purify_joker`.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_corruption_occurred</code></td>
<td>

```lua
{
    ovn_corruption_occurred = true,
    ovn_corruption_type = "Joker", --[[STRING]]
    ovn_former_form_key = card_key, --[[STRING]]
    ovn_corrupted_card = card
    -- ovn_corrupted_card can instead be nil
    -- when corrupting a card destroys it
    -- (e.g. Apache Tears absorption)
}
```

</td>
<td>

Occurs when Joker corruption occurs. Sent by `Ovn_f.corrupt_joker`.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_purification_occurred</code></td>
<td>

```lua
{
    ovn_purification_occurred = true,
    ovn_purification_type = "Joker", --[[STRING]]
    ovn_former_form_key = card_key, --[[STRING]]
    ovn_corrupted_card = card
}
```

</td>
<td>

Occurs when Joker purification occurs. Sent by `Ovn_f.purify_joker`.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_run_started</code></td>
<td>

```lua
{
    ovn_run_started = true,
    new_run = true -- False if game loaded from save
    -- Recommended to check G.STATE as well
}
```

</td>
<td>

Occurs when a run is started or loaded. Sent by the `Game.start_run` hook.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_ice_degraded</code></td>
<td>

```lua
{
    ovn_ice_degraded = true,
    other_card = ice_card,
    ovn_ice_xmult = number
}
```

</td>
<td>

Occurs when an Ice card degrades. Sent by the Ice enhancement register.

</td>
</tr>

<!-------------------->

<tr>
<td><code>ovn_card_removed</code></td>
<td>

```lua
{
    ovn_card_removed = true,
    card = card,
    from_debuff = boolean
}
```

</td>
<td>

Occurs when a card is removed from deck via selling, destruction, or specified removal. Triggers in the same context as a card's `remove_from_deck` function.

</td>
</tr>

<!-------------------->

</table>