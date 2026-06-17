---@class generate_table_ui.Text
---@field text? string|string[]
---@field colour? [number, number, number, number]
---@field align? string
---@field element? {n: number, config?: {string: any}, nodes?: table} Overrides `text`.
---@field cell_fill? [number, number, number, number] The background colour of the text's cell.

---@class generate_table_ui.Config
---@field header_fill? [number, number, number, number] The background colour of header cells, if enabled.
---@field default_cell_fill? [number, number, number, number] The default background colour for all cells.
---@field no_header? boolean If true, the first row of the table will not have a gray background.
---@field default_text_colour? [number, number, number, number] The default colour for all uncoloured text.
---@field text_scale? number Size of text.
---@field outline_colour? [number, number, number, number] The colour of cell borders.

-- Generates the UIBox definition for tabular UI.
---@param table_def generate_table_ui.Text[][]
---@param config? generate_table_ui.Config
---@return {n: G.UIT.O, config: {object: UIBox}}
local function generate_tabular_ui(table_def, config)
    config = config or {}

    local max_row_length = 0
    for _,row in ipairs(table_def) do
        max_row_length = math.max(max_row_length, #row)
    end

    local rows = {}
    for r,row_def in ipairs(table_def) do
        local cells_in_row = {}
        for i = 1, max_row_length do
            local cell_def = row_def[i] or {}
            local is_header = (not config.no_header) and r == 1

            -- Prepare cell properties
            local text = type(cell_def.text) == "table" and cell_def.text or {cell_def.text} --[[@as table]]
            local colour = cell_def.colour or config.default_text_colour
            local align = cell_def.align or "cl"
            local scale = cell_def.scale or config.default_text_scale
            local element = cell_def.element
            local fill = cell_def.cell_fill

            -- Prepare UI elements, particularly text
            local cell_ui_nodes = {}
            if element then
                table.insert(cell_ui_nodes, element)
            else
                for _,text_line in ipairs(text) do
                    local text_el_config = {
                        padding = 0.025,
                        colour = colour or G.C.UI.TEXT_DARK,
                        scale = scale or 0.32,
						align = align,
                        text = text_line,
                    }
                    local text_el = {n=G.UIT.T, config = text_el_config}
                    -- Row wrapper required for multiline tuitext
                    if #text > 1 then
                        text_el = {n=G.UIT.R, nodes = {text_el}}
                    end
                    table.insert(cell_ui_nodes, text_el)
                end
            end

            -- Prepare cell itself
            local header_fill = is_header and (config.header_fill or lighten(G.C.JOKER_GREY, 0.5)) or nil
            local default_fill = config.default_cell_fill
            local cell_el_config = {
                outline = 0.5,
                outline_colour = config.outline_colour or G.C.JOKER_GREY,
                padding = 0.075,
                align = align,
                colour = fill or header_fill or default_fill
            }
            local cell_ui = {n=G.UIT.C, config=cell_el_config, nodes=cell_ui_nodes}
			table.insert(cells_in_row, cell_ui)
        end

        local current_row = {n=G.UIT.R, config={padding = 0}, nodes=cells_in_row}
        table.insert(rows, current_row)
    end

    -- Generate UIBox of table to allow for direct UI manipulation
    local table_ui = UIBox {
        config = {},
        definition =
        {n=G.UIT.ROOT, config={colour=G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={align="cm", padding=0.05}, nodes={
                -- Required to remove gaps between elements
                {n=G.UIT.R, config={align="cm"}, nodes=rows}
            }}
        }}
    }
    local uiel = table_ui.UIRoot

    -- Change widths of cells to line up with up-down-adjacent cells
    local row_count = #table_def
    local col_count = max_row_length
    for c = 1, col_count do
        local max_cell_width = 0

        for r = 1, row_count do
            local row = uiel.children[1].children[1].children[r]
            local cell = row.children[c]
            max_cell_width = math.max(cell.T.w, max_cell_width)
        end

        for r = 1, row_count do
            local row = uiel.children[1].children[1].children[r]
            local cell = row.children[c]
            cell.T.w = max_cell_width
            cell.config.w = max_cell_width
            cell.config.minw = max_cell_width
        end
    end
    table_ui:recalculate()

    -- Finally ready
    return {n=G.UIT.O, config={object=table_ui}}
end

Ovn_f.generate_table_ui = generate_tabular_ui