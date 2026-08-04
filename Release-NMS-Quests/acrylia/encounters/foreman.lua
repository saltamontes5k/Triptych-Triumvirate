-- Foreman Gworknop Encounter

-- NPCs used in event
local undead_deathguard		= 154403;
local fake_foreman_id		= 154118;
local real_foreman_id		= 154389;
local controller			= 154407;
local deathguard			= 154170;
local foreman_ent			= nil;

-- Spawns
local spawnpoints = {3387956, 3387957, 3387958, 3387959, 3387960, 3387961, 3387962, 3387963, 3387964, 3387965};


-- Controller
function evt_controller_timer(e)
	if e.timer == "guard_depop" then
		eq.depop_all(undead_deathguard);
	elseif e.timer == "event_reset" then
		eq.stop_all_timers();
		eq.depop_all(undead_deathguard);
		eq.depop(real_foreman_id);
		Repop();
		eq.get_entity_list():GetSpawnByID(36831):Repop(5); -- NPC: Foreman_Gworknop 
	end
end

function evt_controller_signal(e)
	if e.signal == 1 then
		if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(deathguard) then 	-- checks to see if all deathguards are dead
			StartEvent();
			eq.set_timer("event_reset", 30 * 60 * 1000); --30 min event timer before full reset
		end
	elseif e.signal == 2 then
		eq.stop_timer("event_reset");
		eq.set_timer("event_reset", 5 * 60 * 1000); --5 min to reset event after Foreman Death
	end
end

-- a_grimling_deathguard
function evt_deathguard_death_complete(e)
	eq.signal(controller,1);
end

-- Real Foreman
function evt_real_foreman_death_complete(e)
	eq.signal(controller,2);
end

-- General Functions
function StartEvent()
	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(fake_foreman_id) then
		eq.depop_with_timer(fake_foreman_id);
		foreman_ent = eq.spawn2(real_foreman_id,0,0,344,-276,10,392);
		foreman_ent:Shout("Rise minions! Our master's work must not be interrupted!");
	end

	SpawnGuards();
	eq.set_timer("guard_depop", 20 * 60 * 1000);
end

function Repop()
	for _,spawns in pairs(spawnpoints) do
		local corpses = eq.get_entity_list():GetSpawnByID(spawns);
		corpses:Enable();
		corpses:Reset();
		corpses:Repop(5);
	end
end

function SpawnGuards(undead)
	for _,spawns in pairs(spawnpoints) do
		local npc_list = eq.get_entity_list():GetNPCList();

		if npc_list ~= nil then
			for npc in npc_list.entries do
				if npc:GetSpawnPointID() == spawns then
					eq.spawn2(undead_deathguard,0,0,npc:GetX(), npc:GetY(), npc:GetZ(), npc:GetHeading());
					npc:Depop(true);
				end
			end
		end
	end
end

-- Encounter Load
function event_encounter_load(e)
	eq.register_npc_event("foreman",		Event.timer,			controller,			evt_controller_timer);
	eq.register_npc_event("foreman",		Event.signal,			controller,			evt_controller_signal);

	eq.register_npc_event("foreman",		Event.death_complete,	deathguard,			evt_deathguard_death_complete);

	eq.register_npc_event("foreman",		Event.death_complete,	real_foreman_id,	evt_real_foreman_death_complete);
end
