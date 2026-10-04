-- #Meldrath_The_Malignant (365034) -- MMM raid phase 1, mechanotus instance v1.
-- Rasper: raidMMM.html stage 6. Gated: the path to Meldrath opens only after
-- the five earlier MMM events and Sixton Farqudot are cleared (the zone
-- controller 460590 signals key 5 when ready). Mechanised this pass:
--   * patchwork obliterators -- mezzable add stream every 45s
--   * emergency repair mechanics -- spawn at the breach; if one survives its
--     25s channel, Meldrath fully repairs (kill them)
--   * Meldrath's Malaise -- 150-range PBAE every 30s
--   * tick tock -- targeted explosion on a random raid member every 75s
--   * tormented revenants -- one rises every 90s while the event runs
--   * at 40% Meldrath despawns (live behavior) and phase 2 begins
--     (#Meldrath_the_Malignant_steamsuited 460506 + elite troopers 460505).

local OBLITERATOR  = 460501
local REVENANT     = 460502
local REPAIR       = 460503
local PHASE2_BOSS  = 460506
local ELITE_TROOPER = 460505

local MY_X, MY_Y, MY_Z = 14, 1620, 678.05

local phase1_timers = { "adds", "mechanics", "malaise", "ticktock", "revenants" }
local adds = {}       -- entity ids of spawned adds, for reset cleanup
local engaged = false
local phase_done = false
local ready = false   -- set true by the controller's key-5 signal
local boom_target = nil

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

local function track(mob)
	if mob then
		adds[#adds + 1] = mob:GetID()
	end
	return mob
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

local function engage(e)
	if engaged or phase_done or not ready then
		return
	end
	engaged = true
	eq.set_timer("adds", 45000)
	eq.set_timer("mechanics", 60000)
	eq.set_timer("malaise", 30000)
	eq.set_timer("ticktock", 75000)
	eq.set_timer("revenants", 90000)
	eq.zone_emote(15, "Meldrath the Malignant says, 'You breach my hall? My machines will grind you into scrap for my engines!'")
end

function event_spawn(e)
	ready = false
	engaged = false
	phase_done = false
	pcall(function() e.self:SetInvul(true) end)
end

function event_signal(e)
	if e.signal == 5 then -- controller: all five events + Sixton done
		ready = true
		pcall(function() e.self:SetInvul(false) end)
		eq.zone_emote(15, "Meldrath the Malignant rises from his throne, the wards about him broken!")
		if e.self:IsEngaged() then
			engage(e)
		end
	end
end

function event_combat(e)
	if e.joined then
		if not ready then
			eq.zone_emote(13, "Meldrath is warded by his machines. Clear the five events and Sixton first.")
			e.self:WipeHateList()
			eq.set_timer("resetcheck", 15000)
			return
		end
		engage(e)
		eq.stop_timer("resetcheck")
	else
		eq.set_timer("resetcheck", 60000)
	end
end

function event_timer(e)
	if phase_done then
		return
	end

	if e.timer == "resetcheck" then
		if not e.self:IsEngaged() then
			engaged = false
			boom_target = nil
			clear_adds()
			for _, t in ipairs(phase1_timers) do
				eq.stop_timer(t)
			end
			e.self:Heal()
			eq.zone_emote(15, "Meldrath's machines power down. The event has reset.")
		end
		return
	end

	if not engaged then
		return
	end

	if e.timer == "adds" then
		local targets = alive_clients(300)
		if #targets == 0 then
			return
		end
		for i = 1, 2 do
			local mob = track(eq.spawn2(OBLITERATOR, 0, 0,
				MY_X + math.random(-40, 40), MY_Y + math.random(-30, 30), MY_Z, 0))
			if mob then
				mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			end
		end
	elseif e.timer == "mechanics" then
		-- spawns at the breach (south end of the hall); script in 460503 channels the repair
		track(eq.spawn2(REPAIR, 0, 0, 14, 1515, MY_Z, 0))
		eq.zone_emote(15, "An emergency repair mechanic rolls in from the south! Cut it off before it reaches Meldrath!")
	elseif e.timer == "malaise" then
		eq.zone_emote(15, "Meldrath the Malignant casts Meldrath's Malaise!")
		for _, client in ipairs(alive_clients(150)) do
			client:Damage(e.self, 2000, 0, 28)
		end
		-- doubles as the 40% phase check
		if e.self:GetHPRatio() <= 40 then
			phase_transition(e)
		end
	elseif e.timer == "ticktock" then
		local targets = alive_clients(300)
		if #targets == 0 then
			return
		end
		local victim = targets[math.random(#targets)]
		boom_target = victim:GetID()
		eq.zone_emote(15, "A tick tock whirs: 'Target acquired! Physical translation to location of " .. victim:GetCleanName() .. " in progress. Termination of explosive duties imminent.'")
		eq.set_timer("boom", 5000)
	elseif e.timer == "boom" then
		if boom_target then
			local victim = eq.get_entity_list():GetClientByID(boom_target)
			if victim and victim.valid and victim:GetHPRatio() > 0 then
				victim:Damage(e.self, 8000, 0, 28)
			end
			boom_target = nil
		end
	elseif e.timer == "revenants" then
		local targets = alive_clients(300)
		if #targets == 0 then
			return
		end
		local mob = track(eq.spawn2(REVENANT, 0, 0,
			MY_X + math.random(-30, 30), MY_Y + math.random(-30, 30), MY_Z, 0))
		if mob then
			mob:AddToHateList(targets[math.random(#targets)], 1000, 10000)
			eq.zone_emote(15, "A tormented revenant claws its way out of the mansion floor.")
		end
	end

	-- hp check on every mechanical tick as well
	if e.self:GetHPRatio() <= 40 then
		phase_transition(e)
	end
end

function phase_transition(e)
	if phase_done then
		return
	end
	phase_done = true
	engaged = false
	for _, t in ipairs(phase1_timers) do
		eq.stop_timer(t)
	end
	eq.stop_timer("boom")
	clear_adds()

	eq.zone_emote(15, "Meldrath despairs and retreats deeper into his steamsuit. A foul miasma floods the hall — press east when ready!")
	-- phase 2: steamsuited Meldrath (passive) flanked by two elite troopers
	eq.spawn2(PHASE2_BOSS, 0, 0, MY_X, MY_Y + 60, MY_Z, 0)
	eq.spawn2(ELITE_TROOPER, 0, 0, MY_X - 45, MY_Y + 60, MY_Z, 0)
	eq.spawn2(ELITE_TROOPER, 0, 0, MY_X + 45, MY_Y + 60, MY_Z, 0)
	e.self:Depop(true)
end

function event_death_complete(e)
	-- direct kill without the phase transition (over-burn safety)
	if not phase_done then
		phase_transition(e)
	end
end
