-- The Mindblight (471001) -- SoD Citadel raid: The Mindblight.
-- Rasper: raidDiscord.html (Citadel event 1).
--
-- Simplified live encounter (the 5-directional cycle-to-35% win rule is
-- collapsed to four threshold cycles; un-killed oozes do not split into
-- five; Disgusting Goop on ooze death is not modelled):
--   * Room aura     -- anyone outside 150 units takes 8k + stun every 12s
--                      while the fight runs (live: 32k/tick + stun aura).
--   * 85/70/55/40%  -- the Mindblight dissolves into the walls: three
--                      mindgnawers and three oozes (12s apart) spawn; the
--                      Mindblight recoalesces 60s later. Below 40% it stays
--                      in the fight.
-- On death: Treasure_of_the_Mindblight chest + controller lockout.

local raid = require("sod_raids")

local CYCLES = { 85, 70, 55, 40 }

local engaged = false
local cycle_idx = 1
local cycling = false
local ooze_queue = 0
local adds = {}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function reset(e)
	engaged = false
	cycle_idx = 1
	cycling = false
	ooze_queue = 0
	clear_adds()
	for _, t in ipairs({ "aura", "ooze", "reform", "resetcheck" }) do
		eq.stop_timer(t)
	end
	raid.set_invul(e.self, false)
	e.self:Heal()
	eq.zone_emote(15, "The Mindblight sinks back into the citadel floor, humming.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("aura", 12000)
			eq.zone_emote(15, "The Mindblight convulses -- stay inside the chamber or be unmade!")
		end
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then reset(e) end
		return
	end
	if not engaged then return end

	if e.timer == "aura" then
		-- room aura: punish anyone hiding outside the chamber
		local outside = 0
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)) do
			if math.abs(client:GetX() - e.self:GetX()) > 150
				or math.abs(client:GetY() - e.self:GetY()) > 150 then
				raid.hit(e.self, client, 8000)
				outside = outside + 1
			end
		end
		if outside > 0 then
			eq.zone_emote(15, "The walls of the chamber sear those who hide beyond them!")
		end
	elseif e.timer == "ooze" then
		if ooze_queue > 0 then
			ooze_queue = ooze_queue - 1
			local mob = raid.spawn_add(raid.ADD.ooze, e.self, 70)
			if mob then adds[#adds + 1] = mob:GetID() end
			eq.zone_emote(15, "A Mindshear Ooze bloats out of the walls!")
			if ooze_queue > 0 then eq.set_timer("ooze", 12000) end
		end
	elseif e.timer == "reform" then
		cycling = false
		raid.set_invul(e.self, false)
		eq.zone_emote(15, "The Mindblight recoalesces from the stonework!")
	end

	-- threshold cycles
	if not cycling and cycle_idx <= #CYCLES and e.self:GetHPRatio() <= CYCLES[cycle_idx] then
		cycle_idx = cycle_idx + 1
		cycling = true
		raid.set_invul(e.self, true)
		for i = 1, 3 do
			local mob = raid.spawn_add(raid.ADD.mindgnawer, e.self, 80)
			if mob then adds[#adds + 1] = mob:GetID() end
		end
		ooze_queue = 3
		eq.set_timer("ooze", 3000)
		eq.set_timer("reform", 60000)
		eq.zone_emote(15, "The Mindblight dissolves into the walls -- mindgnawers and oozes pour out!")
	end
end

function event_death_complete(e)
	clear_adds()
	eq.stop_timer("ooze")
	eq.zone_emote(15, "The Mindblight bursts apart -- the citadel's first room falls silent.")
	raid.spawn_chest(e, raid.CHEST.MINDBLIGHT)
	eq.signal(raid.CTRL.MINDBLIGHT, 1)
end
