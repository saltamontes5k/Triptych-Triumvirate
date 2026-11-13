-- Roost (Blackfeather Roost) zone player script: the reconstruction's
-- achievement-route task wiring (global-player-roost fragment, placed
-- zone-local so it cannot shadow the perl global layer). rof2b 2026-11-05.
local roost = require('achievement_quest_roost')

function event_task_accepted(e)
	roost.accepted(e)
end

function event_task_complete(e)
	roost.complete(e)
end

function event_task_stage_complete(e)
	roost.resume(e)
end

function event_enter_zone(e)
	roost.resume(e)
end

function event_task_fail(e)
	roost.resume(e)
end

function event_timer(e)
	if roost.timer(e) then return end
end

function event_click_door(e)
	local result = roost.click_door(e)
	if result and result ~= 0 then return result end
	return 0
end

function event_task_before_update(e)
	local result = roost.before_update(e)
	if result and result ~= 0 then return result end
	return 0
end
