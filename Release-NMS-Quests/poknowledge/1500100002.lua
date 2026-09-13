-- Emissary of Erollisi - Things Are Best With Friends (Erollisi Day)
local ED = require("erollisiday")
local T = ED.TASK.FRIENDS

function event_say(e)
	if not e.message:findi("hail") then
		if e.message:findi("help") and not e.other:IsTaskActive(T) and not e.other:IsTaskCompleted(T) then
			ED.assign(e.other, T)
			ED.upd(e.other, T, 0, 1)
			e.other:SummonItem(ED.ITEM.IDOL_FRIENDSHIP)
			e.self:Say("Take this idol and share its blessing with ten others. Simply hold it and click it upon them. Return to me when you have spread Erollisi's friendship.")
		end
		return
	end

	local c = e.other
	if c:IsTaskCompleted(T) then
		e.self:Say("Erollisi's friendship shines through you, " .. c:GetName() .. ".")
	elseif not c:IsTaskActive(T) then
		e.self:Say("Hail, " .. c:GetName() .. ". I am the Emissary of Erollisi. Will you [" .. eq.say_link("help") .. "] me share the gift of friendship?")
	else
		local done = c:GetTaskActivityDoneCount(T, 1)
		if done >= 10 then
			ED.upd(c, T, 2, 1)
			c:QuestReward(e.self, 0, 0, 0, 0, 0, 3000)
			c:Message(15, "You have shared Erollisi's friendship with ten souls.")
			quest.complete_task(T)
			e.self:Say("You have touched ten hearts with friendship. Erollisi smiles upon you.")
		else
			c:SummonItem(ED.ITEM.IDOL_FRIENDSHIP)
			e.self:Say("You have shared friendship with " .. done .. " of ten. Keep the idol and try again - it does not always take hold at once.")
		end
	end
end
