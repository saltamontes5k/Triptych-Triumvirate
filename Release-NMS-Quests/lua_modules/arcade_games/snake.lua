-- Snake (sample arcade game, Lua). Arrow keys or WASD steer; the clock moves
-- the snake. Best score persists per character and posts to the top-10 board.

local Arcade = require("arcade")

local COLS, ROWS = 20, 15
local CELL = 18

local function opposite(a, b)
	if (a == "up" and b == "down") or (a == "down" and b == "up")
		or (a == "left" and b == "right") or (a == "right" and b == "left") then
		return true
	end
	return false
end

return Arcade.game {
	key = "snake",
	title = "Snake",
	width = COLS * CELL + 20,
	height = ROWS * CELL + 60,
	style = "night",

	start = function(self)
		self.body = { { x = 5, y = 7 }, { x = 4, y = 7 }, { x = 3, y = 7 } }
		self.dir = "right"
		self.next_dir = nil
		self.alive = true
		self.score = 0
		self.best = self:saved("best", 0)
		self:place_food()
		self.mover = self:every(150, function(g) g:step() end)
	end,

	place_food = function(self)
		for _ = 1, 300 do
			local x = math.random(0, COLS - 1)
			local y = math.random(0, ROWS - 1)
			local taken = false
			for _, seg in ipairs(self.body) do
				if seg.x == x and seg.y == y then taken = true break end
			end
			if not taken then
				self.food = { x = x, y = y }
				return
			end
		end
		self.food = { x = 0, y = 0 }
	end,

	step = function(self)
		if not self.alive then return end

		if self.next_dir and not opposite(self.next_dir, self.dir) then
			self.dir = self.next_dir
		end
		self.next_dir = nil

		local head = self.body[1]
		local nx, ny = head.x, head.y
		if self.dir == "up" then ny = ny - 1
		elseif self.dir == "down" then ny = ny + 1
		elseif self.dir == "left" then nx = nx - 1
		elseif self.dir == "right" then nx = nx + 1
		end

		-- walls and self-collision end the run
		if nx < 0 or ny < 0 or nx >= COLS or ny >= ROWS then
			return self:game_over()
		end
		for i = 1, #self.body - 1 do
			if self.body[i].x == nx and self.body[i].y == ny then
				return self:game_over()
			end
		end

		table.insert(self.body, 1, { x = nx, y = ny })

		if self.food and nx == self.food.x and ny == self.food.y then
			self.score = self.score + 10
			self:place_food()
		else
			table.remove(self.body)
		end
	end,

	game_over = function(self)
		self.alive = false
		self:stop(self.mover)
		self:halt()
		if self.score > self.best then
			self.best = self.score
			self:save("best", self.best)
			self:leaderboard("best", self.best)
		end
	end,

	draw = function(self, canvas)
		canvas:banner(
			self.alive and ("Score " .. self.score) or ("Game over -- " .. self.score),
			self.alive and "white" or "red",
			{ y = 4, size = 18 })

		canvas:grid(10, 34, COLS, ROWS, CELL, function(col, row)
			for i, seg in ipairs(self.body) do
				if seg.x == col and seg.y == row then
					return (i == 1) and 0xFF40E060 or 0xFF209040
				end
			end
			if self.food and self.food.x == col and self.food.y == row then
				return 0xFFE04040
			end
			return nil
		end, { action = 0 })

		if not self.alive then
			canvas:banner("press N for a new game", "gold", { y = ROWS * CELL + 20, size = 14 })
		end
	end,

	-- steer: only the head turns, and only when it is not a reversal
	steer = function(self, dir)
		return function(g)
			if g.alive then g.next_dir = dir end
		end
	end,

	buttons = {
		{ "New game", function(g) g:start() end, enabled = function(g) return not g.alive end },
	},

	keys = {
		up = function(g) g:steer("up")(g) end,
		w = function(g) g:steer("up")(g) end,
		down = function(g) g:steer("down")(g) end,
		s = function(g) g:steer("down")(g) end,
		left = function(g) g:steer("left")(g) end,
		a = function(g) g:steer("left")(g) end,
		right = function(g) g:steer("right")(g) end,
		d = function(g) g:steer("right")(g) end,
		n = function(g) if not g.alive then g:start() end end,
		escape = function(g) g.you and g.you:NMSWindowClose(g.win_id) end,
	},
}
