-- netherbian/a_fungal_fiend.lua
-- Derelict Space Station (netherbian v66): a bloom of the Mildew. It fights
-- like a ranger -- shoots its bow at range (SQL special_abilities '11,1',
-- RangedAttack) and shadowsteps (GMMove) back to any target that opens more
-- than STEP_DIST. Vanilla aggro does the rest (faction 79, aggroradius 55).
-- Kills report to the controller (signal 20) when a shrouded Master Officer
-- lands them.

local CONTROLLER = 1520001985
local STEP_DIST  = 35

function event_spawn(e)
	eq.set_timer("shadow", 5000)
end

function event_timer(e)
	if e.timer == "shadow" then
		local target = e.self:GetTarget()
		if target and target.valid then
			local dx = target:GetX() - e.self:GetX()
			local dy = target:GetY() - e.self:GetY()
			if dx * dx + dy * dy > STEP_DIST * STEP_DIST then
				e.self:GMMove(target:GetX() + math.random(-5, 5),
					target:GetY() + math.random(-5, 5),
					target:GetZ(), 0, false)
			end
		end
	end
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 323 then
		eq.signal(CONTROLLER, 20)
	end
end
