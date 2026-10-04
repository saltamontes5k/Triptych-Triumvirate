-- Quarrymaster_Torbjorn (482400) -- Brell's Rest war camp.
--   * Underquarry group mission 304001 (Breaking the Quarry).
--   * T6 keyed raid "The Wrath of Brath" (Underquarry v1): mission done +
--     one Coin of Brell handed in (consumed). Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local TASK = prog.TASK_QUARRY
local KEY = prog.ITEM.coin

local brath_dz = prog.dz("The Wrath of Brath", "underquarry", 1,
	{ 25.67, 218.22, -195.84 })

local function gate(e)
	if not prog.task_done(e.other, TASK) then
		return false, "My quarry routes are worthless until someone walks "
			.. "them. Finish [Breaking the Quarry] first."
	end
	return true
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The Underquarry "
			.. "has gone over to the hive, stone by stone. Ask me about a "
			.. "[task], or about the [wrath] sleeping in the deep cuts.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") then
		e.self:Say("This duty I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector({ TASK })
	elseif e.message:findi("wrath") or e.message:findi("raid") or e.message:findi("brath") then
		local ok, why = gate(e)
		if not ok then
			e.self:Say(why)
			return
		end
		e.self:Say("Brath is the quarry's own anger, given stone. Hand me one "
			.. "[Coin of Brell] to seal the bargain and the deep cuts open.")
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
		prog.request_raid(e, brath_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
