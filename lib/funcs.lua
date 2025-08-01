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

			local subloc_table = loc_func()
			loc_table[section][subsection_name] = subloc_table
		end
	end
end

----

-- Adds an event to G.E_MANAGER that only has the properties trigger, delay, and func.\
-- Event function will always return true, so "return true" is not required.\
-- Consequently, do not use this function if the event function needs to return a non-true value.
---@param trigger string | nil
---@param delay number | nil
---@param func function
Ovn_f.add_simple_event = function(trigger, delay, func)
	G.E_MANAGER:add_event(Event {
		trigger = trigger,
		delay = delay,
		func = function() func(); return true end
	})
end
local add_simple_event = Ovn_f.add_simple_event

----

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
			former_form_key = card_key
		}

        G.GAME.corruptingJoker = false
    end)
end

----

Ovn_f.is_corruptbanished = function(key)
	-- Do not continue if purification is occurring
	if G.GAME.purifyingJoker then return false end

	local has_tsne = next(SMODS.find_card('j_ovn_showneverends')) and true or false

	-- If the Joker is corruptable, continue
	local corrupt_key = Oblivion.corruption_map[key]
	if not corrupt_key then return false end

	-- If its corruption is present, continue
	local has_corrupt_joker = next(SMODS.find_card(corrupt_key)) and true or false
	if not has_corrupt_joker then return false end

	-- If show never ends is not held, continue
	if has_tsne then return false end

	-- DIE
	return true
end

----

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

Ovn_f.joker_is_corruptible = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return false end

	local condition_func = Oblivion.corruption_condition[card_key]
	if condition_func == nil then return true end

	return condition_func()
end

----

Ovn_f.joker_is_purifiable = function(card_key)
	return Oblivion.purity_map[card_key] and true or false
end

----

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