-- Deputy Mims - Can Anybody Find Me / All You Need Is Love / A Fool In Love (Erollisi Day)
local ED = require("erollisiday")
local FIND = ED.TASK.FINDME
local ALL  = ED.TASK.ALLNEED
local FOOL = ED.TASK.FOOL

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other

	if c:IsTaskActive(ALL) then
		ED.upd(c, ALL, 1, 1)
	end

	if c:IsTaskCompleted(FIND) then
		e.self:Say("The goblins have gone quiet. Thank you, " .. c:GetName() .. ".")
	elseif not c:IsTaskActive(FIND) then
		ED.assign(c, FIND)
		ED.upd(c, FIND, 0, 1)
		e.self:Say("Hail, " .. c:GetName() .. ". The goblins near the citadel have been stirring. Will you [" .. eq.say_link("investigate") .. "]?")
	elseif c:GetTaskActivityDoneCount(FIND, 5) >= 1 then
		e.self:Say("Take the Goblin News Flyer to Farnjer and Rolo. They will want to hear of this. Then return to Farnjer.")
	else
		e.self:Say("The goblins dropped pieces of a flyer. Slay the instigators in the Misty Thicket, Runnyeye, and the Gorge of King Xorbb, then bring me the parts.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other

	if c:IsTaskActive(ALL) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.RIVER_FLOWER, item2 = ED.ITEM.GOBLIN_DOLL, item3 = ED.ITEM.BANDIT_DRUM}) then
		ED.upd(c, ALL, 3, 1)
		ED.upd(c, ALL, 4, 1)
		ED.upd(c, ALL, 5, 1)
		ED.upd(c, ALL, 6, 1)
		ED.upd(c, ALL, 7, 1)
		c:QuestReward(e.self, 0, 0, 0, 0, 0, 3000)
		c:Message(15, "You have brought the gifts Deputy Mims and Deputy Ranen spoke of.")
		quest.complete_task(ALL)
		e.self:Say("Ah, the very gifts we discussed! How thoughtful. Thank you, " .. c:GetName() .. ".")

	elseif c:IsTaskActive(FOOL) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.HEARTFELT_LETTER}) then
		ED.upd(c, FOOL, 7, 1)
		e.self:Say("A letter for me? ... 'Deputy Shorttoes'? I am no Deputy Shorttoes. Rolo must be confused. Please tell Farnjer of this.")

	elseif c:IsTaskActive(FIND) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.TORN_FLYER, item2 = ED.ITEM.FLYER_PAGE1, item3 = ED.ITEM.FLYER_PAGE2}) then
		ED.upd(c, FIND, 1, 1)
		ED.upd(c, FIND, 2, 1)
		ED.upd(c, FIND, 3, 1)
		ED.upd(c, FIND, 4, 1)
		c:SummonItem(ED.ITEM.NEWS_FLYER)
		e.self:Say("You found all the pieces! I have pieced them together into a Goblin News Flyer. Take it - and be careful.")

	elseif c:IsTaskActive(FIND) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.NEWS_FLYER}) then
		ED.upd(c, FIND, 5, 1)
		e.self:Say("So the goblins plot together. Farnjer and Rolo must be told. Speak with them, then return to Farnjer.")
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
