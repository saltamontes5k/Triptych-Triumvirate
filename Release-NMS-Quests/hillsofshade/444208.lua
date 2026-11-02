-- Shearon (444208) -- Hills of Shade tasks (Camp Valor arc).
-- Hand-authored; follows the sof_content/gen_givers.py giver shape.
-- Live gates this behind the Crude Satchel ("The Borrowers"); offered directly here.
local TASKS = {300522}
local REQUIRES = {}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". There is work to be done if you would lend a hand. Ask me about a [task].")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		local available = {}
		for _, tid in ipairs(TASKS) do
			local required = REQUIRES[tid]
			if required == nil or e.other:IsTaskCompleted(required) then
				available[#available + 1] = tid
			end
		end
		eq.task_selector(available)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
