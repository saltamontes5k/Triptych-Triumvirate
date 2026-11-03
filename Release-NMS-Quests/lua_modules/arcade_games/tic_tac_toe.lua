-- Tic-Tac-Toe vs the gnome (sample arcade game, Lua).
-- Click a square; the gnome answers half a second later. Saves wins and
-- posts them to the shared top-10 board.

local Arcade = require("arcade")

local LINES = {
	{1,2,3},{4,5,6},{7,8,9},      -- rows
	{1,4,7},{2,5,8},{3,6,9},      -- columns
	{1,5,9},{3,5,7},              -- diagonals
}

local function winner(board)
	for _, line in ipairs(LINES) do
		local v = board[line[1]]
		if v and v == board[line[2]] and v == board[line[3]] then
			return v, line
		end
	end
	for i = 1, 9 do
		if not board[i] then
			return nil, nil -- still open squares
		end
	end
	return "draw", nil
end

local CORNERS = { 1, 3, 7, 9 }

return Arcade.game {
	key = "tic_tac_toe",
	title = "Tic-Tac-Toe",
	width = 300,
	height = 330,
	style = "wood",

	start = function(self)
		self:new_board()
	end,

	new_board = function(self)
		self.board = {}
		self.turn = "X"
		self.over = nil
		self.strike = nil
		self:refresh()
	end,

	draw = function(self, canvas)
		local headline = "Your move (X)"
		if self.over == "draw" then headline = "Draw!"
		elseif self.over == "X" then headline = "You win!"
		elseif self.over == "O" then headline = "The gnome wins!"
		end
		canvas:banner(headline, "gold", { y = 6, size = 22 })

		canvas:grid(30, 50, 3, 3, 78, function(col, row)
			local v = self.board[row * 3 + col + 1]
			if v == "X" then return 0xFF24365C end
			if v == "O" then return 0xFF5C2830 end
			return nil
		end, { action = 1 })

		for i = 1, 9 do
			local col = (i - 1) % 3
			local row = math.floor((i - 1) / 3)
			if self.board[i] then
				local c = (self.board[i] == "X") and 0xFF80A0FF or 0xFFFF9090
				canvas:text(30 + col * 78 + 39, 50 + row * 78 + 24, self.board[i],
					{ size = 34, align = 1, color = c })
			end
		end

		if self.strike then
			local function center(i)
				return 30 + ((i - 1) % 3) * 78 + 39, 50 + math.floor((i - 1) / 3) * 78 + 39
			end
			local x1, y1 = center(self.strike[1])
			local x2, y2 = center(self.strike[3])
			canvas:line(x1, y1, x2, y2, "gold", 4)
		end

		canvas:chip_count(150, 286, self:saved("wins", 0))
		canvas:text(150, 286, "wins", { size = 12, align = 1 })
	end,

	-- grid clicks land here with value = cell index 1..9 (col + row*3 + 1)
	on_grid = function(self, cell)
		self:play(cell)
	end,

	play = function(self, square)
		if self.over or self.turn ~= "X" or self.board[square] then
			return
		end

		self.board[square] = "X"
		self:check()
		if not self.over then
			self.turn = "O"
			-- the gnome ponders
			self:after(500, function(g) g:gnome() end)
		end
	end,

	gnome = function(self)
		if self.over then return end

		local open = {}
		for i = 1, 9 do
			if not self.board[i] then table.insert(open, i) end
		end

		local function finds(want)
			for _, line in ipairs(LINES) do
				local mine, other, spot = 0, 0, nil
				for _, i in ipairs(line) do
					local v = self.board[i]
					if v == want then mine = mine + 1
					elseif v then other = other + 1
					else spot = i end
				end
				if mine == 2 and other == 0 and spot then return spot end
			end
			return nil
		end

		local move = finds("O") or finds("X")
		if not move then
			for _, c in ipairs(CORNERS) do
				if not self.board[c] then move = c break end
			end
		end
		if not move then
			move = open[math.random(#open)]
		end

		self.board[move] = "O"
		self:check()
		if not self.over then
			self.turn = "X"
		end
	end,

	check = function(self)
		local who, line = winner(self.board)
		if who == "X" then
			self.over = "X"
			self.strike = line
			self:save("wins", self:saved("wins", 0) + 1)
			self:leaderboard("wins", self:saved("wins", 0))
		elseif who == "O" then
			self.over = "O"
			self.strike = line
		elseif who == "draw" then
			self.over = "draw"
		end
	end,

	buttons = {
		{ "New game", function(g) g:new_board() end },
	},

	keys = {
		n = function(g) g:new_board() end,
		escape = function(g) g.you and g.you:NMSWindowClose(g.win_id) end,
	},
}
