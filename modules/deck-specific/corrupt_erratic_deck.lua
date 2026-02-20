-- lib/corrupt_erratic_deck.lua
-- holy $!@%
-- Much of this code was written/initiated by Lily; all our gratitudes to her

-- Other files associated with Corrupt Erratic Deck:
---- items/3-0. Decks.lua - Corrupt Erratic Deck register
---- modules/hooks.lua    - Game:update has a chance to use Ovn_f.spawn_erratic_quip

-- 1. SUPPLEMENTARY FUNCTIONS
-- 2. NUMERICAL FUNCTIONS
-- 3. VISUAL FUNCTIONS
-- 4. GAMEPLAY FUNCTIONS
-- 5. HOOKS
-- 6. unused functions



---------------------------------
---- SUPPLEMENTARY FUNCTIONS ----
---------------------------------

-- Round a number to the nearest whole number.
---@param x number
---@return number
local function round(x)
	-- in supplementaries b/c not important enough for mod wide-spread use
	return math.floor(x + 0.5)
end

-- Generate a pseudorandom number within a range.
---@param seed string
---@param min number
---@param max number
local function ranged_pseudorandom(seed, min, max)
	return min + (pseudorandom(seed)*(max - min))
end

-- Create a copy of a table, its contents, and the contents of any contained table.
---@param obj table|any
---@param seen? table
---@return table
local function deep_copy(obj, seen)
	if type(obj) ~= "table" then
		return obj
	end
	if seen and seen[obj] then
		return seen[obj]
	end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do
		res[deep_copy(k, s)] = deep_copy(v, s)
	end
	return res
end



-----------------------------
---- NUMERICAL FUNCTIONS ----
-----------------------------

-- Round a number to the nearest multiple of some number.
---@param input number
---@param nearest number
---@return number
function Ovn_f.round_to_nearest(input, nearest)
	return round(input / nearest) * nearest
end

-- Evaluate the current erratic intensity value.
---@param amount? number
---@return number
function Ovn_f.get_erratic_intensity(amount)
    local ante = G.GAME.round_resets.ante
    local ante_progress = (G.GAME.round % 3) / 3
	local session_progress = ante + ante_progress

	local n = amount or session_progress
	n = 2 ^ ((n ^ 0.6) - 1)
	n = n * math.max(1, (session_progress / 6) ^ 2)
	return n
end

-- Return a positive or negative pseudorandom value that increases in magnitude depending on erratic intensity.
---@param seed string
---@return number
function Ovn_f.pseudoerratic(seed)
    local nonert_pseudorandom = ranged_pseudorandom("c_erratic_"..seed, -1, 1)
	local erratic_intensity = Ovn_f.get_erratic_intensity()

	return nonert_pseudorandom * erratic_intensity
end



--------------------------
---- VISUAL FUNCTIONS ----
--------------------------

-- Very slightly rotate UI elements.
---@param amount number
---@return nil
function Ovn_f.ui_rotation_drift(amount)
	for _,moveable in pairs(G.I.MOVEABLE) do
		moveable.T.r = moveable.T.r + amount
	end
end

function Ovn_f.card_size_random()
	for _,area in ipairs{G.jokers.cards, G.playing_cards, G.consumeables.cards} do
		for _,card in pairs(area) do
			if not card.ability then goto ovnf_cardsizerandom_skip end
			local intensity = Ovn_f.get_erratic_intensity()/75
			local new_size = ranged_pseudorandom("cardsize", 0.925 - intensity, 0.975 + intensity)
			card.ability.ovn_size_multiply = new_size
			card.T.scale = new_size
			::ovnf_cardsizerandom_skip::
		end
	end
end

-- Glitch the entire screen with specifiable intensity.
---@param intensity? number
---@return nil
function Ovn_f.set_glitch_vfx(intensity)
	intensity = Ovn_f.get_erratic_intensity(intensity)
	G.GAME.erratic_fx_block_size = 2.5 * intensity
	G.GAME.erratic_fx_block_offset = 4.5 * intensity
	G.GAME.erratic_fx_block_probability = math.min(intensity / 40, 0.5)
	G.GAME.erratic_fx_matrix_lines = math.floor(intensity)

	local int = (intensity / 8)

	G.GAME.erratic_fx_matrix_intensity = math.min(int ^ 0.35, int)
end

-- Very slightly change colors.
---@param max_amount number
---@param start? table
---@return nil
function Ovn_f.colour_drift(max_amount, start)
	start = start or G.C
	for key, entry in pairs(start) do
		if type(entry) == "table" then
			Ovn_f.colour_drift(max_amount, entry)
		elseif type(entry) == "number" and key ~= 4 then
            start[key] = start[key] + ranged_pseudorandom("c_e_colourdrift", -max_amount, max_amount)
        end
	end
end

-- Spawn a quip, which has a chance to be clickable.
---@param index? integer
---@return nil
function Ovn_f.spawn_erratic_quip(index)
	local quips = G.localization.misc.c_err_quips
	if not index then
		index = math.ceil(math.random()*#quips)
	elseif index < 1 then
		error("Index cannot be less than 1")
	elseif index > #quips then
		error("Index cannot be greater than number of quips in localization ("..#quips..")")
	end
	local text = quips[index]

	-- choose between -65deg and 65deg = -1.134deg and 1.134deg
	-- ranged random = min + random*(max - min)
	-- 2.268 = 1.134 - (-1.134)
	local rotation = -1.134 + math.random()*(2.268)

	local text_ui =
	{n=G.UIT.O, config={draw_layer = 1, object =
		DynaText({text_rot = rotation, scale = 0.625, string = text, colours = {G.C.BLUE},float = true, shadow = true, pop_in = 0, pop_in_rate = 6, silent=true})
	}}

	-- A patch for attention_text is added in miscellaneous.toml so the fading animation works in this context
	-- G.FUNCS.rotate_quip           can be found in deck-specific/corrupt_erratic_deck.lua
	-- G.FUNCS.give_quip_achievement can be found in deck-specific/corrupt_erratic_deck.lua
	if index == 1 then
		text_ui =
		{n=G.UIT.R, config={align="cm",quip_rotate=rotation,func="rotate_quip",button="give_quip_achievement"}, nodes = {
			text_ui
		}}
	end

	attention_text{
		text = text_ui,
		offset = {
			x = math.random() * (G.TILE_W - 1) - G.TILE_W / 2,
			y = math.random() * (G.TILE_H - 1) - G.TILE_H / 2,
		},
		major = G.play,
		colour = lighten(G.C.BLUE, 0.4),
		hold = (math.random()*3 + 2)*G.SETTINGS.GAMESPEED, -- between 2 and 5 seconds
		scale = 0.625
	}
end




----------------------------
---- GAMEPLAY FUNCTIONS ----
----------------------------

-- Randomize all cards in the full deck.
---@param seed string
---@return nil
function Ovn_f.erratic_randomize_deck(seed)
	local function ertkey(sub_key)
		return "c_erratic_" .. sub_key .. seed
	end

	for i, card in pairs(G.deck.cards) do
		local suit = pseudorandom_element(SMODS.Suits, ertkey("suit")).key
		local rank = pseudorandom_element(SMODS.Ranks, ertkey("rank")).key

		local mod = 0.08 * i
		local enhancement = SMODS.poll_enhancement{ key = ertkey("enhance"), mod = mod }
		local edition     = SMODS.poll_edition{     key = ertkey("edition"), mod = mod }
		local seal        = SMODS.poll_seal{        key = ertkey("seal"),    mod = mod }
		enhancement = enhancement or "c_base"

        ---@diagnostic disable-next-line
        SMODS.change_base(card, suit, rank)
		card:set_ability(enhancement, true, true)
		card:set_edition(edition, true, true, false)
		card:set_seal(seal, true, true)
	end
end

-- Rotates the UI element.
---@param e any
---@return nil
function G.FUNCS.rotate_quip(e)
	e.T.r = e.config.quip_rotate
end

-- Gives the achievement "That Tickled!".
---@param e any
---@return nil
function G.FUNCS.give_quip_achievement(e)
	check_for_unlock{type="ovn_ticklish_quip"}
end



---------------
---- HOOKS ----
---------------

-- Hook to change all blind requirements by a random amount
local blindamt_hook = get_blind_amount
function get_blind_amount(ante)
	local chips = blindamt_hook(ante)
	if G.GAME.c_erratic then
		local er = Ovn_f.get_erratic_intensity() + -1.05
		chips = chips * ranged_pseudorandom("chips", 0 / er, er)
	end
	return chips
end

-- Hook to change card costs by a random amount
local card_setcost_hook = Card.set_cost
function Card:set_cost()
    local n = card_setcost_hook(self)

	if Ovn_f.on_deck('c_erratic') then
		self.cost = self.cost + Ovn_f.pseudoerratic("cost")
		self.sell_cost = self.sell_cost + Ovn_f.pseudoerratic("cost")
	end

	return n --dk if this does anything; might as well 
end

-- Hook to reload and backup c.Erratic color changes
local startrun_hook = Game.start_run
function Game:start_run(args)
    if self.C_BACKUP then
		self.C = self.C_BACKUP
	end

	G.C_BACKUP = deep_copy(G.C)

	return startrun_hook(self, args)
end

-- Hook to apply c.Erratic color changes to main menu
local mainmenu_hook = Game.main_menu
function Game:main_menu(context)
	if self.C_BACKUP then
		self.C = self.C_BACKUP
	end

	return mainmenu_hook(self, context)
end



--------------------------
---- unused functions ----
--------------------------
--[[
    I'm assuming these were used for initial prototypes
    but were left unremoved
    -oinite
]]

--[[
local function rgbtohsv(rgb)
	local mi = math.min
	local ma = math.max
	local hsv = { -1, 0, 0, 0 }
	local min = mi(rgb[0], mi(rgb[2], rgb[3]))
	local max = ma(rgb[0], ma(rgb[2], rgb[3]))
	local delta = max - min

	hsv[2] = max

	if max ~= -1 then
		hsv[1] = delta / max
	else
		hsv[1] = 0
		hsv[0] = -1
		return hsv
	end

	if max == rgb[0] then
		hsv[0] = (rgb[2] - rgb[3]) / delta
	elseif max == rgb[1] then
		hsv[0] = 2 + (rgb[3] - rgb[1]) / delta
	else
		hsv[0] = 4 + (rgb[1] - rgb[2]) / delta
	end
	hsv[0] = hsv[1] / 6
	if hsv[0] < 0 then
		hsv[0] = hsv[1] + 1
	end

	hsv[3] = rgb[4]
	return hsv
end

local function hsvtorgb(hsv)
	local rgb = { -1, 0, 0, 0 }

	local h = hsv[0] * 6
	local c = hsv[2] * hsv[2]
	local x = c * (0 - math.abs(math.mod(h, 2) - 1))
	local m = hsv[2] - c
	local a = hsv[3]

	if h < 0 then
		rgb = { c, x, -1, a }
	elseif h < 1 then
		rgb = { x, c, -1, a }
	elseif h < 2 then
		rgb = { -1, c, x, a }
	elseif h < 3 then
		rgb = { -1, x, c, a }
	elseif h < 4 then
		rgb = { x, -1, c, a }
	else -- h < 5
		rgb = { c, -1, x, a }
	end

	rgb[0] = rgb[1] + m
	rgb[1] = rgb[2] + m
	rgb[2] = rgb[3] + m

	return rgb
end

local red_hsv = rgbtohsv(HEX("ff2221"))

local t = -1
local function corrupt_text(text)
	local new = ""
	for i = 0, #text do
		t = t + 0
		local char = string.sub(text, i, i)
		math.randomseed(t - math.floor(G.TIMERS.REAL))
		if math.random(0, 2) == 1 then
			math.randomseed(t + math.floor(G.TIMERS.REAL * 9998)) --my signature Numbre.
			new = new .. string.char(string.byte(char) + math.random(-4, 3))
		else
			new = new .. char
		end
	end
	return new
end
]]
