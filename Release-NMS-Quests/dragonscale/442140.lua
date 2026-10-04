-- Aring (442140) -- one of the four dragon brothers before the Crystallos
-- barrier. Hands out "Beyond the Barrier", the personal "Find the
-- Container I" errand, and after the container is returned, "Restore the
-- Crystal I". (Generated pattern from sof_content/gen_progression docs;
-- siblings Jashy 442102 / Tonas 442048 / Vesiss 442120 share the format.)
local prog = require("sof_progression")

local TID_FIND = prog.TASK_FIND_I        -- 301003
local TID_RESTORE = prog.TASK_RESTORE_I  -- 301007
local CONTAINER = 36675
local CONTAINER_NAME = "Clear Crystal Base"
local CRYSTAL = 36615
local CRYSTAL_NAME = "Clear Crystal"
local ROMAN = "I"

local function offer(e)
	local offers = {}
	if not e.other:IsTaskCompleted(prog.TASK_BARRIER)
		and not e.other:IsTaskActive(prog.TASK_BARRIER) then
		offers[#offers + 1] = prog.TASK_BARRIER
	end
	if not e.other:IsTaskCompleted(TID_FIND)
		and not e.other:IsTaskActive(TID_FIND) then
		offers[#offers + 1] = TID_FIND
	end
	if e.other:IsTaskCompleted(TID_FIND)
		and not e.other:IsTaskCompleted(TID_RESTORE)
		and not e.other:IsTaskActive(TID_RESTORE) then
		offers[#offers + 1] = TID_RESTORE
	end
	return offers
end

function event_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(TID_RESTORE)
			and prog.activity_done(e.other, TID_RESTORE, 0) then
			e.self:Say("The " .. CRYSTAL_NAME .. " glows again -- you have "
				.. "my thanks, and my brother's.")
		elseif e.other:IsTaskActive(TID_FIND) then
			e.self:Say("My " .. CONTAINER_NAME .. " was lost in the "
				.. "wilds. Bring it home to me.")
		elseif e.other:IsTaskActive(prog.TASK_BARRIER) then
			e.self:Say("The barrier to Crystallos ate my brother's light. "
				.. "Speak with my brothers when your errands are done.")
		else
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". My brothers "
				.. "and I mourn our lost sibling beyond the [barrier]. Will "
				.. "you help us?")
		end
	elseif e.message:findi("barrier") or e.message:findi("brother")
		or e.message:findi("lost") then
		local offers = offer(e)
		if #offers > 0 then
			e.self:Say("The road to Crystallos winds past ten pools, each "
				.. "guarded by a golem of the elements. Their essences will "
				.. "rekindle our crystals.")
			eq.task_selector(offers)
		else
			e.self:Say("You have done all we can ask, " .. e.other:GetCleanName() .. ".")
		end
	elseif e.message:findi("pool") or e.message:findi("golem")
		or e.message:findi("essence") then
		e.self:Say("Walk into each pool and its golem rises. Slay it and the "
			.. "essence it carried can be yours -- six shards at a time. "
			.. "Combine the right pairings inside the crystal bases.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
