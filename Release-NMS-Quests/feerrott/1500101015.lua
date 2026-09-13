-- Frostfell (2010): Dorik Gigglegibber - Gathering Holiday Cheer turn-in
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! Bring me five Convivial Gorilla Brainstems and I will reward you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:IsTaskActive(FF.TASK.CHEER) and item_lib.check_turn_in(e.trade, {
		{item1 = FF.ITEM.BRAINSTEM},
		{item2 = FF.ITEM.BRAINSTEM},
		{item3 = FF.ITEM.BRAINSTEM},
		{item4 = FF.ITEM.BRAINSTEM},
		{item5 = FF.ITEM.BRAINSTEM},
	}) then
		e.self:Say("Excellent! Here is your Frostfell Cheer Potion and a Frostfell Gift Box.")
		e.other:SummonItem(FF.ITEM.CHEER_POTION)
		e.other:SummonItem(52459)
		e.other:UpdateTaskActivity(FF.TASK.CHEER, 1, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
