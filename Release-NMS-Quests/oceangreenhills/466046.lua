-- #Cirtan,_Bayle`s_Herald (466046) -- the Oceangreen theme tasks (Bayle's Heraldic Crest pieces).
-- Hand-authored; follows the sof_content/gen_givers.py giver shape.
local TASKS = {303000, 303001, 303100, 303101, 303102, 303103, 303104, 303105, 303106, 303107, 303108, 303109, 303110, 303111, 303112, 303113, 303114, 303115, 303116, 303117, 303118, 303119}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The crest of Bayle must be mended piece by piece, champion. There is work to be had if you would lend a hand. Ask me about a [task].")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector(TASKS)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
