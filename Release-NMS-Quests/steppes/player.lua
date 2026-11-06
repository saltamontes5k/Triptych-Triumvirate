-- Steppes zone player script: the reconstruction's task/scene route wiring
-- (global_player hook, placed zone-local so it cannot shadow the perl global
-- layer). rof2b 2026-11-05.
local steppes = require('achievement_quest_steppes')

function event_task_accepted(e)
	steppes.accepted(e)
end

function event_task_complete(e)
	steppes.complete(e)
end

function event_task_update(e)
	steppes.update(e)
end

function event_task_stage_complete(e)
	steppes.stage(e)
end

function event_enter_zone(e)
	steppes.resume(e)
end

function event_task_fail(e)
	steppes.task_fail(e)
end

function event_cast(e)
	steppes.cast(e)
end

function event_click_door(e)
	steppes.click_door(e)
end

function event_timer(e)
	if steppes.timer(e) then return end
end

function event_task_before_update(e)
	steppes.before_update(e)
end
