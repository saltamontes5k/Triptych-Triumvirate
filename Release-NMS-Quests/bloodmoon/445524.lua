-- [[
-- Harlos Stonethunder (445524) -- Bloodmoon raid 2, version 2.
-- Rasper: raidBloodmoon2.html. Lightning aura casts a ~3.5k AE on everyone
-- inside (scaling with the number of people); the Earthquake aura adds a
-- 4.5k dot + snare while either aura boss lives.
-- ]]
local M = require("sof_bloodmoon_raid")

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 2 then return end
	eq.set_timer("storm", 6000)
end

function event_timer(e)
	if e.timer == "storm" then
		M.aura_damage(e.self, 60, 3500, "Harlos Stonethunder's lightning aura crackles.")
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
end
