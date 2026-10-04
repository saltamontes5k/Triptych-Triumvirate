-- Mycologist_Fenna (481200) -- Brell's Rest war camp.
--   * Fungal Forest group mission 304004 (Spore and Loathing).
--   * T7 raid "The Fungal Corruption" (Fungal Forest v1): mission done +
--     one Emblem of Brell handed in (consumed). Rasper: miscRaidProg.html.
local prog = require("uf_progression")

local TASK = prog.TASK_FUNGAL
local KEY = prog.ITEM.emblem

local fungal_dz = prog.dz("The Fungal Corruption", "fungalforest", 1,
	{ -2141.0, 632.375, 223.75 })

local function gate(e)
	if not prog.task_done(e.other, TASK) then
		return false, "You cannot tell rot from bloom yet. Finish [Spore and "
			.. "Loathing] before I let you near the corruption."
	end
	return true
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetCleanName() .. ". The Fungal Forest "
			.. "is blooming wrong this season -- deliberately wrong. Ask me "
			.. "about a [task], or about the [corruption].")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") then
		e.self:Say("This duty I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector({ TASK })
	elseif e.message:findi("corruption") or e.message:findi("raid") then
		local ok, why = gate(e)
		if not ok then
			e.self:Say(why)
			return
		end
		e.self:Say("The corruption has a heart of spores. Hand me one [Emblem "
			.. "of Brell] and I will mark the path to it.")
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
		prog.request_raid(e, fungal_dz, 80, nil)
		return
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
