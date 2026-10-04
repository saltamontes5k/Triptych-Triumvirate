-- [[
-- Hish`Itar the Stormwave (446206) -- Crystallos raid, Air wing approach.
-- Rasper: raidCrystallos.html (Vyskudra).
-- Rooted; knockback aura prevents passing; procs 5k dd + easily-resisted
-- stun. Its death starts the Vyskudra drake waves. No chest.
--]]
local R = require("sof_crystallos_raid")
local MY_X, MY_Y = 780, -760

local engaged = false

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("knockback", 25000)
			eq.zone_emote(15, "Hish`Itar the Stormwave bars the way, a wall of screaming wind.")
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
			eq.stop_timer("knockback")
			e.self:Heal()
		end
		return
	end
	if e.timer == "knockback" then
		eq.zone_emote(13, "Hish`Itar's knockback aura hurls the raid back!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 150)) do
			c:Damage(e.self, 5000, 0, 9)
		end
		eq.set_timer("knockback", 25000)
	end
end

function event_death_complete(e)
	eq.stop_timer("knockback")
	eq.zone_emote(15, "The stormwall collapses. Vyskudra's approach is open -- but the countdown has begun.")
end
