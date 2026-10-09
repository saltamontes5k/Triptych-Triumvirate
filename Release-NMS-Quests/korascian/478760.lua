-- The Crystal Core (478760) -- SoD raid: Showdown at the Crystal Core
-- (korascian v51). Rasper: miscProgression.html "request Showdown at the
-- Crystal Core".
--
-- Simplified live event (the defended-core reverse escort is not modelled;
-- the fouled core and its Rallosian assault are fought directly):
--   * On engage and at 80/60/40/20% -- Rallosian coresiegers breach (x3).
--   * Ground shatter -- 8k AE within 250 every 60s.
--   * 50% / 25% -- shards of the core split off (x2).
-- On death: Treasure_of_the_Crystal_Core chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local p80 = false
local p60 = false
local p40 = false
local p20 = false
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

local function spawn_wave(e, npc_id, count)
	for _ = 1, count do
		local mob = raid.spawn_add(npc_id, e.self, 70)
		if mob then
			adds[#adds + 1] = mob:GetID()
			local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
			if #targets > 0 then
				mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			end
		end
	end
end

local function reset(e)
	engaged = false
	p80 = false
	p60 = false
	p40 = false
	p20 = false
	p50 = false
	p25 = false
	clear_adds()
	for _, t in ipairs({ "shatter", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "The crystal light steadies. The assault recedes.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("shatter", 60000)
			spawn_wave(e, raid.ADD.coresieger, 3)
			eq.zone_emote(15, "The fouled core pulses -- Rallosian coresiegers breach the chasm!")
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

	if e.timer == "shatter" then
		eq.zone_emote(15, "The Crystal Core convulses -- crystalline shrapnel tears through the chamber!")
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 250)) do
			raid.hit(e.self, client, 8000)
		end
	end

	local hp = e.self:GetHPRatio()
	if not p80 and hp <= 80 then
		p80 = true
		spawn_wave(e, raid.ADD.coresieger, 3)
		eq.zone_emote(15, "Another Rallosian column storms the core!")
	elseif not p60 and hp <= 60 then
		p60 = true
		spawn_wave(e, raid.ADD.coresieger, 3)
		eq.zone_emote(15, "The siege tightens -- more coresiegers pour in!")
	elseif not p50 and hp <= 50 then
		p50 = true
		spawn_wave(e, raid.ADD.shard, 2)
		eq.zone_emote(15, "Shards of the corrupted core split away and attack!")
	elseif not p40 and hp <= 40 then
		p40 = true
		spawn_wave(e, raid.ADD.coresieger, 3)
		eq.zone_emote(15, "The Rallosians throw their reserves at the core!")
	elseif not p25 and hp <= 25 then
		p25 = true
		spawn_wave(e, raid.ADD.shard, 2)
		eq.zone_emote(15, "The core fractures -- shards scythe through the ranks!")
	elseif not p20 and hp <= 20 then
		p20 = true
		spawn_wave(e, raid.ADD.coresieger, 3)
		eq.zone_emote(15, "A final desperate wave storms the chamber!")
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "The Crystal Core is cleansed. Korascian's bloom will shine again.")
	raid.spawn_chest(e, raid.CHEST.CORE)
	eq.signal(raid.CTRL.CORE, 1)
end
