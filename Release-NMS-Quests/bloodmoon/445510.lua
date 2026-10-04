-- [[
-- Vesthun Wolfpaw (445510) -- Bloodmoon raid 1 (The Fanged Moon), version 1.
-- Rasper: raidBloodmoon1.html. Script-driven (npc_spells_id = 0).
-- Fury builds every 30s (emote stand-in); 75/50/25% spawn 4 worgs + 2
-- wereorcs; mezzable haunts trickle in. Adds do not despawn on death.
-- ]]
local M = require("sof_bloodmoon_raid")
local WORG, WEREORC, HAUNT = 445513, 445514, 445515
local waves = {}

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 1 then return end
	eq.set_timer("fury", 30000)
	eq.set_timer("haunt", 45000)
	eq.set_timer("watch", 2000)
end

function event_timer(e)
	if e.timer == "fury" then
		eq.zone_emote(15, "Vesthun Wolfpaw's fury begins to build.")
	elseif e.timer == "haunt" then
		M.spawn_adds(HAUNT, 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
	elseif e.timer == "watch" then
		local r = e.self:GetHPRatio()
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		for _, w in ipairs({ 75, 50, 25 }) do
			if r <= w and not waves[w] then
				waves[w] = true
				M.spawn_adds(WORG, 4, x, y, z, 40)
				M.spawn_adds(WEREORC, 2, x, y, z, 40)
				eq.zone_emote(15, "Bloodmoon worgs and wereorcs surge into the hall!")
			end
		end
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
end
