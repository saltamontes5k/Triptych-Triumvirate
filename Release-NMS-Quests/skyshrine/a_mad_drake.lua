-- skyshrine/a_mad_drake.lua
-- Midnight Snack (skyshrine v41): the Mad One -- the red drake. Angriest of
-- the colored ones. The controller owns its invulnerability and its hate;
-- only the shrouded ghost's bite counts (signal 102 to the controller).

local CONTROLLER = 1520001978
local GHOST_RACE = 117
local COLOR      = 2

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == GHOST_RACE then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
