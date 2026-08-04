--#Cazic_Thule (223166)
--Phase 5 God
--potimeb

function event_death_complete(e)
	-- send a signal to the zone_status that I died
	eq.signal(223097,223166); -- Add Lockout
	eq.signal(223097,6);

	local killer = eq.get_entity_list():GetClientByID(e.killer_id)

    if killer and killer:GetBucket("SeasonalCharacter") == '1' then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end
end