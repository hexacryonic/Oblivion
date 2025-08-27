-- JTML - Jimbo's Tabular Markup Lingo, an alternate syntax for UIBox definitions
-- https://github.com/Oinite12/balatro-modding-modules

-- LuaCATS classes - source code a little below

---@class Balatro.Colour
---@field [1] number -- r
---@field [2] number -- g
---@field [3] number -- b
---@field [4] number -- a
local colour_def = {}

---@class JTML.JTML
---@field [1] "root"|"row"|"column"|"text"|"object"|"box"|"slider"|"input"
---@field id? string
---@field class? string
---@field style? JTML.Style
---@field ondraw? string
---@field onclick? string
---@field reftable? table
---@field refvalue? string
---@field tooltip? { title: string, text: string[] }
---@field detailedtooltip? { title: string, text: string[] }
---@field role? { role_type: "Major"|"Minor"|"Glued" }
---@field norole? boolean
---@field instancetype? "NODE"|"MOVEABLE"|"UIBOX"|"CARDAREA"|"CARD"|"UI_BOX"|"ALERT"|"POPUP"
---@field language? string
---@field object? any
---@field text? string
---@field [2]? JTML.JTML[]|Balatro.UIBoxDefinition[]
local jtml_def = {}

---@class JTML.Style
---@field align? string
---@field minimumWidth? number
---@field minWidth? number
---@field width? number
---@field maxWidth? number
---@field minimumHeight? number
---@field minHeight? number
---@field height? number
---@field maxHeight? number
---@field padding? number
---@field roundness? number
---@field fillColour? Balatro.Colour
---@field fillColor? Balatro.Colour
---@field noFill? boolean
---@field outlineWidth? number
---@field outlineColour? Balatro.Colour
---@field outlineColor? Balatro.Colour
---@field emboss? number
---@field hover? boolean
---@field shadow? boolean
---@field juice? boolean
---@field onePress? any
---@field focus? table
---@field scale? number
---@field colour? Balatro.Colour
---@field color? Balatro.Colour
---@field textOrientation? string
---@field lineEmboss? any
local jtml_style_def = {}

---@class Balatro.UIBoxDefinition
---@field n integer
---@field config? Balatro.UIBoxConfig
---@field nodes Balatro.UIBoxDefinition[]
local uiboxdef_def = {}

---@class Balatro.UIBoxConfig
---@field align? string
---@field h? number
---@field minh? number
---@field maxh? number
---@field w? number
---@field minw? number
---@field maxw? number
---@field padding? number
---@field r? number
---@field colour Balatro.Colour
---@field no_fill? boolean
---@field outline? number
---@field outline_colour? Balatro.Colour
---@field emboss? number
---@field hover? boolean
---@field shadow? boolean
---@field juice? boolean
---@field id? string
---@field instance_type? "NODE"|"MOVEABLE"|"UIBOX"|"CARDAREA"|"CARD"|"UI_BOX"|"ALERT"|"POPUP"
---@field ref_table? table
---@field ref_value? string
---@field func? string
---@field button? string
---@field tooltip? { title: string, text: string[] }
---@field detailed_tooltip? { title: string, text: string[] }
---@field text? string
---@field scale? number
---@field vert? boolean
---@field object? any
---@field role? { role_type: "Major"|"Minor"|"Glued" }
---@field no_role? boolean
---@field lang? string
---@field line_emboss? any	
---@field one_press? any
---@field focus_args table
local uiboxconfig_def = {}

----

-- Splits <input> along <sep>, a character or Lua pattern.
---@param input string
---@param sep string
---@return table
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
	root   = function() return G.UIT.ROOT end,
	row    = function() return G.UIT.R end,
	column = function() return G.UIT.C end,
	text   = function() return G.UIT.T end,
	object = function() return G.UIT.O end,
	box    = function() return G.UIT.B end,
	slider = function() return G.UIT.S end,
	input  = function() return G.UIT.I end
}

local attribute_to_config = {
	id = "id",
	instancetype = "instance_type",
	text = "text",
	reftable = "ref_table",
	refvalue = "ref_value",

	ondraw = "func",
	onclick = "button",
	tooltip = "tooltip",
	detailedtooltip = "detailed_tooltip",
	object = "object",
	role = "role",
	language = "lang",
	norole = "no_role",
}

local style_to_config = {
	align = "align",

	minimumWidth = "minw",
	minWidth = "minw",
	width = "w",
	maxWidth = "maxw",

	minimumHeight = "minh",
	minHeight = "minh",
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
	-- fillColor and color both map to "colour"? that's because:
	-- "colour" is for BOTH G.UIT.R/C background, and G.UIT.T color
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

-- Adds stylerule properties to a UIBox config table.
---@param config Balatro.UIBoxConfig
---@param stylerules JTML.Style
---@return nil
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

-- Generates a UIBox definition table out of a JTML table and stylesheet.
---@param jtml JTML.JTML|Balatro.UIBoxDefinition
---@param stylesheet { [string]: JTML.Style }
---@return Balatro.UIBoxDefinition
local function generate_uibox_definition(jtml, stylesheet)
	if ( -- If jtml is actually just UIBox syntax
		not jtml[1]
		and not jtml[2]
		and jtml.n
		and jtml.config
	) then return jtml --[[@as Balatro.UIBoxDefinition]] end
	local uibox_table = {config = {}}
	stylesheet = stylesheet or {}

	local element_name = jtml[1]
	local children = jtml[2]
	local element_style = jtml.style
	local element_classes = jtml.class and split(jtml.class, "%s") or {}
	local element_id = jtml.id

	uibox_table.n = element_to_n[element_name] and element_to_n[element_name]()

	-- Element attributes to config
	for attribute, value in pairs(jtml) do
		if attribute_to_config[attribute] then
			local config_key = attribute_to_config[attribute]
			uibox_table.config[config_key] = value
		end
	end

	-- First, apply ID style
	if element_id and stylesheet["#" .. element_id] then
		local stylerule = stylesheet["#" .. element_id]
		add_stylerule_to_config(uibox_table.config, stylerule)
	end
	-- Next, apply class styles in order of classes
	for _,classname in ipairs(element_classes) do
		if stylesheet["." .. classname] then
			local stylerule = stylesheet["." .. classname]
			add_stylerule_to_config(uibox_table.config, stylerule)
		end
	end
	-- Finally, apply inline style
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

-- Put function on global scope to use it anywhere
-- global_function = generate_uibox_definition