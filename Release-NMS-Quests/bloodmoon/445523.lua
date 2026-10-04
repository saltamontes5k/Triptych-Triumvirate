-- [[
-- Korvak Stonefire (445523) -- Bloodmoon raid 2, version 2.
-- Rasper: raidBloodmoon2.html. Fire aura deals ~6k to everyone inside.
-- While Korvak or Harlos lives the Earthquake aura also pulses.
-- ]]
local M = require("sof_bloodmoon_raid")

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 2 then return end
	eq.set_timer("fire", 6000)
end

function event_timer(e)
	if e.timer == "fire" then
		M.aura_damage(e.self, 60, 6000, "Korvak Stonefire's fire aura sears the room.")
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
end
