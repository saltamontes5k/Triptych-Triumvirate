-- Tinmyn Cogsloose (436011) -- Oil Cans (300035). Sparks Diggleknob does
-- the distilling (436012); Tinmyn takes the results back and pays out.
local fort = require("sof_fortress")

local TASKS = { fort.TASK_OILCANS }

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. "... *squeak* ... "
			.. "my [oil can] ran dry, and without it I cannot cut, drill, "
			.. "or scream properly.")
	elseif e.message:findi("task") or e.message:findi("oil can")
		or e.message:findi("work") or e.message:findi("jobs") then
		if not e.other:IsTaskCompleted(fort.TASK_OILCANS)
			and not e.other:IsTaskActive(fort.TASK_OILCANS) then
			e.self:Say("Sparks Diggleknob can refine oil for me -- his stand "
				.. "is by the western gate. Tell him Tinmyn sent you?")
			eq.task_selector(TASKS)
		elseif e.other:IsTaskActive(fort.TASK_OILCANS) then
			e.self:Say("Sparks. Western gate. *squeak*")
		end
	end
end

function event_task_accepted(e)
	e.other:Message(15, "Tinmyn squeaks his thanks. Take the request to "
		.. "Sparks Diggleknob by the western gate.")
end

function event_trade(e)
	local item_lib = require("items")
	-- pay out the charm at the final step (deliver activity handles credit)
	if e.other:IsTaskActive(fort.TASK_OILCANS)
		and e.trade and e.trade.click1 == fort.ITEM.gear_saw then
		e.self:Say("*SQUEAK!* She sings again! Take this -- an old can, but "
			.. "the plat in your pocket keeps it humming.")
		e.other:SummonItem(fort.ITEM.oil_can)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
