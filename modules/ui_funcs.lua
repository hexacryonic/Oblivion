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



------------------
---- TABLE UI ----
------------------

local table_ui_style = {
	[".table_container"] = {
		align = "center-middle",
		padding = 0.05
	},
	[".table_body"] = {align = "center-middle"},
	[".table_column"] = {padding = 0},
	[".table_cell"] = {
		outlineWidth = 0.5,
		outlineColour = G.C.JOKER_GREY,
		padding = 0.075,
	},
	[".table_text"] = {
		scale = 0.32,
		colour = G.C.UI.TEXT_DARK,
		padding = 0.025,
	},

	[".align-left"] = {align = "center-left"},
	[".align-right"] = {align = "center-right"},
	[".align-middle"] = {align = "center-middle"},
	[".align-center"] = {align = "center-middle"},

	[".cell_header"] = {
		fillColour = lighten(G.C.JOKER_GREY, 0.5)
	}
}

---@param tbl any[][]
local function transpose_table(tbl)
	local tbl_T = {}
	for _,row in ipairs(tbl) do
		for i, item in ipairs(row) do
			tbl_T[i] = tbl_T[i] or {}
			table.insert(tbl_T[i], item)
		end
	end

	return tbl_T
end

-- Generates the UIBox table for a table of text, like with rows and columns and cells n shit
---@param table_def string[][]
---@param config? {string: any}
---@return Balatro.UIBoxDefinition
function Ovn_f.generate_table_ui(table_def, config)
	config = config or {}
	-- Valid config:
		-- no_header
		-- default_text_colour
		-- text_scale (default 0.32)
		-- outline_colour

	-- Fill in empty spots
	local max_row_length = 0
	for _,row in ipairs(table_def) do
		max_row_length = math.max(max_row_length, #row)
	end
	for _,row in ipairs(table_def) do
		for i = 1, max_row_length do
			row[i] = row[i] or ""
		end
	end

	-- table_def is a table of ROWS,
	-- need to first transpose into a table of COLUMNS
	local table_def_cols = transpose_table(table_def)

	local columns = {}
	for _,col_def in ipairs(table_def_cols) do
		local entries = {}
		for i,cell_def in ipairs(col_def) do
			-- Prepare cell config
			local text, colour, align
			if type(cell_def) == "table" then
				text = cell_def.text
				colour = cell_def.colour or config.default_text_colour
				align = cell_def.align
			else
				text = cell_def
				colour = config.default_text_colour
			end

			-- Prepare classes
			local cell_header_class = (not config.no_header) and i == 1 and " cell_header" or ""
			local align_class = " align-" .. (align or "left")

			-- Define UI
			local cell_ui =
			{"row", class="table_cell" .. cell_header_class .. align_class, style={outlineColour = config.outline_colour}, {
				{"text", class="table_text", style={colour=colour, scale = config.text_scale}, text=text}
			}}
			table.insert(entries, cell_ui)
		end

		local column_ui = {"column", class="table_column", entries}
		table.insert(columns, column_ui)
	end

	local table_ui =
	{"row", class="table_container", {
		-- Required to remove gaps between elements
		{"row", class="table_body", columns}
	}}
	return Ovn_f.jtml_to_uiboxdef(table_ui, table_ui_style)
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
	if card and card.config.center and Ovn_f.joker_is_corruptible(card.config.center.key) and card.config.center.discovered then
		table.insert(info_queue, {
			key = 'ovn_corruptible',
			set = 'Other',
			vars = { localize {
				type = "name_text",
				set = "Joker",
				key = card.config.center.key
			} }
		})
	end

	if card and card.base and card.base.suit == "ovn_Optics" then
		table.insert(info_queue, {
			key = 'ovn_opticinfo',
			set = 'Other',
		})
	end

	if card and card.config.center and G.your_collection and (
		card.config.center.credits
		or card.config.center.uses_placeholder_sprite
	) then for _,collection_area in ipairs(G.your_collection) do
		if card.area == collection_area then
			if card.config.center.credits then
				-- Only way to attach vars to send to the description dummy
				G.P_CENTERS['dd_ovn_credits'].specific_vars = card.config.center.credits
				table.insert(info_queue, G.P_CENTERS['dd_ovn_credits'])
			end

			if card.config.center.uses_placeholder_sprite then
				table.insert(info_queue, {
					key = 'ovn_placeholder_sprite',
					set = 'Other'
				})
			end

			break
		end
	end end
end

-- Automatically formats a list of localization strings into a JTML element.
---@param desc string[]
---@param args? table
---@return JTML.JTML
function Ovn_f.localize_desc(desc, args)
	args = args or {}
	args.scale = args.scale or 1.125
	args.empty_line_space = args.empty_line_space or 0.15
	args.padding = args.padding or 0.03
	args.text_colour = args.text_colour or G.C.UI.TEXT_LIGHT
	args.align = args.align or "left"

	local align = "center-"..args.align

	local row_nodes = {}
	for _,row_text in ipairs(desc) do
		local row_text_parsed = loc_parse_string(row_text)
		local row_ui_text
		if row_text_parsed then
			row_ui_text = SMODS.localize_box(row_text_parsed, {
				text_colour = args.text_colour,
				scale = args.scale,
			})
		end
		local padding = row_text_parsed and args.padding or args.empty_line_space
		local row_ui = {"row", style={padding = padding, align = align}, row_ui_text}
		table.insert(row_nodes, row_ui)
	end

	return {"row", style={align = align}, row_nodes}
end



-----------------
---- CONFIG ----
-----------------

Oblivion.obj.config_tab = function ()
	local config_ui =
	{"root", style={
		align = "center-middle",
		padding = 0.2,
		fillColour = G.C.BLACK,
		roundness = 0.1,
		emboss = 0.05,
	}, {
		{"row", {
			create_toggle {
				label = localize("k_cfg_family_friendly"),
				ref_table = Oblivion.config,
				ref_value = "family_friendly",
				callback = Ovn_f.reload_localization
			}
		}},
		{"row", {
			create_toggle {
				label = localize("k_cfg_disable_c_erratic_shader"),
				ref_table = Oblivion.config,
				ref_value = "disable_c_erratic_shader"
			}
		}},
	}}

	return Ovn_f.jtml_to_uiboxdef(config_ui, {})
end



-----------------
---- CREDITS ----
-----------------

local credits_ui_style = {
	[".credits_ui_style"] = {
		align = "center-middle",
		padding = 0.2,
		fillColour = G.C.BLACK,
		roundness = 0.1,
		emboss = 0.05,
		minWidth = 6,
		minHeight = 6
	},
	[".credits_header"] = {
		align = "center-middle",
		padding = 0.2,
		outlineColour = G.C.JOKER_GREY,
		roundness = 0.1,
		outlineWidth = 1
	},
	[".credits_header_text"] = {
		scale = 0.45,
		colour = G.C.UI.TEXT_LIGHT
	},
	[".credits_text"] = {
		scale = 0.4,
		colour = G.C.UI.TEXT_LIGHT,
		padding = 0.05,
	},
	[".credits_body"] = {align = "center-middle"},
}

local function header(text)
	return
	{"row", style={align="center-middle", padding=0.2}, {
		{"row", class="credits_header", {
			{"text", class="credits_header_text", text=text}
		}}
	}}
end

local table_config = {
	no_header = true,
	default_text_colour = G.C.UI.TEXT_LIGHT,
	text_scale = 0.36,
	outline_colour = darken(G.C.JOKER_GREY, 0.5)
}

local function primary_contributors()
	local credits_copy = Ovn_f.bi_shallow_copy(G.localization.misc.credits)
	for _,row in ipairs(credits_copy) do
		row[1] = {
			text = row[1],
			colour = G.C.BLUE,
			align = "right"
		}
	end
	return Ovn_f.generate_table_ui(credits_copy, table_config)
end

local function additional_credits()
	local credits_copy = Ovn_f.bi_shallow_copy(G.localization.misc.credits_additional)
	for _, row in ipairs(credits_copy) do
		row[1] = {
			text = row[1],
			colour = G.C.BLUE,
			align = "right"
		}
		row[2] = {
			text = row[2],
			colour = G.C.ORANGE,
			align = "center"
		}
	end
	return Ovn_f.generate_table_ui(credits_copy, table_config)
end

function Ovn_f.credits_ui()
	local credits_ui =
	{"root", class="credits_ui_style", {
		{"column", {
			header(localize("k_primary_contributors")),
			{"row", class="credits_body", {
				primary_contributors(),
			}},
			header(localize("k_additional_credits")),
			{"row", class="credits_body", {
				additional_credits(),
			}},
		}},
		{"column", {
			header(localize("k_sources")),
			Ovn_f.localize_desc(G.localization.misc.credits_long),
		}}
	}}

	return Ovn_f.jtml_to_uiboxdef(credits_ui, credits_ui_style)
end