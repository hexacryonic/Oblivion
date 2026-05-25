if not (SMODS.Mods["PlayLog"] or {}).can_load then return end

return { misc = { playlog = {

-----------------------------

plog_corrupt = "#1#{} corrupted into #2#",
plog_purify = "#1#{} purified into #2#",
plog_recorrupt = "#1# {}re-corrupted",
plog_repurify = "#1#{} re-purified",
plog_corrupt_modifiers = "#1#{} corrupted #2#{} into #3#",
plog_purify_modifiers = "#1#{} purified #2#{} into #3#",

-----------------------------

} } }