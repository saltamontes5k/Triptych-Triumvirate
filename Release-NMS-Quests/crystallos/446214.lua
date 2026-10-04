-- [[
-- Kerafyrm the Awakened (446214) -- Crystallos raid, finale boss.
-- Rasper: raidCrystallos.html (Kerafyrm the Awakened).
--
-- Rooted, huge aggro range, summons at full hp, ~15k hits, single+AE rampage,
-- hatelist-wide spell interrupt every ~10s, random 3300 dd + flux.
-- Roughly every 30s a wing-blast emote -> 20k AE to either side (keep him
-- facing one way). Four Heralds (Charayan/Grendish/Jortrev/Susarrak) offer
-- "frustrate him" to block an emote-told AE (each on a cooldown) and give
-- 18s raid benefits. 75%-35%: wyvern assassins target the Heralds (killing
-- one loses its block); a crystal spawns ~1/min, splits 1->2->4 dealing
-- damage to anyone near. At 35% four Crusaders spawn (idle). At 4% the
-- Crusaders put Kerafyrm back to sleep and the loot chest spawns.
--
-- This is a simplified-but-faithful version: Herald blocks/benefits are
-- scripted; assassins + crystal-split are scripted spawns.
--]]

local R = require("sof_crystallos_raid")
local CHEST = 446269
local ASSASSIN, CRYSTAL = 446225, 446231

local MY_X, MY_Y = 1560, 400

local engaged = false
local assassins = {}
local crystals = {}
local assassins_done = false
local heralds_alive = true

local HERALD_NPCS = { 446215, 446216, 446217, 446218 }

-- one Herald may be told "frustrate him" to block the next big AE (flag on
-- this boss; the herald enforces its own cooldown via a local timer).
local block_next = false

local function check_heralds()
	for _, id in ipairs(HERALD_NPCS) do
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(id) then
			return true
		end
	end
	return false
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("interrupt", 10000)
			eq.set_timer("wingblast", 30000)
			eq.set_timer("assassins", 30000)
			eq.set_timer("crystal", 60000)
			eq.zone_emote(15, "Kerafyrm the Awakened opens its eyes. The world holds its breath.")
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
			assassins_done = false
			R.clear_list(assassins)
			R.clear_list(crystals)
			for _, t in ipairs({ "interrupt", "wingblast", "assassins", "crystal" }) do eq.stop_timer(t) end
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	local hp = e.self:GetHPRatio()

	if e.timer == "interrupt" then
		eq.zone_emote(13, "Kerafyrm's will cuts through the channel -- you can't concentrate!")
		for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 500)) do
			c:InterruptSpell(0)
		end
		eq.set_timer("interrupt", 10000)
		return
	end

	if e.timer == "wingblast" then
		if block_next then
			block_next = false
			eq.zone_emote(13, "A Herald frustrates Kerafyrm's wind -- the blast is swallowed whole!")
		else
			eq.zone_emote(13, "Kerafyrm flaps his wings and a mighty wind fills the chamber!")
			for _, c in ipairs(R.alive_clients(MY_X, MY_Y, 500)) do
				c:Damage(e.self, 20000, 0, 9)
			end
		end
		eq.set_timer("wingblast", 30000)
		return
	end

	if e.timer == "assassins" then
		-- 75-35% window: assassins hunt the Heralds
		if hp <= 75 and hp >= 35 then
			if not check_heralds() then
				heralds_alive = false
			end
			if heralds_alive then
				eq.zone_emote(13, "Wyvern assassins slip from the shadows, seeking the Heralds!")
				local new = R.spawn_adds(ASSASSIN, 2, MY_X, MY_Y, e.self:GetZ(), 120)
				for _, id in ipairs(new) do assassins[#assassins + 1] = id end
			end
		elseif hp < 35 and not assassins_done then
			assassins_done = true
			eq.zone_emote(13, "The wyvern assassins break off. At 4%, the Crusaders will act.")
			eq.stop_timer("assassins")
		end
		eq.set_timer("assassins", 30000)
		return
	end

	if e.timer == "crystal" then
		if hp <= 75 and hp >= 35 then
			eq.zone_emote(13, "A prismatic crystal manifests above Kerafyrm and splits, raining ruin!")
			local new = R.spawn_adds(CRYSTAL, 2, MY_X, MY_Y, e.self:GetZ() + 60, 40)
			for _, id in ipairs(new) do crystals[#crystals + 1] = id end
		end
		eq.set_timer("crystal", 60000)
	end
end

-- the "frustrate him" block is offered when any Herald is alive
-- (simplified: one shared cooldown; each Herald has a say handler below
--  via the herald NPC scripts that signal this boss).
function event_signal(e)
	if e.signal == 9001 then
		-- Herald "frustrate him" -> block the next wing blast
		block_next = true
		eq.zone_emote(13, "A Herald's warding wraps the chamber -- the next great blast is blocked!")
	end
end

function event_death_complete(e)
	R.clear_list(assassins)
	R.clear_list(crystals)
	for _, t in ipairs({ "interrupt", "wingblast", "assassins", "crystal" }) do eq.stop_timer(t) end
	R.chest(e.self, CHEST, "Crystallos: Kerafyrm")
	R.signal(R.SIG.kerafyrm)
	eq.zone_emote(15, "Kerafyrm shrieks as the Crusaders' binding takes hold once more. The Awakened sleeps.")
end
