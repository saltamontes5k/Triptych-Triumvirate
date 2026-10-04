-- General Bahgresh (478701) -- SoD raid: Fall of General Bahgresh.
-- Rasper: raidKith.html.
--
-- Simplified live encounter (the kyv heal-share retreats at 75/50/25 and the
-- tethered camp failure timer are not modelled):
--   * On engage -- the three kyv (Rasven/Ythalym/Vacklun) attack with him.
--   * Corruption -- random client 6k viral hit every 45s.
--   * 70% / 40%     -- two dark camps (ritualists + a priest) rise.
--   * 25%           -- AE knockback-stun: 8k to everyone within 200.
-- On death: Treasure_of_Bahgresh chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local camp70_done = false
local camp40_done = false
local knock25_done = false
local adds = {}

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function spawn_camp(e, priests)
	local count = 0
	for i = 1, 4 do
		local mob = raid.spawn_add(raid.ADD.ritualist, e.self, 60)
		if mob then
			adds[#adds + 1] = mob:GetID()
			count = count + 1
		end
	end
	for i = 1, priests do
		local mob = raid.spawn_add(raid.ADD.priest, e.self, 60)
		if mob then adds[#adds + 1] = mob:GetID() end
	end
	return count
end

local function reset(e)
	engaged = false
	camp70_done = false
	camp40_done = false
	knock25_done = false
	clear_adds()
	for _, t in ipairs({ "corruption", "resetcheck" }) do
		eq.stop_timer(t)
	end
	e.self:Heal()
	eq.zone_emote(15, "The dark energy fades. Bahgresh's ambush has failed to form.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("corruption", 45000)
			-- phase 1: the kyv vanguard
			for _, id in ipairs(raid.ADD.kyv) do
				local mob = raid.spawn_add(id, e.self, 50)
				if mob then
					adds[#adds + 1] = mob:GetID()
					local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
					if #targets > 0 then
						mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
					end
				end
			end
			eq.zone_emote(15, "Three kyv materialize around General Bahgresh -- Rasven, Ythalym, and Vacklun!")
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

	if e.timer == "corruption" then
		local victim = raid.random_client(e.self:GetX(), e.self:GetY(), 300)
		if victim then
			eq.zone_emote(15, "Dark energy gnaws at " .. victim:GetCleanName() .. "!")
			raid.hit(e.self, victim, 6000)
		end
	end

	-- 70% / 40%: camp waves
	if not camp70_done and e.self:GetHPRatio() <= 70 then
		camp70_done = true
		spawn_camp(e, 1)
		eq.zone_emote(15, "A dark energy builds to the west -- a ritual camp rises!")
	elseif not camp40_done and e.self:GetHPRatio() <= 40 then
		camp40_done = true
		spawn_camp(e, 1)
		eq.zone_emote(15, "A dark energy builds to the east -- another ritual camp rises!")
	end

	-- 25%: knockback-stun AE
	if not knock25_done and e.self:GetHPRatio() <= 25 then
		knock25_done = true
		eq.zone_emote(15, "General Bahgresh slams the ground -- the shockwave hurls you back!")
		for _, client in ipairs(raid.alive_clients(e.self:GetX(), e.self:GetY(), 200)) do
			raid.hit(e.self, client, 8000)
			pcall(function() client:Knockback(e.self:GetX(), e.self:GetY()) end)
		end
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "General Bahgresh falls. The Army of Light holds the woods.")
	raid.spawn_chest(e, raid.CHEST.BAHGRESH)
	eq.signal(raid.CTRL.BAHGRESH, 1)
end
