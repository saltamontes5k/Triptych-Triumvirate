-- Pallorax the Soul Slayer (478717) -- SoD Korafax raid 1.
-- Rasper: raidKorafax.html.
--
-- Simplified live encounter (Draw of the Void's flux, Screeching Terror fear,
-- spell slow and Flanking Slash are not modelled individually):
--   * Draw of the Void -- random client 6.5k every 40s while active.
--   * 80/60/40/20%     -- he goes inactive and runs to a riftseeker portal;
--                         two riftseeker sentinels defend it. Killing both
--                         returns him to the fight (live: sentinels grant
--                         the raid short-term buffs).
-- On death: Treasure_of_Pallorax chest + controller lockout.

local raid = require("sod_raids")

local engaged = false
local portals = { 80, 60, 40, 20 }
local portal_idx = 1
local sentinels_up = false
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
	portal_idx = 1
	sentinels_up = false
	clear_adds()
	for _, t in ipairs({ "draw", "portalcheck", "resetcheck" }) do
		eq.stop_timer(t)
	end
	raid.set_invul(e.self, false)
	e.self:Heal()
	eq.zone_emote(15, "Pallorax prowls back from the portals, soul unsated.")
end

function event_combat(e)
	if e.joined then
		if not engaged then
			engaged = true
			eq.set_timer("draw", 40000)
			eq.zone_emote(15, "Pallorax the Soul Slayer howls -- the hunt begins!")
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

	if e.timer == "draw" then
		local victim = raid.random_client(e.self:GetX(), e.self:GetY(), 300)
		if victim then
			eq.zone_emote(15, "The void draws at " .. victim:GetCleanName() .. "!")
			raid.hit(e.self, victim, 6500)
		end
	elseif e.timer == "portalcheck" then
		-- sentinels dead -> the soul slayer returns
		if sentinels_up
			and not eq.get_entity_list():IsMobSpawnedByNpcTypeID(raid.ADD.sentinel) then
			sentinels_up = false
			raid.set_invul(e.self, false)
			eq.stop_timer("portalcheck")
			eq.zone_emote(15, "The sentinels fall -- Pallorax rips free of the portal and returns!")
		end
	end

	-- portal phases
	if portal_idx <= #portals and e.self:GetHPRatio() <= portals[portal_idx] then
		portal_idx = portal_idx + 1
		sentinels_up = true
		raid.set_invul(e.self, true)
		for i = 1, 2 do
			local mob = raid.spawn_add(raid.ADD.sentinel, e.self, 60)
			if mob then
				adds[#adds + 1] = mob:GetID()
				local targets = raid.alive_clients(e.self:GetX(), e.self:GetY(), 300)
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.set_timer("portalcheck", 5000)
		eq.zone_emote(15, "Pallorax tears open a riftseeker portal and slips through! Two sentinels guard the tear.")
	end
end

function event_death_complete(e)
	clear_adds()
	eq.zone_emote(15, "Pallorax the Soul Slayer is slain. Three tower keys tumble from his hide.")
	raid.spawn_chest(e, raid.CHEST.PALLORAX)
	eq.signal(raid.CTRL.PALLORAX, 1)
end
