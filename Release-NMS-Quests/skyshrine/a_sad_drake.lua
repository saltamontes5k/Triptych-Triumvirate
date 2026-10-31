-- skyshrine/a_sad_drake.lua
-- Midnight Snack (skyshrine v41): the Sad One -- the blue drake. It is
-- sorry about the whole arrangement, and it still hunts you. The controller
-- owns its invulnerability and its hate; only the shrouded ghost's bite
-- counts (signal 101 to the controller).

local CONTROLLER = 1520001978
local GHOST_RACE = 117
local COLOR      = 1

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == GHOST_RACE then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
