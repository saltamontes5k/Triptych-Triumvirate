-- [[
-- Aar`Kol (446204) -- Crystallos raid, Ice Constructs (third chamber).
-- Rasper: raidCrystallos.html (Ice Constructs).
--
-- Hits to ~12k, AE rampage. Spells:
--   * Freezing Sleetstorm (12116) -- PBAE 4k DoT, slows + snares on fade
--   * Guardian's Challenge (12113) -- 50-range PBAE 4k dd, 5k dot, 2k mana dot,
--     root + flux
--   * Sleetstorm (2148) -- PBAE 1.5k dd + melee/spell slow, 20 disease counters
-- Constructs spawn during the fight; they proc a 4s stun + knockback.
-- On death: Treasure_of_Aar_Kol (446262) + ice-wing lockout.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446262
local CONSTRUCT = 446222

local MY_X, MY_Y = -500, 1400

local engaged = false
local adds = {}

local SPELLS = { 12116, 12113, 2148 }

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("ice_cast", 20000)
			eq.set_timer("constructs", 45000)
			eq.zone_emote(15, "Aar`Kol turns toward the raid, rime crackling over his claws.")
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
			R.clear_list(adds)
			eq.stop_timer("ice_cast")
			eq.stop_timer("constructs")
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "ice_cast" then
		local spell = SPELLS[math.random(#SPELLS)]
		eq.zone_emote(13, "Aar`Kol gestures and a blast of glacial sleet erupts around the raid!")
		local t = R.alive_clients(MY_X, MY_Y, 120)
		if #t > 0 then
			for _, c in ipairs(t) do
				e.self:CastSpell(spell, c:GetID())
			end
		end
		eq.set_timer("ice_cast", 22000)
	elseif e.timer == "constructs" then
		eq.zone_emote(13, "Jagged ice constructs crawl forth, shards stabbing the raid!")
		local new = R.spawn_adds(CONSTRUCT, 3, MY_X, MY_Y, e.self:GetZ(), 70)
		for _, id in ipairs(new) do adds[#adds + 1] = id end
		eq.set_timer("constructs", 45000)
	end
end

function event_death_complete(e)
	R.clear_list(adds)
	eq.stop_timer("ice_cast")
	eq.stop_timer("constructs")
	R.chest(e.self, CHEST, "Crystallos: Ice Constructs")
	R.signal(R.SIG.ice)
	eq.zone_emote(15, "Aar`Kol shatters into a lattice of ice. The ice wing is breached.")
end
