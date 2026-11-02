local quests = require("achievement_quest_npcs")

-- NMS preserved: "Utenka's Combat Trial" (600272) from the retired
-- #Champion_Utenka.pl; runs alongside the crescent module glue.
local function trial_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		if not quest.istaskcompleted(600272) and not quest.istaskactive(600272) then
			e.self:Say("Halt! Do you smell that? That is the smell of an untrained fighter. It clings to you, friend. If you would walk out the gates of this city, you will first prove you can swing a sword - or a spell - against the [dummies].")
		elseif quest.istaskactive(600272) then
			e.self:Say("Ten dummies. Break them. The dummies respawn, so you needn't fear running out of practice.")
		else
			e.self:Say("You smell of victory. Well done, recruit.")
		end
	end
	if text:find("dummies", 1, true) then
		e.self:Say("The training dummies are in the next room. Destroy ten of them - auto-attack will do, or your spells if you are of that persuasion. They will likely respawn faster than you can break them. Return to me when you have done it.")
		if not quest.istaskactive(600272) and not quest.istaskcompleted(600272) then
			e.other:AssignTask(600272)
		end
	end
end

function event_say(e) quests.say(e); trial_say(e) end
function event_trade(e) quests.trade(e) end
function event_task_accepted(e) quests.accepted(e) end
