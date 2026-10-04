-- Foreman_Bagrinhold (486200) -- Brell's Rest war camp.
--   * Foundation group mission 304000 (Clogging the Foundations).
--   * T6 keyed raid "Masked Invaders" (Foundation v1): mission done +
--     one Coin of Brell handed in (consumed). Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local TASK = prog.TASK_FOUNDATION
local KEY = prog.ITEM.coin

local masked_dz = prog.dz("Masked Invaders", "foundation", 1,
	{ 1163.0, -1111.42, -207.27 })

local function gate(e)
	if not prog.task_done(e.other, TASK) then
		return false, "The Foundation is unmapped. Finish [Clogging the "
			.. "Foundations] before I commit a raid to the lower works."
	end
	return true
end

local function offer_tasks(e)
	e.self:Say("This duty I can entrust to you, " .. e.other:GetCleanName() .. ".")
	eq.task_selector({ TASK })
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The Foundation's "
			.. "lower works crawl with bellikos. Ask me about a [task], or "
			.. "about the [masked] invaders the scouts keep swearing they saw.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") then
		offer_tasks(e)
	elseif e.message:findi("masked") or e.message:findi("raid") or e.message:findi("invaders") then
		local ok, why = gate(e)
		if not ok then
			e.self:Say(why)
			return
		end
		e.self:Say("The masked ones wear bellikos faces. Hand me one [Coin of "
			.. "Brell] to seal the bargain and I will open their hall to you.")
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
		prog.request_raid(e, masked_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
