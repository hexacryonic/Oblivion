---------------------------
---- CLASS DEFINITIONS ----
---------------------------

-- Credits to Aikoyori for the inspiration for the description dummies
-- Note about generate_ui: Set `desc_nodes.name` to set the dummy's name
-- and insert into `desc_nodes` to add UI elements; specifically, insert a LIST of UIBox definitions
Oblivion.DescriptionDummy = SMODS.Center:extend {
	set = 'DescriptionDummy',
	class_prefix = 'dd',
	required_params = {
		'key',
	},
	inject = function(self)
		G.P_CENTERS[self.key] = self
	end
}



--------------------------
---- OBJECT OWNERSHIP ----
--------------------------

-- Ownership of Black Hole for Event Horizon effect
SMODS.Consumable:take_ownership('black_hole', {
	use = function (self, card, area, copier)
		local all_event_horizons = SMODS.find_card('j_ovn_event_horizon')
		if #all_event_horizons > 0 then
			for i,event_horizon in ipairs(all_event_horizons) do
				local speed = 1 + (i-1)*0.1
				-- Mult
				Ovn_f.add_simple_event('after', 0.2/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = localize('k_upgrade_ex'),
						colour = G.C.MULT,
						instant = true
					})
				end)
				-- Chip
				Ovn_f.add_simple_event('after', 0.9/speed, function ()
					play_sound('tarot1')
					if card then card:juice_up(0.8, 0.5) end
					event_horizon:juice_up(0.8, 0.5)
					card_eval_status_text(event_horizon, 'extra', nil, nil, nil, {
						message = localize('k_upgrade_ex'),
						colour = G.C.CHIPS,
						instant = true
					})
				end)
				if i == #all_event_horizons then
					speed = 1
				end
				delay(1.3/speed)
			end
			for hand_key in pairs(G.GAME.hands) do
				level_up_hand(card, hand_key, true)
			end
		else
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname=localize('k_all_hands'),chips = '...', mult = '...', level=''})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.2, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = true
				return true end }))
			update_hand_text({delay = 0}, {mult = '+', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				return true end }))
			update_hand_text({delay = 0}, {chips = '+', StatusText = true})
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.9, func = function()
				play_sound('tarot1')
				card:juice_up(0.8, 0.5)
				G.TAROT_INTERRUPT_PULSE = nil
				return true end }))
			update_hand_text({sound = 'button', volume = 0.7, pitch = 0.9, delay = 0}, {level='+1'})
			delay(1.3)
			for k, v in pairs(G.GAME.hands) do
				level_up_hand(card, k, true)
			end
        	update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
		end
	end
}, true)

-- Ownership of Orbital Tag for Event Horizon effect
SMODS.Tag:take_ownership('orbital', {
	apply = function(self, tag, context)
		if context.type == 'immediate' then
			local lock = tag.ID
			local all_event_horizons = SMODS.find_card('j_ovn_event_horizon')
			if #all_event_horizons > 0 then
				level_up_hand(tag, tag.ability.orbital_hand, nil, tag.config.levels)
				tag:yep('+', G.C.MONEY,function() 
					G.CONTROLLER.locks[lock] = nil
					return true
				end)
				tag.triggered = true
				return true
			else
				update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {
					handname= tag.ability.orbital_hand,
					chips = G.GAME.hands[tag.ability.orbital_hand].chips,
					mult = G.GAME.hands[tag.ability.orbital_hand].mult,
					level= G.GAME.hands[tag.ability.orbital_hand].level})
				level_up_hand(tag, tag.ability.orbital_hand, nil, tag.config.levels)
				update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
				tag:yep('+', G.C.MONEY,function() 
					G.CONTROLLER.locks[lock] = nil
					return true
				end)
				tag.triggered = true
				return true
			end
		end
	end
})

-- Ownership of all default JimboQuips to use THE SHOW NEVER ENDS
for i=1,10 do
	SMODS.JimboQuip:take_ownership('lq_' .. i, {
		extra = {
			center = 'j_ovn_showneverends',
			particle_colours = {
				G.C.RARITY['ovn_corrupted'],
				G.C.BLUE,
				G.C.PURPLE
			}
		}
	})
end
for i=1,7 do
	SMODS.JimboQuip:take_ownership('wq_' .. i, {
		extra = {
			center = 'j_ovn_showneverends',
			particle_colours = {
				G.C.RARITY['ovn_corrupted'],
				G.C.BLUE,
				G.C.PURPLE
			}
		}
	})
end