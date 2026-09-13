-- Darenne K`Reil - Only Fools Fall In (Erollisi Day master quest)
local ED = require("erollisiday")
local T = ED.TASK.ONLYFOOLS

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("The fort is brighter for your efforts, " .. c:GetName() .. ".")
	elseif not c:IsTaskActive(T) then
		ED.assign(c, T)
		ED.upd(c, T, 0, 1)
		e.self:Say("Hail, " .. c:GetName() .. ". Strange times when I, a Teir`dal, speak of love. Yet there are three here whose hearts ache. Help Muku Wolfeetz, Toxon Frennor, and Lithxn. Bring me what they give you.")
	else
		e.self:Say("Help the three I named: Muku Wolfeetz, Toxon Frennor, and Lithxn. Bring me a Squeezed Glee, a Nut Your Day Cookie, and a Frisky Fudge Brownie.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other
	if c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.SQUEEZED_GLEE, item2 = ED.ITEM.NUT_COOKIE, item3 = ED.ITEM.FUDGE_BROWNIE}) then
		ED.upd(c, T, 1, 1)
		ED.upd(c, T, 2, 1)
		ED.upd(c, T, 3, 1)
		ED.upd(c, T, 4, 1)
		c:SummonItem(ED.ITEM.GUMDROP_FAM)
		c:Message(15, "You have gathered the gifts of love for Darenne K`Reil.")
		quest.complete_task(T)
		e.self:Say("You have done what I could not. Take this Lovely Gumdrop Familiar - may it remind you of the love you have kindled here.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
