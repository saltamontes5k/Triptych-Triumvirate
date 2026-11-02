-- skyshrine/a_bad_drixie.lua
-- Midnight Snack (skyshrine v41): the Bad One -- the drixie. Small, fast,
-- and bad in the way small fast things are. The controller owns its
-- invulnerability and its hate; only the shrouded ghost's bite counts
-- (signal 104 to the controller).

local CONTROLLER = 1520001978
local GHOST_RACE = 117
local COLOR      = 4

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == GHOST_RACE then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
