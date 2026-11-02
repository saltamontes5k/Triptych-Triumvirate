-- #The_Gearmarshal (436189) -- the Mechanotus group missions (Ancient Faycite sections).
-- Hand-authored; follows the sof_content/gen_givers.py giver shape.
local TASKS = {301100, 301101, 301102, 301103, 301104, 301105, 301106, 301107, 301108, 301109, 301110, 301111, 301112, 301113, 301114}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The Great Wheel grinds on. Groups seeking glory against the clockworks may ask me about a [task].")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector(TASKS)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
