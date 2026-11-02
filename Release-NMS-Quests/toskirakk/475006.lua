-- #Mitius,_Herald_of_Change (475006) -- the Rathe theme tasks (Rallosian Battle Figure parts) and the Timeshear missions.
-- Hand-authored; follows the sof_content/gen_givers.py giver shape, split
-- into keyword menus because the task chooser caps at 40 entries.
local SETS = {
	{ keyword = "duty", label = "the duties of change", tasks = {303030, 303031, 303032, 303033, 303034, 303035, 303147, 303148, 303149, 303150, 303151, 303152, 303153, 303154, 303155, 303156, 303157, 303158, 303159, 303163, 303164, 303165, 303166, 303167, 303168, 303169, 303170, 303171} },
	{ keyword = "timeshear", label = "the Timeshear missions", tasks = {303002, 303003, 303005, 303011, 303012, 303020, 303021, 303022, 303023, 303024, 303036, 303040, 303041, 303048, 303049, 303050, 303051, 303071, 303072, 303073, 303077, 303080, 303081, 303160, 303161, 303162} },
}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Change is coming to Toskirakk whether its masters will it or no. Ask me about a [task].")
		return
	end
	for _, set in ipairs(SETS) do
		if e.message:findi(set.keyword) then
			e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
			eq.task_selector(set.tasks)
			return
		end
	end
	if e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		local labels = {}
		for _, set in ipairs(SETS) do
			labels[#labels + 1] = "[" .. set.keyword .. "] for " .. set.label
		end
		e.self:Say("Ask me about " .. table.concat(labels, ", or ") .. ".")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
