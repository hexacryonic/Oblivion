-- These functions are used by UI elements, usually those in lib/ui_hook.lua
-- this was a bit more full before i moved deck stuff to their own files

local JTML = Ovn_f.JTML

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

-- Release the Joker stored by Supply Drop.
function G.FUNCS.supply_empty(e)
	local card = e.config.ref_table
	card.area:remove_from_highlighted(card)
	if card.config.center.key ~= "j_ovn_supplydrop" then return end

	local save_file = G.PROFILES[G.SETTINGS.profile]
	local stored_joker_key = save_file.ovn_supply_drop
	local stored_joker_edition = save_file.ovn_supply_drop_edition
	local stored_joker_sticker = save_file.ovn_supply_drop_sticker

	SMODS.add_card{
		area = G.joker,
		key = stored_joker_key,
		edition = stored_joker_edition,
		no_edition = true,
		stickers = stored_joker_sticker,
		force_stickers = true,
	}

	Ovn_f.add_simple_event('after', 0.1, function ()
		SMODS.calculate_effect({
			message = localize("empty"),
			colour = G.C.DARK_EDITION
		}, card)
	end)

	save_file.ovn_supply_drop = nil
	save_file.ovn_supply_drop_edition = nil
	save_file.ovn_supply_drop_sticker = nil
end

-- Determine whether Supply Drop can release its stored Joker.
function G.FUNCS.supply_can_empty(e)
	local has_room = #G.jokers.cards < G.jokers.config.card_limit
	if has_room then
		e.config.colour = G.C.DARK_EDITION
		e.config.button = "supply_empty"
	else
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	end
end

-- Store a target Joker into Supply Drop.
function G.FUNCS.supply_store(e)
	local card = e.config.ref_table
	card.area:remove_from_highlighted(card)
	if card.config.center.key ~= "j_ovn_supplydrop" then return end

	local save_file = G.PROFILES[G.SETTINGS.profile]
	-- this gives a card's position in a card area, not ace, king, 10 etc
	-- (that would be card.base.id or whatever)
	local card_index = card.rank
	if card_index == 1 then return end

	local left_joker = G.jokers.cards[card_index-1]
	local left_joker_key = left_joker.config.center.key
	local left_joker_edition = left_joker.edition and left_joker.edition.key
	local left_joker_stickers = {}
	for sticker_key in pairs(SMODS.Stickers) do
		if left_joker.ability[sticker_key] then
			table.insert(left_joker_stickers, sticker_key)
		end
	end

	save_file.ovn_supply_drop = left_joker_key
	save_file.ovn_supply_drop_edition = left_joker_edition
	save_file.ovn_supply_drop_sticker = left_joker_stickers
	check_for_unlock({type = 'ovn_sell_supply_drop'})

	-- i think you can use smods.destroy_cards but idk, too lazy to check -oin
	Ovn_f.add_simple_event('after', 0.1, function ()
		left_joker:start_dissolve({G.C.RARITY['ovn_corrupted']})
		SMODS.calculate_effect({
			message = localize("stored"),
			colour = G.C.DARK_EDITION
		}, card)
	end)
end

-- Determine whether Supply Drop can store a target Joker.
function G.FUNCS.supply_can_store(e)
	local card = e.config.ref_table
	if card.rank == 1 then -- Leftmost card
		e.config.colour = G.C.UI.BACKGROUND_INACTIVE
		e.config.button = nil
	else
		e.config.colour = G.C.DARK_EDITION
		e.config.button = "supply_store"
	end
end



--------------------
---- SUIT CHART ----
--------------------

-- Generates the suit chart.
---@return nil
function Ovn_f.initialize_suit_chart()
	local w = 85
	local outline = 4
	local shadow_offset = 6
	G.ovn_suit_chart_cfg = {
		w = 85,
		outline = 4,
		shadow_offset = 6
	}
	local full_w = w + 2*outline + shadow_offset

	local c = SMODS.CanvasSprite{
		W=G.CARD_W,H=G.CARD_W, canvasW= full_w,canvasH=full_w, canvasScale= 1
	}
	love.graphics.push()
	love.graphics.origin()
	c.canvas:renderTo(function ()
		local middle = w/2 + outline
		local radius = w/2
		local shadow_colour = {0,0,0,0.4}
		love.graphics.setColor(unpack(shadow_colour))
		love.graphics.circle("fill", middle + shadow_offset, middle + shadow_offset, radius + outline)
	end)
	love.graphics.pop()
	G.ovn_suit_chart = UIBox{
		definition =
		JTML.flex{mode="column", style={colour={0,0,0,0}}, {
			JTML.flex{style={align="center-middle", padding=0.1}, {
				JTML.object{id="canvas", style={WH={G.CARD_W,G.CARD_W}, colour=G.C.RED}, object=c}
			}}
		}},
		config = {
			major = G.deck,
			align = 'tm',
			offset = {x=0.2, y=-0.2},
			bond = 'Weak'
		}
	}
	Ovn_f.update_suit_chart(true)
end

-- Updates the suit chart.
---@param instant? boolean If true, the update will not occur during an event.
---@return nil
function Ovn_f.update_suit_chart(instant)
	-- BUG: improper update when changing cards outside scoring
	local suit_count = {}
	local suit_list = {}
	for _,card in ipairs(G.playing_cards) do
		if not SMODS.has_no_suit(card) then
			if not suit_count[card.base.suit] then
				suit_count[card.base.suit] = 0
				table.insert(suit_list, card.base.suit)
			end
			suit_count[card.base.suit] = suit_count[card.base.suit] + 1
		end
	end
	table.sort(suit_list, function(a,b)
		if suit_count[a] == suit_count[b] then
			return SMODS.Suits[a].sort_id > SMODS.Suits[b].sort_id
		end
		return suit_count[a] < suit_count[b]
	end)
	print(suit_count)

	local w = G.ovn_suit_chart_cfg.w
	local outline = G.ovn_suit_chart_cfg.outline
	local shadow_offset = G.ovn_suit_chart_cfg.shadow_offset
	local full_w = w + 2*outline + shadow_offset

	local c = G.ovn_suit_chart:get_UIE_by_ID("canvas").config.object.canvas
	Ovn_f.add_simple_event(instant and "instant" or "after", 0, function ()
		c:renderTo(function ()
			local middle = w/2 + outline
			local radius = w/2

			local suitless_colour_under = darken(G.C.UI.BACKGROUND_INACTIVE, 0.6)
			suitless_colour_under[2] = suitless_colour_under[2]*1.4
			love.graphics.setColor(unpack(suitless_colour_under))
			love.graphics.circle("fill", middle, middle, radius + outline)

			local suitless_colour = lighten(G.C.UI.BACKGROUND_INACTIVE, 0.1)
			love.graphics.setColor(unpack(suitless_colour))
			love.graphics.circle("fill", middle, middle, radius)

			local previous_angle_under = -math.pi/2
			for _,suit in ipairs(suit_list) do
				local colour = darken(G.C.SUITS[suit], 0.6)
				colour[2] = colour[2]*1.4
				local arclength = -2*math.pi*(suit_count[suit]/#G.playing_cards)
				love.graphics.setColor(unpack(colour))
				love.graphics.arc("fill", middle, middle, radius + outline, previous_angle_under, previous_angle_under + arclength)
				previous_angle_under = previous_angle_under + arclength
			end

			local previous_angle = -math.pi/2
			for _,suit in ipairs(suit_list) do
				local colour = lighten(G.C.SUITS[suit], 0.1)
				local arclength = -2*math.pi*(suit_count[suit]/#G.playing_cards)
				love.graphics.setColor(unpack(colour))
				love.graphics.arc("fill", middle, middle, radius, previous_angle, previous_angle + arclength)
				previous_angle = previous_angle + arclength
			end
		end)
	end)
end



-----------------------
---- MISCELLANEOUS ----
-----------------------

-- Applies additional tooltips to the hovered card.
---@param _c SMODS.Center honestly idek what the types are
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
	if card.seal and Ovn_f.descend_table{card.area, "config", "collection"} then
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

	-- Tags
	if getmetatable(card) == Tag and card.for_collection then
		local tag_proto = SMODS.Tags[card.key]
		-- Credits
		if tag_proto.credits then
			-- Only way to attach vars to send to the description dummy
			G.P_CENTERS['dd_ovn_credits'].specific_vars = tag_proto.credits
			table.insert(info_queue, G.P_CENTERS['dd_ovn_credits'])
		end

		-- Placeholder note
		if tag_proto.uses_placeholder_sprite then
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
---@field text_colour? Colour Default colour for uncoloured text.
---@field align? "left" | "center" | "middle" | "right" Alignment of all text.

-- Automatically formats a list of localization strings into a JTML element.
---@param desc string[]
---@param config? localize_desc.Config
---@return UINode
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
				shadow = config.shadow
			})
		end
		local padding = row_text_parsed and config.padding or config.empty_line_space
		local row_ui = JTML.flex{mode="column", style={padding=padding, align=align}, row_ui_text}
		table.insert(row_nodes, row_ui)
	end

	return
	JTML.flex{self_mode=(config.node_type or "row"), mode="row", style={align=align}, row_nodes}
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
---@param nodes UINode[]
---@return nil
function Ovn_f.notification(nodes, sustain)
	local style = {
		["root"] = { ---@type JTML.flex.style
			align = "center-left",
			roundCorners = true,
			padding = 0.06,
			colour = G.C.UI.TRANSPARENT_DARK
		},
		["notif_container"] = {
			align = "center-left",
			padding = 0.2,
			WH = {20, nil},
			roundCorners = true,
			colour = G.C.BLACK,
			outline = {1.5, G.C.GREY},
		},
		["node_container"] = {
			align = "center-middle",
			roundCorners = true,
		}
	}

	local def =
	JTML.flex{mode="row", style=style.root, {
		JTML.flex{mode="row", style=style.notif_container, {
			JTML.flex{mode="row", style=style.node_container, nodes}
		}}
	}}

	notif_event(nil, function ()
		if G.achievement_notification then
			G.achievement_notification:remove()
			G.achievement_notification = nil
		end
		G.achievement_notification = G.achievement_notification or UIBox{
			definition = def,
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