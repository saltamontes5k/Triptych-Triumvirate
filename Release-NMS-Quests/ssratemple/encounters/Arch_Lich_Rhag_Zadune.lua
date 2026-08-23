local zhezum_id = 162178;  -- Use the following to reset the event: #npctypespawn 162178
local mozdezh_id = 162192;
local lich_id = 162177;

local STATE_START = 0;
local STATE_ZHEZUM_DEAD = 1;
local STATE_MOZDEZH_DEAD = 2;
local STATE_END = 255;

local bucket_key = "ssratemple.lich";
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

	local zhezum = npcs:GetNPCByNPCTypeID(zhezum_id);
	if zhezum.valid then
		return STATE_START;
	end

	local mozdezh = npcs:GetNPCByNPCTypeID(mozdezh_id);
	if mozdezh.valid then
		return STATE_ZHEZUM_DEAD;
	end

	local lich = npcs:GetNPCByNPCTypeID(lich_id);
	if lich.valid then
		return STATE_MOZDEZH_DEAD;
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
	if npc_id == zhezum_id then
		set_state(STATE_START);

		local entities = eq.get_entity_list();
		for i,id in ipairs({mozdezh_id, lich_id}) do
			local mob = entities:GetMobByNpcTypeID(id);
			if mob.valid then
                eq.debug("depopping " .. id);
				mob:Depop();
			end
		end
	end
end

function evt_zone_death(e)
	process_death(e.self:GetNPCTypeID());
end

function process_death(npc_id)
	if npc_id == zhezum_id then
		set_state(STATE_ZHEZUM_DEAD);
		eq.unique_spawn(mozdezh_id, 0, 0, 634.3, -280.5, 147.6, 383.2);
	end

	if npc_id == mozdezh_id then
		set_state(STATE_MOZDEZH_DEAD);
		eq.unique_spawn(lich_id, 0, 0, 420, -144, 270.1, 0);
	end

	if npc_id == lich_id then
		set_state(STATE_END);
	end
end

function reset(e, new_state)
	eq.depop_all(zhezum_id);
	eq.depop_all(mozdezh_id);
	eq.depop_all(lich_id);

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
		eq.unique_spawn(zhezum_id, 0, 0, 547, -412, 9.1, 0);
	end

	if state == STATE_ZHEZUM_DEAD then
		process_death(zhezum_id);
	end

	if state == STATE_MOZDEZH_DEAD then
		process_death(mozdezh_id);
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
		e.self:Message(1, "---------------------  Rhag Cycle  ------------------------");
		e.self:Message(1, "Control options for Rhag cycle event: ["..eq.say_link("status_rhag", true).."] to view current state.  ["..eq.say_link("reset_rhag", true).."] to reset to beginning.  ["..eq.say_link("state1_rhag", true).."] to reset to mozdezh spawned.  ["..eq.say_link("state2_rhag", true).."] to reset to arch lich spawned.");
		e.self:Message(1, "["..eq.say_link("goto_active_rhag", true).."]");
		e.self:Message(1, "-----------------------------------------------------------");
		return;
	end

	if e.message:findi("status_rhag") then
		local state = get_state();
		if state == STATE_START then
			e.self:Message(1, "Zhezum is up and waiting to be killed to start event.");
		elseif state == STATE_ZHEZUM_DEAD then
			e.self:Message(1, "Zhezum has been killed and Mozdezh has spawned.");
		elseif state == STATE_MOZDEZH_DEAD then
			e.self:Message(1, "Zhezum and Mozdezh have been killed and Arch Lich Rhag Zadune has spawned.");
		elseif state == STATE_END then
			e.self:Message(1, "Arch lich has been killed and cycle is complete.");
		else
			e.self:Message(1, "Unrecognized state: "..state);
		end

		return;
	end

	if e.message:findi("reset_rhag") then
		reset(e, STATE_START);
		e.self:Message(1, "Rhag cycle reset to start");
		return;
	end

	if e.message:findi("state1_rhag") then
		reset(e, STATE_ZHEZUM_DEAD);
		e.self:Message(1, "Rhag cycle reset to Zhezum dead and Mozdezh spawned.");
		return;
	end

	if e.message:findi("state2_rhag") then
		reset(e, STATE_MOZDEZH_DEAD);
		e.self:Message(1, "Rhag cycle reset to Mozdezh dead and arch lich spawned.");
		return;
	end

	if e.message:findi("goto_active_rhag") then
		MoveToFirstNPC(e.self, {zhezum_id, mozdezh_id, lich_id});
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
	

	eq.register_npc_event(Event.spawn,          zhezum_id,  evt_zone_spawn);
	eq.register_npc_event(Event.death_complete, zhezum_id,  evt_zone_death);
	eq.register_npc_event(Event.death_complete, mozdezh_id, evt_zone_death);
	eq.register_npc_event(Event.death_complete, lich_id,    evt_zone_death);

	eq.register_player_event(Event.say, GMControl);

	if not saving_enabled then
		check_state(e, false, -1);
	end
end
