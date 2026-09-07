-- Other files associated with Instability/Corrupt Plasma Deck:
---- modules/hooks.lua - HOOKS
------ Card:change_suit (modifiers)
------ SMODS.change_base (modifiers)

-- 1. JOKER TRANSMUTATION
-- 2. JOKER TRANSMUTATION STATES
-- 3. MODIFIER TRANSMUTATION
-- 4. CALCULATION MACROS

local simple_event = Ovn_f.add_simple_event



-----------------------------
---- JOKER TRANSMUTATION ----
-----------------------------

-- Transmutes a Joker into its corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_joker = function(card)
	local card_key = card.config.center.key
	local corrupted_card_key = Oblivion.corruption_map[card_key]
	G.jokers:remove_from_highlighted(card)

	G.GAME.corruptingJoker = true
	local ability = card.ability
	local card_destroyed = false

	if corrupted_card_key == "j_ovn_apache_tears" and Ovn_f.has_joker("j_ovn_apache_tears") then
		SMODS.destroy_cards(card)
		card_destroyed = true
	elseif corrupted_card_key ~= card_key then
		card:set_ability(G.P_CENTERS[corrupted_card_key], false, true)
	-- as Apache Tears "absorbs" the corrupted card instead
	end

	PlayLog.log{ type = "ovn_transmute_joker", transmute_type = "corrupt", from = card_key, to = corrupted_card_key }
    simple_event(nil, nil, function()
        play_sound("ovn_corrupting_joker")

		if not card_destroyed then
			card:juice_up(0.3, 0.5)
			card.ability.ovn_former_form = card_key
			card:calculate_joker(Ovn_f.calculate_corrupted_from(card_key, ability))
		end

		SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Joker", card_key, card_destroyed and nil or card))

        G.GAME.corruptingJoker = false
    end)
end

-- Transmutes a Joker into its pure variant.
---@param card Card
---@return nil
Ovn_f.purify_joker = function(card)
	local card_key = card.config.center.key
	local pmap_entry = Oblivion.purity_map[card_key]
	local pure_card_key = (
		card.ability.ovn_former_form
		or (
			type(pmap_entry) == "table"
			and pseudorandom_element(pmap_entry, pseudoseed("purifyJoker"))
			or pmap_entry -- type == "string"
		)
	)
	G.jokers:remove_from_highlighted(card)

	G.GAME.purifyingJoker = true
	local ability = card.ability

	if pure_card_key ~= card_key then
		card:set_ability(G.P_CENTERS[pure_card_key])
	end

	PlayLog.log{ type = "ovn_transmute_joker", transmute_type = "purify", from = card_key, to = pure_card_key }
    simple_event(nil, nil, function()
        play_sound("ovn_purifying")
		card:juice_up(0.3, 0.5)
		card:calculate_joker(Ovn_f.calculate_purified_from(card_key, ability))
		SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Joker", card_key, card))
    end)
	simple_event('after', 1, function() G.GAME.purifyingJoker = false end)
end



------------------------------------
---- JOKER TRANSMUTATION STATES ----
------------------------------------

-- Determines whether a Joker has a defined corruption.
---@param card_key string
---@return boolean
Ovn_f.joker_has_corruption = function(card_key)
	return Oblivion.corruption_map[card_key] ~= nil
end

-- Determines the key of a Joker's corruption condition.
---@param card_key string
---@return string|nil
Ovn_f.joker_corruption_condition = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return end

	local condition_def = Oblivion.corruption_condition[card_key]
	if condition_def == nil then return end

	local condition_key = condition_def[1]
	return condition_key
end

-- Determines whether a Joker is corruptible based on its defined corruption conditions.
---@param card_key string
---@return boolean
Ovn_f.joker_is_corruptible = function(card_key)
	if Oblivion.corruption_map[card_key] == nil then return false end

	local condition_def = Oblivion.corruption_condition[card_key]
	if condition_def == nil then return true end

	local condition_func = condition_def[2]
	return condition_func() and true or false
end

-- Determines whether a Joker is purifiable.
---@param card_key string
---@return boolean
Ovn_f.joker_is_purifiable = function(card_key)
	return Oblivion.purity_map[card_key] and true or false
end

-- Sets a random former form of a (corrupted) card if not set./
---@param card Card
---@return nil|string
Ovn_f.set_random_former_form = function(card)
	if card.ability.ovn_former_form then return end
	local card_key = card.config.center.key

	local pure_form_options = Oblivion.purity_map[card_key]
	if not pure_form_options then return end
	if type(pure_form_options) == "string" then
		card.ability.ovn_former_form = pure_form_options
		return pure_form_options
	end

	local former_form = pseudorandom_element(pure_form_options, "ovn_former_form")
	card.ability.ovn_former_form = former_form
	return former_form
end

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
	-- Do not destroy if self-corruptible
	if corrupt_key == card_key then return false end

	-- In pool if Joker's corrupt variant is not held
	local has_corrupt_joker = Ovn_f.has_joker(corrupt_key)
	if not has_corrupt_joker then return false end

	-- In pool even if Apache Tears is present, but it hasn't absorbed the Joker yet
	if Oblivion.corruption_map[card_key] == 'j_ovn_apache_tears' then
		local apache_absorption = false
		for _,tear_card in ipairs(SMODS.find_card('j_ovn_apache_tears')) do
			if tear_card.ability.extra.track_corrupts[card_key] == true then
				apache_absorption = true
				break
			end
		end
		if not apache_absorption then return false end
	end

	-- DIE
	return true
end



--------------------------------
---- MODIFIER TRANSMUTATION ----
--------------------------------

-- Transmutes a playing card's regular modifiers into their corrupted variants.
---@param card Card
---@return nil
Ovn_f.corrupt_modifiers = function(card)
	local transmuted = false
	local corrupt_keys = {}
	local old_keys = {}

	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
		table.insert(corrupt_keys, new_enhancement)
		table.insert(old_keys, enhancement_key)
	end

	local seal_key = card.seal
	local cseal, new_seal
	if seal_key then
		cseal = Oblivion.seal_corrupt
		new_seal = cseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
			table.insert(corrupt_keys, new_seal)
			table.insert(old_keys, seal_key)
		end
	end

	if transmuted then
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "corrupt", card = card, from = old_keys, to = corrupt_keys }

		simple_event('immediate', nil, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)

			if new_enhancement then
				card:calculate_enhancement(Ovn_f.calculate_corrupted_from(enhancement_key))
				SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Enhancement", enhancement_key, card))
			end

			if new_seal then
				card:calculate_seal(Ovn_f.calculate_corrupted_from(seal_key))
				SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Seal", seal_key, card))
			end
		end)
	end
end

-- Transmutes a playing card's regular enhancement_key into it corrupted variant.
---@param card Card
---@return nil
Ovn_f.corrupt_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local cenh = Oblivion.enhancement_corrupt
	local new_enhancement = cenh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "corrupt", card = card, from = enhancement_key, to = new_enhancement }
		simple_event('immediate', nil, function()
			play_sound('ovn_optic', 1, 1.1)
			card:juice_up(0.5, 0.5)
			card:calculate_enhancement(Ovn_f.calculate_corrupted_from(enhancement_key))
			SMODS.calculate_context(Ovn_f.calculate_corruption_occurred("Enhancement", enhancement_key, card))
		end)
	end
end

-- Transmutes a playing card's corrupted modifiers into their regular variants.
---@param card Card
---@return nil
Ovn_f.purify_modifiers = function(card)
	local transmuted = false
	local pure_keys = {}
	local old_keys = {}

	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		transmuted = true
		table.insert(old_keys, enhancement_key)
		table.insert(pure_keys, new_enhancement)
	end

	local seal_key = card.seal
	local pseal, new_seal
	if seal_key then
		pseal = Oblivion.seal_purify
		new_seal = pseal[seal_key]
		if new_seal then
			card:set_seal(new_seal)
			transmuted = true
			table.insert(old_keys, seal_key)
			table.insert(pure_keys, new_seal)
		end
	end

	if transmuted then
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "purify", card = card, from = old_keys, to = pure_keys }

		simple_event('immediate', nil, function()
			play_sound('ovn_purifying', 1, 1.1)
			card:juice_up(0.5, 0.5)

			if new_enhancement then
				card:calculate_enhancement(Ovn_f.calculate_purified_from(enhancement_key))
				SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Enhancement", enhancement_key, card))
			end

			if new_seal then
				card:calculate_seal(Ovn_f.calculate_purified_from(seal_key))
				SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Seal", seal_key, card))
			end
		end)
	end
end

-- Transmutes a playing card's corrupted enhancement_key into its regular variant.
---@param card Card
---@return nil
Ovn_f.purify_enhancement = function(card)
	local enhancement_key = card.config.center.key
	local penh = Oblivion.enhancement_purify
	local new_enhancement = penh[enhancement_key]
	if new_enhancement then
		card:set_ability(G.P_CENTERS[new_enhancement], nil, true)
		PlayLog.log{ type = "ovn_transmute_modifiers", transmute_type = "purify", card = card, from = enhancement_key, to = new_enhancement }
		simple_event('immediate', nil, function()
			play_sound('ovn_purifying', 1, 1.1)
			card:juice_up(0.5, 0.5)
			card:calculate_enhancement(Ovn_f.calculate_purified_from(enhancement_key))
			SMODS.calculate_context(Ovn_f.calculate_purification_occurred("Enhancement", enhancement_key, card))
		end)
	end
end



----------------------------
---- CALCULATION MACROS ----
----------------------------

---@class CorruptedFromContext
---@field ovn_corrupted_from true
---@field ovn_former_form_key string Corresponds to the key of an item.
---@field ovn_former_form_ability {string: any}|nil If Joker was corrupted into something new, this is its ability table prior to corruption.

---@class CorruptionOccurredContext
---@field ovn_corruption_occurred true
---@field ovn_corruption_type "Joker"|"Enhancement"|"Seal"
---@field ovn_former_form_key string Corresponds to the key an item.
---@field ovn_corrupted_card Card|nil The card that experienced the corruption.

---@class PurifiedFromContext
---@field ovn_corrupted_from true
---@field ovn_former_form_key string Corresponds to the key of an item.
---@field ovn_former_form_ability {string: any}|nil If Joker was purified into something new, this is its ability table prior to purification.

---@class PurificationOccurredContext
---@field ovn_purification_occurred true
---@field ovn_purification_type "Joker"|"Enhancement"|"Seal"
---@field ovn_former_form_key string Corresponds to the key an item.
---@field ovn_purified_card Card|nil The card that experienced the purification.

-- Prepares a context table corresponding to `ovn_corrupted_from`.
---@param key string
---@param ability? {string: any}
---@return CorruptedFromContext
Ovn_f.calculate_corrupted_from = function(key, ability)
	return {
		ovn_corrupted_from = true,
		ovn_former_form_key = key,
		ovn_former_form_ability = ability
	}
end

-- Prepares a context table corresponding to `ovn_corruption_occurred`.
---@param corruption_type string
---@param key string
---@param corrupted_card? Card
---@return CorruptionOccurredContext
Ovn_f.calculate_corruption_occurred = function(corruption_type, key, corrupted_card)
	return {
		ovn_corruption_occurred = true,
		ovn_corruption_type = corruption_type,
		ovn_former_form_key = key,
		ovn_corrupted_card = corrupted_card
	}
end

-- Prepares a context table corresponding to `ovn_purified_from`.
---@param key string
---@param ability? {string: any}
---@return PurifiedFromContext
Ovn_f.calculate_purified_from = function(key, ability)
	return {
		ovn_purified_from = true,
		ovn_former_form_key = key,
		ovn_former_form_ability = ability
	}
end

-- Prepares a context table corresponding to `ovn_purification_occurred`.
---@param purification_type string
---@param key string
---@param purified_card? Card
---@return PurificationOccurredContext
Ovn_f.calculate_purification_occurred = function(purification_type, key, purified_card)
	return {
		ovn_purification_occurred = true,
		ovn_purification_type = purification_type,
		ovn_former_form_key = key,
		ovn_purified_card = purified_card
	}
end