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

	[".credits_text_container"] = {
		padding = 0.1
	},

	[".credits_text"] = {
		scale = 0.4,
		colour = G.C.UI.TEXT_LIGHT,
		padding = 0.05,
	},
	[".credits_body"] = {align = "center-middle"},
	[".credits_name"] = {colour = G.C.BLUE},
	[".left"] = {align = "center-right"},
	[".right"] = {align = "center-left"},
}

local function credits_names(loc_list)
	local entries = {}
	for _,credit_info in ipairs(loc_list) do
		local name = credit_info[1]
		table.insert(entries,
			{"row", class="left", style={padding=0}, { -- padding enables alignment
				{"text", class="credits_text credits_name", text=name}
			}}
		)
	end

	return
	{"column", class="credits_text_container left", entries}
end

local function credits_desc(loc_list)
	local entries = {}
	for _,credit_info in ipairs(loc_list) do
		local description = credit_info[2]
		table.insert(entries,
			{"row", class="right", style={padding=0}, {
				{"text", class="credits_text", text=description}
			}}
		)
	end

	return
	{"column", class="credits_text_container right", entries}
end

local function header(text)
	return
	{"row", style={align="center-middle"}, {
		{"row", class="credits_header", {
			{"text", class="credits_header_text", text=text}
		}}
	}}
end

function Ovn_f.credits_ui()
	local credits_ui =
	{"root", class="credits_ui_style", {
		header(localize("k_primary_contributors")),
		{"row", class="credits_body", {
			credits_names(G.localization.misc.credits),
			credits_desc(G.localization.misc.credits)
		}},
		header(localize("k_additional_credits")),
		{"row", class="credits_body", {
			credits_names(G.localization.misc.credits_additional),
			credits_desc(G.localization.misc.credits_additional)
		}},
	}}

	return Ovn_f.jtml_to_uiboxdef(credits_ui, credits_ui_style)
end