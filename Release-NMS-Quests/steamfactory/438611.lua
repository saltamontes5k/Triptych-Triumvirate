-- Mining_Behemoth (438611) -- Secrets of Faydwer Steam Factory raid, event 2.
-- Tracked source: Release-NMS-Quests/steamfactory/438611.lua.
-- Rasper: raidSteam.html.
--
-- Simplified live encounter (carriers are killed, not snared/path-blocked):
--   * AE rampage emulated by a periodic 150-range AE (emote warns).
--   * every 35s a coloured crystal carrier arrives; if it lives 15s it
--     triggers its effect -- green: Static Charge AE, purple: Power Surge AE,
--     red/yellow/blue: a short emote-only empowerment.
--   * 25% -- blasting charges spawn on a random member and detonate for 15k
--     unless killed in time.
-- On death: spawns the punchable Treasure_of_Mining_Behemoth chest.

local CARRIER_R, CARRIER_Y, CARRIER_G = 438634, 438635, 438636
local CARRIER_B, CARRIER_P = 438637, 438638
local BLASTING = 438639
local CHEST    = 438651

local MY_X, MY_Y, MY_Z = -1253.625, 1475.0, 160.125

local engaged = false
local charges25_done = false
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
		expedition:SetLootEventBySpawnID(chest:GetID(), "Mining Behemoth")
	end
end

local function engage(e)
	if engaged then return end
	engaged = true
	eq.set_timer("rampage", 40000)
	eq.set_timer("carriers", 35000)
	eq.zone_emote(15, "The Mining Behemoth stirs, drills grinding. 'THREAT DETECTED. RECLAIMING THE VEIN.'")
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
			charges25_done = false
			clear_adds()
			for _, t in ipairs({ "rampage", "carriers", "carrier_boom", "charge", "charge_boom" }) do
				eq.stop_timer(t)
			end
			e.self:Heal()
			eq.zone_emote(15, "The Mining Behemoth grinds to a halt. The event has reset.")
		end
		return
	end
	if not engaged then return end

	if e.timer == "rampage" then
		eq.zone_emote(15, "The Behemoth sweeps its drills in a wide, grinding arc!")
		for _, client in ipairs(alive_clients(150)) do
			client:Damage(e.self, 4500, 0, 28)
		end
	elseif e.timer == "carriers" then
		local pick = math.random(5)
		local id = ({ CARRIER_R, CARRIER_Y, CARRIER_G, CARRIER_B, CARRIER_P })[pick]
		local color = ({ "red", "yellow", "green", "blue", "purple" })[pick]
		local mob = eq.spawn2(id, 0, 0,
			MY_X + math.random(-60, 60), MY_Y + math.random(-60, 60), MY_Z, 0)
		if mob then
			adds[#adds + 1] = mob:GetID()
			e.self:SetEntityVariable("carrier_color", color)
			eq.zone_emote(15, "A " .. color .. " crystal carrier lurches toward the Behemoth! Kill it before it connects!")
			eq.set_timer("carrier_boom", 15000)
		end
	elseif e.timer == "carrier_boom" then
		local color = e.self:GetEntityVariable("carrier_color") or ""
		if color == "green" then
			eq.zone_emote(15, "Static Charge erupts from the Behemoth!")
			for _, client in ipairs(alive_clients(200)) do
				client:Damage(e.self, 8000, 0, 28)
			end
		elseif color == "purple" then
			eq.zone_emote(15, "Power Surge detonates across the vein!")
			for _, client in ipairs(alive_clients(200)) do
				client:Damage(e.self, 12000, 0, 28)
			end
		elseif color ~= "" then
			eq.zone_emote(15, "The " .. color .. " crystal feeds the Behemoth!")
		end
		e.self:SetEntityVariable("carrier_color", "")
	elseif e.timer == "charge" then
		local targets = alive_clients(300)
		if #targets == 0 then return end
		local victim = targets[math.random(#targets)]
		local mob = eq.spawn2(BLASTING, 0, 0, victim:GetX(), victim:GetY(), victim:GetZ(), 0)
		if mob then
			adds[#adds + 1] = mob:GetID()
			e.self:SetEntityVariable("charge_target", tostring(victim:GetID()))
			eq.zone_emote(15, "A blasting charge skitters toward " .. victim:GetCleanName() .. "!")
			eq.set_timer("charge_boom", 6000)
		end
	elseif e.timer == "charge_boom" then
		local tid = tonumber(e.self:GetEntityVariable("charge_target") or "0")
		if tid and tid > 0 then
			local victim = eq.get_entity_list():GetClientByID(tid)
			if victim and victim.valid and victim:GetHPRatio() > 0 then
				eq.zone_emote(15, "The blasting charge detonates!")
				victim:Damage(e.self, 15000, 0, 28)
			end
		end
		e.self:SetEntityVariable("charge_target", "0")
	end

	-- 25%: blasting charges begin
	if not charges25_done and e.self:GetHPRatio() <= 25 then
		charges25_done = true
		eq.zone_emote(15, "Blasting charges begin to spawn across the mine!")
		eq.set_timer("charge", 25000)
	end
end

function event_death_complete(e)
	clear_adds()
	for _, t in ipairs({ "rampage", "carriers", "carrier_boom", "charge", "charge_boom" }) do
		eq.stop_timer(t)
	end
	eq.zone_emote(15, "The Mining Behemoth collapses in a shower of ore and broken crystal.")
	spawn_chest(e)
end
