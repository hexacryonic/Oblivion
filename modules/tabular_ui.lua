---@param tbl any[][]
---@return any[][]
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
}

---@class generate_table_ui.Config
---@field header_fill? Balatro.Colour The background colour of header cells, if enabled.
---@field default_cell_fill? Balatro.Colour The default background colour for all cells.
---@field no_header? boolean If true, the first row of the table will not have a gray background.
---@field default_text_colour? Balatro.Colour The default colour for all uncoloured text.
---@field text_scale? number Size of text.
---@field outline_colour? Balatro.Colour The colour of cell borders.

---@class generate_table_ui.Text
---@field text? string|string[]
---@field colour? Balatro.Colour
---@field align? "left" | "center" | "middle" | "right"
---@field element? Balatro.UIBoxDefinition|JTML.JTML
---@field cell_fill? Balatro.Colour The background colour of the text's cell.

-- Generates the UIBox table for a table of text, like with rows and columns and cells n shit
---@param table_def generate_table_ui.Text[][]
---@param config? generate_table_ui.Config
---@return Balatro.UIBoxDefinition
local function generate_tabular_ui(table_def, config)
	config = config or {}

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

	-- Prepare each column
	local columns = {}
	for _,col_def in ipairs(table_def_cols) do
		local entries = {}
		for i,cell_def in ipairs(col_def) do
            local is_header = (not config.no_header) and i == 1

			-- Prepare cell config
			local text = type(cell_def.text) == "table" and cell_def.text or {cell_def.text}
			local colour = cell_def.colour or config.default_text_colour
			local align = cell_def.align
			local scale = cell_def.scale or config.default_text_scale
			local element = cell_def.element
            local fill = cell_def.cell_fill

			-- Prepare classes
			local align_class = " align-" .. (align or "left")

			-- Prepare UI elements, particularly text
			local cell_ui_nodes = {}
			if element then
				table.insert(cell_ui_nodes, element)
			else
				for _,a_text in ipairs(text) do
					local text_el = {"text", class="table_text", style={colour=colour, scale = scale}, text=a_text}
					if #text > 1 then
						text_el = {"row", {text_el}}
					end
					table.insert(cell_ui_nodes, text_el)
				end
			end

            -- Prepare cell style
            local header_fill = is_header and (config.header_fill or lighten(G.C.JOKER_GREY, 0.5)) or nil
            local default_fill = config.default_cell_fill
            local cell_style = {
                outlineColour = config.outline_colour,
                fillColour = fill or header_fill or default_fill,
            }

			-- Define UI
			local cell_ui = {"row", class="table_cell" .. align_class, style=cell_style, cell_ui_nodes}
			table.insert(entries, cell_ui)
		end

		local column_ui = {"column", class="table_column", entries}
		table.insert(columns, column_ui)
	end

	-- Generate UIBox of table to allow for direct UI manipulation
	local table_ui_jtml =
	{"root", style={fillColour=G.C.CLEAR}, {
		{"row", class="table_container", {
			-- Required to remove gaps between elements
			{"row", class="table_body", columns}
		}}
	}}
	local table_ui = Ovn_f.jtml_to_uiboxdef(table_ui_jtml, table_ui_style)
	local uibox = UIBox{definition = table_ui, config={}}
	local uiel  = uibox.UIRoot

	-- Change heights of cells to line up with left-right-adjacent cells
	local row_count = #table_def
	local col_count = #table_def_cols
	for r=1,row_count do
		local cell_heights = {}

		for c=1,col_count do
			local column = uiel.children[1].children[1].children[c]
			local cell = column.children[r]
			table.insert(cell_heights, cell.T.h)
		end

		local max_cell_height = math.max(unpack(cell_heights))

		for c=1,col_count do
			local column = uiel.children[1].children[1].children[c]
			local cell = column.children[r]
			cell.T.h = max_cell_height
			cell.config.h = max_cell_height
			cell.config.minh = max_cell_height
		end
	end
	uibox:recalculate()

	-- Finally ready
	local final_return = {n=G.UIT.O, config={object=uibox}}
	return final_return
end

Ovn_f.generate_table_ui = generate_tabular_ui