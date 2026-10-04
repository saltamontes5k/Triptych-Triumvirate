-- [[
-- Ki`Mrash (446208) -- Crystallos raid, basement guard (before Brood Mother).
-- Rasper: raidCrystallos.html (Brood Mother Visziaj).
-- Like Dar`Kelor but AE rampage instead of flurry; 10k PBAE + flux. No chest.
--]]
local R = require("sof_crystallos_raid")
local MY_X, MY_Y = -220, 120

local engaged = false

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("flux", 25000)
			eq.zone_emote(15, "Ki`Mrash lumbers up, and the chamber trembles.")
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			eq.stop_timer("flux")
			e.self:Heal()
		end
		return
	end
	if e.timer == "flux" then
		eq.zone_emote(13, "Ki`Mrash pounds the ground -- a devastating pulse!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 120)) do
			c:Damage(e.self, 10000, 0, 8)
		end
		eq.set_timer("flux", 25000)
	end
end

function event_death_complete(e)
	eq.stop_timer("flux")
end
