-- Reaver Lebanezer (444008) -- Hills of Shade tasks (Bertox Chosen arc).
-- Hand-authored; follows the sof_content/gen_givers.py giver shape.
-- One of Our Own requires the four Bertox Chosen dig tasks (live also wants Amiable faction).
local TASKS = {300536}
local REQUIRES = {[300536] = {300529, 300530, 300531, 300535}}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". There is work to be done if you would lend a hand. Ask me about a [task].")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		local available = {}
		for _, tid in ipairs(TASKS) do
			local required = REQUIRES[tid]
			local ok = true
			if type(required) == "number" then
				ok = e.other:IsTaskCompleted(required)
			elseif type(required) == "table" then
				for _, pre in ipairs(required) do
					if not e.other:IsTaskCompleted(pre) then
						ok = false
						break
					end
				end
			end
			if ok then
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
