-- #Commander_Gearwell (441711) -- openGyroZeka top-floor rare.
-- Rasper: "procs a 1k dot" (npc_spells 1520007951, Static Bolt) and
-- "can dispel itself" (purges its own debuffs on a timer).

local CANCEL_MAGIC = 48

function event_combat(e)
	if e.joined then
		e.self:SetTimer("purge", 45000)
	else
		e.self:StopTimer("purge")
	end
end

function event_timer(e)
	if e.timer == "purge" then
		e.self:Emote("vents hissing steam, scouring the grime from its joints.")
		e.self:CastSpell(CANCEL_MAGIC, e.self:GetID())
	end
end
