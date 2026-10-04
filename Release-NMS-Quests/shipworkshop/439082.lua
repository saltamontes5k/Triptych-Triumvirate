-- an injured spy (439082) -- S.H.I.P. Workshop, up past the spiral ramp.
-- The [Spy Report] (29065) for the Search for the Ultimate Story chain.
local prog = require("sof_progression")

function event_say(e)
	if e.message:findi("hail") then
		if not prog.has_flag(e.other, prog.FLG.disguise)
			and not e.other:IsTaskCompleted(prog.TASK_DISRUPT) then
			e.self:Say("You... you are no steamwork. They will hear you "
				.. "before they see you. Get a [disguise] from the spy by "
				.. "the doors, or leave me to bleed in peace.")
			return
		end
		if prog.has_flag(e.other, prog.FLG.spy_report) then
			e.self:Say("Go -- Gurtrude needs that report more than I need "
				.. "company.")
			return
		end
		prog.set(e.other, prog.FLG.spy_report, 1)
		e.other:SummonItem(prog.ITEM.spy_report)
		e.self:Say("You came. Good. Take the [spy report] to Gurtrude in "
			.. "Fortress Mechanotus. Tell her... tell her the workshop "
			.. "counts its clocks by the thousand.")
	end
end
