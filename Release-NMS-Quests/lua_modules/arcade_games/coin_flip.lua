-- Coin Flip -- sample arcade game (Lua). Ten chips a flip; the coin spins on
-- a tween. Chips persist per character.

local Arcade = require("arcade")

local BET = 10

-- chips on the table are the player's carried platinum (live behaviour)
local function chips(self)
	return self:plat()
end

return Arcade.game {
	key = "coin_flip",
	title = "Coin Flip",
	width = 320,
	height = 250,
	style = "wood",

	start = function(self)
		self.spin = 0
		self.busy = false
		self.msg = "Ten chips a flip. Heads or tails?"
	end,

	draw = function(self, canvas)
		canvas:banner("Coin Flip", "gold", { y = 8, size = 24 })

		-- the coin: width follows |cos| so it appears to turn
		local w = math.floor(68 * math.abs(math.cos(self.spin * math.pi * 6)))
		if w < 4 then w = 4 end
		local x = 126 + math.floor((68 - w) / 2)
		canvas:rect(x, 78, w, 68, { fill = 0xFFF0C040 })
		canvas:rect(x + 3, 81, math.max(1, w - 6), 62, { fill = 0xFFF8D870 })

		canvas:text(126, 160, self.msg, { size = 14, align = 1 })
		canvas:chip_count(126, 184, chips(self))
	end,

	buttons = {
		{ "Heads", function(g) g:flip("heads") end, color = "blue" },
		{ "Tails", function(g) g:flip("tails") end, color = "red" },
	},

	flip = function(self, pick)
		if self.busy then return end
		if chips(self) < BET then
			self.msg = "You need 10 chips to flip."
			return
		end

		self.busy = true
		self.pick = pick
		self.result = (math.random(2) == 1) and "heads" or "tails"
		self.spin = 0
		self:tween(self, "spin", 1, 900, "out", function(g)
			g.busy = false
			if g.result == g.pick then
				g:payout(BET)
				g.msg = g.result .. "! +" .. BET .. " plat."
			else
				g:stake(BET)
				g.msg = g.result .. ". -" .. BET .. " plat."
			end
		end)
	end,

	keys = {
		h = function(g) g:flip("heads") end,
		t = function(g) g:flip("tails") end,
		escape = function(g) g.you and g.you:NMSWindowClose(g.win_id) end,
	},
}
