--#Innoruuk (223167)
--Phase 5 God
--potimeb

local EVENT_MOBS     = {223231,223232}
local DISTANCE_CHECK = 1000 * 1000

function event_spawn(e)
	eq.set_next_hp_event(75)
end

function event_hp(e)
	if e.hp_event == 75 then
		SpawnAdds(e,3,4)
		eq.set_next_hp_event(20)
	elseif e.hp_event == 20 then
		SpawnAdds(e,4,5)
	end
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("reset")
		eq.set_timer("aggro_link", 3 * 1000)
	else
		eq.set_timer("reset", 5 * 60 * 1000)
		eq.stop_timer("aggro_link")
	end
end

function event_timer(e)
	eq.stop_timer(e.timer)
	if e.timer == "reset" then
		eq.set_next_hp_event(75)
		for k,v in pairs(EVENT_MOBS) do
			eq.depop_all(v)
		end
	elseif e.timer == "aggro_link" then
		eq.set_timer("aggro_link", 3 * 1000)

		local npc_list =  eq.get_entity_list():GetNPCList();
		for npc in npc_list.entries do
			if npc.valid and not npc:IsEngaged() and (npc:GetNPCTypeID() == EVENT_MOBS[1] or npc:GetNPCTypeID() == EVENT_MOBS[2]) then
				npc:AddToHateList(e.self:GetHateRandom(),1)
			end
		end
	end
end

function SpawnAdds(e,min_adds,max_adds)	-- spawns 4 adds (2 sets of same type)	
	local SPAWN_COUNT = math.random(min_adds,max_adds)
	local ENTITY_LIST = eq.get_entity_list()

	eq.spawn2(EVENT_MOBS[1],0,0,210,315,5,257):AddToHateList(ENTITY_LIST:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), DISTANCE_CHECK)) -- NPC: Guardian of the dark prince
	eq.spawn2(EVENT_MOBS[2],0,0,300,215,5,387):AddToHateList(ENTITY_LIST:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), DISTANCE_CHECK))	-- NPC: Hatebringer of Innoruuk

	if SPAWN_COUNT >= 3 then
		eq.spawn2(EVENT_MOBS[1],0,0,280,330,15,324):AddToHateList(ENTITY_LIST:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), DISTANCE_CHECK))
	end

	if SPAWN_COUNT >= 4 then
		eq.spawn2(EVENT_MOBS[2],0,0,325,280,15,324):AddToHateList(ENTITY_LIST:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), DISTANCE_CHECK))
	end

	if SPAWN_COUNT == 5 then
		eq.spawn2(eq.ChooseRandom(EVENT_MOBS[1],EVENT_MOBS[2]),0,0,255,255,5,324):AddToHateList(ENTITY_LIST:GetRandomClient(e.self:GetX(), e.self:GetY(), e.self:GetZ(), DISTANCE_CHECK))
	end
end

function event_death_complete(e)
	-- send a signal to the zone_status that I died
	eq.signal(223097,223167) -- Add Lockout
	eq.signal(223097,6)

	local killer = eq.get_entity_list():GetClientByID(e.killer_id)

    if killer and killer:GetBucket("SeasonalCharacter") == '1' then
        killer:CastToClient():SetBucket('flag-semaphore', '204')
        killer:Signal(100)
    end
end
