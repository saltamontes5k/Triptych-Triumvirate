-- [[
-- Keeper of the Stones (446201) -- Crystallos raid, Keepers of Stone.
-- Rasper: raidCrystallos.html (Keepers of Stone).
--
-- Rooted; ~10k hits, single+AE rampage, flurries, self 100 melee/500 spell DS.
--   * 80% -- wave of elemental adds (6k hit, ~50% melee mitigation; mezzable)
--   * 50% -- persistent 25% melee-slow aura
--   * 30% -- wave of drake adds (proc frontal AE attack-debuff; mezzable)
-- The run-up has bounding "boulder" traps that root / nuke.
-- On death: Treasure_of_the_Keeper (446261) + earth-wing lockout.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446261
local ELEM_ADD, DRAKE_ADD = 446224, 446223

local MY_X, MY_Y = 560, -500

local engaged = false
local elems_done, drakes_done = false, false
local adds = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("boulder", 40000)
			eq.zone_emote(15, "The Keeper of the Stones rumbles awake. The earth itself protests.")
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
			elems_done, drakes_done = false, false
			R.clear_list(adds)
			eq.stop_timer("boulder")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "boulder" then
		eq.zone_emote(13, "A great stone boulder crashes down the tunnel!")
		local t = R.alive_clients(MY_X, MY_Y, 400)
		if #t > 0 then
			local v = t[math.random(#t)]
			if math.random(4) == 1 then
				v:Damage(e.self, 20000, 0, 1)
			else
				v:Damage(e.self, 10000, 0, 1)
			end
		end
		eq.set_timer("boulder", 40000)
		return
	end

	-- 80% elemental adds
	if not elems_done and e.self:GetHPRatio() <= 80 then
		elems_done = true
		eq.zone_emote(13, "Elementals surge from the stone to defend their keeper!")
		adds = R.spawn_adds(ELEM_ADD, 4, MY_X, MY_Y, e.self:GetZ(), 60)
	end

	-- 30% drake adds
	if not drakes_done and e.self:GetHPRatio() <= 30 then
		drakes_done = true
		eq.zone_emote(13, "Drakes swoop in, their breath stripping armor from the raid!")
		local d = R.spawn_adds(DRAKE_ADD, 3, MY_X, MY_Y, e.self:GetZ(), 70)
		for _, id in ipairs(d) do adds[#adds + 1] = id end
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	eq.stop_timer("boulder")
	R.chest(e.self, CHEST, "Crystallos: Keepers of Stone")
	R.signal(R.SIG.earth)
	eq.zone_emote(15, "The Keeper crumbles. The earth wing's heart is stilled.")
end
