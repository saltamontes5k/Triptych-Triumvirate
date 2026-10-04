-- a steamwork spy mk-I (439019) -- S.H.I.P. Workshop, by the entrance.
-- Grants the clockwork disguise used by the Disrupt the Workshop chain
-- (progression task 301001 and faction task 300033); the injured spy (439082)
-- and the courier chain check the sof.prog.disguise flag.
local prog = require("sof_progression")
local ILLUSION = 38390 -- Illusion: Junkyard Gnomework

function event_say(e)
	if e.message:findi("hail") then
		if not prog.has_flag(e.other, prog.FLG.disguise) then
			prog.set(e.other, prog.FLG.disguise, 1)
			e.other:CastSpell(ILLUSION, e.other:GetID())
			e.self:Say("*psst* Take this form, " .. e.other:GetCleanName()
				.. ". The workshop will see a steamwork now, not a warm body. "
				.. "The injured spy waits up past the spiral ramp.")
		else
			e.self:Say("You already wear our shape. The injured spy waits above.")
		end
	end
end
