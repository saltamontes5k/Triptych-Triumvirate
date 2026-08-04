--Tallon_Zek (223077)
--Phase 4
--potimeb

function event_death_complete(e)
	eq.signal(223097,223077); -- Add Loot Lockout
	eq.signal(223097,5); -- send a signal to the zone_status that I died

	local killer = eq.get_entity_list():GetClientByID(e.killer_id)

    if killer and killer:GetBucket("SeasonalCharacter") == '1' then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end
end