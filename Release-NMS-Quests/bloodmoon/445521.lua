-- [[
-- Malkazor Darkshadow (445521) -- Bloodmoon raid 2, version 2.
-- Rasper: raidBloodmoon2.html. Leashed. Conjures a roaming vortex dealing
-- ~5.5k per tick to anyone standing in it (approximated as a pulse).
-- ]]
local M = require("sof_bloodmoon_raid")

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 2 then return end
	eq.set_timer("vortex", 6000)
end

function event_timer(e)
	if e.timer == "vortex" then
		M.aura_damage(e.self, 60, 5500, "Malkazor Darkshadow conjures a vortex of dark energy.")
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
end
