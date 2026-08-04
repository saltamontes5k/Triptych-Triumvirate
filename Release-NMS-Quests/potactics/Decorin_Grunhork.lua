function event_death_complete(e)
	local trigger_npc = eq.get_entity_list():GetMobByNpcTypeID(214123) -- NPC: #rallos_trigger

	if trigger_npc then
		eq.signal(214123, 214057, 0) -- NPC: #rallos_trigger
	end
end

function event_signal(e)
	eq.depop_with_timer()
end

function event_spawn(e)
	-- Don't mess with the doors in the respawning instance.
	if eq.is_farming_instance() then
		return;
	end
	local door_ids = {16, 17}
	for _, door_id in pairs(door_ids) do
		local door = eq.get_entity_list():FindDoor(door_id)
		if door then
			door:SetLockPick(1)
		end
	end
end
