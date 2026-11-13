-- My Stats -- a non-game info window (sample arcade game, Lua).
-- Shows the window API doing plain widgets: no input, just a portrait of the
-- player and a couple of arcade numbers pulled from the other games.

local Arcade = require("arcade")

local CLASSES = {
	[1] = "Warrior", [2] = "Cleric", [3] = "Paladin", [4] = "Ranger",
	[5] = "Shadow Knight", [6] = "Druid", [7] = "Monk", [8] = "Bard",
	[9] = "Rogue", [10] = "Shaman", [11] = "Necromancer", [12] = "Wizard",
	[13] = "Magician", [14] = "Enchanter", [15] = "Beastlord", [16] = "Berserker",
}

return Arcade.game {
	key = "my_stats",
	title = "My Stats",
	width = 320,
	height = 260,
	style = "night",

	start = function(self)
	end,

	draw = function(self, canvas)
		local c = self:client()
		if not c then return end

		canvas:banner(c:GetName(), "gold", { y = 6, size = 22 })
		canvas:line(60, 44, 260, 44, "gray", 1)

		local class_name = CLASSES[c:GetClassID()] or "Adventurer"
		canvas:text(16, 56, "Level " .. c:GetLevel() .. " " .. class_name, { size = 14 })

		local hp, max_hp = c:GetHP(), c:GetMaxHP()
		canvas:text(16, 78, "Hit points", { size = 12, color = "gray" })
		canvas:rect(110, 80, 180, 12, { fill = 0xFF20222E })
		canvas:rect(110, 80, math.floor(180 * math.max(0, math.min(1, hp / math.max(1, max_hp)))), 12, { fill = 0xFF30C030 })
		canvas:text(16, 96, hp .. " / " .. max_hp, { size = 12 })

		canvas:text(16, 122, "Arcade record", { size = 12, color = "gray" })
		canvas:text(16, 138, "Coin Flip chips: " .. Arcade.commas(self:saved("chips", 100)), { size = 13 })
		canvas:text(16, 156, "Tic-Tac-Toe wins: " .. Arcade.commas(self:saved("wins", 0)), { size = 13 })
		canvas:text(16, 174, "Snake best: " .. Arcade.commas(self:saved("best", 0)), { size = 13 })

		canvas:label(16, 210, "Say 'games' to the host for more")
	end,
}
