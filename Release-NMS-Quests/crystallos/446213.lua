-- [[
-- Vyskudra the Ancient (446213) -- Crystallos raid, wing boss (Air).
-- Rasper: raidCrystallos.html (Vyskudra).
--
-- Hish`Itar gates the approach (knockback aura; dies to start the real
-- event). Then 18 drakes spawn in 3-at-a-time waves over ~5 minutes; kill
-- fast because Vyskudra spawns 5 minutes after Hish`Itar. Vyskudra:
--   ~12k hits, AE rampage; emoted 15k frontal/rear AEs + flux wingflap;
--   Unstable Charge (18s cure-or-15k-AE); a large tornado at the room's
--   center -- stay inside or get 8k dd + stun; storm entities/spawn.
-- On death: Treasure_of_Vyskudra (446268) + air-wing boss chest.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446268
local HISHITAR = 446206
local DRAKE_SMALL, TORNADO, SQUALL = 446232, 446230, 446226

local MY_X, MY_Y = 1780, 1740

local engaged = false
local waves = 0
local drakes = {}

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("drake_wave", 20000)
			eq.set_timer("tornado", 30000)
			eq.zone_emote(15, "Vyskudra rises on a storm of wings, lightning snapping at her flanks.")
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
			waves = 0
			R.clear_list(drakes)
			eq.stop_timer("drake_wave")
			eq.stop_timer("tornado")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "drake_wave" then
		if waves < 6 then
			eq.zone_emote(13, "Vyskudra howls and more storm drakes pour into the chamber!")
			local new = R.spawn_adds(DRAKE_SMALL, 3, MY_X, MY_Y, e.self:GetZ(), 100)
			for _, id in ipairs(new) do drakes[#drakes + 1] = id end
			waves = waves + 1
		end
		eq.set_timer("drake_wave", 20000)
		return
	end

	if e.timer == "tornado" then
		eq.zone_emote(13, "The storm gathers into distinct units! Stay inside the great tornado!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 100)) do
			-- outside the central tornado -> bombarded
			if math.random(2) == 1 then
				c:Damage(e.self, 8000, 0, 9)
			end
		end
		eq.set_timer("tornado", 30000)
	end
end

function event_death_complete(e)
	R.clear_list(drakes)
	eq.stop_timer("drake_wave")
	eq.stop_timer("tornado")
	R.chest(e.self, CHEST, "Crystallos: Aerius Windfury")
	R.signal(R.SIG.air)
	eq.zone_emote(15, "The air falls still. Vyskudra's storm is no more.")
end
