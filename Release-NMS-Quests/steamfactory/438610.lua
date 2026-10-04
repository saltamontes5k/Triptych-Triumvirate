-- Spindlecrank (438610) -- Secrets of Faydwer Steam Factory raid, event 1.
-- Tracked source: Release-NMS-Quests/steamfactory/438610.lua.
-- Rasper: raidSteam.html.
--
-- Simplified live encounter (the catwalk ranged split and the tether-click
-- vent puzzle are not modelled):
--   * Rotor Wash  -- PBAE on the raid every 30s (emote warns).
--   * Dust Blast  -- targeted blind every 45s.
--   * 75%         -- three ground adds (menders heal it, shock troops fight,
--                    both mezzable).
--   * 50%         -- "vent" leak: a 7k AE every 30s until the fight ends
--                    (live requires clicking the correct vent with a tether).
-- On death: spawns the punchable Treasure_of_Spindlecrank chest.

local GRENADIER = 438630
local HANGAR    = 438631
local MENDER    = 438632
local SHOCK     = 438633
local CHEST     = 438650

local MY_X, MY_Y, MY_Z = 613.5, -1106.75, 97.125

local engaged = false
local adds75_done = false
local adds = {}

local function alive_clients(radius)
	local out = {}
	local clients = eq.get_entity_list():GetClientList()
	if not clients then return out end
	for client in clients.entries do
		if client and client:GetHPRatio() > 0
			and math.abs(client:GetX() - MY_X) <= (radius or 300)
			and math.abs(client:GetY() - MY_Y) <= (radius or 300) then
			out[#out + 1] = client
		end
	end
	return out
end

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then mob:Depop() end
	end
	adds = {}
end

local function spawn_chest(e)
	local expedition = eq.get_expedition()
	if not expedition.valid then return end
	local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
	local chest = eq.unique_spawn(CHEST, 0, 0, x, y, z + 5, 0)
	if chest ~= nil then
		expedition:SetLootEventBySpawnID(chest:GetID(), "Spindlecrank")
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("rotorwash", 30000)
	eq.set_timer("dustblast", 45000)
	eq.set_timer("grenadiers", 45000)
	eq.zone_emote(15, "Spindlecrank roars to life, its rotors screaming. 'INTRUDERS. BEGIN THE PURGE.'")
end

function event_combat(e)
	if e.joined then
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			adds75_done = false
			clear_adds()
			for _, t in ipairs({ "rotorwash", "dustblast", "grenadiers", "vents" }) do
				eq.stop_timer(t)
			end
			e.self:Heal()
			eq.zone_emote(15, "Spindlecrank powers down. The event has reset.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "rotorwash" then
		eq.zone_emote(15, "Spindlecrank's blades churn -- ROTOR WASH!")
		for _, client in ipairs(alive_clients(150)) do
			client:Damage(e.self, 5000, 0, 28)
		end
	elseif e.timer == "dustblast" then
		local targets = alive_clients(300)
		if #targets == 0 then return end
		local victim = targets[math.random(#targets)]
		eq.zone_emote(15, "A dust blast tears into " .. victim:GetCleanName() .. "!")
		victim:Damage(e.self, 3000, 0, 28)
	elseif e.timer == "grenadiers" then
		-- live: a catwalk team must kill these before their grenades land.
		for i = 1, 2 do
			local mob = eq.spawn2(GRENADIER, 0, 0,
				MY_X + math.random(-40, 40), MY_Y + math.random(-40, 40), MY_Z + 40, 0)
			if mob then adds[#adds + 1] = mob:GetID() end
		end
		e.self:SetEntityVariable("grenade_warn", "1")
		eq.set_timer("grenade_boom", 12000)
	elseif e.timer == "grenade_boom" then
		if e.self:GetEntityVariable("grenade_warn") == "1"
			and eq.get_entity_list():IsMobSpawnedByNpcTypeID(GRENADIER) then
			eq.zone_emote(15, "Detonating grenades wash the hangar floor in fire!")
			for _, client in ipairs(alive_clients(200)) do
				client:Damage(e.self, 10000, 0, 28)
			end
		end
		e.self:SetEntityVariable("grenade_warn", "0")
	elseif e.timer == "vents" then
		eq.zone_emote(15, "Toxic fumes pour from the ventilation shafts!")
		for _, client in ipairs(alive_clients(200)) do
			client:Damage(e.self, 7000, 0, 28)
		end
	end

	-- 75%: ground adds
	if not adds75_done and e.self:GetHPRatio() <= 75 then
		adds75_done = true
		local targets = alive_clients(300)
		for i = 1, 3 do
			local which = (i == 1) and MENDER or SHOCK
			local mob = eq.spawn2(which, 0, 0,
				MY_X + math.random(-45, 45), MY_Y + math.random(-45, 45), MY_Z, 0)
			if mob then
				adds[#adds + 1] = mob:GetID()
				if #targets > 0 then
					mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
				end
			end
		end
		eq.zone_emote(15, "Maintenance units pour out to defend Spindlecrank!")
	end

	-- 50%: vent leak
	if e.self:GetHPRatio() <= 50 and e.self:GetEntityVariable("vents_on") ~= "1" then
		e.self:SetEntityVariable("vents_on", "1")
		eq.zone_emote(15, "Toxic fumes leak from the ventilation shafts! You cannot reach the levers in time!")
		eq.set_timer("vents", 30000)
	end
end

function event_death_complete(e)
	clear_adds()
	eq.stop_timer("vents")
	eq.zone_emote(15, "Spindlecrank shudders and collapses, spilling its salvage across the foundry.")
	spawn_chest(e)
end
