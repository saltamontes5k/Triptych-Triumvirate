-- Pathfinder_Odele (487100) -- Brell's Rest war camp.
--   * Lichen Creep group mission 304003 (Clearing the Creep).
--   * T7 raid "A Cunning Plan" (Lichen Creep v1): mission done +
--     one Emblem of Brell handed in (consumed). Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local TASK = prog.TASK_CREEP
local KEY = prog.ITEM.emblem

local cunning_dz = prog.dz("A Cunning Plan", "lichencreep", 1,
	{ 527.0, -1414.0, 22.0 })

local function gate(e)
	if not prog.task_done(e.other, TASK) then
		return false, "The creep swallows the unwary. Finish [Clearing the "
			.. "Creep] so my maps mean something."
	end
	return true
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". Lichen Creep is "
			.. "worse than the maps say -- something in there is [thinking]. "
			.. "Or ask me about the [task] of marking it.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") then
		e.self:Say("This duty I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector({ TASK })
	elseif e.message:findi("thinking") or e.message:findi("cunning") or e.message:findi("raid") then
		local ok, why = gate(e)
		if not ok then
			e.self:Say(why)
			return
		end
		e.self:Say("Vzarn. A lost Autarchian mind, still scheming. Hand me one "
			.. "[Emblem of Brell] and I will show you his warren.")
	elseif e.message:findi("ready") or e.message:findi("enter") then
		prog.ready(e)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, { item1 = KEY }) then
		local ok, why = gate(e)
		if not ok then
			e.other:SummonItem(KEY)
			e.self:Say(why)
			return
		end
		prog.request_raid(e, cunning_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
