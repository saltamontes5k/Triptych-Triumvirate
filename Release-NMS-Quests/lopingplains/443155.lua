-- #Vrald (443155) -- Secrets of Faydwer faction task (302000) plus the
-- Bloodmoon Keep group missions (Were-orc claws and Ancient Emerald Faycite
-- Bisections).
-- Giver shape follows the retired sof_content/gen_givers.py output; the
-- event_task_complete handler is carried over from that generated file.
local TASKS = {302000, 301200, 301201, 301202, 301203, 301204, 301205, 301206}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The Bloodmoon rises over the plains. Ask me about a [task] if you would hunt.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector(TASKS)
	end
end

function event_task_complete(e)
	if e.task_id == 302000 then
		e.other:AddAAPoints(2)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
