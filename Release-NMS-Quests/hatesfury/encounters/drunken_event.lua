-- Drunken Buccaneer Event

local killed                    = 0;
local public_trigger_amount     = 26;
local private_trigger_amount    = 12;
local is_private_instance       = false;
local controller_id             = 228010; -- Attendant Mi`ta
local drunken_sp2               = {29216,29215,29214,29213,29212,29211,29209,29210,29208,29160,29161,29162}
local event_mobs                = {228002,228007,228008,228009,228026,228027,228028,228029,228030,228031,228032,228051,228085,228086,228087,228088,228093,228101};

function Controller_Spawn(e)
    local expedition = eq.get_expedition()
    killed = 0; -- Ensure Counter is Reset

    if expedition.valid and expedition:GetName() == "Hate's Fury (Non-Respawning)" then
        is_private_instance = true;
    end
end

function Controller_Signal(e)
    local drunken_mob = eq.get_entity_list():IsMobSpawnedByNpcTypeID(228111);

    if e.signal == 1 and not drunken_mob then
        killed = killed + 1;

        if is_private_instance and killed == private_trigger_amount then
            eq.unique_spawn(228111,0,0,431,1006,-607.4, 0); -- NPC: the_Drunken_Buccaneer
        elseif not is_private_instance and killed == public_trigger_amount then
            eq.unique_spawn(228111,0,0,431,1006,-607.4, 0); -- NPC: the_Drunken_Buccaneer
            killed = 0; -- Reset
        end
    end
end

function Add_Spawn(e)
    if has_value(drunken_sp2, e.self:CastToNPC():GetSp2()) then -- Verify mob spawns in the Drunked Buccaneer's Room
        e.self:SetEntityVariable("Drunken_Count", "1");
    end
end

function Add_Death(e)
    if e.self:GetEntityVariable("Drunken_Count") == "1" then
        eq.signal(controller_id,1);
    end
end

function has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end
	return false
end

function event_encounter_load(e)
	-- Controller
	eq.register_npc_event(Event.spawn,			    controller_id,	Controller_Spawn);
	eq.register_npc_event(Event.signal,			    controller_id,	Controller_Signal);

	-- Mez and Non Mezable Members
	for i = 1, #event_mobs do
		eq.register_npc_event(Event.death_complete,	event_mobs[i], 	Add_Death);
		eq.register_npc_event(Event.spawn,			event_mobs[i], 	Add_Spawn);
	end
end
