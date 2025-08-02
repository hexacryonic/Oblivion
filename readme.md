put smth later

# Documentation
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