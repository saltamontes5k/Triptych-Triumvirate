-- Toxon Frennor - Crazy Little Thing (Erollisi Day)
local ED = require("erollisiday")
local T = ED.TASK.CRAZY
local ONLY = ED.TASK.ONLYFOOLS

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("The clockworks are quiet again - for now.")
	elseif not c:IsTaskActive(T) then
		ED.assign(c, T)
		ED.upd(c, T, 0, 1)
		c:SummonItem(ED.ITEM.POISON_VIAL)
		e.self:Say("Hail. I am testing a new poison on the clockworks. Take this Phosphoric Gnomish Poison Vial, use it on five clockworks, and slay them. Then bring me a Golden Thevetia Flower and a Roseus Thevetia Flower.")
	else
		e.self:Say("Poison five clockworks, then bring me a Golden Thevetia Flower and a Roseus Thevetia Flower.")
		c:SummonItem(ED.ITEM.POISON_VIAL)
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other
	if c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.POISON_VIAL, item2 = ED.ITEM.GOLDEN_FLOWER, item3 = ED.ITEM.ROSEUS_FLOWER}) then
		ED.upd(c, T, 3, 1)
		ED.upd(c, T, 4, 1)
		ED.upd(c, T, 5, 1)
		c:SummonItem(ED.ITEM.NUT_COOKIE)
		c:SummonItem(ED.ITEM.CANDY_SASSY, 6)
		c:QuestReward(e.self, 0, 0, 0, 0, 0, 5000)
		c:Message(15, "Toxon Frennor pockets the extracts with a grin.")
		quest.complete_task(T)
		ED.upd(c, ONLY, 2, 1)
		e.self:Say("Excellent! The extracts are just what I needed. Take this Nut Your Day Cookie and these candy hearts.")
	elseif c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.POISON_VIAL}) then
		ED.upd(c, T, 2, 1)
		e.self:Say("Good, the vial is spent. Now find the flowers.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
