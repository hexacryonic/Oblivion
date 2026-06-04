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

SMODS.Joker:take_ownership('jokerless_1', {
	restrictions = jokerless_restrictions
}, true)
