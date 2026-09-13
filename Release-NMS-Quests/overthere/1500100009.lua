-- Lithxn - I Think I Love You (Erollisi Day)
local ED = require("erollisiday")
local T = ED.TASK.ITHINK
local ONLY = ED.TASK.ONLYFOOLS

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("The extracts are potent. My thanks, " .. c:GetName() .. ".")
	elseif not c:IsTaskActive(T) then
		ED.assign(c, T)
		ED.upd(c, T, 0, 1)
		e.self:Say("Hail. I am Lithxn. I seek rare extracts for a feast. Will you gather Cabilis Habanero, Serrano, and Garlic extracts, and a Toxxulian Sesame Extract from East Freeport?")
	else
		e.self:Say("Bring me a Cabilis Habanero Extract and a Cabilis Serrano Extract from Cabilis East, a Cabilis Garlic Extract from Cabilis West, and a Toxxulian Sesame Extract from East Freeport.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other
	if c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.HABANERO, item2 = ED.ITEM.SERRANO, item3 = ED.ITEM.GARLIC, item4 = ED.ITEM.SESAME}) then
		ED.upd(c, T, 1, 1)
		ED.upd(c, T, 2, 1)
		ED.upd(c, T, 3, 1)
		ED.upd(c, T, 4, 1)
		ED.upd(c, T, 5, 1)
		c:SummonItem(ED.ITEM.FUDGE_BROWNIE)
		c:SummonItem(ED.ITEM.CANDY_SWEET, 6)
		c:QuestReward(e.self, 0, 0, 0, 0, 0, 5000)
		c:Message(15, "Lithxn eagerly takes the extracts.")
		quest.complete_task(T)
		ED.upd(c, ONLY, 3, 1)
		e.self:Say("Perfect. Take this Frisky Fudge Brownie and these candy hearts.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
