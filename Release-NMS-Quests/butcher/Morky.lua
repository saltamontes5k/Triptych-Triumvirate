-- Frostfell (2006): Morky - A Gift for Tinam (Butcherblock Mountains)
local FF = require("frostfell")

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("You caught me! What do you want, land-walker?")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:IsTaskActive(FF.TASK.TINAM) and item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.COINS}) then
		e.self:Say("Shiny coins! Fine, take the spear. Now leave me be!")
		e.other:SummonItem(FF.ITEM.SPEAR)
		e.other:UpdateTaskActivity(FF.TASK.TINAM, 5, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
