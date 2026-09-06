-- modules/item-specific/instability.lua
-- Keeping everything related to instability in one file

-- Other files associated with Instability/Corrupt Plasma Deck:
---- items/0-2. Instability.lua - Scoring calculation registers
---- items/3-0. Decks.lua       - Corrupt Plasma Deck register
---- lovely/constnat_parameters - Make the instability parameter constant

-- 1. FUNCTIONS
-- 2. HOOKS



---------------
-- FUNCTIONS --
---------------

-- Enable Corrupt Plasma Deck's effect, which involes the instable scoring calculation.
function Ovn_f.enable_instability()
    if G.GAME.ovn_has_instability then return end
    G.GAME.ovn_has_instability = true
	Ovn_f.add_simple_event(nil, nil, function ()
		SMODS.set_scoring_calculation("ovn_instable")
	end)
end

-- Disable Corrupt Plasma Deck's effect.
function Ovn_f.disable_instability()
    if not G.GAME.ovn_has_instability then return end
    G.GAME.ovn_has_instability = nil
	Ovn_f.add_simple_event(nil, nil, function ()
    	SMODS.set_scoring_calculation("multiply")
	end)
end

-- Changes Instability if enabled.
---@param amount number
---@return nil
Ovn_f.change_instability = function(amount)
	if not G.GAME.ovn_has_instability then return end
	Ovn_f.add_simple_event(nil, nil, function ()
		delay(0.25)
		SMODS.Scoring_Parameters.ovn_instability:modify(amount)
		update_hand_text({immediate = true, delay = 0}, {["ovn_instability"] = G.GAME.ovn_instability})
	end)
end

-- This increase of instability is used when a corrupted Joker is obtained.
---@param factor? integer
---@return nil
Ovn_f.corruption_instability = function(factor)
	if not G.GAME.ovn_has_instability then return end
	factor = factor or 1
	local mod = G.GAME.instability_per_c_joker or 0
	Ovn_f.change_instability(mod*factor)
end

-- This increase of instability is used when a playing card of Optics is obtained.
---@param factor? integer
---@return nil
Ovn_f.optic_instability = function(factor)
	if not G.GAME.ovn_has_instability then return end
	factor = factor or 1
	local mod = G.GAME.instability_per_optic or 0
	Ovn_f.change_instability(mod*factor)
end




-----------
-- HOOKS --
-----------

-- Hook for redirecting Instability scoring parameter value (not stored in SMODS.ScoringParameter)
local smods_getscoringparam_hook = SMODS.get_scoring_parameter
function SMODS.get_scoring_parameter(key, flames)
    if key == "ovn_instability" then return G.GAME.ovn_instability end
    return smods_getscoringparam_hook(key, flames)
end