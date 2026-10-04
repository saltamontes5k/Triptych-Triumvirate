-- [[
-- Crazok Moonfang (445525) -- Bloodmoon raid 2 finale, version 2.
-- Rasper: raidBloodmoon2.html. AE rampage, Crazok's Bite (36 disease
-- counters -> charm if uncured), roaming fear aura. Win chest on death.
-- ]]
local M = require("sof_bloodmoon_raid")
local CHEST = 445541
local BUCKET = "sof.bm.raid.crazok"

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 2 then return end
	eq.set_timer("bite", 25000)
	eq.set_timer("fear", 20000)
end

function event_timer(e)
	if e.timer == "bite" then
		eq.zone_emote(15, "Crazok Moonfang's bite courses with disease! Cure it, and fast.")
	elseif e.timer == "fear" then
		eq.zone_emote(15, "Crazok Moonfang's aura radiates terror.")
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
	if M.version() ~= 2 then return end
	M.chest(e.self, CHEST, "Bloodmoon: Crazok Moonfang")
	M.flag_all(BUCKET, 1)
	M.signal(2, 1102)
end
