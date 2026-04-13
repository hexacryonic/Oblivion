-- These functions are used by UI elements, usually those in lib/ui_hook.lua
-- this was a bit more full before i moved deck stuff to their own files



-------------------------
---- G.FUNCS ENTRIES ----
-------------------------

-- Corrupt Pure Visage.
---@param e any
---@return nil
function G.FUNCS.transmute_card(e)
	local card = e.config.ref_table
	if card.config.center.key == "j_ovn_pure_visage" then
		Ovn_f.corrupt_joker(card)
	end
end

-- Determine whether Pure Visage can be corrupted via its button.
---@param e any
---@return nil
function G.FUNCS.can_transmute(e)
	local card = e.config.ref_table
	if card.ability.extra.on_cooldown <= 0 then
		e.config.colour = G.C.GREEN
		e.config.button = "transmute_card"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

-- Rotates the UI element.
---@param e any
---@return nil
function G.FUNCS.rotate_node(e)
	e.T.r = e.config.rotate
end



-----------------------
---- MISCELLANEOUS ----
-----------------------

-- Applies additional tooltips to the hovered card.
---@param _c SMODS.Center
---@param card Card
---@param info_queue table
---@return nil
function Ovn_f.additional_infoqueue_tooltips(_c, card, info_queue)
	if not card then return end

	-- "Optics give double chips"
	if Ovn_f.descend_table{card, "base", "suit"} == "ovn_Optics" then
		table.insert(info_queue, {
			key = 'ovn_opticinfo',
			set = 'Other',
		})
	end

	-- Cards with centers
	if Ovn_f.descend_table{card, "config", "center", "discovered"} then
		if Ovn_f.joker_has_corruption(card.config.center.key) then
			local j_key = card.config.center.key
			-- "Joker is corruptible"
			if Ovn_f.joker_is_corruptible(j_key) then
				table.insert(info_queue, {
					key = 'ovn_corruptible',
					set = 'Other',
					vars = { localize {
						type = "name_text",
						set = "Joker",
						key = j_key
					} }
				})
			-- "Joker requires condition for corruption"
			-- "This is that condition"
			elseif Ovn_f.joker_corruption_condition(j_key) then
				local condition_key = Ovn_f.joker_corruption_condition(j_key)
				table.insert(info_queue, {
					key = 'ovn_almost_corruptible',
					set = 'Other',
				})
				table.insert(info_queue, {
					key = 'ovn_corrupt_condition_' .. condition_key,
					set = 'Other'
				})
			end
		end

		if Ovn_f.descend_table{card.area, "config", "collection"} then
			-- Credits
			if card.config.center.credits then
				-- Only way to attach vars to send to the description dummy
				G.P_CENTERS['dd_ovn_credits'].specific_vars = card.config.center.credits
				table.insert(info_queue, G.P_CENTERS['dd_ovn_credits'])
			end

			-- Placeholder note
			if card.config.center.uses_placeholder_sprite then
				table.insert(info_queue, {
					key = 'ovn_placeholder_sprite',
					set = 'Other'
				})
			end
		end
	end

	-- Cards with seals
	if card.seal then
		local select_seal = SMODS.Seals[card.seal]
		-- Credits
		if select_seal.credits then
			-- Only way to attach vars to send to the description dummy
			G.P_CENTERS['dd_ovn_credits'].specific_vars = select_seal.credits
			table.insert(info_queue, G.P_CENTERS['dd_ovn_credits'])
		end

		-- Placeholder note
		if select_seal.uses_placeholder_sprite then
			table.insert(info_queue, {
				key = 'ovn_placeholder_sprite',
				set = 'Other'
			})
		end
	end
end

---@class localize_desc.Config
---@field scale? number Size of text.
---@field empty_line_space? number Height of empty lines.
---@field padding? number Size of spacing around text.
---@field text_colour? Balatro.Colour Default colour for uncoloured text.
---@field align? "left" | "center" | "middle" | "right" Alignment of all text.

-- Automatically formats a list of localization strings into a JTML element.
---@param desc string[]
---@param config? localize_desc.Config
---@return Balatro.UIBoxDefinition
function Ovn_f.localize_desc(desc, config)
	config = config or {}
	config.scale = config.scale or 1.125
	config.empty_line_space = config.empty_line_space or 0.15
	config.padding = config.padding or 0.03
	config.text_colour = config.text_colour or G.C.UI.TEXT_LIGHT
	config.align = config.align or "left"

	local align = "center-"..config.align

	local row_nodes = {}
	for _,row_text in ipairs(desc) do
		local row_text_parsed = loc_parse_string(row_text)
		local row_ui_text
		if row_text_parsed then
			row_ui_text = SMODS.localize_box(row_text_parsed, {
				text_colour = config.text_colour,
				scale = config.scale,
			})
		end
		local padding = row_text_parsed and config.padding or config.empty_line_space
		local row_ui = {"row", style={padding = padding, align = align}, row_ui_text}
		table.insert(row_nodes, row_ui)
	end

	return Ovn_f.jtml_to_uiboxdef({"row", style={align = align}, row_nodes}, {})
end

local function notif_event(delay, func, dont_trigger_after)
	G.E_MANAGER:add_event(Event {
		no_delete = true,
		pause_force = true,
		timer = 'UPTIME',
		trigger = not dont_trigger_after and 'after' or nil,
		delay = delay,
		func = function()
			func()
			return true
		end,
	}, 'achievement')
end

-- Spawns a notification, similar in behavior to achievements.
---@param nodes (JTML.JTML|Balatro.UIBoxDefinition)[]
---@return nil
function Ovn_f.notification(nodes, sustain)
	local style = {
		[".root"] = {
			align = "center-left",
			roundness = 0.1,
			padding = 0.06,
			fillColour = G.C.UI.TRANSPARENT_DARK
		},
		[".notif_container"] = {
			align = "center-left",
			padding = 0.2,
			minWidth = 20,
			roundness = 0.1,
			fillColour = G.C.BLACK,
			outlineWidth = 1.5,
			outlineColour = G.C.GREY
		},
		[".node_container"] = {
			align = "center-middle",
			roundness = 0.1
		}
	}

	local def =
	{"root", class="root", {
		{"row", class="notif_container", {
			{"row", class="node_container", nodes}
		}}
	}}

	notif_event(nil, function ()
		if G.achievement_notification then
			G.achievement_notification:remove()
			G.achievement_notification = nil
		end
		G.achievement_notification = G.achievement_notification or UIBox{
			definition = Ovn_f.jtml_to_uiboxdef(def, style),
			config = {
				align = 'cr',
				offset = {x=20,y=0},
				major = G.ROOM_ATTACH,
				bond = 'Weak'
			}
		}
	end, true)
	notif_event(0.1, function ()
		G.achievement_notification.alignment.offset.x = (
			G.ROOM.T.x
			- G.achievement_notification.UIRoot.children[1].children[1].T.w
			- 0.8
		)
	end)
	notif_event(0.1, function ()
		play_sound('highlight1', nil, 0.5)
		play_sound('foil2', 0.5, 0.4)
	end)
	notif_event(sustain or 3, function ()
		G.achievement_notification.alignment.offset.x = 20
	end)
	notif_event(0.5, function ()
		if G.achievement_notification then
			G.achievement_notification:remove()
			G.achievement_notification = nil
		end
	end)
end