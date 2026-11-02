local M=require('achievement_quest_blightfire_spirits')

-- NMS preserved: SoD "Locate Zheren" (task 600213) from the retired
-- #Selay_the_Cascade.pl; runs alongside the spirits scene glue.
local function cascade_say(e)
	local text = e.message:lower()
	if text:find("hail", 1, true) then
		e.self:Say("Yes, I know of you, " .. e.other:GetName() .. ". You would be surprised how many rumors of your daring adventures have reached my ears. And last night you were in my [" .. quest.saylink("dreams") .. "].")
	end
	if text:find("dreams", 1, true) then
		e.self:Say("Yes. As I slept I saw a great many things, obscured by pouring rainfall. Lethar was by my side again. When I woke, I knew there was a [" .. quest.saylink("certain path") .. "] you must walk.")
	end
	if text:find("certain path", 1, true) then
		e.self:Say("Make your way to Sunderock and seek out Captain Zheren. He will have more information for you.")
		if not quest.istaskactive(600213) and not quest.istaskcompleted(600213) then
			quest.assigntask(600213)
		end
	end
end

function event_spawn(e) M.spawn(e) end
function event_say(e) M.say(e); cascade_say(e) end
function event_aggro_say(e) M.say(e) end
function event_trade(e) M.trade(e) end
function event_timer(e) M.timer(e) end
