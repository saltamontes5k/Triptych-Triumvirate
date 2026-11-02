-- #Tynoc,_Herald_of_Scale (452153) -- the Field of Scale theme tasks (Baron Yosig's Skeleton pieces) and the Timeshear missions.
-- Hand-authored; follows the sof_content/gen_givers.py giver shape, split
-- into keyword menus because the task chooser caps at 40 entries.
local SETS = {
	{ keyword = "duty", label = "the duties of the field", tasks = {303200, 303201, 303202, 303203, 303204, 303205, 303206, 303207, 303208, 303209, 303210, 303211, 303212, 303213, 303214, 303215, 303216, 303217, 303218} },
	{ keyword = "timeshear", label = "the Timeshear missions", tasks = {303002, 303003, 303005, 303011, 303012, 303020, 303021, 303022, 303023, 303024, 303036, 303040, 303041, 303048, 303049, 303050, 303051, 303071, 303072, 303073, 303077, 303080, 303081, 303160, 303161, 303162} },
}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The field of the old war still seethes, outlander. There is work to be had -- ask me about a [task].")
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
