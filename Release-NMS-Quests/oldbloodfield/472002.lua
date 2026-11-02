-- #Herald_Argoth (472002) -- the Discord theme tasks (Dark Soul Crystal pieces) and the Timeshear missions.
-- Hand-authored; follows the sof_content/gen_givers.py giver shape, split
-- into keyword menus because the task chooser caps at 40 entries.
local SETS = {
	{ keyword = "duty", label = "the works against Discord", tasks = {303042, 303043, 303044, 303045, 303046, 303047, 303172, 303173, 303174, 303175, 303176, 303177, 303178, 303179, 303180, 303181, 303182, 303183, 303184, 303185, 303186, 303219} },
	{ keyword = "timeshear", label = "the Timeshear missions", tasks = {303002, 303003, 303005, 303011, 303012, 303020, 303021, 303022, 303023, 303024, 303036, 303040, 303041, 303048, 303049, 303050, 303051, 303071, 303072, 303073, 303077, 303080, 303081, 303160, 303161, 303162} },
}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Discord seeps through the old bloodfield. There is work against it -- ask me about a [task].")
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
