-- skyshrine/a_frosted_cake.lua
-- Midnight Snack (skyshrine v41): a frosted cake. It just sits there.
-- Round, sweet, completely unaware of what it is. One hit, one bite; the
-- controller counts every qualifying one (signal 200) and every fourth cake
-- wakes the Sugar Rage.

local CONTROLLER = 1520001978
local GHOST_RACE = 117

function event_spawn(e)
	e.self:SetDisableMelee(true)
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == GHOST_RACE then
		eq.signal(CONTROLLER, 200)
	end
end
