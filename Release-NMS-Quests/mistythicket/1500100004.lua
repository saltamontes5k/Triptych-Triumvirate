-- Rolo - A Fool In Love (Erollisi Day)
local ED = require("erollisiday")
local FOOL = ED.TASK.FOOL
local FIND = ED.TASK.FINDME

function event_say(e)
	if not e.message:findi("hail") then return end
	local c = e.other
	if not c:IsTaskActive(FOOL) and not c:IsTaskCompleted(FOOL) then
		ED.assign(c, FOOL)
	end
	if c:IsTaskActive(FOOL) then
		ED.upd(c, FOOL, 1, 1)
		if c:GetTaskActivityDoneCount(FOOL, 6) >= 1 then
			e.self:Say("You have been so kind, " .. c:GetName() .. ". Please, take this Heartfelt Letter to Deputy Mims in the tower to the west.")
		else
			e.self:Say("Oh, woe is me! I have written a poem for my darling, but I have nothing to write with! I need a Chewed Steel Nib, a Fluffy Quill, Heart-Drawn Paper, and some Drying Sand. Bring them to me and I will pen a letter.")
		end
	end

	if c:IsTaskActive(FIND) and c:GetTaskActivityDoneCount(FIND, 6) >= 1 and c:GetTaskActivityDoneCount(FIND, 7) < 1 then
		ED.upd(c, FIND, 7, 1)
		e.self:Say("A flyer naming us all? Then we are all in danger. Go back to Farnjer, quickly!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local c = e.other
	if c:IsTaskActive(FOOL) and item_lib.check_turn_in(e.trade, {item1 = ED.ITEM.CHEWED_NIB, item2 = ED.ITEM.FLUFFY_QUILL, item3 = ED.ITEM.HEART_PAPER, item4 = ED.ITEM.DRYING_SAND}) then
		ED.upd(c, FOOL, 2, 1)
		ED.upd(c, FOOL, 3, 1)
		ED.upd(c, FOOL, 4, 1)
		ED.upd(c, FOOL, 5, 1)
		ED.upd(c, FOOL, 6, 1)
		c:SummonItem(ED.ITEM.HEARTFELT_LETTER)
		e.self:Say("At last! Here is my Heartfelt Letter. Please take it to Deputy Mims in the tower to the west.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
