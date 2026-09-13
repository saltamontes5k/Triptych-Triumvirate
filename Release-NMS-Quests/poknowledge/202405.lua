-- Frostfell (2006): Santug Claugg - Santug's List + A Gift for Tinam (Plane of Knowledge)
local FF = require("frostfell")

local LIST_PORTIONS = {
	87531, 87532, 87533, 87534, 87535, 87536, 87537, 87538, 87539, 87540,
}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Happy Frostfell! I could use help with my [list] or with poor [Ebenizer].")
	elseif e.message:findi("list") then
		FF.assign(e.other, FF.TASK.LIST)
		e.self:Say("A grimp tore my List into ten portions! Kill grimps and bring every portion back to me.")
	elseif e.message:findi("ebenizer") then
		FF.assign(e.other, FF.TASK.TINAM)
		e.self:Say("Ebenizer Sprooket, in the Butcherblock Mountains, needs a Frostfell gift for Tinam. Seek him near the docks.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local p = e.other
	local portions = {}
	for i, id in ipairs(LIST_PORTIONS) do
		portions["item" .. i] = id
	end
	if p:IsTaskActive(FF.TASK.LIST) and item_lib.check_turn_in(e.trade, portions) then
		e.self:Say("My List, whole again! Take this Santug Suit.")
		p:SummonItem(87561)
		p:UpdateTaskActivity(FF.TASK.LIST, 0, 1)
		p:UpdateTaskActivity(FF.TASK.LIST, 1, 1)
	elseif p:IsTaskActive(FF.TASK.TINAM) and item_lib.check_turn_in(e.trade, {item1 = FF.ITEM.DOLLY}) then
		e.self:Say("The clockwork dolly! Tinam will be so happy. Here is a Frostfell Tree for your trouble.")
		p:SummonItem(87565)
		p:UpdateTaskActivity(FF.TASK.TINAM, 10, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
