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

Oblivion.PassiveEffects = {}
Oblivion.PassiveEffectsOrder = {}
Oblivion.PassiveEffect = SMODS.GameObject:extend {
	class_prefix = 'pfx',
	set = 'PassiveEffect',
	required_params = {
		'key',
	},

	obj_buffer = {},
	obj_table = Oblivion.PassiveEffects,

	register = function (self)
		self.name = self.name or self.key
		Oblivion.PassiveEffect.super.register(self)
	end,
	inject = function (self, i)
		table.insert(Oblivion.PassiveEffectsOrder, self)
	end,
	-- not actually ready but i already prepared this so it stays
	generate_ui = function (self, info_queue, desc_nodes, specific_vars, full_UI_table)
		local target = {
			type = 'descriptions',
			key = self.key,
			set = self.set,
			nodes = desc_nodes,
			AUT = full_UI_table,
			vars = specific_vars or {}
		}
		local res = {}
		if self.loc_vars and type(self.loc_vars) == 'function' then
			res = self:loc_vars(info_queue) or {}
			target.vars = res.vars or target.vars
			target.key = res.key or target.key
			target.set = res.set or target.set
			target.scale = res.scale
			target.text_colour = res.text_colour
			if desc_nodes == full_UI_table.main then
				full_UI_table.box_starts = res.box_starts
				full_UI_table.box_ends = res.box_ends
			end
		end

		if desc_nodes == full_UI_table.main and not full_UI_table.name then
			full_UI_table.name = localize {
				type = 'name',
				set = res.name_set or target.set,
				key = res.name_key or target.key,
				nodes = full_UI_table.name,
				vars = res.name_vars or target.vars or {}
			}
		elseif desc_nodes ~= full_UI_table.main and not desc_nodes.name then
			desc_nodes.name = localize{
				type = 'name_text',
				key = res.name_key or target.key,
				set = res.name_set or target.set,
				vars = res.name_vars or target.vars or {}
			}

			if (
				(
					not full_UI_table.from_detailed_tooltip
					or full_UI_table.info[1] == desc_nodes
				)
				and not full_UI_table.no_styled_name
			) then
				desc_nodes.name_styled = {}

				localize{
					type = 'name',
					key = res.name_key or target.key,
					set = res.name_set or target.set,
					nodes = desc_nodes.name_styled,
					fixed_scale = 0.63,
					no_pop_in = true,
					no_shadow = true,
					y_offset = 0,
					no_spacing = true,
					no_bump = true,
					vars = res.name_vars or target.vars
				}
				desc_nodes.name_styled = SMODS.info_queue_desc_from_rows(desc_nodes.name_styled, true)
				desc_nodes.name_styled.config.align = "cm"
			end
		end
		if res.main_start then
			desc_nodes[#desc_nodes + 1] = res.main_start
		end

		localize(target)
		if res.main_end then
			desc_nodes[#desc_nodes + 1] = res.main_end
		end
		desc_nodes.background_colour = res.background_colour
	end,

	activate = function (self)
		if type(G.GAME.active_passive_effects) ~= 'table' then
			sendWarnMessage(('Global table G.GAME.active_passive_effects not defined, passive effect %s not activated.'):format(self.key))
			return
		end
		if type(self.add_to_deck) == "function" then
			self:add_to_deck()
		end
		G.GAME.active_passive_effects[self.key] = true
	end,
	deactivate = function (self)
		if type(G.GAME.active_passive_effects) ~= 'table' then
			sendWarnMessage(('Global table G.GAME.active_passive_effects not defined, passive effect %s not deactivated.'):format(self.key))
			return
		end
		if type(self.remove_from_deck) == "function" then
			self:remove_from_deck()
		end
		G.GAME.active_passive_effects[self.key] = true
	end,
}

function Ovn_f.get_passive_effects_scoring_targets(_context)
    local ret = {}
	if not G.GAME.active_passive_effects then return ret end

	local func = type(_context) == "string" and _context or 'calculate'
    for _, pfx in ipairs(Oblivion.PassiveEffectsOrder) do
		if G.GAME.active_passive_effects[pfx.key] and type(pfx[func]) == "function" then
			table.insert(ret, pfx)
		end
    end

	return ret
end



--------------------------
---- OBJECT OWNERSHIP ----
--------------------------

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
}, true)

-- Ownership of Glass Cards for Black Knife functionality
local glass_calc_hook = G.P_CENTERS['m_glass'].calculate
SMODS.Enhancement:take_ownership('glass', {
	set_ability = function (self, card, initial, delay_sprites)
		if #SMODS.find_card('j_ovn_black_knife') > 0 then
			card.ability.Xmult  = G.P_CENTERS['j_ovn_black_knife'].config.extra.new_glass_xmult
			card.ability.x_mult = G.P_CENTERS['j_ovn_black_knife'].config.extra.new_glass_xmult
		end
	end,
	calculate = function (self, card, context)
		local ret = glass_calc_hook(self, card, context)
		if type(ret) ~= "table" then return ret end
		if (
			context.destroy_card
			and context.cardarea == G.play
			and context.destroy_card == card
			and #SMODS.find_card('j_ovn_black_knife') > 0
			and ret.remove == true
		) then
			ret.remove = nil
			card.ovn_saved_blackknife = true
		end
		return ret
	end
}, true)

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

-- Ownership of Jokerless (challenge) to ban The Abyss and Charybdis
local jokerless_restrictions = SMODS.Challenges.c_jokerless_1.restrictions --[[@as table[] ]]
table.insert(jokerless_restrictions.banned_cards, {id = 'c_ovn_abyss'})
table.insert(jokerless_restrictions.banned_cards, {id = 'c_ovn_charybdis'})
table.insert(jokerless_restrictions.banned_cards, {id = 'v_ovn_wicked_invocation'})
table.insert(jokerless_restrictions.banned_cards, {id = 'v_ovn_call_of_the_void'})
table.insert(jokerless_restrictions.banned_tags,  {id = 'tag_ovn_corrtag'})
table.insert(jokerless_restrictions.banned_tags,  {id = 'tag_ovn_miasmatag'})
table.insert(jokerless_restrictions.banned_tags,  {id = 'tag_ovn_stygiantag'})
table.insert(jokerless_restrictions.banned_other, {id = 'bl_ovn_purity', type = 'blind'})
table.insert(jokerless_restrictions.banned_other, {id = 'bl_ovn_stygian', type = 'blind'})

SMODS.Challenge:take_ownership('jokerless_1', {
	restrictions = jokerless_restrictions
}, true)
