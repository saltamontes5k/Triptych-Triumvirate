local controller_id = 162255;  -- Use the following to reset the event: #npctypespawn 162255
local serpent_triggers = {162012, 162021, 162013, 162060, 162024, 162011, 162059, 162258, 162089, 162023}; -- 7 Taskmasters, 2 Rhzoth, 1 Warder
local serpent_triggers_s2 = {33885, 33891, 33886, 33964, 33895, 33884, 33963, 37145, 34043, 34235}; -- Spawn2 ids for the above triggers
local serpent_id = 162261;
local exiled_id = 162232;
local cursed_id = 162206;

local STATE_START = 0;
local STATE_TRIGGERS_DEAD = 1;
local STATE_SERPENT_DEAD = 2;
local STATE_EXILED_DEAD = 3;
local STATE_END = 255;

local bucket_key = "ssratemple.cursed";
local saving_enabled = true;

function get_state_from_bucket()
	if eq.get_zone_instance_id() == 0 then
		return -1;
	end

	local zone = eq.get_zone();
	local state_str = zone:GetBucket(bucket_key);
	if state_str == nil then
		state_str = "0";
	end

	local state = tonumber(state_str);
	if state == nil then
		state = 0;
	end

	return state;
end

function get_state_from_zone()
	local npcs = eq.get_entity_list();

	local controller = npcs:GetNPCByNPCTypeID(controller_id);
	if controller.valid then
		return STATE_START;
	end

	local serpent = npcs:GetNPCByNPCTypeID(serpent_id);
	if serpent.valid then
		return STATE_TRIGGERS_DEAD;
	end

	local exiled = npcs:GetNPCByNPCTypeID(exiled_id);
	if exiled.valid then
		return STATE_SERPENT_DEAD;
	end

	local cursed = npcs:GetNPCByNPCTypeID(cursed_id);
	if cursed.valid then
		return STATE_EXILED_DEAD;
	end

	return STATE_END;
end

function get_state()
	if not saving_enabled then
		return get_state_from_bucket();
	else
		return get_state_from_zone();
	end
end

function set_state(new_state)
	if saving_enabled then
		return;
	end

	local instance_id = eq.get_zone_instance_id();
	if instance_id == 0 then
		-- Let the open world be governed by the agents of chaos
		return;
	end

	local zone = eq.get_zone();
	zone:SetBucket(bucket_key, tostring(new_state));
end

function evt_zone_spawn(e)
	process_spawn(e.self:GetNPCTypeID());
end

function process_spawn(npc_id)
	if npc_id == controller_id then
		set_state(STATE_START);
	end
end

function evt_zone_death(e)
	process_death(e.self:GetNPCTypeID());
end

function process_death(npc_id)
	if npc_id == serpent_id then
		set_state(STATE_SERPENT_DEAD);
		local mob = eq.unique_spawn(exiled_id, 0, 0, -30, -10, -223, 130);
		mob:Shout("FOOLS! Your doom approaches!");
	end

	if npc_id == exiled_id then
		set_state(STATE_EXILED_DEAD);
		local mob = eq.unique_spawn(cursed_id, 0, 0, -30, -10, -223, 130);
		mob:Shout("FOOLS! Your doom is here! TREMBLE!");
	end

	if npc_id == cursed_id then
		set_state(STATE_END);
	end
end

function check_serpent_triggers(e)
	local state = get_state();
	if state ~= STATE_START then
		return;
	end

	local entity_list = eq.get_entity_list();
	for i,id in ipairs(serpent_triggers) do
		local mob = entity_list:GetMobByNpcTypeID(id);
		if mob.valid then
			return;
		end
	end

	spawn_serpent(e);
end

function spawn_serpent(e)
	set_state(STATE_TRIGGERS_DEAD);
	local mob = eq.unique_spawn(serpent_id, 0, 0, -30, -10, -223, 130);
	mob:Shout("I will not be contained! My prison weakens, and I will claw my way back into this world, even if it dooms me!");

	-- Depop controller
	if e ~= nil then
		e.self:Depop(true);
	end
end

function reset(e, new_state)
	eq.depop_all(controller_id);
	for i,id in ipairs(serpent_triggers) do
		eq.depop_all(id);
	end
	eq.depop_all(serpent_id);
	eq.depop_all(exiled_id);
	eq.depop_all(cursed_id);

	set_state(new_state);
	check_state(e, true, new_state);
end

function check_state(e, check_start, new_state)
	local state = new_state;
	if state == -1 then
		state = get_state();
	end

	if state == -1 then
		return;
	end

	if check_start and state == STATE_START then
		eq.unique_spawn(controller_id, 0, 0, 0, 0, 0, 0);
		local entity_list = eq.get_entity_list();
		for i,id in ipairs(serpent_triggers) do
			local mob = entity_list:GetMobByNpcTypeID(id);
			if not mob.valid then
				local sp2 = serpent_triggers_s2[i];
				eq.spawn_from_spawn2(sp2);
			end
		end
	end

	if state == STATE_TRIGGERS_DEAD then
		spawn_serpent(nil);
	end

	if state == STATE_SERPENT_DEAD then
		process_death(serpent_id);
	end

	if state == STATE_EXILED_DEAD then
		process_death(exiled_id);
	end
end

function MoveToFirstNPC(client, npcids)
	local entity_list = eq.get_entity_list();
	for _,id in ipairs(npcids) do
		local npc = entity_list:GetNPCByNPCTypeID(id);
		if npc.valid then
			client:MovePCInstance(eq.get_zone_id(), eq.get_zone_instance_id(), npc:GetX(), npc:GetY(), npc:GetZ(), npc:GetHeading());
			return
		end
	end

	client:Message(MT.Red, "NPC not found");
end

function GMControl(e)
	if e.self:Admin() <= 100 then
		return
	end

	if e.message:findi("help") then
		e.self:Message(1, "---------------------  Cursed Cycle  ----------------------");
		e.self:Message(1, "Control options for Cursed cycle event: ["..eq.say_link("status_cursed", true).."] to view current state.  ["..eq.say_link("reset_cursed", true).."] to reset to beginning.  ["..eq.say_link("state1_cursed", true).."] to reset to all triggers killed and serpent spawned.  ["..eq.say_link("state2_cursed", true).."] to reset to exiled spawned. ["..eq.say_link("state3_cursed", true).."] to reset to Vyzh`dra spawned.");
		e.self:Message(1, "["..eq.say_link("goto_next_cursed_trigger", true).."] ["..eq.say_link("goto_cursed_spawn").."]");
		e.self:Message(1, "-----------------------------------------------------------");
		return;
	end

	if e.message:findi("status_cursed") then
		local state = get_state();
		if state == STATE_START then
			e.self:Message(1, "Event is at the start waiting on the initial 10 triggers to be killed.");
		elseif state == STATE_TRIGGERS_DEAD then
			e.self:Message(1, "Triggers have been killed and serpent has been spawned.");
		elseif state == STATE_SERPENT_DEAD then
			e.self:Message(1, "Serpent has been killed and exiled has been spawned.");
		elseif state == STATE_EXILED_DEAD then
			e.self:Message(1, "Exiled has been killed and Vyzh`dra the Cursed has been spawned.");
		elseif state == STATE_END then
			e.self:Message(1, "Vhyz`dra encounter has ended.");
		else
			e.self:Message(1, "Unrecognized state: "..state);
		end

		return;
	end

	if e.message:findi("reset_cursed") then
		reset(e, STATE_START);
		e.self:Message(1, "Reset to start");
		return;
	end

	if e.message:findi("state1_cursed") then
		reset(e, STATE_TRIGGERS_DEAD);
		e.self:Message(1, "Reset to serpent spawned");
		return;
	end

	if e.message:findi("state2_cursed") then
		reset(e, STATE_SERPENT_DEAD);
		e.self:Message(1, "Reset to exiled spawned");
		return;
	end

	if e.message:findi("state3_cursed") then
		reset(e, STATE_EXILED_DEAD);
		e.self:Message(1, "Reset to Vhyz`dra spawned");
		return;
	end

	if e.message:findi("goto_next_cursed_trigger") then
		MoveToFirstNPC(e.self, serpent_triggers);
	end

	if e.message:findi("goto_cursed_spawn") then
		MoveToFirstNPC(e.self, {serpent_id, exiled_id, cursed_id});
	end
end

function event_encounter_load(e)
	if not eq.is_static_instance() then
		return;
	end	

	local rule_enabled = eq.get_rule("Zone:StateSavingOnShutdown");
	if rule_enabled ~= nil and rule_enabled == "true" then
		saving_enabled = true;
	end

	eq.register_npc_event(Event.tick,           controller_id, check_serpent_triggers);
	eq.register_npc_event(Event.spawn,          controller_id, evt_zone_spawn);
	eq.register_npc_event(Event.death_complete, serpent_id,    evt_zone_death);
	eq.register_npc_event(Event.death_complete, exiled_id,     evt_zone_death);
	eq.register_npc_event(Event.death_complete, cursed_id,     evt_zone_death);

	eq.register_player_event(Event.say, GMControl);

	if not saving_enabled then
		check_state(e, false, -1);
	end
end
