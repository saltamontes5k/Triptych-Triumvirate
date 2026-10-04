-- Sparks Diggleknob (436012) -- the Oil Cans (300035) distillery.
-- Deliver activities credit the hand-ins; Sparks refines and passes the
-- next item down the chain (High Quality Oil, then the Gear Saw).
local fort = require("sof_fortress")

function event_say(e)
	if e.message:findi("hail") then
		if e.other:IsTaskActive(fort.TASK_OILCANS) then
			e.self:Say("Tinmyn's can, eh? His standards would kill a "
				.. "tradesman. First a Can of [Dirty Oil] -- the menders "
				.. "slop it about everywhere.")
		else
			e.self:Say("Hail, " .. e.other:GetCleanName() .. ". Fresh oil, "
				.. "honest measure.")
		end
	elseif e.message:findi("dirty oil") then
		e.self:Say("The steamwork menders leak it by the barrel. Smell for "
			.. "regret.")
	elseif e.message:findi("warm oil") then
		e.self:Say("Warmer. The troopers and soldiers run hot -- wring it "
			.. "out of them.")
	elseif e.message:findi("unrefined") then
		e.self:Say("Wretched, Murky, and Sticky -- the oil oozes south of "
			.. "the oilsheets. Bring me three cans of the [unrefined] "
			.. "stuff and I will do the rest.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:IsTaskActive(fort.TASK_OILCANS) then
		local t = e.trade
		-- unrefined x3 -> distill the High Quality can
		if t.click1 == fort.ITEM.unrefined_oil then
			local cnt = (t.click1 == fort.ITEM.unrefined_oil and 1 or 0)
				+ (t.click2 == fort.ITEM.unrefined_oil and 1 or 0)
				+ (t.click3 == fort.ITEM.unrefined_oil and 1 or 0)
				+ (t.click4 == fort.ITEM.unrefined_oil and 1 or 0)
			if cnt >= 3 and not fort.activity_done(e.other, fort.TASK_OILCANS, 5) then
				e.self:Say("Simmer, strain, decant... one Can of High "
					.. "Quality Oil. Tinmyn will weep.")
				e.other:SummonItem(fort.ITEM.hq_oil)
				return
			end
		end
		-- metal cutting blade -> fashion the Oil-Powered Gear Saw
		if t.click1 == fort.ITEM.blade then
			e.self:Say("A tooth here, a wheel there... one Oil-Powered Gear "
				.. "Saw. Tinmyn will hear it singing from here.")
			e.other:SummonItem(fort.ITEM.gear_saw)
			return
		end
		-- taste notes on the earlier samples
		if t.click1 == fort.ITEM.dirty_oil then
			e.self:Say("Bah -- dirt and regret. Not even Tinmyn deserves "
				.. "this. Try the [warm oil].")
			return
		end
		if t.click1 == fort.ITEM.warm_oil then
			e.self:Say("Warmer, but still gutter-swill. The [unrefined] "
				.. "ooze oil is what I need -- three cans.")
			return
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
