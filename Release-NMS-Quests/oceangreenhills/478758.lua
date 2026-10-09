-- Queen Malarian (478758) -- SoD raid: Queen Malarian (oceangreenhills v51).
-- Rasper: miscProgression.html "request Queen Malarian".
--
-- Simplified live encounter (the spreading-brood field phases are not
-- modelled):
--   * Venom -- random client 6k hit every 45s.
--   * 75% / 50% / 25% -- the brood rises: 4 malarian broodlings per phase.
-- On death: Treasure_of_Malarian chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local p75 = false
local p50 = false
local p25 = false
local adds = {}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function spawn_brood(e)
	for _ = 1, 4 do
		local mob = raid.spawn_add(raid.ADD.broodling, e.self, 60)
		if mob then adds[#adds + 1] = mob:GetID() end
	end
end

local function reset(e)
	engaged = false
	p75 = false
	p50 = false
	p25 = false
	clear_adds()
	for _, t in ipairs({ "venom", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "The brood scatters. Queen Malarian withdraws into the plague winds.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("venom", 45000)
			eq.zone_emote(15, "Queen Malarian skitters forth -- 'My children hunger!'")
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
			eq.zone_emote(15, "Malarian venom sprays across " .. victim:GetCleanName() .. "!")
			raid.hit(e.self, victim, 6000)
		end
	end

	if not p75 and e.self:GetHPRatio() <= 75 then
		p75 = true
		spawn_brood(e)
		eq.zone_emote(15, "The plague brood boils up out of the earth!")
	elseif not p50 and e.self:GetHPRatio() <= 50 then
		p50 = true
		spawn_brood(e)
		eq.zone_emote(15, "Another wave of Malarian's brood crests the hill!")
	elseif not p25 and e.self:GetHPRatio() <= 25 then
		p25 = true
		spawn_brood(e)
		eq.zone_emote(15, "Queen Malarian shrieks -- the last of her brood swarms!")
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "Queen Malarian falls. The plague brood is motherless.")
	raid.spawn_chest(e, raid.CHEST.MALARIAN)
	eq.signal(raid.CTRL.MALARIAN, 1)
end
