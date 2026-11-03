-- Blackjack (sample arcade game, Lua). Ten-chip bets, 3:2 blackjack, dealer
-- stands on 17. The hole card flips on a tween when you stand.

local Arcade = require("arcade")

local BET = 10

local SUITS = { "h", "d", "c", "s" }

local function chips(self)
	return self:saved("chips", 100)
end

local function new_deck()
	local deck = {}
	for _, suit in ipairs(SUITS) do
		for rank = 2, 10 do
			table.insert(deck, { rank = rank, suit = suit })
		end
		for _, face in ipairs({ "J", "Q", "K", "A" }) do
			table.insert(deck, { rank = face, suit = suit })
		end
	end
	-- Fisher-Yates over math.random
	for i = #deck, 2, -1 do
		local j = math.random(i)
		deck[i], deck[j] = deck[j], deck[i]
	end
	return deck
end

local function rank_value(rank)
	if rank == "A" then return 11 end
	if rank == "J" or rank == "Q" or rank == "K" then return 10 end
	return rank
end

-- aces drop from 11 to 1 as needed
local function hand_value(hand, hide_hole)
	local total, aces = 0, 0
	for i, card in ipairs(hand) do
		if not (hide_hole and i == 2) then
			local v = rank_value(card.rank)
			total = total + v
			if card.rank == "A" then aces = aces + 1 end
		end
	end
	while total > 21 and aces > 0 do
		total = total - 10
		aces = aces - 1
	end
	return total
end

return Arcade.game {
	key = "blackjack",
	title = "Blackjack",
	width = 460,
	height = 320,
	style = "wood",

	start = function(self)
		self.phase = "bet"
		self.msg = "Ten chips a hand. Deal when ready."
		self.ph = {}
		self.dh = {}
		self.deck = nil
		self.hole_flip = 0
		self:refresh()
	end,

	deal = function(self)
		if self.phase ~= "bet" then return end
		if chips(self) < BET then
			self.msg = "You need 10 chips for a hand."
			return
		end

		self.deck = new_deck()
		self.ph = {}
		self.dh = {}
		self.phase = "dealing"
		self.msg = ""

		-- deal P, D, P, D(hole) with card slide tweens
		local function pop()
			return table.remove(self.deck)
		end
		self.ph[1] = pop()
		self.dh[1] = pop()
		self.ph[2] = pop()
		self.dh[2] = pop()   -- hole card
		self.dh[2].flip = 0

		self:after(500, function(g)
			local pv = hand_value(g.ph)
			local dv = hand_value(g.dh, true)
			if pv == 21 or dv == 21 then
				g:reveal(true)
			else
				g.phase = "player"
				g.msg = "Hit or stand?"
			end
		end)
	end,

	hit = function(self)
		if self.phase ~= "player" then return end
		table.insert(self.ph, table.remove(self.deck))
		local v = hand_value(self.ph)
		if v > 21 then
			self:reveal(false, "bust")
		elseif v == 21 then
			self:stand(true)
		end
	end,

	stand = function(self, auto)
		if self.phase ~= "player" and not auto then return end
		self.phase = "dealer"

		-- reveal the hole card with a flip tween, then the dealer draws to 17
		self:tween(self.dh[2], "flip", 1, 400, "linear", function(g)
			local function dealer_step(dg)
				local v = hand_value(dg.dh)
				if v < 17 then
					table.insert(dg.dh, table.remove(dg.deck))
					dg:after(350, dealer_step)
				else
					dg:settle()
				end
			end
			dealer_step(g)
		end)
	end,

	reveal = function(self, was_natural, how)
		self.phase = "done"
		self:tween(self.dh[2], "flip", 1, 400, "linear", function(g)
			local pv = hand_value(g.ph)
			local dv = hand_value(g.dh)
			if was_natural then
				if pv == 21 and dv == 21 then
					g:settle("push")
				else
					g:settle("blackjack")
				end
			elseif how == "bust" then
				g:settle("bust")
			else
				g:settle()
			end
		end)
	end,

	settle = function(self, how)
		self.phase = "done"

		if not how then
			local pv = hand_value(self.ph)
			local dv = hand_value(self.dh)
			if dv > 21 then how = "dealer_bust"
			elseif pv > dv then how = "win"
			elseif pv < dv then how = "lose"
			else how = "push" end
		end

		local c = chips(self)
		if how == "win" or how == "dealer_bust" then
			self:save("chips", c + BET)
			self.msg = "You win +" .. BET .. " chips!"
		elseif how == "blackjack" then
			self:save("chips", c + math.floor(BET * 2.5))
			self.msg = "Blackjack! +" .. math.floor(BET * 2.5) .. " chips."
		elseif how == "push" then
			self.msg = "Push -- bet returned."
		else
			self:save("chips", c - BET)
			self.msg = (how == "bust") and "Bust. -" .. BET .. " chips."
				or ((how == "lose") and "Dealer wins. -" .. BET .. " chips."
				or "Dealer wins. -" .. BET .. " chips.")
		end

		self:leaderboard("chips", chips(self))
		self:refresh()
	end,

	draw = function(self, canvas)
		canvas:banner("Blackjack", "gold", { y = 4, size = 22 })

		-- dealer row
		canvas:text(16, 40, "Dealer", { size = 12, color = "gray" })
		for i, card in ipairs(self.dh) do
			local flip = (i == 2) and (card.flip or 0) or 1
			if flip < 1 and i == 2 then
				canvas:card(120 + (i - 1) * 44, 58, nil, {})
			else
				canvas:card(120 + (i - 1) * 44, 58, card)
			end
		end
		if #self.dh > 0 then
			canvas:text(400, 62, tostring(hand_value(self.dh, self.phase ~= "done" and self.phase ~= "dealer" or false)), { size = 14, color = "gray" })
		end

		-- player row
		canvas:text(16, 130, "You (" .. hand_value(self.ph) .. ")", { size = 12, color = "gray" })
		for i, card in ipairs(self.ph) do
			canvas:card(120 + (i - 1) * 44, 148, card)
		end

		canvas:text(230, 240, self.msg, { size = 14, align = 1 })
		canvas:chip_count(230, 262, chips(self))
		canvas:chip_stack(60, 250, math.max(0, math.floor(chips(self) / 100)))
	end,

	buttons = {
		{ "Deal", function(g) g:deal() end, enabled = function(g) return g.phase == "bet" or g.phase == "done" end, color = "green" },
		{ "Hit", function(g) g:hit() end, enabled = function(g) return g.phase == "player" end },
		{ "Stand", function(g) g:stand() end, enabled = function(g) return g.phase == "player" end, color = "red" },
		{ "New hand", function(g) g:start() end, enabled = function(g) return g.phase == "done" end },
	},

	keys = {
		h = function(g) g:hit() end,
		s = function(g) g:stand() end,
		d = function(g) g:deal() end,
		escape = function(g) g.you and g.you:NMSWindowClose(g.win_id) end,
	},
}
