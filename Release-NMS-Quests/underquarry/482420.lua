-- Wrath_of_Brath (482420) -- Underquarry v1 raid.
-- Tracked source: Release-NMS-Quests/underquarry/482420.lua.
-- Rasper: miscRaidProg.html.
--
-- Simplified live encounter:
--   * every 35s a seismic slam (7k AE, 150 range);
--   * every 60s a boulder volley -- three raiders take 5k;
--   * every 90s two rubble golems shake loose;
--   * 25% -- the wrath hardens (attack speed rises; slams every 25s).
-- On death: Treasure_of_Brath chest + 72h lockout.

local prog = require("uf_progression")

local RUBBLE = 482421
local CHEST = prog.CHEST.brath
local LOCKOUT = eq.seconds("72h")

local engaged = false
local enraged = false
local adds = {}

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("slam", 35000)
	eq.set_timer("volley", 60000)
	eq.set_timer("rubble", 90000)
	eq.zone_emote(15, "The quarry itself stands up. BRATH IS WRATHFUL!")
end

function event_combat(e)
	if e.joined then
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			enraged = false
			prog.clear_adds(adds)
			adds = {}
			for _, t in ipairs({ "slam", "volley", "rubble", "slam_fast" }) do
				eq.stop_timer(t)
			end
			e.self:Heal()
			eq.zone_emote(15, "Brath crumbles back into the quarry wall. The event has reset.")
		end
		return
	end
	if not engaged then return end
	local x, y = e.self:GetX(), e.self:GetY()

	if e.timer == "slam" or e.timer == "slam_fast" then
		eq.zone_emote(13, "Brath slams the ground -- the whole quarry shakes!")
		for _, c in ipairs(prog.alive_clients(x, y, 150)) do
			c:Damage(e.self, 7000, 0, 28)
		end
		eq.set_timer(enraged and "slam_fast" or "slam",
			(enraged and 25000 or 35000))
	elseif e.timer == "volley" then
		local targets = prog.alive_clients(x, y, 300)
		for i = 1, math.min(3, #targets) do
			local victim = targets[math.random(#targets)]
			eq.zone_emote(13, "A boulder smashes into " .. victim:GetCleanName() .. "!")
			victim:Damage(e.self, 5000, 0, 28)
		end
	elseif e.timer == "rubble" then
		for i = 1, 2 do
			local m = eq.spawn2(RUBBLE, 0, 0, x + math.random(-60, 60),
				y + math.random(-60, 60), e.self:GetZ(), 0)
			if m then adds[#adds + 1] = m:GetID() end
		end
		eq.zone_emote(15, "Rubble golems shake loose from Brath's hide!")
	end

	if not enraged and e.self:GetHPRatio() <= 25 then
		enraged = true
		eq.stop_timer("slam")
		eq.set_timer("slam_fast", 25000)
		eq.zone_emote(15, "Brath's stone skin cracks -- his wrath quickens!")
	end
end

function event_death_complete(e)
	prog.clear_adds(adds)
	adds = {}
	for _, t in ipairs({ "slam", "volley", "rubble", "slam_fast" }) do
		eq.stop_timer(t)
	end
	eq.zone_emote(15, "Brath collapses into rubble. The quarry is still.")
	prog.spawn_chest(e, CHEST, "The Wrath of Brath")
	local exp = eq.get_expedition()
	if exp.valid and not exp:HasLockout("The Wrath of Brath") then
		exp:AddLockout("The Wrath of Brath", LOCKOUT)
	end
end
