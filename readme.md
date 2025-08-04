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

A purity map is automatically generated. Note that a single Joker can only corrupt into one corrupted Joker.

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

A purity map is automatically generated. Note that a single enhancement can only corrupt into one corrupted enhancement.

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

## Contexts
This context is used on the newly created (corrupted) Joker after a previous Joker was corrupted. It is sent by `Ovn_f.corrupt_joker`.
```lua
if context.ovn_corrupted_from then
{
    ovn_corrupted_from = true,
    ovn_former_form_key = card_key
}
```

This context is used when Joker corruption occurs. It is sent by `Ovn_f.corrupt_joker`.
```lua
if context.ovn_corruption_occurred and ovn_corruption_type == "Joker" then
{
    ovn_corruption_occurred = true,
    ovn_corruption_type = "Joker",
    ovn_former_form_key = card_key,
    ovn_corrupted_card = card
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