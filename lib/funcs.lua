-- Compiles all localization present in the directory <lang>, usually the name of the localization folder.\
-- I.e. on en-us.lua, <lang> = "en-us", load files in the directory \en-us.
---@param loc_table table
---@param lang string
---@return nil
function Ovn_f.compile_localization(loc_table, lang)
	local loc_folder = ("localization/%s/"):format(lang)
	local loc_path = Oblivion.mod_path .. loc_folder
	local loc_sections = {"descriptions", "misc"}

	for _,section in ipairs(loc_sections) do
		loc_table[section] = loc_table[section] or {}
		local files = NFS.getDirectoryItems(loc_path .. section)
		local folder = loc_folder .. section
		for __,file_name in ipairs(files) do
			local subsection_name = file_name:gsub(".lua", "")
			local loc_func, err = SMODS.load_file(folder .. "/" .. file_name, "Oblivion")
			if err then error(err) end

			if loc_func then
				local subloc_table = loc_func()
				loc_table[section][subsection_name] = subloc_table
			end
		end
	end
end

----

-- A shorthand of adding an event to G.E_MANAGER that only defines the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value\
-- or if other parameters such as blocking require specification.
---@param trigger string | nil
---@param delay number | nil
---@param func function
---@return nil
Ovn_f.add_simple_event = function(trigger, delay, func)
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end
local add_simple_event = Ovn_f.add_simple_event

----

-- Determines whether the player is holding the Joker of specified card key.
---@param card_key string
---@return boolean
Ovn_f.has_joker = function(card_key)
	return next(SMODS.find_card(card_key)) and true or false
end

----

-- Destroys a Joker and creates its corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_joker = function(card)
	local card_key = card.config.center.key
	local corrupted_card_key = Oblivion.corruption_map[card_key]

    add_simple_event('after', 0.4, function()
        G.GAME.corruptingJoker = true

        play_sound("ovn_abyss")
        card:start_dissolve({G.C.RARITY['ovn_corrupted']})
        G.jokers:remove_from_highlighted(card)

        local corrupted_card = SMODS.add_card{
			set = "Joker",
			area = G.jokers,
			key = corrupted_card_key
		}
        corrupted_card:juice_up(0.3, 0.5)

        if not corrupted_card.ability.extra then corrupted_card.ability.extra = {} end
        corrupted_card.ability.extra.ovn_former_form = card_key
		corrupted_card:calculate_joker{
			ovn_corrupted_from = true,
			ovn_former_form_key = card_key
		}
		SMODS.calculate_context({
			ovn_corruption_occurred = true,
			ovn_corruption_type = "Joker",
			ovn_former_form_key = card_key,
			ovn_corrupted_card = corrupted_card
		})

        G.GAME.corruptingJoker = false
    end)
end

----

-- Determines if a Joker should be out of all pools\
-- due to its corrupted variant being present.
---@param card_key string
---@return boolean
Ovn_f.is_corruptbanished = function(card_key)
	-- Do not continue if purification is occurring
	if G.GAME.purifyingJoker then return false end

	-- In pool if showneverends is held
	local has_tsne = Ovn_f.has_joker('j_ovn_showneverends')
	if has_tsne then return false end

	-- In pool if Joker is not even corruptible
	local corrupt_key = Oblivion.corruption_map[card_key]
	if not corrupt_key then return false end

	-- In pool if Joker's corrupt variant is not hled
	local has_corrupt_joker = Ovn_f.has_joker(corrupt_key)
	if not has_corrupt_joker then return false end

	-- DIE
	return true
end

----

-- Destroys a Joker and creates its pure variant.
---@param card Card
---@return nil
Ovn_f.purify_joker = function(card)
	local card_key = card.config.center.key
	local pmap_entry = Oblivion.purity_map[card_key]
	local pure_card_key = (
		card.ability.extra
		and card.ability.extra.ovn_former_form
		or (
			type(pmap_entry) == "table"
			and pseudorandom_element(pmap_entry, pseudoseed("purifyJoker"))
			or pmap_entry -- type == "string"
		)
	)

    add_simple_event('after', 0.4, function()
        G.GAME.purifyingJoker = true

        play_sound("ovn_pure")
        card:start_dissolve({G.C.MONEY})
        G.jokers:remove_from_highlighted(card)

        local purified_card = create_card("Joker", G.jokers, nil, nil, nil, nil, pure_card_key)
        purified_card:add_to_deck()
        G.jokers:emplace(purified_card)
        purified_card:juice_up(0.3, 0.5)
    end)
	add_simple_event('after', 1, function() G.GAME.purifyingJoker = false end)
end

----

-- Determines whether a Joker is corruptible based on its defined corruption conditions.
---@param card_key string
---@return boolean
Ovn_f.joker_is_corruptible = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return false end

	local condition_func = Oblivion.corruption_condition[card_key]
	if condition_func == nil then return true end

	return condition_func()
end

----

-- Determines whether a Joker is purifiable.
---@param card_key string
---@return boolean
Ovn_f.joker_is_purifiable = function(card_key)
	return Oblivion.purity_map[card_key] and true or false
end

----

-- Transmutes a playing card's regular enhancement into its corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		add_simple_event('after', 0.1, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)
		end)
	end
end

----

-- Transmutes a playing card's corrupted enhancement into its regular variant.
---@param card Card
---@return nil
Ovn_f.purify_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		add_simple_event('after', 0.1, function()
			play_sound('ovn_pure', 1, 1.1)
			card:juice_up(0.5, 0.5)
		end)
	end
end

----

-- Changes Instability on Corrupt Plasma Deck, else does nothing.
---@param amount number
---@return nil
Ovn_f.increase_instability = function(amount)
	if not G.GAME.in_corrupt_plasma or amount == 0 or amount == nil then return end
	add_simple_event('after', 0.5, function ()
		if amount < 0 then
			play_sound("ovn_decrement", 1, 0.8)
		elseif amount > 0 then
			play_sound("ovn_increment", 1, 0.9)
		end
		G.GAME.instability = G.GAME.instability + amount
	end)
end

-- This increase of instability is used when a corrupted Joker is obtained.
---@param factor? integer
---@return nil
Ovn_f.corruption_instability = function(factor)
	if G.GAME.in_corrupt_plasma then
		Ovn_f.increase_instability((G.GAME.corrumod or 0)*(factor or 1))
	end
end

-- This increase of instability is used when a playing card of Optics is obtained.
---@param factor? integer
---@return nil
Ovn_f.optic_instability = function(factor)
	if G.GAME.in_corrupt_plasma then
		Ovn_f.increase_instability((G.GAME.opticmod or 0)*(factor or 1))
	end
end

----

-- In Corrupt Yellow Deck, increases the hand cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_hand_cost = function(amount, instant)
	-- Primarily used in C-Yellow Deck
	if not G.GAME.in_corrupt_yellow then return end
	local _mod = function(mod)
		local hand_UI = G.HUD:get_UIE_by_ID('hand_UI_count')
		if not hand_UI then
			print("[OVN_F] ease_hand_cost - hand_UI_count not found")
			return
		end

		mod = mod or 0
		local text = '+'
		local col = G.C.MONEY
		if mod < 0 then
			text = ''
			col = G.C.RED
		end

		--Ease from current chips to the new number of chips
		G.GAME.cy_handcost = G.GAME.cy_handcost + mod
		G.GAME.c_yellow_current_round.hands_cost =  "$" .. G.GAME.cy_handcost
		hand_UI.config.object:update()
		G.HUD:recalculate()

		--Popup text next to the chips in UI showing number of chips gained/lost
		attention_text({
			text = text..mod,
			scale = 0.8,
			hold = 0.7,
			cover = hand_UI.parent,
			cover_colour = col,
			align = 'cm',
		})

		--Play a chip sound
		play_sound('coin6')
	end

	if instant then
		_mod(amount)
	else
		add_simple_event('immediate', nil, function()
			_mod(amount)
		end)
	end
end

-- In Corrupt Yellow Deck, increases the discard cost with corresponding animations.
---@param amount number
---@param instant boolean?
---@return nil
Ovn_f.ease_discard_cost = function(amount, instant)
	if not G.GAME.in_corrupt_yellow then return end
	local _mod = function(mod)
		local discard_UI = G.HUD:get_UIE_by_ID('discard_UI_count')
		if not discard_UI then
			print("[OVN_F] ease_discard_cost - discard_UI_count not found")
			return
		end

		mod = mod or 0
		local text = '+'
		local col = G.C.MONEY
		if mod < 0 then
			text = ''
			col = G.C.RED
		end

		--Ease from current chips to the new number of chips
		G.GAME.cy_discardcost = G.GAME.cy_discardcost + mod
		G.GAME.c_yellow_current_round.discard_cost =  "$" .. G.GAME.cy_discardcost
		discard_UI.config.object:update()
		G.HUD:recalculate()

		--Popup text next to the chips in UI showing number of chips gained/lost
		attention_text({
			text = text..mod,
			scale = 0.8,
			hold = 0.7,
			cover = discard_UI.parent,
			cover_colour = col,
			align = 'cm',
		})

		--Play a chip sound
		play_sound('coin6')
	end

	if instant then
		_mod(amount)
	else
		add_simple_event('immediate', nil, function()
			_mod(amount)
		end)
	end
end