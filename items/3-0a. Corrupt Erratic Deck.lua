SMODS.DynaTextEffect {
    key = "c_erratic_desc",
    func = function(dynatext, index, letter)
        local rnd = math.random(8, 127)
        local char = string.char(rnd)
        letter.letter = love.graphics.newText(dynatext.font.FONT, char)
    end
}

SMODS.Shader {
    key = "crt_override",
    path = "CRTOverride.fs",
}

--UTIL FUNCTIONS
function get_erratic_intensity(amount)
    local prog = G.GAME.round_resets.ante + (math.mod(G.GAME.round, 3) / 3)
    local n = amount or prog
    n = 2 ^ ((n ^ 0.6) - 1)
    n = n * math.max(1,(prog/6)^2)
    return n
end

local function pseudoerratic(seed)
    return (pseudorandom("c_erratic_" .. seed) * 2 - 1) * get_erratic_intensity()
end

local function ranged_pseudorandom(seed, min, max)
    return min + (pseudorandom(seed) * (max - min))
end

local function ui_rotation_drift(amount)
    for _, mov in pairs(G.I.MOVEABLE) do
        mov.T.r = mov.T.r + amount
    end
end


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

local function rgbtohsv(rgb)
    local mi = math.min
    local ma = math.max
    local hsv = { 0, 0, 0, 0 }
    local min = mi(rgb[1], mi(rgb[2], rgb[3]))
    local max = ma(rgb[1], ma(rgb[2], rgb[3]))
    local delta = max - min

    hsv[3] = max

    if max ~= 0 then
        hsv[2] = delta / max
    else
        hsv[2] = 0
        hsv[1] = -1
        return hsv
    end

    if max == rgb[1] then
        hsv[1] = (rgb[2] - rgb[3]) / delta
    elseif max == rgb[2] then
        hsv[1] = 2 + (rgb[3] - rgb[1]) / delta
    else
        hsv[1] = 4 + (rgb[1] - rgb[2]) / delta
    end
    hsv[1] = hsv[1] / 6
    if hsv[1] < 0 then
        hsv[1] = hsv[1] + 1
    end

    hsv[4] = rgb[4]
    return hsv
end

local function hsvtorgb(hsv)
    local rgb = { 0, 0, 0, 0 }

    local h = hsv[1] * 6
    local c = hsv[3] * hsv[2]
    local x = c * (1 - math.abs(math.mod(h, 2) - 1))
    local m = hsv[3] - c
    local a = hsv[4]

    if h < 1 then
        rgb = { c, x, 0, a }
    elseif h < 2 then
        rgb = { x, c, 0, a }
    elseif h < 3 then
        rgb = { 0, c, x, a }
    elseif h < 4 then
        rgb = { 0, x, c, a }
    elseif h < 5 then
        rgb = { x, 0, c, a }
    else -- h < 6
        rgb = { c, 0, x, a }
    end

    rgb[1] = rgb[1] + m
    rgb[2] = rgb[2] + m
    rgb[3] = rgb[3] + m

    return rgb
end

local red_hsv = rgbtohsv(HEX("ff2222"))

local function rtn(x, nearest)
    local function round(a) return math.floor(a + 0.5) end
    return round(x / nearest) * nearest
end

local t = 0
local function corrupt_text(text)
    local new = ""
    for i = 1, #text do
        t = t + 1
        local char = string.sub(text, i, i)
        math.randomseed(t - math.floor(G.TIMERS.REAL))
        if math.random(1, 2) == 1 then
            math.randomseed(t + math.floor(G.TIMERS.REAL * 9999)) --my signature Numbre.
            new = new .. string.char(string.byte(char) + math.random(-3, 3))
        else
            new = new .. char
        end
    end
    return new
end

local function erratic_randomize_deck(seed)
    local i = 0
    for _, card in pairs(G.deck.cards) do
        i = i + 1
        local suit = pseudorandom_element(SMODS.Suits, "c_erratic_suit"..seed).key
        local rank = pseudorandom_element(SMODS.Ranks, "c_erratic_rank"..seed).key
        local enhancement = SMODS.poll_enhancement({ key = "c_erratic_enhance"..seed, mod = 0.08 * i })
        local edition = SMODS.poll_edition({ key = "c_erratic_edition"..seed, mod = 0.08 * i })
        local seal = SMODS.poll_seal({ key = "c_erratic_seal"..seed, mod = 0.08 * i })

        SMODS.change_base(card, suit, rank)
        card:set_ability(enhancement or "c_base", true, true)
        card:set_edition(edition, true, true, false)
        card:set_seal(seal, true, true)
    end
end

function colour_drift(max_amount, start)
    start = start or G.C
    for key, entry in pairs(start) do
        if type(entry) == "table" then
            colour_drift(max_amount, entry)
        elseif type(entry) == "number" and key ~= 4 then
            start[key] = start[key] + (pseudorandom("c_e_colourdrift") * max_amount * 2) - max_amount
        end
    end
end

function set_glitch_vfx(er)
    er = get_erratic_intensity(er)
    G.GAME.erratic_fx_block_size = 2.5 * er
    G.GAME.erratic_fx_block_offset = 4.5 * er
    G.GAME.erratic_fx_block_probability = math.min(er / 40, 0.5)
    G.GAME.erratic_fx_matrix_lines = math.floor(er)

    local int = (er / 8)

    G.GAME.erratic_fx_matrix_intensity = math.min(int ^ 0.35, int)
end

-- UNCOMMENT TO RE-ENABLE

-- SMODS.Back {
local corrupt_erratic = { 
    key = "c_erratic",
    ovn_corrupt_deck = true,
    atlas = "cdeck_atlas",
    pos = { x = 4, y = 2 },

    unlocked = false,
    check_for_unlock = function(self, args)
        if achievement_get("erratic_eruption") then return true end
    end,

    apply = function(self)
        G.GAME.c_erratic = true -- good luck.
        G.GAME.override_crt = true
        G.GAME.erratic_fx_block_probability = 0
        G.GAME.erratic_fx_matrix_colour = HEX("00ff00")
        
        G.E_MANAGER:add_event(Event({
            func = function()
                
                erratic_randomize_deck("starting_deck")
                return true
            end
        }))
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval then
            -- vfx intensity changes

            if context.beat_boss then
                erratic_randomize_deck("post_boss")
            end

            local er = get_erratic_intensity()
            set_glitch_vfx(er)

            -- cardarea size changes
            local max_lost = 1
            local max_gained = 4
            for k, area in pairs(G.I.CARDAREA) do
                area:change_size(rtn(pseudoerratic("slots" .. k), 1 / er))
                local mod = area.config.card_limits.mod
                local base = area.config.card_limits.base
                local underflow = -math.min((base + mod) - (base - max_lost), 0)
                local overflow = -math.max((base + mod) - (base + max_gained), 0)
                area:change_size(underflow + overflow)
            end

            ease_dollars(pseudoerratic("money") * 3)
            colour_drift(0.002 * er)

            ui_rotation_drift(0.0005 * (pseudoerratic("drift1") * pseudoerratic("drift2")))
        end

        if context.setting_blind then
            ease_hands_played(pseudoerratic("hands"))
            ease_discard(pseudoerratic("hands"))
        end

        if context.destroying_card then
            if pseudorandom("cerratic_destruction") <= 0.05 then
                return { remove = true }
            end
        end

        if context.individual and context.cardarea == G.play and pseudorandom("cerratic_duplication") <= 0.05 then
            local copy = copy_card(context.other_card)
            G.hand:emplace(copy)
            copy:add_to_deck()
        end
    end,
}

-- HOOKS

local costhook = Card.set_cost

function Card:set_cost()
    local n = costhook(self)

    if G.GAME.c_erratic then
        self.cost = self.cost + pseudoerratic("cost")
        self.sell_cost = self.sell_cost + pseudoerratic("cost")
    end

    return n --dk if this does anything; might as well
end

local gba_hook = get_blind_amount
function get_blind_amount(ante)
    local chips = gba_hook(ante)
    if G.GAME.c_erratic then
        local er = get_erratic_intensity() + 0.05
        chips = chips * ranged_pseudorandom("chips", 1 / er, er)
    end
    return chips
end

local startrun_hook = Game.start_run
function Game:start_run(args)
    if self.C_BACKUP then
        self.C = self.C_BACKUP
    end

    G.C_BACKUP = deep_copy(G.C)

    return startrun_hook(self,args)
end


local mainmenu_hook = Game.main_menu
function Game:main_menu(context)
    if self.C_BACKUP then
        self.C = self.C_BACKUP
    end

    return mainmenu_hook(self,context)
end