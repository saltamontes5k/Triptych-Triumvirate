-- Muku Wolfeetz - Lures Hurt (Erollisi Day)
local ED = require("erollisiday")
local T = ED.TASK.LURES
local ONLY = ED.TASK.ONLYFOOLS

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("The totem sings of love and the sea.")
	elseif not c:IsTaskActive(T) then
		ED.assign(c, T)
		ED.upd(c, T, 0, 1)
		e.self:Say("Hail. I am Muku Wolfeetz. I seek a Totem of Love and Ocean to calm the spirits here. Will you [" .. eq.say_link("help me") .. "]? Slay an iksar skeleton and a sarnak skeleton for their bones, gather beach grass from the shore, and fish up a cockatrice claw.")
	else
		e.self:Say("Bring me an Iksar Tailbone, a Sarnak Voicebox, a Bunch of Beach Grass, and a Cockatrice Claw fished from the shore.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other
	if c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.IKSAR_TAILBONE, item2 = ED.ITEM.SARNAK_VOICEBOX, item3 = ED.ITEM.BEACH_GRASS, item4 = ED.ITEM.COCKATRICE_CLAW}) then
		ED.upd(c, T, 1, 1)
		ED.upd(c, T, 3, 1)
		ED.upd(c, T, 5, 1)
		ED.upd(c, T, 6, 1)
		ED.upd(c, T, 7, 1)
		c:SummonItem(ED.ITEM.TOTEM)
		c:Message(15, "You bind the totem's pieces with the magic of the sea.")
		e.self:Say("The pieces fit! Here is your Totem of Love and Ocean. Give it to me when you are ready.")
	elseif c:IsTaskActive(T) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.TOTEM}) then
		ED.upd(c, T, 8, 1)
		c:SummonItem(ED.ITEM.SQUEEZED_GLEE)
		c:SummonItem(ED.ITEM.CANDY_SULTRY, 6)
		c:QuestReward(e.self, 0, 0, 0, 0, 0, 5000)
		c:Message(15, "Muku Wolfeetz accepts the Totem of Love and Ocean.")
		quest.complete_task(T)
		ED.upd(c, ONLY, 1, 1)
		e.self:Say("The spirits are calm. Take this Squeezed Glee and these candy hearts, with my thanks.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
