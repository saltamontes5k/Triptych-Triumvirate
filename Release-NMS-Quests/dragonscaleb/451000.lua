-- [[
-- Overseer Gakkor Deepscar (451000) -- Deepscar's Den, dragonscaleb version 51.
-- Rasper: raidDeepscar.html. Script-driven (npc_spells_id = 0).
--
-- Simplified / collapsed vs live:
--   * three frontal/PBAE spells collapsed to one timed raid PBAE;
--   * the boulder rain is an emote + a 4k hit to everyone stacked on a
--     random victim (live: three rain ticks over 6s);
--   * the six golem rooms are collapsed to "a golem + two room adds";
--     Saffron's chain, Cerulean's prisons, Amethyst's rampage etc. are
--     represented by the room add, not modelled individually;
--   * at 50% Kirkoten Arcanist/Oracle/Champion spawn on a repeating timer.
-- On death: punchable Treasure_of_Deepscar + flag + lockout signal.
-- ]]
local M = require("sof_dsb_raid")

local GOLEMS = { 451001, 451002, 451003, 451004, 451005, 451006 }
local ROOM_ADDS = { 451007, 451008, 451009, 451010, 451010, 451010 }
local KIRK = { 451011, 451012, 451013 }
local CHEST = 451100
local CTRL = 451630
local BUCKET = "sof.dsb.raid.deepscar"

local GATES = { 92, 86, 80, 74, 68, 62, 56, 50, 44, 38, 32, 26, 15 }
local gates_seen = {}
local kirk_on = false

function event_combat(e)
	if not e.joined then eq.stop_all_timers(); return end
	if M.version() ~= 51 then return end
	eq.set_timer("spell", 18000)
	eq.set_timer("rain", 14000)
	eq.set_timer("watch", 2000)
	eq.set_timer("kirk", 60000)
	eq.zone_emote(15, "Overseer Gakkor Deepscar heaves his bulk forward in the Minotaur Fort!")
end

function event_timer(e)
	if e.timer == "spell" then
		eq.zone_emote(15, "Overseer Gakkor Deepscar unleashes a whirlwind of force!")
		M.ae_damage(e.self, 60, 5000)
	elseif e.timer == "rain" then
		local c = M.random_client(e.self, 250)
		if c then
			eq.zone_emote(15, "Boulders begin to unlodge above " .. c:GetCleanName() .. "!")
			local x, y = c:GetX(), c:GetY()
			M.ae_at(x, y, 40, e.self, 4000)
			M.ae_at(x, y, 40, e.self, 4000)
		end
	elseif e.timer == "kirk" then
		if e.self:GetHPRatio() <= 50 then
			kirk_on = true
			M.spawn_adds(KIRK[1], 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
			M.spawn_adds(KIRK[2], 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
			M.spawn_adds(KIRK[3], 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
			eq.zone_emote(15, "Kirkoten Arcanists, Oracles and Champions surge into the fort!")
		end
	elseif e.timer == "watch" then
		local r = e.self:GetHPRatio()
		for i = 1, #GATES do
			if r <= GATES[i] and not gates_seen[i] then
				gates_seen[i] = true
				local room = math.random(#GOLEMS)
				M.spawn_adds(GOLEMS[room], 1, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
				M.spawn_adds(ROOM_ADDS[room], 2, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 30)
				eq.zone_emote(15, "Deepscar chants a low hymn -- a formation appears in the crystals of the "
					.. ({"Northwest obsidian", "northern vermilion", "northeastern viridian", "southeastern saffron", "southern cerulean", "southwestern amethyst"})[room] .. " room!")
				break
			end
		end
	end
end

function event_death_complete(e)
	eq.stop_all_timers()
	if M.version() ~= 51 then return end
	M.chest(e.self, CHEST, "Deepscar's Den")
	M.flag_all(BUCKET, 1)
	M.signal(CTRL, 1201)
end
