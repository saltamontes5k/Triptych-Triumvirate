local quests = require("achievement_quest_npcs")

-- NMS preserved: TSS "Reakash's Revenge" (600565) from the retired
-- Councilmember_Reakash.pl; the retired Serenity chain (600246) is covered by
-- the reconstructed council content in achievement_quest_npcs.
local function revenge_say(e)
	local text = e.message:lower()
	if text:find("revenge", 1, true) or text:find("vengeance", 1, true) then
		if not quest.istaskactive(600565) and not quest.istaskcompleted(600565) then
			e.self:Say("Since you mention [vengeance] - the crevice spiderlings of the Hollows nibble at my collections while I meditate. Eight of them, and my collections will know peace.")
			e.other:AssignTask(600565)
		elseif quest.istaskactive(600565) then
			e.self:Say("Eight crevice spiderlings, little one. My collections are patient, but I am not.")
		else
			e.self:Say("My collections are at peace, thanks to you.")
		end
	end
end

function event_say(e) quests.say(e); revenge_say(e) end
function event_trade(e) quests.trade(e) end
function event_task_accepted(e) quests.accepted(e) end
