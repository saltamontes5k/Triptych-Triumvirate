-- Venom Lord Ksathrax (478719) -- SoD Korafax raid 3.
-- Rasper: raidKorafax.html.
--
-- Simplified live encounter (the uncureable venom AE, room geometry and the
-- projection HP-linking are not modelled; Kyv/Vitrik/Ra'tuk adds use ikaav
-- stand-ins):
--   * Venom spit    -- random client 7k every 45s (live: do NOT cure).
--   * Room cycle    -- every 150s a venomous tunat surfaces; if it still
--                      lives after 75s, the ikaavs empower Ksathrax
--                      (he heals 10% and the tunat is withdrawn).
--   * 70/40/10%     -- ikaav adds.
--   * 50%           -- a Venomous Projection splits off.
-- On death: Treasure_of_Ksathrax chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local adds70_done = false
local adds40_done = false
local adds10_done = false
local projection_done = false
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
	adds70_done = false
	adds40_done = false
	adds10_done = false
	projection_done = false
	clear_adds()
	for _, t in ipairs({ "venom", "rooms", "roomcheck", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "Ksathrax's venom pools and stills. The hunt abates.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("venom", 45000)
			eq.set_timer("rooms", 150000)
			eq.zone_emote(15, "Venom Lord Ksathrax rears up -- 'MINE IS THE VENOM THAT ENDS EMPIRES!'")
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

	if e.timer == "venom" then
		local victim = raid.random_client(e.self:GetX(), e.self:GetY(), 300)
		if victim then
			eq.zone_emote(15, "Ksathrax spits venom across " .. victim:GetCleanName() .. " -- DO NOT CURE IT!")
			raid.hit(e.self, victim, 7000)
		end
	elseif e.timer == "rooms" then
		local mob = raid.spawn_add(raid.ADD.tunat, e.self, 120)
		if mob then adds[#adds + 1] = mob:GetID() end
		eq.set_timer("roomcheck", 75000)
		eq.zone_emote(15, "A venomous tunat surfaces in the side rooms, feeding the ikaav covens!")
	elseif e.timer == "roomcheck" then
		eq.stop_timer("roomcheck")
		if eq.get_entity_list():IsMobSpawnedByNpcTypeID(raid.ADD.tunat) then
			eq.zone_emote(15, "The tunat lives -- the ikaavs empower Ksathrax!")
			e.self:SetHP(e.self:GetHP() + math.floor(e.self:GetMaxHP() * 0.10))
			clear_adds() -- withdraw the tunat with the ikaavs
		else
			eq.zone_emote(15, "The tunat is slain before the ikaavs could feed.")
		end
	end

	-- 70/40/10%: ikaav adds
	if not adds70_done and e.self:GetHPRatio() <= 70 then
		adds70_done = true
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.ikaav, e.self, 50)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Ikaav venommasters slither to Ksathrax's defense!")
	end
	if not adds40_done and e.self:GetHPRatio() <= 40 then
		adds40_done = true
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.ikaav, e.self, 50)
			if mob then adds[#adds + 1] = mob:GetID() end
		end
		eq.zone_emote(15, "More ikaav venommasters answer the lord of venom!")
	end
	if not adds10_done and e.self:GetHPRatio() <= 10 then
		adds10_done = true
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.ikaav, e.self, 50)
			if mob then adds[#adds + 1] = mob:GetID() end
		end
		eq.zone_emote(15, "The last of the coven throws itself at you!")
	end

	-- 50%: Venomous Projection
	if not projection_done and e.self:GetHPRatio() <= 50 then
		projection_done = true
		local mob = raid.spawn_add(raid.ADD.projection, e.self, 40)
		if mob then
			adds[#adds + 1] = mob:GetID()
			local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
			if #targets > 0 then
				mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			end
		end
		eq.zone_emote(15, "A Venomous Projection splits from Ksathrax and attacks!")
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "Venom Lord Ksathrax crashes down, his venom spent.")
	raid.spawn_chest(e, raid.CHEST.KSATHRAX)
	eq.signal(raid.CTRL.KSATHRAX, 1)
end
