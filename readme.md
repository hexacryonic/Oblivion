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
This context is used for adding repetitions *from* playing cards with modifiers. It is sent during the main scoring loop, received by enhancements, seals, editions, and stickers, and defined by the `SMODS.calculate_repetitions` hook. (Much thanks to [Paperback](https://github.com/Balatro-Paperback/paperback) for the code for this context.)
```lua
if context.ovn_repetition_from_playing_card then
{
    other_card = card
    cardarea = G.play --[[etc.]],
    scoring_hand = scoring_hand,
    ovn_repetition_from_playing_card = true,
}
```

This context is used on the newly transformed (corrupted) Joker after a previous Joker was corrupted. It is sent by `Ovn_f.corrupt_joker`.
```lua
if context.ovn_corrupted_from then
{
    ovn_corrupted_from = true,
    ovn_former_form_key = card_key,
    ovn_former_form_ability = table
}
```

This context is used when Joker corruption occurs. It is sent by `Ovn_f.corrupt_joker`.
```lua
if context.ovn_corruption_occurred and ovn_corruption_type == "Joker" then
{
    ovn_corruption_occurred = true,
    ovn_corruption_type = "Joker",
    ovn_former_form_key = card_key,
    ovn_corrupted_card = card -- nil if card is destroyed due to corruption (e.g. Apache Tears absorption)
}
```

This context is used on the newly transformed (purified) Joker after a previous Joker was purified. It is sent by `Ovn_f.purify_joker`.
```lua
if context.ovn_purified_from then
{
    ovn_purified_from = true,
    ovn_former_form_key = card_key,
    ovn_former_form_ability = table
}
```

This context is used when Joker purification occurs. It is sent by `Ovn_f.purify_joker`.
```lua
if context.ovn_purification_occurred and ovn_purification_type == "Joker" then
{
    ovn_purification_occurred = true,
    ovn_purification_type = "Joker",
    ovn_former_form_key = card_key,
    ovn_purified_card = card
}
```

This context is used when a run is started or loaded. It is sent by the `Game.start_run` hook.
```lua
if context.ovn_run_started then
{
    ovn_run_started = true,
    -- Recommended to check G.STATE as well
}
```

This context is used when an Ice card degrades. It is sent by the Ice enhancement register.
```lua
if context.ovn_ice_degraded then
{
    ovn_ice_degraded = true,
    other_card = ice_card,
    ovn_ice_xmult = number
}
```

This context is used when a card is removed from deck via selling, destruction, or specified removal. It triggers in the same context as a card's `remove_from_deck` function.
```lua
if context.ovn_card_removed then
{
    ovn_card_removed = true,
    card = card,
    from_debuff = boolean
}
```