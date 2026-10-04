-- #Meldrath_the_Malignant_steamsuited (460506) -- MMM raid phase 2,
-- mechanotus instance v1. Rasper: raidMMM.html stage 6, second half.
-- Phase 2: two elite troopers (460505) fall; then Meldrath reanimates the
-- four bosses the raid already killed (460560-460563). Once they fall he
-- attacks:
--   * support-unit targeted AE every 40s (emote warns the target to run out)
--   * at 15% a swarm of steamwork buzzkills (460504) spawns
-- On death: spawns the Treasure (460507) and grants the per-character
-- sof_meldrath_defeated bucket that gates Little Bo's Rk. III stock.

local ELITE_TROOPER = 460505
local BUZZKILL      = 460504
local SUPPORT_UNIT  = 460570
local TREASURE      = 460507

local REANIM = { 460560, 460561, 460562, 460563 } -- Breakneck/Krond/Brinda/Bargangle

local MY_X, MY_Y, MY_Z = 14, 1680, 678.05

local engaged = false
local troopers_down = false
local reanim_out = false
local buzzkills_out = false
local adds = {}

local function alive_clients(radius)
	local out = {}
	local clients = eq.get_entity_list():GetClientList()
	if not clients then
		return out
	end
	for client in clients.entries do
		if client and client:GetHPRatio() > 0
			and math.abs(client:GetX() - MY_X) <= (radius or 300)
			and math.abs(client:GetY() - MY_Y) <= (radius or 300) then
			out[#out + 1] = client
		end
	end
	return out
end

local function count_type(npc_type)
	local n = 0
	local npcs = eq.get_entity_list():GetNPCList()
	if not npcs then
		return 0
	end
	for npc in npcs.entries do
		if npc and npc.valid and npc:GetNPCTypeID() == npc_type and npc:GetHPRatio() > 0 then
			n = n + 1
		end
	end
	return n
end

local function spawn_troopers()
	for i = 1, 2 do
		local mob = eq.spawn2(ELITE_TROOPER, 0, 0, MY_X + (i == 1 and -45 or 45), MY_Y, MY_Z, 0)
		if mob then
			adds[#adds + 1] = mob:GetID()
		end
	end
end

local function spawn_reanim()
	reanim_out = true
	local targets = alive_clients(300)
	local i = 0
	for _, rid in ipairs(REANIM) do
		i = i + 1
		local mob = eq.spawn2(rid, 0, 0, MY_X + (i - 2.5) * 30, MY_Y + 55, MY_Z, 0)
		if mob then
			adds[#adds + 1] = mob:GetID()
			if #targets > 0 then
				mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			end
		end
	end
	eq.zone_emote(15, "Meldrath the Malignant raises the dead! Breakneck, Krond, Brinda and Bargangle rise again to bar your path!")
end

local function clear_adds()
	local el = eq.get_entity_list()
	for _, id in ipairs(adds) do
		local mob = el:GetNPCByID(id)
		if mob and mob.valid then
			mob:Depop()
		end
	end
	adds = {}
end

function event_spawn(e)
	eq.zone_emote(15, "Meldrath's steamsuit lumbers into the eastern hall, flanked by elite troopers. His eyes burn through the portholes.")
	eq.set_timer("engagecheck", 10000)
end

function event_timer(e)
	if e.timer == "engagecheck" then
		if not troopers_down and count_type(ELITE_TROOPER) == 0 then
			troopers_down = true
			eq.zone_emote(15, "Meldrath the Malignant says, 'You destroy my armor piece by piece! Then I will destroy you with my own two hands!'")
			spawn_reanim()
			eq.set_timer("reanimcheck", 5000)
		end
		return
	end

	if e.timer == "reanimcheck" then
		if reanim_out and not engaged and count_type(REANIM[1]) + count_type(REANIM[2]) + count_type(REANIM[3]) + count_type(REANIM[4]) == 0 then
			engaged = true
			eq.stop_timer("reanimcheck")
			local targets = alive_clients(300)
			if #targets > 0 then
				e.self:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			end
			eq.set_timer("support", 40000)
			eq.zone_emote(15, "The reanimated bosses fall. Meldrath charges in himself!")
		end
		return
	end

	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			troopers_down = false
			reanim_out = false
			buzzkills_out = false
			clear_adds()
			eq.stop_timer("support")
			e.self:Heal()
			spawn_troopers() -- wiped raid gets the flankers back
			eq.zone_emote(15, "The steamsuit stands down. New troopers file in beside it.")
		end
		return
	end

	if not engaged then
		return
	end

	if e.timer == "support" then
		local targets = alive_clients(300)
		if #targets == 0 then
			return
		end
		eq.spawn2(SUPPORT_UNIT, 0, 0, MY_X + math.random(-40, 40), MY_Y - 40, MY_Z, 0)
		local victim = targets[math.random(#targets)]
		eq.zone_emote(15, "A support unit turns to face " .. victim:GetCleanName() .. "!")
		eq.set_timer("supportblast", 3000)
		-- remember the victim for the blast
		e.self:SetEntityVariable("support_target", tostring(victim:GetID()))
	elseif e.timer == "supportblast" then
		local id = tonumber(e.self:GetEntityVariable("support_target") or "0")
		if id and id > 0 then
			local victim = eq.get_entity_list():GetClientByID(id)
			if victim and victim.valid and victim:GetHPRatio() > 0 then
				eq.zone_emote(15, "The support unit fires its payload at " .. victim:GetCleanName() .. "!")
				victim:Damage(e.self, 6000, 0, 28)
			end
		end
		e.self:SetEntityVariable("support_target", "0")
	elseif e.timer == "buzzkillcheck" then
		if not buzzkills_out and e.self:GetHPRatio() <= 15 then
			buzzkills_out = true
			eq.zone_emote(15, "Meldrath the Malignant says, 'Buzzkills! Stall them while I disengage!'")
			local targets = alive_clients(300)
			for i = 1, 4 do
				local mob = eq.spawn2(BUZZKILL, 0, 0,
					MY_X + math.random(-40, 40), MY_Y + math.random(-20, 20), MY_Z, 0)
				if mob then
					adds[#adds + 1] = mob:GetID()
					if #targets > 0 then
						mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
					end
				end
			end
		end
	end

	-- passive checks
	if engaged and not buzzkills_out and e.self:GetHPRatio() <= 15 then
		eq.set_timer("buzzkillcheck", 500)
	end
end

function event_combat(e)
	if not e.joined then
		eq.set_timer("resetcheck", 60000)
	end
end

function event_death_complete(e)
	eq.zone_emote(15, "The steamsuit crashes down. Meldrath the Malignant is defeated! His treasure spills across the floor.")
	clear_adds()

	-- per-character vendor unlock: gates Little Bo's Rk. III stock
	local clients = eq.get_entity_list():GetClientList()
	if clients then
		for client in clients.entries do
			if client and client:GetBucket("sof_meldrath_defeated") ~= "1" then
				client:SetBucket("sof_meldrath_defeated", "1")
				client:Message(15, "You have helped defeat Meldrath the Malignant. Word of the victory spreads through the Brownie Resistance.")
			end
		end
	end

	-- punchable loot-event chest (Anguish/Solteris convention)
	local expedition = eq.get_expedition()
	if expedition.valid then
		local chest = eq.unique_spawn(TREASURE, 0, 0, MY_X + 30, MY_Y, MY_Z, 0)
		if chest ~= nil then
			expedition:SetLootEventBySpawnID(chest:GetID(), "Meldrath the Malignant")
		end
	end
end
