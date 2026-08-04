function event_click_door(e)
    local door_id = e.door:GetDoorID();
    local instance_id = eq.get_zone_instance_id();
    if door_id == 3 and (eq.get_entity_list():IsMobSpawnedByNpcTypeID(228119) or eq.get_entity_list():IsMobSpawnedByNpcTypeID(228120)) then -- Door In
        e.self:Message(MT.White, "You got the door open.")
        e.self:MovePCInstance(228,instance_id,-1066,-48,-284,380);
    elseif door_id == 4 and (eq.get_entity_list():IsMobSpawnedByNpcTypeID(228119) or eq.get_entity_list():IsMobSpawnedByNpcTypeID(228120)) then -- Door Out
        e.self:Message(MT.White, "You got the door open.")
        e.self:MovePCInstance(228,instance_id,-1360,-290,74,128)
    end
end
