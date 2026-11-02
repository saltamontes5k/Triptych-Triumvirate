-- #Chief_Machinist_Bildarol (436182) -- the Ak`Anon Strike Force clockwork tasks (Model XLII Spatial Temporal Oculus parts).
-- Hand-authored; follows the sof_content/gen_givers.py giver shape.
local TASKS = {300000, 300002, 300003, 300004, 300005, 300006, 300007, 300008, 300009, 300010, 300011, 300020, 300021, 300022, 300023, 300024, 300026, 300027, 300028, 300029, 300030, 300031, 300032, 300033, 300037}

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hm? Oh -- a surface walker with all limbs intact. Rare. I have [task]s if you have the nerve.")
	elseif e.message:findi("task") or e.message:findi("work") or e.message:findi("offer") or e.message:findi("jobs") then
		e.self:Say("These are the duties I can entrust to you, " .. e.other:GetCleanName() .. ".")
		eq.task_selector(TASKS)
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
