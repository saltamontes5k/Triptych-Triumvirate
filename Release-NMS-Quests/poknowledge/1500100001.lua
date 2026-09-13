-- Grimble Grumblemaker - The Perfect Companion (Erollisi Day)
local ED = require("erollisiday")
local T = ED.TASK.PERFECT

function event_say(e)
	if not e.message:findi("hail") then
		if e.message:findi("help") and not e.other:IsTaskActive(T) and not e.other:IsTaskCompleted(T) then
			ED.assign(e.other, T)
			ED.upd(e.other, T, 0, 1)
			e.self:Say("Wonderful! I have marked the lonely hearts of Norrath on your Find window. Seek them out and offer a kind word. When you have greeted them all, return to me.")
		end
		return
	end

	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("The warmth you have spread will outlast the season, " .. c:GetName() .. ".")
	elseif not c:IsTaskActive(T) then
		e.self:Say("Hail, " .. c:GetName() .. "! Erollisi's Day is a time to remind the lonely that they are not alone. Will you [" .. eq.say_link("help") .. "] me spread a little love?")
	elseif ED.all_done(c, T, 1, 16) then
		ED.upd(c, T, 17, 1)
		c:SummonItem(ED.ITEM.DAY_FLOWERS)
		c:Message(15, "You have visited every lonely heart in Norrath.")
		quest.complete_task(T)
		e.self:Say("You have visited every heart I named and brightened each one. Please accept these Erollisi Day flowers, with my thanks.")
	else
		e.self:Say("There are still hearts waiting for a friendly word. I have marked them all on your Find window.")
	end
end
