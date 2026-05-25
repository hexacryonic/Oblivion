-- Generates immediately after the game finishes loading

G.E_MANAGER:add_event(Event {
	blocking = false,
	func = function()
		-- Corrupt to Pure Jokers
		Oblivion.purity_map = {}
		local pmap = Oblivion.purity_map
		for pure_key,corrupt_key in pairs(Oblivion.corruption_map) do
			if not G.P_CENTERS[corrupt_key] then
				print("[OBLIVION] Purity mapping: Joker " .. corrupt_key .. " does not exist!")
			end
			if not pmap[corrupt_key] then
				pmap[corrupt_key] = pure_key
			elseif type(pmap[corrupt_key]) == "string" then
				pmap[corrupt_key] = {pmap[corrupt_key]}
				table.insert(pmap[corrupt_key], pure_key)
			else
				table.insert(pmap[corrupt_key], pure_key)
			end
		end

		-- Corrupt to Pure Enhancements
		Oblivion.enhancement_purify = {}
		local penh = Oblivion.enhancement_purify
		for pure_key,corrupt_key in pairs(Oblivion.enhancement_corrupt) do
			if not G.P_CENTERS[corrupt_key] then
				print("[OBLIVION] Purity mapping: Enhancement " .. corrupt_key .. " does not exist!")
			end
			penh[corrupt_key] = pure_key
		end

		-- Corrupt to Pure Seals
		Oblivion.seal_purify = {}
		local pseal = Oblivion.seal_purify
		for pure_key,corrupt_key in pairs(Oblivion.seal_corrupt) do
			if not SMODS.Seals[corrupt_key] then
				print("[OBLIVION] Purity mapping: Seal " .. corrupt_key .. " does not exist!")
			end
			pseal[corrupt_key] = pure_key
		end

		-- Purity map entries map to either a string (only pure form) or a list of strings (list of pure forms)

		-- For rarity-modifier mapping, convert "*" to an actual list of all defined modifiers
		local all_modis = {}
		for modifier in pairs(Oblivion.modifier_def) do
			table.insert(all_modis, modifier)
		end

		for _,rarity_modi_def in pairs(Oblivion.rarity_modifier_map) do
			rarity_modi_def.modifiers = all_modis
		end

		-- Generate list of suit-changing tarots for Prism
		Oblivion.suit_changing_tarots = {}
		for _,tarot_proto in ipairs(G.P_CENTER_POOLS.Tarot) do
			if Ovn_f.descend_table{tarot_proto, "config", "suit_conv"} then
				Oblivion.suit_changing_tarots[tarot_proto.key] = true
			end
		end

		return true
	end
})