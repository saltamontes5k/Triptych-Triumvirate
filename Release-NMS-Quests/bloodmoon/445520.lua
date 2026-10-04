-- [[
-- Balvik Spiritshadow (445520) -- Bloodmoon raid 2, version 2.
-- Rasper: raidBloodmoon2.html. Leashed to the room. Invokes a roaming
-- healing aura that tops up either orc inside it.
-- ]]
local M = require("sof_bloodmoon_raid")
local ORCS = { 445521, 445522, 445523, 445524, 445525 }

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 2 then return end
	eq.set_timer("heal", 10000)
end

function event_timer(e)
	if e.timer ~= "heal" then return end
	eq.zone_emote(15, "Balvik Spiritshadow invokes an aura of healing power.")
	for _, id in ipairs(ORCS) do
		local n = M.npc_by_id(id)
		if n and n.valid and n:GetHPRatio() > 0
			and math.abs(n:GetX() - e.self:GetX()) <= 60 then
			M.max_heal(n)
		end
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
end
