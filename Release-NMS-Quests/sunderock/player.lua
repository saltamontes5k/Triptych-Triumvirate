-- Sunderock Springs zone player script: the reconstruction's task and
-- acquisition wiring (global_player hook, placed zone-local so it cannot
-- shadow the perl global layer). The moors crossroads-sign entry lives in
-- moors/player.lua (prepare_board). rof2b 2026-11-05.
local sunderock = require('achievement_quest_sunderock')

function event_task_accepted(e)
	sunderock.resume(e)
end

function event_task_complete(e)
	sunderock.complete(e)
end

function event_task_update(e)
	sunderock.resume(e)
end

function event_task_stage_complete(e)
	sunderock.resume(e)
end

function event_enter_zone(e)
	sunderock.resume(e)
end

function event_task_fail(e)
	sunderock.resume(e)
end

function event_player_pickup(e)
	sunderock.pickup(e)
end

function event_loot(e)
	sunderock.loot(e)
end

function event_timer(e)
	if sunderock.timer(e) then return end
end
