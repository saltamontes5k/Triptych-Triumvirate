-- Pyrotechnician Flizcog (436007) -- Destroying the Competition (300031).
-- Grants the Automated Incendiary Device on accept; "more" re-arms it.
local fort = require("sof_fortress")

local TASKS = { fort.TASK_COMPETITION }

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". Love the smell "
			.. "of burning steamworks in the morning. Ask me about a "
			.. "[task].")
	elseif e.message:findi("task") or e.message:findi("work")
		or e.message:findi("offer") or e.message:findi("jobs") then
		if not e.other:IsTaskCompleted(fort.TASK_COMPETITION)
			and not e.other:IsTaskActive(fort.TASK_COMPETITION) then
			e.self:Say("Two hours, five bombs, one Steam Factory. You in?")
			eq.task_selector(TASKS)
		elseif e.other:IsTaskActive(fort.TASK_COMPETITION) then
			e.self:Say("The device has your name on it. Tick tock.")
		else
			e.self:Say("You have had your fun with my bombs, "
				.. e.other:GetCleanName() .. ".")
		end
	elseif e.message:findi("more") then
		-- ran out of charges: re-issue the device
		if e.other:IsTaskActive(fort.TASK_COMPETITION)
			and e.other:CountItem(fort.ITEM.incendiary) == 0 then
			e.other:SummonItem(fort.ITEM.incendiary)
			e.self:Say("Careful with this one! It is my last spare.")
		else
			e.self:Say("You still carry a device. Do not waste it.")
		end
	end
end

function event_task_accepted(e)
	if e.task_id == fort.TASK_COMPETITION then
		e.other:SummonItem(fort.ITEM.incendiary)
		e.other:Message(15, "Flizcog slaps an Automated Incendiary Device "
			.. "Mark XIV into your hands. 'Two hours. The showrooms, the "
			.. "fan hall, the foundry walk, the compression room, and the "
			.. "power station. GO!'")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
