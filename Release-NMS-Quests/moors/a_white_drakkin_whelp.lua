-- moors/a_white_drakkin_whelp.lua
-- King of the Monsters (moors v40): the white whelp -- labeled Drunk. It
-- phases in and out (set invisibility, no spell) so the kaiju has to time
-- the bite. Whelps never fight back; they beeline for the Plane of
-- Knowledge stone, and only the shrouded kaiju's bite counts (signal 104
-- to the controller).

local CONTROLLER = 1520001970
local COLOR      = 4
local STONE      = { x = -1378.8, y = -612.8 }
local JITTER     = 40
local PHASE_MS   = 4000

local phased = false

function event_spawn(e)
	e.self:SetDisableMelee(true)
	eq.set_timer("waddle", 3000)
	eq.set_timer("phase", PHASE_MS)
end

function event_timer(e)
	if e.timer == "waddle" then
		e.self:MoveTo(STONE.x + math.random(-JITTER, JITTER), STONE.y + math.random(-JITTER, JITTER), e.self:GetZ(), 0, false)
	elseif e.timer == "phase" then
		phased = not phased
		e.self:SetInvisible(phased and 1 or 0)
	end
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 436 then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
