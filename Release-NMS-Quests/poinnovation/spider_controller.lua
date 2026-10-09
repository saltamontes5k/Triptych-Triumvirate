-- Manaetic Behemoth event controller (Plane of Innovation)
-- The event starts when a player enters the machine room. Power carriers stream
-- toward the dormant Manaetic Behemoth; each one that reaches (1125,0) feeds it
-- power and resets the wake-up. Starve the machine of carriers for 5 minutes and
-- it awakens, vulnerable, to be killed.

local EVENT_DURATION_SECONDS = 20 * 60; --max length of the wave phase
local WAVE_INTERVAL_MS       = 60 * 1000; --time between clockwork carrier waves
local DORMANT_RESPAWN_MS     = 900 * 1000; --15 minutes before the dormant behemoth returns

local event_active  = false;
local player_waiting = false; --a player entered while the dormant behemoth was respawning

local device_ids = {
	206000,
	206001,
	206002,
	206069,
	206070,
	206071,
	206072,
	206086
};

local function event_key()
	return "poinnovation_mb_event_active_" .. tostring(eq.get_zone_instance_id());
end

local function cleanup_devices()
	for _, npc_id in ipairs(device_ids) do
		eq.depop_all(npc_id);
	end
end

local function spawn_wave()
	eq.spawn2(206000, 28, 0, 803, -285, 4.63, 314); -- NPC: a_clockwork_device
	eq.spawn2(206001, 29, 0, 804, 285, 4.63, 314); -- NPC: a_clockwork_device
	eq.spawn2(206002, 30, 0, 1443, 285, 4.63, 314); -- NPC: a_clockwork_device
	eq.spawn2(206086, 31, 0, 1443, -285, 4.63, 314); -- NPC: a_clockwork_device
	eq.spawn2(eq.ChooseRandom(206071, 206070), 26, 0, 1155, 605, 4.63, 0); -- NPC(s): a_clockwork_device
	eq.spawn2(eq.ChooseRandom(206072, 206069), 24, 0, 1155, -600, 4.63, 0); -- NPC(s): a_clockwork_device
end

local function ensure_dormant()
	if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(206046) then
		eq.spawn2(206046, 0, 0, 1125, 0, 12.5, 0); -- NPC: Manaetic_Behemoth
	end
end

local function stop_event()
	event_active = false;
	eq.stop_timer("spiders");
	eq.stop_timer("event_timeout");
	eq.delete_data(event_key());
	eq.signal(206046, 99);
	cleanup_devices();
end

local function start_event()
	if event_active then
		return;
	end

	if not eq.get_entity_list():IsMobSpawnedByNpcTypeID(206046) then
		return;
	end

	event_active   = true;
	player_waiting = false;
	eq.set_data(event_key(), "1", tostring(EVENT_DURATION_SECONDS + 120));
	eq.signal(206046, 99);
	cleanup_devices();
	eq.zone_emote(MT.NPCQuestSay, "Clockwork power carriers begin streaming toward the Manaetic Behemoth! Destroy them before they reach it -- starve the Behemoth of power and it will awaken, vulnerable, to your attack!");
	eq.signal(206046, 2);
	spawn_wave();
	eq.set_timer("spiders", WAVE_INTERVAL_MS);
	eq.set_timer("event_timeout", EVENT_DURATION_SECONDS * 1000);
end

function event_spawn(e)
	event_active   = false;
	player_waiting = false;
	eq.delete_data(event_key());
	cleanup_devices();
	eq.set_proximity(700, 1550, -700, 700, -100, 150, false);
	--give the static spawn a moment to come up before falling back to a dynamic spawn
	eq.set_timer("ensure_dormant", 5000);
end

function event_enter(e)
	player_waiting = true;
	start_event();
end

function event_signal(e)
	if e.signal == 10 then
		--the targetable behemoth was killed or timed out; bring the dormant one back
		eq.set_timer("dormant_respawn", DORMANT_RESPAWN_MS);
	end
end

function event_timer(e)
	if e.timer == "spiders" then
		if not event_active or not eq.get_entity_list():IsMobSpawnedByNpcTypeID(206046) then
			stop_event();
			return;
		end

		spawn_wave();
	elseif e.timer == "event_timeout" then
		eq.zone_emote(MT.NPCQuestSay, "The flow of power carriers finally ceases and the construction bay falls silent. The Manaetic Behemoth remains dormant.");
		stop_event();
	elseif e.timer == "ensure_dormant" then
		eq.stop_timer("ensure_dormant");
		ensure_dormant();
	elseif e.timer == "dormant_respawn" then
		eq.stop_timer("dormant_respawn");
		ensure_dormant();
		if player_waiting then
			start_event();
		end
	end
end
