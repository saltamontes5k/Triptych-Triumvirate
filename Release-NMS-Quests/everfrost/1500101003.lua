-- Frostfell (2006): The Grinnuch - Saving Santug boss
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You dare disturb The Grinnuch? The gifts are mine!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:IsTaskActive(FF.TASK.SANTUG) and item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.ORNATE_SLED}) then
		e.self:Say("Bah! Take this stocking and be gone.")
		e.other:SummonItem(FF.ITEM.STOCKING)
		FF.upd(e.other, FF.TASK.SANTUG, 2, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
