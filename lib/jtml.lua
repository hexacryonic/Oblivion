-- JTML - Jimbo's Tabular Markup Lingo

local function split(input, sep)
	-- this function taken from https://stackoverflow.com/a/7615129
	if sep == nil then sep = "%s" end
	local t = {}
	for str in input:gmatch("([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

local element_to_n = {
	root   = "ROOT",
	row    = "R",
	column = "C",
	text   = "T",
	object = "O",
	box    = "B",
	slider = "S",
	input  = "I"
}

-- not listed bellow: text, class

local attribute_to_config = {
	id = "id",
	instancetype = "instance_type",
	text = "text",
	reftable = "ref_table",
	refvalue = "ref_value",

	ondraw = "func",
	onclick = "button",
	tooltip = "tooltip",
	detailedTooltip = "detailed_tooltip",
	object = "object",
	role = "role",
	language = "lang",
	norole = "no_role",
}

local style_to_config = {
	align = "align",

	minimumWidth = "minw",
	width = "w",
	maxWidth = "maxw",

	minimumHeight = "minh",
	height = "h",
	maxHeight = "maxh",

	padding = "padding",
	roundness = "r",
	fillColour = "colour",
	fillColor = "colour",

	noFill = "no_fill",
	outlineWidth = "outline",
	outlineColour = "outline_colour",
	outlineColor = "outline_colour",
	emboss = "emboss",

	hover = "hover",
	shadow = "shadow",
	juice = "juice",

	onePress = "one_press",
	focus = "focus_args",

	scale = "scale",
	colour = "colour",
	color = "colour",
	textOrientation = "vert",
	lineEmboss = "line_emboss"
}

local pre_formatting = {
	align = function(input)
		local split_input = split(input:lower(), "%-")
		if #split_input < 2 then return input end
		local a = split_input[1]
		local b = split_input[2]

		local a_map = {
			top = "t",
			center = "c",
			middle = "c",
			bottom = "b",
		}
		local b_map = {
			left = "l",
			middle = "m",
			center = "m",
			right = "r",
		}

		return a_map[a] .. b_map[b]
	end,
	textOrientation = function(input)
		if input == "vertical" then return true end
		return false
	end
}

local function add_stylerule_to_config(config, stylerules)
	for property, value in pairs(stylerules) do
		if style_to_config[property] then
			local config_key = style_to_config[property]
			local proper_value = value
			if pre_formatting[property] then
				proper_value = pre_formatting[property](value)
			end
			config[config_key] = proper_value
		end
	end
end

local function generate_uibox_definition(jtml, stylesheet)
	if ( -- If jtml is actually just UIBox syntax
		not jtml[1]
		and not jtml[2]
		and jtml.n
		and jtml.config
	) then return jtml end
	local uibox_table = {config = {}}

	local element_name = jtml[1]
	local children = jtml[2]
	local element_style = jtml.style
	local element_classes = jtml.class and split(jtml.class, "%s") or {}
	local element_id = jtml.id

	local n_key = element_to_n[element_name]
	uibox_table.n = G.UIT[n_key]

	for attribute, value in pairs(jtml) do
		if attribute_to_config[attribute] then
			local config_key = attribute_to_config[attribute]
			uibox_table.config[config_key] = value
		end
	end

	-- First, ID style
	if element_id and stylesheet["#" .. element_id] then
		local stylerule = stylesheet["#" .. element_id]
		add_stylerule_to_config(uibox_table.config, stylerule)
	end
	-- Next, class styles in order of classes
	for _,classname in ipairs(element_classes) do
		if stylesheet["." .. classname] then
			local stylerule = stylesheet["." .. classname]
			add_stylerule_to_config(uibox_table.config, stylerule)
		end
	end
	-- Finally, inline style
	if element_style then
		add_stylerule_to_config(uibox_table.config, element_style)
	end

	if children then
		for _,child_jtml in ipairs(children) do
			uibox_table.nodes = uibox_table.nodes or {}
			local new_node = generate_uibox_definition(child_jtml, stylesheet)
			table.insert(uibox_table.nodes, new_node)
		end
	end
	return uibox_table
end

Ovn_f.jtml_to_uiboxdef = generate_uibox_definition