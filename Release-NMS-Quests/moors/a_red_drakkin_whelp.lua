-- moors/a_red_drakkin_whelp.lua
-- King of the Monsters (moors v40): the red whelp -- it snared itself at
-- the gate and crawls. Whelps never fight back; they beeline for the Plane
-- of Knowledge stone, and only the shrouded kaiju's bite counts (signal
-- 102 to the controller).

local CONTROLLER = 1520001970
local COLOR      = 2
local STONE      = { x = -1378.8, y = -612.8 }
local JITTER     = 40

function event_spawn(e)
	e.self:SetDisableMelee(true)
	e.self:CastSpell(242, e.self:GetID()) -- Snare: its own fault, really
	eq.set_timer("waddle", 3000)
end

function event_timer(e)
	if e.timer == "waddle" then
		e.self:MoveTo(STONE.x + math.random(-JITTER, JITTER), STONE.y + math.random(-JITTER, JITTER), e.self:GetZ(), 0, false)
	end
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 436 then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
