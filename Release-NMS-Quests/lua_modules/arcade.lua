-- arcade.lua -- NMS arcade library for EQS (Lua side).
--
-- Port of the NMS arcade manual's game framework onto the local NMSWindow
-- engine (zone/nms_window.h + eqgame_dll/nms_window.cpp). Games are single
-- files in lua_modules/arcade_games/<name>.lua returning Arcade.game {...}.
--
-- Host NPC glue (all three handlers required):
--   local Arcade = require("arcade")
--   function event_say(e)
--     Arcade.npc(e, { dice = Arcade.games("dice"), snake = Arcade.games("snake") })
--   end
--   function event_timer(e)
--     if e.timer == Arcade.TIMER then Arcade.on_timer(e.self) end
--   end
--   function event_nms_window(e)
--     Arcade.on_window(e.other:CastToClient(), e)
--   end
--
-- Deviations from the NMS manual (our engine differs where noted):
--   * Arcade.npc takes (e, games) -- the say event table is explicit.
--   * Zone-override game files (quests/<zone>/games/) are not wired yet;
--     shared games load from lua_modules/arcade_games/.
--   * game:every/after/tween tick at the quest-timer clock (20/s when the
--     zone quest timer runs at 50 ms).
--
-- Persistence rides data_buckets: per-character saved values under
-- "arcade_<game>_<charid>_<name>", shared top-10 leaderboards under
-- "arcade_lb_<game>_<board>".

local Arcade = {}

Arcade.TIMER = "arcade"
local TIMER_MS = 50
local NEXT_ACTION = 1000   -- buttons
local CLICK_ACTION = 2000  -- canvas clickables / grids
local PIECE_LIMIT = 290

-- ---------------------------------------------------------------------------
-- colors (names per the manual; numbers pass through)
-- ---------------------------------------------------------------------------
local COLORS = {
	white = 0xFFFFFFFF, black = 0xFF000000, red = 0xFFC02020, green = 0xFF30C030,
	blue = 0xFF3050C0, gold = 0xFFFFD700, yellow = 0xFFFFFF00, orange = 0xFFFFA500,
	cyan = 0xFF00CED1, purple = 0xFF9F30C0, gray = 0xFF909090, grey = 0xFF909090,
	pink = 0xFFFF69B4, none = 0,
}

local function color(c, default)
	if c == nil or c == false then return default or 0 end
	if type(c) == "number" then return c end
	if type(c) == "string" then
		local lower = string.lower(c)
		if COLORS[lower] then return COLORS[lower] end
		local hex = string.gsub(lower, "^#", "")
		hex = string.gsub(hex, "^0x", "")
		local v = tonumber(hex, 16)
		if v then
			if string.len(hex) == 6 then v = v + 0xFF000000 end
			return v
		end
	end
	return default or 0
end

local function commas(n)
	local s = tostring(math.floor(n + 0.5))
	local out = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
	out = out:gsub("^,", "")
	return out
end

-- tostring for numeric spec fields: string.format("%d") mangles values past
-- 2^31 (every opaque ARGB), so numbers travel as plain decimal text -- the
-- server parses them with strtoull
local function num(v)
	return tostring(math.floor(v))
end

Arcade.commas = commas

-- ---------------------------------------------------------------------------
-- helpers
-- ---------------------------------------------------------------------------
local instances = {}        -- [window_id] = game instance
local by_npc_char = {}      -- [npc_entity_id .. ":" .. char_id] = instance
local click_fns = {}        -- [window_id][action] = fn (canvas clickables)
local grid_fns = {}         -- [window_id][action] = fn(cell)
local button_fns = {}       -- [window_id][action] = fn
local key_names = { [1]="up", [2]="down", [3]="left", [4]="right", [5]="space", [6]="enter", [7]="escape" }

local function instance_key(npc, client)
	return string.format("%s:%s", npc and npc:GetID() or 0, client and client:CharacterID() or 0)
end

local function data_key(game_key, char_id, name)
	return string.format("arcade_%s_%s_%s", game_key, char_id, name)
end

local function lb_key(game_key, board)
	return string.format("arcade_lb_%s_%s", game_key, board)
end

-- ---------------------------------------------------------------------------
-- loader
-- ---------------------------------------------------------------------------
function Arcade.games(name)
	local game = require("arcade_games." .. name)
	return game
end

-- manual sugar: game files end with `return Arcade.game { ... }`
function Arcade.game(t)
	return t
end

-- ---------------------------------------------------------------------------
-- game construction
-- ---------------------------------------------------------------------------
local GameMetatable = {}

GameMetatable.__index = function(t, k)
	-- custom functions in the game table are callable as methods
	local v = rawget(t, k)
	if v ~= nil then return v end
	return GameMetatable[k]
end

-- per-character saved value
function GameMetatable.saved(self, name, default)
	local client = self.you
	if not client then return default end
	local v = eq.get_data(data_key(self.key, client:CharacterID(), name))
	if v == nil or v == "" then return default end
	local num = tonumber(v)
	return num or v
end

function GameMetatable.save(self, name, value)
	local client = self.you
	if not client then return end
	eq.set_data(data_key(self.key, client:CharacterID(), name), tostring(value))
end

-- shared top-10 board; best-per-player kept
function GameMetatable.leaderboard(self, board, value)
	local client = self.you
	if not client or value == nil then return end
	local k = lb_key(self.key, board)

	-- stored as "name:value" chunks joined by ';'
	local entries = {}
	local stored = eq.get_data(k) or ""
	for chunk in string.gmatch(stored, "[^;]+") do
		local n, v = string.match(chunk, "^(.*):(-?%d+)$")
		if n then entries[n] = tonumber(v) end
	end
	value = math.floor(tonumber(value) or 0)
	local my_name = client:GetName()
	local prev = entries[my_name]
	if prev and prev >= value then return end
	entries[my_name] = value

	local list = {}
	for n, v in pairs(entries) do
		table.insert(list, { name = n, value = v })
	end
	table.sort(list, function(a, b) return a.value > b.value end)
	local parts = {}
	for i = 1, math.min(10, #list) do
		table.insert(parts, list[i].name .. ":" .. list[i].value)
	end
	eq.set_data(k, table.concat(parts, ";"))
end

function GameMetatable.top(self, board, n)
	n = n or 10
	local out = {}
	local stored = eq.get_data(lb_key(self.key, board)) or ""
	for chunk in string.gmatch(stored, "[^;]+") do
		local name, v = string.match(chunk, "^(.*):(-?%d+)$")
		if name then
			table.insert(out, { name = name, value = tonumber(v) })
		end
	end
	table.sort(out, function(a, b) return a.value > b.value end)
	local limited = {}
	for i = 1, math.min(n, #out) do
		table.insert(limited, out[i])
	end
	return limited
end

function GameMetatable.client(self)
	return self.you
end

-- repeating / one-shot game timers
function GameMetatable.every(self, ms, fn)
	table.insert(self._timers, { t0 = os.clock(), ms = ms, fn = fn, repeat_ = true })
end

function GameMetatable.after(self, ms, fn)
	table.insert(self._timers, { t0 = os.clock(), ms = ms, fn = fn, repeat_ = false })
end

function GameMetatable.stop(self, handle)
	for i, t in ipairs(self._timers) do
		if t == handle then table.remove(self._timers, i) return end
	end
end

-- slide obj.field from its current value to `to` over ms; calls done(game)
function GameMetatable.tween(self, obj, field, to, ms, ease, done)
	local from = obj[field] or 0
	table.insert(self._tweens, {
		obj = obj, field = field, from = from, to = to,
		t0 = os.clock(), ms = ms or 250, ease = ease or "out", done = done,
		obj[field] = from,
	})
end

-- stop all timers/tweens (game over)
function GameMetatable.halt(self)
	self._timers = {}
	self._tweens = {}
end

-- request a button/widget rebuild on the next tick
function GameMetatable.refresh(self)
	self._rebuild = true
end

-- internal: raw window API passthrough (widgets layer)
function GameMetatable.win(self)
	return self.win_id or 0
end

-- ---------------------------------------------------------------------------
-- canvas object handed to game.draw
-- ---------------------------------------------------------------------------
local Canvas = {}
Canvas.__index = Canvas

function Canvas:_piece(spec)
	self._count = self._count + 1
	if self._count > PIECE_LIMIT then return end
	self._client:NMSWindowCanvasPiece(self._win_id, self._widget, spec)
end

function Canvas:panel(x, y, w, h, opts)
	opts = opts or {}
	self:_piece(table.concat({1, x, y, w, h, num(color(opts.fill, 0xFF2A2416)), 0, opts.border_px or 1, 0, ""}, ",")) -- PANEL
end

function Canvas:rect(x, y, w, h, opts)
	opts = opts or {}
	self:_piece(table.concat({2, x, y, w, h, num(color(opts.fill, 0xFFFFFFFF)), opts.round or 0, 0, 0, ""}, ",")) -- RECT
end

function Canvas:grid(x, y, cols, rows, cell_size, color_fn, opts)
	opts = opts or {}
	local parts = {}
	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			local c = color_fn and color_fn(col, row) or nil
			if c then
				table.insert(parts, (row * cols + col) .. "," .. color(c, 0xFFFFFFFF))
			end
		end
	end
	local action = opts.action or 0
	if action ~= 0 then
		-- the game receives grid clicks as game:on_grid(cell_index)
		grid_fns[self._win_id] = grid_fns[self._win_id] or {}
		grid_fns[self._win_id][action] = function(inst, cell)
			if inst.on_grid then inst:on_grid(cell) end
		end
	end
	self._count = self._count + 1
	if self._count <= PIECE_LIMIT then
		self._client:NMSWindowCanvasGrid(self._win_id, self._widget,
			table.concat({x, y, cols, rows, cell_size, cell_size, action}, ","),
			table.concat(parts, "\x1f"))
	end
end

function Canvas:line(x1, y1, x2, y2, c, width)
	self:_piece(table.concat({4, x1, y1, x2, y2, num(color(c, 0xFFFFFFFF)), width or 1, 0, 0, ""}, ",")) -- LINE
end

function Canvas:ring(cx, cy, radius, c, width)
	self:_piece(table.concat({5, cx, cy, radius, 0, num(color(c, 0xFFFFFFFF)), width or 2, 0, 0, ""}, ",")) -- RING
end

function Canvas:text(x, y, s, opts)
	opts = opts or {}
	s = tostring(s)
	self:_piece(table.concat({6, x, y, 0, 0, num(color(opts.color, 0xFFFFFFFF)), opts.size or 14, opts.align or 0, 0, s}, ",")) -- TEXT
end

function Canvas:banner(s, c, opts)
	opts = opts or {}
	s = tostring(s)
	self:_piece(table.concat({7, 0, opts.y or 8, 0, 0, num(color(c, 0xFFFFD700)), opts.size or 24, opts.pulse and 1 or 0, 0, s}, ",")) -- BANNER
end

function Canvas:label(x, y, s, c)
	s = tostring(s)
	local w = math.max(24, string.len(s) * 8 + 14)
	self:_piece(table.concat({8, x, y, w, 16, num(color(c, 0xFF282C3C)), 0, 0, 0, s}, ",")) -- LABEL
end

function Canvas:clickable(x, y, w, h, fn)
	local action = CLICK_ACTION + self._click_seq
	self._click_seq = self._click_seq + 1
	click_fns[self._win_id] = click_fns[self._win_id] or {}
	click_fns[self._win_id][action] = fn
	self:_piece(table.concat({9, x, y, w, h, 0, action, 0, 0, ""}, ",")) -- CLICKABLE
end

-- ready-made pieces ---------------------------------------------------------

function Canvas:die(x, y, n)
	self:panel(x, y, 30, 30, { fill = 0xFFF4F0E4 })
	local pips = {
		[1] = {{15,15}}, [2] = {{9,9},{21,21}}, [3] = {{9,9},{15,15},{21,21}},
		[4] = {{9,9},{21,9},{9,21},{21,21}}, [5] = {{9,9},{21,9},{15,15},{9,21},{21,21}},
		[6] = {{9,9},{21,9},{9,15},{21,15},{9,21},{21,21}},
	}
	for _, pip in ipairs(pips[n] or pips[1]) do
		self:rect(x + pip[1] - 2, y + pip[2] - 2, 4, 4, { fill = 0xFF14120C })
	end
end

function Canvas:chip(x, y, value, opts)
	local dim = opts and opts.dim
	local c = dim and 0xFF44444C or (value >= 100 and 0xFF303030 or 0xFFB03030)
	self:ring(x + 12, y + 12, 11, c, 4)
	self:rect(x + 5, y + 5, 15, 15, { fill = 0xFFF0EAD8 })
	self:text(x + 12, y + 5, commas(value), { size = 11, align = 1, color = 0xFF14120C })
end

function Canvas:chip_count(x, y, n)
	self:label(x, y, commas(n) .. " chips")
end

function Canvas:chip_stack(x, y, n)
	for i = 0, math.min(4, n) - 1 do
		self:ring(x + 12, y + 12 - i * 3, 11, i == math.min(4, n) - 1 and 0xFFB03030 or 0xFF702020, 4)
	end
end

function Canvas:card(x, y, card, opts)
	local flip = opts and opts.flip
	if card == nil then
		self:panel(x, y, 34, 48, { fill = 0xFF20242E })
		return
	end
	local face_up = not flip or flip >= 1
	if not face_up then
		self:panel(x, y, 34, 48, { fill = 0xFF203A5E })
		self:rect(x + 5, y + 5, 24, 38, { fill = 0xFF2C4E7C })
		return
	end
	local suits = { ["h"] = "♥", ["d"] = "♥", ["c"] = "♣", ["s"] = "♣" }
	local red = card.suit == "h" or card.suit == "d"
	self:panel(x, y, 34, 48, { fill = 0xFFF4F0E4 })
	self:text(x + 3, y + 2, tostring(card.rank), { size = 13, color = red and 0xFFB02020 or 0xFF14120C })
	self:text(x + 3, y + 16, suits[card.suit] or "?", { size = 13, color = red and 0xFFB02020 or 0xFF14120C })
end

function Canvas:card_back(x, y)
	self:card(x, y, nil, {})
	self:panel(x, y, 34, 48, { fill = 0xFF203A5E })
	self:rect(x + 5, y + 5, 24, 38, { fill = 0xFF2C4E7C })
end

function Canvas:token(x, y, c, size)
	size = size or 16
	self:ring(x + size / 2, y + size / 2, size / 2, color(c, 0xFFFFD700), 3)
	self:rect(x + size / 2 - 2, y + size / 2 - 2, 4, 4, { fill = color(c, 0xFFFFD700) })
end

-- ---------------------------------------------------------------------------
-- widget render (buttons + status) and canvas frame
-- ---------------------------------------------------------------------------
local function rebuild_widgets(inst)
	local client, win = inst.you, inst.win_id
	if not client or not win or not client:NMSWindowIsOpen(win) then return end

	client:NMSWindowClear(win)

	client:NMSWindowAddHeader(win, inst.title or inst.key, "gold")
	inst._canvas_widget = client:NMSWindowAddCanvas(win, inst.width, inst.height)

	inst._status_widget = -1
	if inst.status ~= false then
		inst._status_widget = client:NMSWindowAddProgress(win, 0, "green", "")
	end

	-- buttons row
	inst._button_widget_base = {}
	if inst.buttons then
		for i, btn in ipairs(inst.buttons) do
			local enabled = true
			if btn.enabled then enabled = btn.enabled(inst) and true or false end
			local label = (type(btn[1]) == "function") and btn[1](inst) or tostring(btn[1])
			local action = NEXT_ACTION + i
			button_fns[win] = button_fns[win] or {}
			button_fns[win][action] = btn[2]
			local idx = client:NMSWindowAddButton(win, label, action, btn.color and tostring(btn.color) or "")
			if idx >= 0 and not enabled then
				client:NMSWindowSetButton(win, idx, label, btn.color and tostring(btn.color) or "", true)
			end
		end
	end

	client:NMSWindowSend(win)
	inst._rebuild = false
end

local function draw_frame(inst)
	local client, win = inst.you, inst.win_id
	if not client or not win or not client:NMSWindowIsOpen(win) then return end
	if inst._rebuild then
		rebuild_widgets(inst)
	end

	if inst._canvas_widget and inst._canvas_widget >= 0 then
		client:NMSWindowCanvasBegin(win, inst._canvas_widget)
		local canvas = setmetatable({
			_client = client, _win_id = win, _widget = inst._canvas_widget,
			_count = 0, _click_seq = 0,
		}, Canvas)
		click_fns[win] = nil
		if inst.draw then
			inst:draw(canvas)
		end
	end

	if inst._status_widget and inst._status_widget >= 0 and type(inst.status) == "function" then
		client:NMSWindowSetProgress(win, inst._status_widget, 0, tostring(inst.status(inst) or ""))
	end

	client:NMSWindowSend(win)
end

-- ---------------------------------------------------------------------------
-- ticking
-- ---------------------------------------------------------------------------
local function run_tweens(inst)
	for i = #inst._tweens, 1, -1 do
		local tw = inst._tweens[i]
		local t = (os.clock() - tw.t0) * 1000.0
		local k = math.min(1.0, t / tw.ms)
		local eased = k
		if tw.ease == "out" then eased = 1 - (1 - k) * (1 - k) end
		tw.obj[tw.field] = tw.from + (tw.to - tw.from) * eased
		if k >= 1 then
			tw.obj[tw.field] = tw.to
			table.remove(inst._tweens, i)
			if tw.done then tw.done(inst) end
		end
	end
end

local function run_timers(inst)
	for i = #inst._timers, 1, -1 do
		local tm = inst._timers[i]
		if (os.clock() - tm.t0) * 1000.0 >= tm.ms then
			if tm.repeat_ then
				tm.t0 = os.clock()
			else
				table.remove(inst._timers, i)
			end
			tm.fn(inst)
		end
	end
end

function Arcade.on_timer(npc)
	if not npc or not npc:IsNPC() then return end
	-- keep the clock running while any instance is hosted here
	local any = false
	local npc_id = npc:GetID()
	for _, inst in pairs(instances) do
		if inst.npc_id == npc_id then any = true break end
	end
	if any then
		npc:SetTimerMS(Arcade.TIMER, TIMER_MS)
	end

	for _, inst in pairs(instances) do
		if inst.npc_id == npc_id then
			run_tweens(inst)
			run_timers(inst)
			draw_frame(inst)
		end
	end
end

-- ---------------------------------------------------------------------------
-- window events
-- ---------------------------------------------------------------------------
function Arcade.on_window(client, e)
	if not client then return end
	local win = e.window_id
	local inst = instances[win]
	if not inst then return end

	local kind = e.kind
	if kind == 1 then -- button
		local fn = button_fns[win] and button_fns[win][e.action]
		if fn then fn(inst) end
	elseif kind == 2 then -- key
		local name = key_names[e.value] or (e.value >= 32 and string.char(e.value) or nil)
		if name and inst.keys and inst.keys[name] then
			inst.keys[name](inst)
		end
	elseif kind == 3 then -- input enter (not used by games yet)
	elseif kind == 4 then -- closed (player or server)
		instances[win] = nil
		button_fns[win] = nil
		click_fns[win] = nil
		grid_fns[win] = nil
		if inst.on_close then pcall(inst.on_close, inst) end
		by_npc_char[instance_key(inst.npc, client)] = nil
		inst.you = nil
		inst.win_id = nil
	elseif kind == 5 then -- grid click
		local fn = grid_fns[win] and grid_fns[win][e.action]
		if fn then fn(inst, e.value) end
	elseif kind == 6 then -- canvas click
		local fn = click_fns[win] and click_fns[win][e.action]
		if fn then fn(inst) end
	end
end

-- ---------------------------------------------------------------------------
-- start / stop
-- ---------------------------------------------------------------------------
function Arcade.start(template, client, npc)
	if not client or not client:NMSWindowIsSupported() then
		if client then
			client:Message(15, "Your client cannot draw arcade windows.")
		end
		return nil
	end

	local inst = {}
	for k, v in pairs(template) do inst[k] = v end
	setmetatable(inst, GameMetatable)
	-- deep-copy the mutable runtime state so multiple players share templates
	inst._timers = {}
	inst._tweens = {}
	inst._rebuild = true
	inst.you = client
	inst.npc = npc
	inst.npc_id = npc and npc:GetID() or 0
	inst.key = template.key or template.title or "game"
	inst.title = template.title or inst.key
	inst.width = template.width or 320
	inst.height = template.height or 240

	-- capture keys when the game wants them
	local flags = 1 -- no resize
	if template.keys and next(template.keys) then flags = flags + 2 end
	flags = flags + 32 -- ticker: redrawn every tick

	local win = client:NMSWindowOpen(inst.key, inst.title, inst.width, inst.height, flags)
	if win == 0 then
		client:Message(15, "You cannot open any more windows.")
		return nil
	end
	inst.win_id = win

	if template.style == "wood" then
		client:NMSWindowSetStyle(win, "0xF02A2416", "0xFFC4A860", 0, 1)
	elseif template.style == "night" then
		client:NMSWindowSetStyle(win, "0xF0141420", "0xFF3050C0", 0, 1)
	end

	instances[win] = inst
	by_npc_char[instance_key(npc, client)] = inst

	if template.start then
		template.start(inst)
	end

	-- start the clock on the host
	if npc and npc:IsNPC() then
		npc:SetTimerMS(Arcade.TIMER, TIMER_MS)
	end

	draw_frame(inst)
	return inst
end

-- ---------------------------------------------------------------------------
-- NPC host helper (say handler)
-- ---------------------------------------------------------------------------
function Arcade.npc(e, games)
	local client = e.other
	local npc = e.self
	local say = e.message or ""

	-- exact match: start that game
	for name, template in pairs(games) do
		if string.lower(say) == string.lower(name) then
			Arcade.start(template, client, npc)
			return
		end
	end

	-- otherwise list them
	npc:Say(string.format("Welcome to the arcade, %s. Pick a game:", client:GetName()))
	local names = {}
	for name in pairs(games) do
		table.insert(names, name)
	end
	table.sort(names)
	for _, name in ipairs(names) do
		e.other:Message(15, eq.say_link(name, false, name))
	end
	e.other:Message(15, "Click a game to play. Say 'games' to see this list again.")
end

Arcade.instances = instances

return Arcade
