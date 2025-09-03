-- lib/ui_funcs.lua
-- These functions are used by UI elements, usually those in lib/ui_hook.lua
-- this was a bit more full before i moved deck stuff to their own files



-------------------------
---- G.FUNCS ENTRIES ----
-------------------------

-- Corrupt Pure Visage.
---@param e any
---@return nil
function G.FUNCS.transmute_card(e)
	local card = e.config.ref_table
	if card.config.center.key == "j_ovn_pure_visage" then
		Ovn_f.corrupt_joker(card)
	end
end

-- Determine whether Pure Visage can be corrupted via its button.
---@param e any
---@return nil
function G.FUNCS.can_transmute(e)
	local card = e.config.ref_table
	if card.ability.extra.on_cooldown <= 0 then
		e.config.colour = G.C.GREEN
		e.config.button = "transmute_card"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

----

-- will move somewhere else later idk
G.C.INST = HEX('04248F')
G.C.UI_INST = G.C.INST