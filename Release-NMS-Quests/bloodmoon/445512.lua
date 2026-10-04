-- [[
-- Wilnok Boneshard (445512) -- Bloodmoon raid 1 (The Fanged Moon), version 1.
-- Rasper: raidBloodmoon1.html. The two brothers must stay within 5% or
-- both heal to full; mezzable haunts and immune dominated spirits spawn.
-- Chest + flag fire when both brothers and Vesthun are dead.
-- ]]
local M = require("sof_bloodmoon_raid")
local SELF_ID, PARTNER, VESTHUN = 445512, 445511, 445510
local HAUNT, DOMINATED, CHEST = 445515, 445516, 445540
local BUCKET = "sof.bm.raid.fanged_moon"

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 1 then return end
	eq.set_timer("balance", 5000)
	eq.set_timer("adds", 40000)
end

function event_timer(e)
	if e.timer == "balance" then
		local a, b = M.npc_by_id(SELF_ID), M.npc_by_id(PARTNER)
		if a and a.valid and b and b.valid and a:GetHPRatio() > 0 and b:GetHPRatio() > 0 then
			if math.abs(a:GetHPRatio() - b:GetHPRatio()) > 5 then
				eq.zone_emote(15, "The Boneshard brothers' bond knits their wounds closed.")
				M.max_heal(a); M.max_heal(b)
			end
		end
	elseif e.timer == "adds" then
		M.spawn_adds(HAUNT, 2, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
		M.spawn_adds(DOMINATED, 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
	if M.version() ~= 1 then return end
	if not M.alive_type(PARTNER) and not M.alive_type(VESTHUN) then
		M.chest(e.self, CHEST, "Bloodmoon: The Fanged Moon")
		M.flag_all(BUCKET, 1)
		M.signal(1, 1101)
	end
end
