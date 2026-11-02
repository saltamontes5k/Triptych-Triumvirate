-- netherbian/a_zombie.lua
-- Derelict Space Station (netherbian v66): one of the old crew, still on
-- duty. Plain melee brute -- it shambles, it swings, that is the whole
-- resume (faction 79, aggroradius 55). Kills report to the controller
-- (signal 30) when a shrouded Master Officer lands them.

local CONTROLLER = 1520001985

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 323 then
		eq.signal(CONTROLLER, 30)
	end
end
