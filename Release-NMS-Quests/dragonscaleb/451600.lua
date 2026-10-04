-- [[
-- Big Bynn I (451600) -- Big Bynn's Lair, dragonscaleb version 52.
-- Rasper: raidBigBynn.html. Script-driven (npc_spells_id = 0).
-- Tinmizer (451601) says "begin" to wake him (signal 1).
--
-- Simplified but complete:
--   * 90/80/70/60/50% -- spawn 5 faycite crystals; after 20s any survivors
--     are "eaten"; if more than one survives, Big Bynn heals and casts the
--     phase PBAE;
--   * 40% -- one-time When Sparks Fly + Fizzle PBAEs;
--   * swallow -- every 60s a group is "swallowed": 6 stomach crystals spawn
--     and must be destroyed within 150s or the raid takes a 90k DT;
--   * 10% -- Crystal Fever, deactivates, three core golems spawn; when the
--     golems die he wakes and casts Crystal Fever often to the death.
-- On death: punchable Treasure_of_Big_Bynn + flag + lockout signal.
-- ]]
local M = require("sof_dsb_raid")

local GOLEM, STOMACH, RAT = 451607, 451608, 451609
local CHEST, CTRL = 451620, 451631
local BUCKET = "sof.dsb.raid.bigbynn"

-- hp threshold -> crystal npc + phase PBAE message
local PHASES = {
	[90] = { crystal = 451602, msg = "Blaze of Glory" },
	[80] = { crystal = 451603,  msg = "Shiverspine" },
	[70] = { crystal = 451604, msg = "Skyslam" },
	[60] = { crystal = 451605,   msg = "Frenzied Breath" },
	[50] = { crystal = 451606,    msg = "Fetid Stench" },
}
local ORDER = { 90, 80, 70, 60, 50 }

local awake = false
local engaged = false
local fired = {}
local sparks_done = false
local golems_up = false
local golem_set = false
local swallowed = false

local function clear_crystals(t)
	local list = eq.get_entity_list():GetNPCList()
	if not list then return end
	for n in list.entries do
		if n and n:GetNPCTypeID() == t then n:Depop() end
	end
end

function event_signal(e)
	if e.signal == 1 and not awake then
		awake = true
		eq.zone_emote(15, "Big Bynn I yawns, and the cave fills with smoke. 'WHO DARES DISTURB MY HOARD?'")
	end
end

function event_combat(e)
	if e.joined and not engaged then
		engaged = true
		awake = true
		eq.set_timer("swallow", 60000)
		eq.set_timer("watch", 2000)
		eq.stop_timer("resetcheck")
	elseif not e.joined then
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		eq.stop_timer("resetcheck")
		if not e.self:IsEngaged() then
			awake, engaged = false, false
			fired, swallowed, golems_up, golem_set, sparks_done = {}, false, false, false, false
			eq.stop_all_timers()
			e.self:Heal()
		end
		return
	end
	if not engaged then return end

	if e.timer == "swallow" then
		if not swallowed and e.self:GetHPRatio() > 10 then
			swallowed = true
			eq.zone_emote(15, "Big Bynn swallows a group whole! Destroy the crystals within him!")
			M.spawn_adds(STOMACH, 6, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 40)
			M.spawn_adds(RAT, 3, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 40)
			eq.set_timer("regurg", 150000)
		end
	elseif e.timer == "regurg" then
		if swallowed then
			if M.count_type(STOMACH) > 0 then
				eq.zone_emote(15, "The swallowed group is not freed in time -- Big Bynn's gut CRUSHES them!")
				for _, c in ipairs(M.alive_clients(e.self:GetX(), e.self:GetY(), 400)) do
					pcall(function() c:Damage(e.self, 90000, 0, 28) end)
				end
			else
				eq.zone_emote(15, "The stomach crystals shatter -- Big Bynn regurgitates the group!")
			end
			swallowed = false
			clear_crystals(RAT)
			eq.set_timer("swallow", 60000)
		end
	elseif e.timer == "eat90" then
		local n = M.count_type(PHASES[90].crystal)
		eq.stop_timer("eat90"); eater(e.self, 90, n)
	elseif e.timer == "eat80" then
		local n = M.count_type(PHASES[80].crystal)
		eq.stop_timer("eat80"); eater(e.self, 80, n)
	elseif e.timer == "eat70" then
		local n = M.count_type(PHASES[70].crystal)
		eq.stop_timer("eat70"); eater(e.self, 70, n)
	elseif e.timer == "eat60" then
		local n = M.count_type(PHASES[60].crystal)
		eq.stop_timer("eat60"); eater(e.self, 60, n)
	elseif e.timer == "eat50" then
		local n = M.count_type(PHASES[50].crystal)
		eq.stop_timer("eat50"); eater(e.self, 50, n)
	elseif e.timer == "fever" then
		eq.zone_emote(15, "Big Bynn's core runs hot -- CRYSTAL FEVER!")
		M.ae_damage(e.self, 100, 4000)
	elseif e.timer == "watch" then
		local r = e.self:GetHPRatio()
		-- 40% one-time double PBAE
		if not sparks_done and r <= 40 then
			sparks_done = true
			eq.zone_emote(15, "Big Bynn roars -- WHEN SPARKS FLY!")
			M.ae_damage(e.self, 100, 3000)
			eq.zone_emote(15, "Big Bynn follows with FIZZLE!")
			M.ae_damage(e.self, 100, 4200)
		end
		for _, pct in ipairs(ORDER) do
			if r <= pct and not fired[pct] then
				fired[pct] = true
				M.spawn_adds(PHASES[pct].crystal, 5, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 50)
				eq.zone_emote(15, "Faycite crystals form around Big Bynn!")
				eq.set_timer("eat" .. pct, 20000)
			end
		end
		-- 10%: deactivate + core golems
		if r <= 10 and not golem_set then
			golem_set = true
			eq.zone_emote(15, "Big Bynn deactivates -- core golems rise to defend him!")
			M.spawn_adds(GOLEM, 3, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 40)
		end
		if golem_set and not golems_up and not M.alive_type(GOLEM) then
			golems_up = true
			eq.zone_emote(15, "The core golems fall. Big Bynn shudders back to life!")
			eq.set_timer("fever", 20000)
		end
	end
end

function eater(npc, pct, survivors)
	local phase = PHASES[pct]
	clear_crystals(phase.crystal)
	if survivors > 1 then
		eq.zone_emote(15, "Big Bynn devours the crystals and heals -- " .. phase.msg .. "!")
		M.max_heal(npc)
		M.ae_damage(npc, 100, 3000)
	else
		eq.zone_emote(15, "The crystals are destroyed before Big Bynn can eat them.")
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
	if M.version() ~= 52 then return end
	M.chest(e.self, CHEST, "Big Bynn's Lair")
	M.flag_all(BUCKET, 1)
	M.signal(CTRL, 1202)
end
