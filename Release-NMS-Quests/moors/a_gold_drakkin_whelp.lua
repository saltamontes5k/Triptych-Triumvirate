-- moors/a_gold_drakkin_whelp.lua
-- King of the Monsters (moors v40): the gold whelp -- Veeshan's favorite.
-- The first bite never lands: the whelp cheats death once (event_death
-- aborts the kill, the engine parks it at zero, and a tick later it is
-- back on its feet praising Veeshan). The second bite counts like any
-- other (signal 105 to the controller).

local CONTROLLER = 1520001970
local COLOR      = 5
local STONE      = { x = -1378.8, y = -612.8 }
local JITTER     = 40

local cheated_death = false

function event_spawn(e)
	e.self:SetDisableMelee(true)
	eq.set_timer("waddle", 3000)
end

function event_timer(e)
	if e.timer == "waddle" then
		e.self:MoveTo(STONE.x + math.random(-JITTER, JITTER), STONE.y + math.random(-JITTER, JITTER), e.self:GetZ(), 0, false)
	elseif e.timer == "unfurl" then
		e.self:SetHP(e.self:GetMaxHP())
	end
end

function event_death(e)
	if not cheated_death then
		cheated_death = true
		e.self:Say("Praise Veeshan! I live again! We live again! ALL of us live again!")
		eq.set_timer("unfurl", 100)
		return 1 -- non-zero aborts the death (attack.cpp parks the body at 0)
	end
	return 0
end

function event_death_complete(e)
	local killer = eq.get_entity_list():GetClientByID(e.killer_id)
	if killer and killer:GetRace() == 436 then
		eq.signal(CONTROLLER, 100 + COLOR)
	end
end
