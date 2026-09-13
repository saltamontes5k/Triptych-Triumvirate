-- Frostfell (2007): Zoog - Great Divide toymaker quest giver
local FF = require("frostfell")
local TASKS = { FF.TASK.KANF, FF.TASK.GEMMI, FF.TASK.BRAM, FF.TASK.HAILIE }

function event_say(e)
	if e.message:findi("hail") then
		local active = false
		for _, t in ipairs(TASKS) do
			if e.other:IsTaskActive(t) then
				active = true
				if e.other:GetTaskActivityDoneCount(t, 2) >= 1 then
					FF.upd(e.other, t, 3, 1)
				end
			end
		end
		if active then
			e.self:Say("Well done, the toymakers are safe! Happy Frostfell!")
		else
			e.self:Say("Our Frostfell toymakers are lost in the Great Divide. Say 'more' to help.")
		end
	elseif e.message:findi("more") then
		for _, t in ipairs(TASKS) do
			if not e.other:IsTaskActive(t) and not e.other:IsTaskCompleted(t) then
				FF.assign(e.other, t)
				break
			end
		end
		e.self:Say("Search the Great Divide and free our lost toymakers!")
	end
end
