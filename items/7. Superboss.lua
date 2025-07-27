-- Adds an event to G.E_MANAGER that only has the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value.
---@param trigger string | nil
---@param delay number | nil
---@param func function
local function add_simple_event(trigger, delay, func)
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end

G.FUNCS.welcometohell = function()
	G.GAME.imcoming = true
	local text = nil

	add_simple_event('after', 0.4, function ()
		text = DynaText {
			string = {"I see you."},
			colours = { G.C.WHITE },
			rotate = 2,
			shadow = true,
			bump = true,
			float = true,
			scale = 0.9,
			pop_in = 1.4 / G.SPEEDFACTOR,
			pop_in_rate = 1.5 * G.SPEEDFACTOR,
			pitch_shift = 0.25,
		}
	end)
	
	add_simple_event('after', 2.6, function ()
		text:pop_out(4)
		ease_background_colour{new_colour = G.ARGS.LOC_COLOURS.ovn_corrupted, contrast = 1}
	end)
	
	G.GAME.win_ante = 9
end

local gu = Game.update
function Game:update(dt)
	gu(self, dt)
	if (
		G.GAME
		and G.GAME.round_resets.ante == 8
		and G.GAME.used_insecurity
		and G.GAME.used_tres
		and G.GAME.used_recall
		and G.GAME.round_resets.blind_states.Boss == 'Upcoming'
		and G.GAME.shop
		and G.GAME.imcoming
	) then G.FUNCS.welcometohell() end
end

----

local function ominous_consumable_consequence(consumable_name, card_obj, sound_per, sound_vol)
	add_simple_event('after', 0.4, function ()
		card_obj:juice_up(0.3, 0.4)
		play_sound("ovn_" .. consumable_name, sound_per, sound_vol)
		card_obj.children.center.pinch.x = true
	end)
	delay(0.6)
	G.GAME["used_" .. consumable_name] = true
	G.GAME["not_used_" .. consumable_name] = false
end

local function ominous_consumable_badge()
	return create_badge('???', G.ARGS.LOC_COLOURS.ovn_corrupted, G.C.RED, 1.2)
end

SMODS.Consumable {
	set = "Tarot",
	name = "ovn_Insecurity",
	key = "insecurity",
	
	atlas = "cataclysm_atlas",
	pos = {x=0, y=0},

	cost = 2,
	
	set_card_type_badge = function(self, card, badges)
		badges[1] = ominous_consumable_badge()
	end,

	in_pool = function() return G.GAME.not_used_insecurity end,
	can_use = function(self, card) return true end,
	use = function(self, card, area, copier)
		ominous_consumable_consequence("insecurity", card)
	end,
}

SMODS.Consumable {
	set = "Planet",
	name = "ovn_Tres",
	key = "tres",

	atlas = "cataclysm_atlas",
	pos = {x=1, y=0},

	cost = 2,

	set_card_type_badge = function(self, card, badges)
		badges[1] = ominous_consumable_badge()
	end,

	in_pool = function() return G.GAME.not_used_tres end,
	can_use = function(self, card) return true end,

	use = function(self, card, area, copier)
		ominous_consumable_consequence("tres", card, 1, 1.2)
	end,
}

SMODS.Consumable {
	set = "Spectral",
	name = "ovn_Recall",
	key = "recall",

	atlas = "cataclysm_atlas",
	pos = {x=2, y=0},

	cost = 2,

	set_card_type_badge = function(self, card, badges)
		badges[1] = ominous_consumable_badge()
	end,

	in_pool = function() return G.GAME.not_used_recall end,
	can_use = function(self, card) return true end,

	use = function(self, card, area, copier)
		ominous_consumable_consequence("recall", card)
	end,
}
