-- Hook to add the warning text element
local uidef_runsetup_hook = G.UIDEF.run_setup_option_new_model
function G.UIDEF.run_setup_option_new_model(type)
    local t = uidef_runsetup_hook(type)

    local warning_text_def =
    {n=G.UIT.R, config={align = "cm", padding = 0.1}, nodes={
		{n=G.UIT.T, config={id = 'warning_text_deck', ref_table = Oblivion, ref_value = "ovn_c_erratic_warn", scale = 0.4, colour = G.C.CLEAR}}
	}}

    local poopshit = t.nodes[1].nodes
    table.insert(poopshit, 2, warning_text_def)

    return t
end

-- Hook for Corrupt Erratic Deck warning
local funcs_deckselectnext_hook = G.FUNCS.deck_select_next
function G.FUNCS.deck_select_next(e)
    local new_page = math.min(math.max(Galdur.run_setup.current_page + e.config.ref_value, 1), #Galdur.run_setup.pages+1)
    local warning_text = e.UIBox:get_UIE_by_ID('warning_text_deck')
    if (
		Oblivion.config.disable_c_erratic_warning
		or Galdur.run_setup.choices.deck.name ~= "b_ovn_c_erratic"
        or new_page <= #Galdur.run_setup.pages
    ) then
        e.warning_countdown = nil
        warning_text.config.colour = G.C.CLEAR
        warning_text.config.shadow = false
        funcs_deckselectnext_hook(e)
        return
    end

	-- this would have been three clicks, each changing the text
	-- but for some god damn reason changing Oblivion.ovn_c_erratic_warn (ref_value) crashes the game
	-- at engine/ui.lua "self.config.object:set_role(self.config.role[...]" attempt to index field "object" (a nil value)
	-- If anyone can fix this please lmk thx -Oin

    e.warning_countdown = (e.warning_countdown or 0) + 1
    --if e.warning_countdown >= 4
    if e.warning_countdown >= 2 then
        funcs_deckselectnext_hook(e)
        return
    end

    -- Oblivion.ovn_c_erratic_warn = localize("k_ovn_c_erratic_warn_" .. e.warning_countdown)

	warning_text:juice_up()
    warning_text.config.colour = G.C.WHITE
    warning_text.config.shadow = true
    e.config.disable_button = true
    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.06, blockable = false, blocking = false, func = function()
      play_sound('tarot2', 0.76, 0.4);return true end}))

    G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.35, blockable = false, blocking = false, func = function()
      e.config.disable_button = nil;return true end}))

    play_sound('tarot2', 1, 0.4)
end