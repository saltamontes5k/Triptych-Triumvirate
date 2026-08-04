function event_death_complete(e)
	local instance_id = eq.get_zone_instance_id() or 0;
	local airplane_sirran_status = tonumber(eq.get_data("airplane-sirran-" .. instance_id)) or 0;

	if not (eq.get_entity_list():IsMobSpawnedByNpcTypeID(71013)) then -- Don't spawn Sirran if Guardian is still up
		eq.set_data("airplane-sirran-" .. instance_id, "5", tostring(eq.seconds("24h")));
		eq.spawn2(71058,0,0,955,-570,466,390); -- NPC: Sirran_the_Lunatic
	end

	eq.signal(71013, 1); -- The_Spiroc_Guardian
end

function event_killed_merit(e)
    if not e.other then
        return
    end
    
    local count = tonumber(e.other:GetEntityVariable("bird_farmer")) or 0
    count = count + 1

    if count >= 100 then
        local awarded = e.other:GetBucket("bird_farmer")
        if awarded == nil or awarded == "" then
            eq.debug("check 3: " .. tostring(awarded));
            
            eq.discord_send("ooc", "All hail " .. e.other:GetCleanName() .. ", the Sweaty Bird Farmer!")
            eq.world_emote(335, "All hail " .. e.other:GetCleanName() .. ", the Sweaty Bird Farmer!")

            e.other:SetBucket("bird_farmer", "birds aren't real")

            e.other:SetBucket("flag-semaphore", "207")
            e.other:Signal(100)

            e.other:DeleteEntityVariable("bird_farmer")
            return
        end
    end
    e.other:SetEntityVariable("bird_farmer", tostring(count or "0"))
end
