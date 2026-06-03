local JTML = {}
Ovn_f.JTML = JTML

------------------------------------
--#region SUPPLEMENTARY FUNCTIONS --
------------------------------------

JTML.f = {}
JTML.f.handle_alias = {}

-- Returns a function that checks if a table contains some or all of a list of keys,
-- and whether said keys map to the intended data type.
---@param format_def {[any]: string}
---@return fun(tbl: table): boolean
local function is_table_format(format_def)
	return function(tbl)
		local is_empty = true
		for key,value in pairs(tbl) do
			-- "X" ~= nil
			-- "X" ~= "Y"
			if type(value) ~= format_def[key] then
				return false
			end
			is_empty = false
		end
		return not is_empty
	end
end

JTML.f.is_tooltip_def = is_table_format({
	["title"] = "string", ["text"] = "table",
	["filler"] = "table", ["snap"] = "boolean",
})

JTML.f.is_colour = is_table_format({
	[1] = "number", [2] = "number",
	[3] = "number", [4] = "number",
})

-- Apply UINode config values given a JTML node's config values.
JTML.f.handle_alias.config = function (alias_list, mode, node, config)
	for key,value in pairs(node) do
		local uinode_alias = alias_list[key]
		local alias_type = type(uinode_alias)
		-- Skip everything if key is not defined
		if not uinode_alias then
		-- Key and alias are the same
		elseif uinode_alias == true then
			config[key] = value
		-- Key and alias have same behaviors
		elseif alias_type == "string" then
			config[uinode_alias] = value
		-- Key and alias have same behaviors, but change truthy to strictly true
		elseif alias_type == "table" and uinode_alias[1] then
			config[uinode_alias[1]] = true
		-- Key and alias do NOT have same behaviors
		elseif alias_type == "function" then
			uinode_alias(value, mode, node, config)
		end
	end
end

--#endregion
------------------------------------

-----------------------------------
--#region GENERIC STYLE HANDLING --
-----------------------------------

-- faster to do this honestly
local align_codes = {
	[      "top-left"] = "tl",
	[    "top-middle"] = "tm",
	[     "top-right"] = "tr",

	[   "center-left"] = "cl",
	[ "center-middle"] = "cm",
	[  "center-right"] = "cr",

	[   "bottom-left"] = "bl",
	[ "bottom-middle"] = "bm",
	[  "bottom-right"] = "br",
}

function JTML.f.handle_alias.align(value, mode, node, config)
	config.align = align_codes[value]
end

function JTML.f.handle_alias.outline(value, mode, node, config)
	if type(value) ~= "table" then return end
	config.outline        = value[1]
	config.outline_colour = value[2]
	config.line_emboss    = value[3]
end

function JTML.f.handle_alias.shadow(value, mode, node, config)
	if value == true then
		config.shadow = true
	elseif JTML.f.is_colour(value) then
		config.shadow = true
		config.shadow_colour = value
	end
end

local JTML_style_aliases = {
	align = JTML.f.handle_alias.align,
	WH = function (value, mode, node, config)
		if mode == "text" or type(value) ~= "table" then return end
		if mode == "object" then
			config.w = value[1]; config.h = value[2]
		else -- mode == "flex"
			config.minw = value[1]; config.minh = value[2]
		end
	end,
	maxWH = function (value, mode, node, config)
		-- whitelist handles mode-check
		if type(value) ~= "table" then return end
		config.maxw = value[1]; config.maxh = value[2]
	end,
	noFill = {"no_fill"},
	padding = true,
	colour = true,
	color = "colour",
	roundCorners = {"r"},
	emboss = true,
	outline = JTML.f.handle_alias.outline,
	shadow = JTML.f.handle_alias.shadow,
	scale = true,
	verticalText = {"vert"},
	lang = true,
	font = true,
	hover = true,
}

local JTML_style_whitelist = {
	maxWH = "flex",
	noFill = "flex",
	roundCorners = "flex",
	emboss = "flex",
	scale = "text",
	verticalText = "text",
	lang = "text",
	font = "text",
}

function JTML.f.handle_alias.style(style, mode, node, config)
	-- Single style support
	if #style == 0 then style = {style} end
	for _,single_style in ipairs(style) do
		for key,value in pairs(single_style) do
			local uinode_alias = JTML_style_aliases[key]
			local alias_type = type(uinode_alias)
			local whitelisted_mode = JTML_style_whitelist[key] or mode

			-- Skip everything if key is not defined
			if not uinode_alias or whitelisted_mode ~= mode then
			-- Key and alias are the same
			elseif uinode_alias == true then
				config[key] = value
			-- Key and alias have same behaviors
			elseif alias_type == "string" then
				config[uinode_alias] = value
			-- Key and alias have same behaviors, but change truthy to strictly true
			elseif alias_type == "table" and uinode_alias[1] then
				config[uinode_alias[1]] = true
			-- Key and alias do NOT have same behaviors
			elseif alias_type == "function" then
				uinode_alias(value, mode, node, config)
			end
		end
	end
end

--#endregion
---------------------------

------------------------------------
--#region GENERIC CONFIG HANDLING --
------------------------------------

function JTML.f.handle_alias.tooltip(value, mode, node, config)
	if type(value) ~= "table" then
	elseif JTML.f.is_tooltip_def(value) then
		local tooltip_def = value
		local tooltip_cfg = {
			title = tooltip_def.title,
			text = tooltip_def.text and {} or nil,
			filler = tooltip_def.filler,
		}
		for _,text_def in ipairs(tooltip_def.text or {}) do
			if type(text_def) == "table" then
				table.insert(tooltip_cfg.text, {
					ref_table = text_def[1],
					ref_value = text_def[2]
				})
			elseif type(text_def) == "string" then
				table.insert(tooltip_cfg.text, text_def)
			end
		end
		if tooltip_def.snap then
			config.on_demand_tooltip = tooltip_cfg
		else
			config.tooltip = tooltip_cfg
		end
	else -- value is an object prototype
		config.detailed_tooltip = value
	end
end

function JTML.f.handle_alias.ondraw(value, mode, node, config)
	if type(value) == "string" then
		config.func = value
	elseif type(value) == "function" then
		-- Temporary G.FUNCS entry - removed when corresponding UIElement is removed
		G.FUNCS[value] = value
		config.func = value
	elseif type(value) == "table" then
		if type(value[1]) == "string" then
			config.func = value[1]
		elseif type(value[1]) == "function" then
			G.FUNCS[value[1]] = value[1]
			config.func = value[1]
		end
		config.insta_func = value.insta
	end
end

function JTML.f.handle_alias.onclick(value, mode, node, config)
	if type(value) == "string" then
		config.button = value
	elseif type(value) == "function" then
		-- Temporary G.FUNCS entry - removed when corresponding UIElement is removed
		G.FUNCS[value] = value
		config.button = value
	elseif type(value) == "table" then
		if type(value[1]) == "string" then
			config.button = value[1]
		elseif type(value[1]) == "function" then
			G.FUNCS[value[1]] = value[1]
			config.button = value[1]
		end
		config.one_press = value.one_press
		config.button_UIE = value.entangled_element
		config.button_dist = value.hold_offset
		config.button_delay = value.delay
	end
end

function JTML.f.handle_alias.reference(value, mode, node, config)
	config.ref_table = value[1]
	config.ref_value = value[2]
end

function JTML.f.handle_alias.role(value, mode, node, config)
	if mode ~= "object" then return end
	if value == "none" then
		config.no_role = true
	elseif type(value) == "table" then
		config.role = value
	end
end

local JTML_config_aliases = {
	id = true,
	tooltip = JTML.f.handle_alias.tooltip,
	instance_type = true,
	on_draw = JTML.f.handle_alias.ondraw,
	on_click = JTML.f.handle_alias.onclick,
	reference = JTML.f.handle_alias.reference,
	gamepad_focus = "focus_args",
	role = JTML.f.handle_alias.role,
	style = JTML.f.handle_alias.style
}

local object_config_aliases = {
	id = true,
	tooltip = JTML.f.handle_alias.tooltip,
	instance_type = true,
	on_draw = JTML.f.handle_alias.ondraw,
	on_click = JTML.f.handle_alias.onclick,
	reference = JTML.f.handle_alias.reference,
	gamepad_focus = "focus  _args",
	role = JTML.f.handle_alias.role,
}

local object_stylecfg_aliases = {
	align = JTML.f.handle_alias.align,
	padding = true,
	outline = JTML.f.handle_alias.outline,
}

--#endregion
------------------------------------

----------------------------
--#region NODE DEFINITION --
----------------------------

local flex_nodes = {
	[G.UIT.ROOT] = true,
	[G.UIT.R] = true,
	[G.UIT.C] = true
}

---@param node JTML.flex.config
---@return UINode
JTML.flex = function (node)
	local config = {}
	JTML.f.handle_alias.config(JTML_config_aliases, "flex", node, config)

	local children_uit
	if node.mode == "row" then
		children_uit = G.UIT.R
	elseif node.mode == "column" then
		children_uit = G.UIT.C
	end

	local self_uit = G.UIT.ROOT
	if node.self_mode == "row" then
		self_uit = G.UIT.R
	elseif node.self_mode == "column" then
		self_uit = G.UIT.C
	end

	local warn_unset_node_mode = false
	local multiple_nonflex = false
	local has_text = false
	local uinode = {n=self_uit, config=config, nodes=node[1] or node.nodes}

	for i,child_node in ipairs(uinode.nodes or {}) do
		local node_type = child_node.n

		-- Mode is set
		if children_uit then
			if flex_nodes[node_type] then
				child_node.n = children_uit
			else
				local child_config = {
					align = uinode.nodes[i].config.align,
					padding = uinode.nodes[i].config.padding
				}
				uinode.nodes[i] = {n=children_uit, config=child_config, nodes={uinode.nodes[i]}}
			end
		-- Mode not set - prepare warnings
		else
			-- Flex node cannot be changed
			if flex_nodes[node_type] or multiple_nonflex then
				warn_unset_node_mode = true
				break
			-- Allow multiple text
			elseif node_type == G.UIT.T then
				has_text = true
			-- If flex contains object, it must contain only one object
			elseif node_type == G.UIT.O then
				-- Mix texts and objects - do warning
				if has_text then
					warn_unset_node_mode = true
					break
				end
				multiple_nonflex = true
			end
		end
	end

	if warn_unset_node_mode then
		local traceback = debug.traceback()
		local lines = {}
		for str in traceback:gmatch("[^\n]+") do
			table.insert(lines, str)
		end
		local lowest_stack_i_guess_question_mark = lines[3]:gsub("^ +", "")
		sendWarnMessage(lowest_stack_i_guess_question_mark .. " - Flex `node.mode` not set, please set for proper behaviors!")
	end

	return uinode
end

---@param node JTML.object.config
---@return UINode
JTML.object = function (node)
	local config = {}
	JTML.f.handle_alias.config(JTML_config_aliases, "object", node, config)

	local select_obj = node[1] or node.object
	if type(select_obj) == "table" then
		config.object = select_obj
	end

	local uinode = {n=G.UIT.O, config=config}
	return uinode
end

JTML.f.generate_text_node = function (node)
	local config = {}
	JTML.f.handle_alias.config(JTML_config_aliases, "text", node, config)

	config.text = node[1] or node.text
	config.scale = config.scale or 0.5

	local uinode = {n=G.UIT.T, config=config}
	return uinode
end

---@param node JTML.text.config
---@return UINode
JTML.text = function (node)
	if JTML.f.is_dynatext(node) or node.dyna then
		return JTML.f.generate_dynatext_node(node)
	else
		return JTML.f.generate_text_node(node)
	end
end

--#endregion
----------------------------

---------------------
--#region DYNATEXT --
---------------------

local dynatext_style_keys = {
	'rotation', 'spacing', 'curve',
	'popIn', 'bump', 'float', 'quiver'
}

-- Check if a node is dynatext.
JTML.f.is_dynatext = function (node)
	if type(node[1]) == "table" then return true end
	if type(node.text) == "table" then return true end

	if (
		type(node.role) == "table"
		and (node.role.role_type or "Major") ~= "Major"
	) then return true end

	local style = node.style
	if not style then return false end
	if #style == 0 then style = {style} end
	for _,single_style in ipairs(style) do
		if single_style.colour and type(single_style.colour[1]) == "table" then return true end
		if single_style.color and type(single_style.color[1]) == "table" then return true end
		for _,key in ipairs(dynatext_style_keys) do
			if single_style[key] then return true end
		end
	end
	return false
end

local dynatext_objdef_alises = {
	shadow = JTML.f.handle_alias.shadow,
	colour = function (value, mode, style, obj_def)
		if type(value[1]) == "number" then
			value = {value}
		end
		obj_def.colours = value
	end,
	color = function (value, mode, style, obj_def)
		if type(value[1]) == "number" then
			value = {value}
		end
		obj_def.colours = value
	end,
	scale = true,
	lang = "font",
	font = 'font',
	rotation = "text_rot",
	spacing = true,
	curve = {"rotate"},
	popIn = function (value, mode, style, obj_def)
		obj_def.random_delay   = value.randomSelect and true or nil
		obj_def.pop_delay      = value.delay
		obj_def.pop_in_rate    = value.rate
		obj_def.min_cycle_time = value.minCycleTime
		obj_def.silent         = value.silent and true or nil
		obj_def.pitch_shift    = value.pitchShift
	end,
	bump = function(value, mode, style, obj_def)
		if value == true then
			obj_def.bump = true
		elseif type(value) == "table" then
			obj_def.bump = true
			obj_def.bump_rate = value[1]
			obj_def.bump_amount = value[2]
		end
	end,
	float = {"float"},
	quiver = function(value, mode, style, obj_def)
		obj_def.quiver = {speed=0.5, amount=0.7}
		if value == true then
		elseif type(value) == "number" then
			obj_def.quiver.amount = value
		elseif type(value) == "table" then
			obj_def.quiver = {speed=value[1], amount=value[2]}
		end
	end,
}

JTML.f.generate_dynatext_node = function (node)
	local config = {}
	local obj_def = {}

	JTML.f.handle_alias.config(object_config_aliases, "object", node, config)

	if node.style then
		if #node.style == 0 then node.style = {node.style} end
		for _,single_style in ipairs(node.style) do
			JTML.f.handle_alias.config(object_stylecfg_aliases, "object", node, config)
			JTML.f.handle_alias.config(dynatext_objdef_alises, "object", single_style, obj_def)
		end
	end

	obj_def.string = node[1] or node.text
	obj_def.scale = obj_def.scale or 0.5
	config.object = DynaText(obj_def)

	local uinode = {n=G.UIT.O, config=config}
	return uinode
end

--#endregion
---------------------

--------------------
--#region SPRITES --
--------------------

local sprite_objdef_aliases = {
	XY = function (value, mode, style, obj_def)
		if type(value) ~= "table" then return end
		obj_def.X = value[1]
		obj_def.Y = value[2]
	end,
	WH = function (value, mode, style, obj_def)
		obj_def.W = value[1]
		obj_def.H = value[2]
	end,
	scale = function (value, mode, style, obj_def)
		if type(value) == "number" then
			obj_def.W = 2.4*obj_def.new_sprite_atlas.px/82*value
			obj_def.H = 2.4*obj_def.new_sprite_atlas.py/82*value
		elseif type(value) == "table" then
			obj_def.W = 2.4*obj_def.new_sprite_atlas.px/82*value[1]
			obj_def.H = 2.4*obj_def.new_sprite_atlas.py/82*value[2]
		end
	end,
}

JTML.sprite = function (node)
	local config = {}
	local obj_def = {}
	if not node.sprite then
		error("Sprite requires target sprite to render")
	end

	-- If atlas is directly specified, animation must also be specified
	local is_animated = node.sprite.animated
	if node.sprite.atlas_def then
		obj_def.new_sprite_atlas = node.sprite.atlas_def
	elseif G.ANIMATION_ATLAS[node.sprite.atlas] then
		is_animated = true
		obj_def.new_sprite_atlas = G.ANIMATION_ATLAS[node.sprite.atlas]
	elseif G.ASSET_ATLAS[node.sprite.atlas] then
		is_animated = false
		obj_def.new_sprite_atlas = G.ASSET_ATLAS[node.sprite.atlas]
	end

	obj_def.sprite_pos = {
		x = node.sprite.pos[1],
		y = node.sprite.pos[2]
	}

	JTML.f.handle_alias.config(object_config_aliases, "object", node, config)

	if node.style then
		if #node.style == 0 then node.style = {node.style} end
		for _,single_style in ipairs(node.style) do
			JTML.f.handle_alias.config(object_stylecfg_aliases, "object", node, config)
			JTML.f.handle_alias.config(sprite_objdef_aliases, "object", single_style, obj_def)
		end
	end

	config.object = (is_animated and AnimatedSprite or Sprite)(
		obj_def.X or 0,
		obj_def.Y or 0,
		obj_def.W or 2.4*obj_def.new_sprite_atlas.px/82,
		obj_def.H or 2.4*obj_def.new_sprite_atlas.py/82,
		obj_def.new_sprite_atlas,
		obj_def.sprite_pos or {x=0, y=0}
	)

	local uinode = {n=G.UIT.O, config=config}
	return uinode
end

--------------------
--#endregion

------------------
--#region HOOKS --
------------------

-- Remove temporary functions that are added by on_draw and on_click
local uiel_remove_hook = UIElement.remove
function UIElement:remove()
	if type(self.config.func) == "function" then
		G.FUNCS[self.config.func] = nil
	end
	if type(self.config.button) == "function" then
		G.FUNCS[self.config.button] = nil
	end
	uiel_remove_hook(self)
end

--#endregion
------------------

----------------------------
--#region LUA ANNOTATIONS --
----------------------------

---@class JTML.ALL.config
---@field id? string Used to allow `UIBox:get_UIE_by_ID(id)` to target the current node.
--- If prototype of an object, displays the name and description of said object,
--- otherwise follows definition for tooltip formatting.
---@field tooltip? JTML.tooltip_def|Center
---@field instance_type? 'NODE' | 'MOVEABLE' | 'SPRITE' | 'UIBOX' | 'POPUP' | 'CARD' | 'CARDAREA' | 'ALERT' | 'POPUP'
---@field on_draw? string|function|JTML.on_draw
---@field on_click? string|function|JTML.on_click
---@field reference? JTML.reference
---@field gamepad_focus? {button?: string, snap_to?: boolean, funnel_to?: boolean} Describes how gamepad inputs deal with the element.

---@class JTML.flex.config: JTML.ALL.config
---@field [1]? UINode[] A list of UINodes. Overrides `nodes`.
---@field nodes? UINode[] A list of UINodes. Overridden by [1].
--- Determines the node type that this node's children will be.
--- Roots, rows, and columns are re-set to the specified mode, and text, objects, and boxes are wrapped with the specified node.
--- Does not need to be set if node has no children, or node has one child, which is a non-flex object.
---@field mode? "row"|"column"
---@field self_mode? "root"|"row"|"column"
---@field style? JTML.flex.style|JTML.flex.style[]

---@class JTML.object.config: JTML.ALL.config
---@field [1]? Moveable The object to contain. Overrides `object`.
---@field object? Moveable The object to contain. Overridden by [1].
---@field role? "none"|JTML.moveable_role
---@field style? JTML.object.style|JTML.object.style[]

---@class JTML.text.config: JTML.ALL.config
---@field [1]? string|string[] The text to display. If list, text cycles through options. Overrides `text`.
---@field text? string|string[] The text to display. If list, text cycles through options. Overridden by [1].
---@field style? JTML.text.style|JTML.text.style[]
---@field role? "none"|JTML.moveable_role
---@field dyna? boolean If true, text is forced to be a DynaText.

---@class JTML.sprite.config: JTML.ALL.config
---@field sprite JTML.sprite_def The sprite to display.
---@field style? JTML.sprite.style|JTML.sprite.style[]


---@class JTML.ALL.style
---Of the form "<vert>-<hoz>"
---where <vert> is one of "top", "center", "bottom"
---and <hoz> is one of "left", "middle", "right".
---@field align? string
---@field padding? number The amount of space between a node's contents and its bounding edges.
---@field outline? JTML.outline_def
---@field shadow? true|Colour If true, add a black transparent shadow. If Colour, add a shadow with the specified colour.
---@field hover? boolean TODO figure this out

---@class JTML.flex.style: JTML.ALL.style
---@field WH? [number, number] First value corresponds to width; second value corresponds to height.
---@field maxWH? [number, number] First value corresponds to width; second value corresponds to height.
---@field noFill? boolean If true, children flexes will not match width/height of biggest sibling.
---@field roundCorners? boolean If true, corners are rounded; this is most visible if `colour`/`color` or `outline` are defined.
---@field emboss? number Determines how much the element is "raised", increasing visual depth.
---@field colour? Colour The colour of the element's background; use only this or only `color`.
---@field color? Colour The colour of the element's background; use only this or only `colour`.

---@class JTML.object.style: JTML.ALL.style
---@field WH? [number, number] First value corresponds to width; second value corresponds to height.
---@field colour? Colour The colour of the outline around the contained object; use only this or only `color`.
---@field color? Colour The colour of the outline around the contained object; use only this or only `colour`.

---@class JTML.text.style: JTML.ALL.style
--- The colour of the text; use only this or only `color`.
--- If this value is a list, letters are coloured in order of the colours, starting with the second colour.
---@field colour? Colour|Colour[]
--- The colour of the text; use only this or only `colour`. 
--- If this value is a list, letters are coloured in order of the colours, starting with the second colour.
---@field color? Colour|Colour[]
---@field scale? number The size of the text.
---@field verticalText? boolean If true, text is rendered vertically. (Currently does nothing if text is considered DynaText)
---@field lang? Language Font from the specified language is used for the text; overridden by `font`.
---@field font? Font The font to use for the text; overrides `lang`.
---@field rotation? number Rotates the entire text; units are in radians, positive is clockwise.
---@field spacing? number The distance of space between letters.
---@field curve? boolean If true, letters are each rotated so the entire string has a curve.
---@field popIn? JTML.popIn_def
--- First number is frequency of bumping, second number is height of bump.
--- If this value is true instead of a table, first number == 2.666, second number == 1.
---@field bump? true|[number, number]
---@field float? boolean If true, text has a wavy effect applied to it.
--- First number is speed of quiver, second number is strength of quiver.
--- If this value is a number instead of a table, it sets the strength of quiver, and speed == 0.5.
--- If this value is true, speed == 0.5 and strength == 0.7.
---@field quiver? true|number|[number, number]

---@class JTML.sprite.style: JTML.ALL.style
--- First number displaces sprite horizontally, second number displaces sprite vertically.
---@field XY? [number, number]
--- First number determines width, second number determines height.
--- Use only this or only `scale`.
---@field WH? [number, number]
--- If number, scales both width and height.
--- If table, first number scales width, second number scales height.
--- Use only this or only `WH`.
---@field scale number|[number, number]



---@class Colour
---@field [1] number Red channel, values from 0 to 1
---@field [2] number Green channel, values from 0 to 1
---@field [3] number Blue channel, values from 0 to 1
---@field [4] number Alpha channel, values from 0 to 1

---@class JTML.on_draw
---@field [1] string|function Strings are keys in G.FUNCS.
---@field insta? boolean TODO figure this out

---@class JTML.on_click
---@field [1] string|function Strings are keys in G.FUNCS.
---@field one_press? boolean If true, button can only be clicked once before being disabled.
---@field entangled_element? table Another element that is clicked if this element is clicked.
--- When this element is clicked, it is offset vertically to visually depict a button press;
--- this value determines the distance of that offset.
---@field hold_offset? number
---@field delay? number The number of seconds before the element can be clicked.

--{[1]: string|function, one_press: boolean, entangled_element: table, hold_offset: number, delay: number}

---@class JTML.reference
---@field [1] table
---@field [2] string|any A key in [1].

---@class JTML.tooltip_def
---@field title? string
---@field text? ( string | JTML.reference )[]
---@field filler? { func: function, args?: any }
--- If true, sets tooltip's Y position at the bottom of the element if at the top half,
--- or at the top of the element if at the bottom half.
---@field snap? boolean

---@class JTML.outline_def
---@field [1] number The thickness of the outline.
---@field [2]? Colour The colour of the outline; default is G.C.UI.OUTLINE_LIGHT.
---@field [3]? number Determines how much the outline is "raised", increasing visual depth.

---@class JTML.moveable_role
---@field role_type? string
---| "Major" # Movement not tied to any other moveable.
---| "Glued" # Strictly follows movement of its major moveable; then the object is considered minor.
---| "Minor" # A more configurable version of "Glued"; then the object is considered minor.
---@field major? Moveable If this object is minor, this is the moveable that the object will follow.
---@field offset? {x: number, y: number} If this object is minor, this defines the object's displacement relative to its major.
---@field xy_bond? JTML.moveable_role.strong_or_weak Related to the object's x and y (position) values.
---@field wh_bond? JTML.moveable_role.strong_or_weak Related to the object's w and h (relative size) values.
---@field r_bond? JTML.moveable_role.strong_or_weak Related to the object's r (rotation) value.
---@field scale_bond? JTML.moveable_role.strong_or_weak Related to the object's scale (size factor) value.
---@field draw_major? any TODO figure this out

---@alias JTML.moveable_role.strong_or_weak
---| "Strong" This property is copied exactly from the major moveable.
---| "Weak" This property is calculated by the object itself.

---@class JTML.popIn_def
---@field randomSelect? boolean If true, the list of strings given to the `text` node is picked from randomly instead of cycled through.
---@field delay? number
---@field rate? number How fast each letter pops in during the pop-in animation.
---@field minCycleTime? number TODO figure this out
---@field silent? boolean If true, letters do not click when popping in.
---@field pitchShift? number Added to the pitch of the next letter's pop-in sound. Positive - pitch increase. Negative - pitch decrease. Zero - constant pitch.

---@class JTML.sprite_def
--- A string in G.ASSET_ATLAS, G.ANIMATION_ATLAS, or SMODS.Atlases.
--- Attempts to automatically determine if atlas is animated.
---@field atlas? string
--- Coordinate of target sprite on the atlas.
--- First value is X, second value is Y. (0-indexed)
--- If atlas is animated, second value dictates which row on the animation atlas to use.
---@field pos? [number, number]
---@field atlas_def? SMODS.Atlas|table Overrides `atlas`.
---@field animated? boolean Must be specified if `atlas_def` is specified; if true, interpret `atlas_def` as an animation atlas.

--#endregion
----------------------------