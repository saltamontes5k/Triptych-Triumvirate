-- Octa the Collector (436133) -- Fortress Mechanotus open-world raid target.
-- Rasper: openFortress.html -- "It starts out non-agro roaming around
-- repairing any damaged zone trash. After attacking for a bit it activates
-- and starts fighting back... it summons adds which can AE and if absorbed
-- by Octa trigger a bigger AE or buff Octa in some way."
--
-- Simplified encounter (the idle repair roam is not modelled):
--   * aggroradius 0: Octa never opens -- it must be attacked first.
--   * while engaged, a large systems unit spawns every ~40s (cap 6 alive).
--   * absorbed adds punish or empower Octa (adds signal 436133 on death):
--       1 mechanic -> Octa knits its plating back (heals 8%)
--       2 mender   -> absorbed steam vents: Release of Steam PBAE
--       3 trooper  -> Octa overcharges 5%
--       4 reaper   -> absorbed lifeforce: Blood of Fire AE + Octa heals 10%
-- Stats/loot: utils/sql/20260928_sof_fortress_rares.sql (loot table 93838
-- keeps the live-parse decoders/armor/named drops).

local SPELL_STEAM = 7739 -- Release of Steam (Octa's own PBAE)
local SPELL_FIRE = 9027  -- Blood of Fire (reaper-absorb punish)

local function alive_adds()
	local count = 0
	local list = eq.get_entity_list():GetNPCList()
	for npc in list do
		if npc.valid and npc:GetNPCTypeID() >= 436710 and npc:GetNPCTypeID() <= 436713 then
			count = count + 1
		end
	end
	return count
end

function event_combat(e)
	if e.joined then
		eq.zone_emote(15, "Octa the Collector's servos whine. 'UNAUTHORIZED ORGANICS DETECTED. INITIATING RECLAMATION.'")
		eq.set_timer("systems", 40000)
	else
		eq.stop_timer("systems")
		eq.set_timer("resetcheck", 30000)
	end
end

function event_timer(e)
	if e.timer == "systems" then
		if alive_adds() >= 6 then return end
		local which = 436710 + math.random(0, 3)
		local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
		local add = eq.spawn2(which, 0, 0, x + math.random(-40, 40), y + math.random(-40, 40), z, 0)
		if add ~= nil then
			local t = e.self:GetTarget()
			if t ~= nil then add:AddToHateList(t, 1) end
			eq.zone_emote(15, "A large systems unit drops from Octa's maintenance bay!")
		end
	elseif e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			eq.stop_timer("resetcheck")
			e.self:Heal()
			eq.zone_emote(15, "Octa the Collector powers down and resumes its rounds.")
		end
	end
end

function event_signal(e)
	if e.signal == 1 then
		e.self:Heal(8)
		eq.zone_emote(15, "Octa the Collector knits its new plating shut. (" .. e.self:GetHPRatio() .. "%)")
	elseif e.signal == 2 then
		e.self:CastSpell(SPELL_STEAM, e.self:GetID())
		eq.zone_emote(15, "The absorbed mender's steam vents through Octa's hull!")
	elseif e.signal == 3 then
		e.self:Heal(5)
		eq.zone_emote(15, "Octa the Collector overcharges on the wrecked trooper's coils.")
	elseif e.signal == 4 then
		e.self:CastSpell(SPELL_FIRE, e.self:GetID())
		e.self:Heal(10)
		eq.zone_emote(15, "Octa the Collector drinks the reaper's harvested lifeforce!")
	end
end

function event_death_complete(e)
	eq.stop_timer("systems")
	eq.zone_emote(15, "Octa the Collector collapses into a heap of salvaged parts.")
end
